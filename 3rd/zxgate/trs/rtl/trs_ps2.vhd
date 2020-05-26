----------------------------------------------------------
--  trs_ps2.vhd
--		trs80 PS/2 keyboard interface
--		=============================
--
--  04/14/02	Daniel Wallner	Creation
----------------------------------------------------------

-- PS/2 keyboard scancodes can be found at
-- http://www.beyondlogic.org/keyboard/keybrd.htm

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity trs_ps2 is
	port(
		Clk			: in std_logic;
		Rst_n		: in std_logic;
		Tick1us		: in std_logic;
		PS2_Clk		: in std_logic;
		PS2_Data	: in std_logic;
		Key_Addr	: in std_logic_vector(7 downto 0);
		Key_Data	: out std_logic_vector(7 downto 0)
	);
end trs_ps2;

architecture rtl of trs_ps2 is

	signal	PS2_Sample		: std_logic;
	signal	PS2_Data_s		: std_logic;

	signal	RX_Bit_Cnt		: unsigned(3 downto 0);
	signal	RX_Byte			: unsigned(2 downto 0);
	signal	RX_ShiftReg		: std_logic_vector(7 downto 0);
	signal	RX_Release		: std_logic;
	signal	RX_Received		: std_logic;

	signal	LookUp			: std_logic_vector(6 downto 0);
	signal	BitMask			: std_logic_vector(7 downto 0);

	signal	Matrix_Set		: std_logic;
	signal	Matrix_Clear	: std_logic;
	signal	Matrix_Wr_Addr	: unsigned(6 downto 0);

	type Matrix_Image is array (natural range <>) of std_logic_vector(7 downto 0);
	signal	Matrix			: Matrix_Image(0 to 7);

begin

	process (Clk, Rst_n)
		variable PS2_Data_r		: std_logic_vector(1 downto 0);
		variable PS2_Clk_r		: std_logic_vector(1 downto 0);
		variable PS2_Clk_State	: std_logic;
	begin
		if Rst_n = '0' then
			PS2_Sample <= '0';
			PS2_Data_s <= '0';
			PS2_Data_r := "11";
			PS2_Clk_r := "11";
			PS2_Clk_State := '1';
		elsif Clk'event and Clk = '1' then
			if Tick1us = '1' then
				PS2_Sample <= '0';

				-- Deglitch
				if PS2_Data_r = "00" then
					PS2_Data_s <= '0';
				end if;
				if PS2_Data_r = "11" then
					PS2_Data_s <= '1';
				end if;
				if PS2_Clk_r = "00" then
					if PS2_Clk_State = '1' then
						PS2_Sample <= '1';
					end if;
					PS2_Clk_State := '0';
				end if;
				if PS2_Clk_r = "11" then
					PS2_Clk_State := '1';
				end if;

				-- Double synchronise
				PS2_Data_r(1) := PS2_Data_r(0);
				PS2_Clk_r(1) := PS2_Clk_r(0);
				PS2_Data_r(0) := PS2_Data;
				PS2_Clk_r(0) := PS2_Clk;
			end if;
		end if;
	end process;

	process (Clk, Rst_n)
		variable Cnt : integer;
	begin
		if Rst_n = '0' then
			RX_Bit_Cnt <= (others => '0');
			RX_ShiftReg <= (others => '0');
			RX_Received <= '0';
			Cnt := 0;
		elsif Clk'event and Clk = '1' then
			RX_Received <= '0';
			if Tick1us = '1' then

				if PS2_Sample = '1' then
					if RX_Bit_Cnt = "0000" then
						if PS2_Data_s = '0' then -- Start bit
							RX_Bit_Cnt <= RX_Bit_Cnt + 1;
						end if;
					elsif RX_Bit_Cnt = "1001" then -- Parity bit
						RX_Bit_Cnt <= RX_Bit_Cnt + 1;
						-- Ignoring parity
					elsif RX_Bit_Cnt = "1010" then -- Stop bit
						if PS2_Data_s = '1' then
							RX_Received <= '1';
						end if;
						RX_Bit_Cnt <= "0000";
					else
						RX_Bit_Cnt <= RX_Bit_Cnt + 1;
						RX_ShiftReg(6 downto 0) <= RX_ShiftReg(7 downto 1);
						RX_ShiftReg(7) <= PS2_Data_s;
					end if;
				end if;

				-- TimeOut
				if PS2_Sample = '1' then
					Cnt := 0;
				elsif Cnt = 127 then
					RX_Bit_Cnt <= "0000";
					Cnt := 0;
				else
					Cnt := Cnt + 1;
				end if;
			end if;
		end if;
	end process;

	process (Clk, Rst_n)
	begin
		if Rst_n = '0' then
			RX_Byte <= (others => '0');
			RX_Release <= '0';
			Matrix_Set <= '0';
			Matrix_Clear <= '0';
			Matrix_Wr_Addr <= (others => '0');
		elsif Clk'event and Clk = '1' then
			Matrix_Set <= '0';
			Matrix_Clear <= '0';

			if RX_Received = '1' then
				RX_Byte <= RX_Byte + 1;
				if RX_ShiftReg = x"F0" then
					RX_Release <= '1';
				elsif RX_ShiftReg = x"E0" then
				else
					RX_Release <= '0';
					-- Normal key press
					if unsigned(LookUp) /= 0 and RX_Release = '0' then
						Matrix_Wr_Addr <= unsigned(LookUp);
						Matrix_Set <= '1';
					end if;
					-- Normal key release
					if unsigned(LookUp) /= 0 and RX_Release = '1' then
						Matrix_Wr_Addr <= unsigned(LookUp);
						Matrix_Clear <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;

	-- trs80 keymap:
	-- @, a, b, c, d, e, f, g
	-- h, i, j, k, l, m, n, o
	-- p, q, r, s, t, u, v, w
	-- x, y, z,  , F2, F3, F4, F1
	-- 0, 1, 2, 3, 4, 5, 6, 7
	-- 8, 9, :, ;, ,, _, ., /
	-- return, clear, break, up, down, left, right, space
	-- shift

	process (RX_ShiftReg)
	begin
		case RX_ShiftReg is
		when x"0e" => LookUp <= "1000000"; -- @ ?
		when x"1c" => LookUp <= "1000001"; -- a
		when x"32" => LookUp <= "1000010"; -- b
		when x"21" => LookUp <= "1000011"; -- c
		when x"23" => LookUp <= "1000100"; -- d
		when x"24" => LookUp <= "1000101"; -- e
		when x"2b" => LookUp <= "1000110"; -- f
		when x"34" => LookUp <= "1000111"; -- g
		when x"33" => LookUp <= "1001000"; -- h
		when x"43" => LookUp <= "1001001"; -- i
		when x"3b" => LookUp <= "1001010"; -- j
		when x"42" => LookUp <= "1001011"; -- k
		when x"4b" => LookUp <= "1001100"; -- l
		when x"3a" => LookUp <= "1001101"; -- m
		when x"31" => LookUp <= "1001110"; -- n
		when x"44" => LookUp <= "1001111"; -- o
		when x"4d" => LookUp <= "1010000"; -- p
		when x"15" => LookUp <= "1010001"; -- q
		when x"2d" => LookUp <= "1010010"; -- r
		when x"1b" => LookUp <= "1010011"; -- s
		when x"2c" => LookUp <= "1010100"; -- t
		when x"3c" => LookUp <= "1010101"; -- u
		when x"2a" => LookUp <= "1010110"; -- v
		when x"1d" => LookUp <= "1010111"; -- w
		when x"22" => LookUp <= "1011000"; -- x
		when x"35" => LookUp <= "1011001"; -- y
		when x"1a" => LookUp <= "1011010"; -- z
--		when x"06" => LookUp <= "1011100"; -- F2 ?
--		when x"04" => LookUp <= "1011101"; -- F3 ?
--		when x"0c" => LookUp <= "1011110"; -- F4 ?
--		when x"05" => LookUp <= "1011111"; -- F1 ?
		when x"45" => LookUp <= "1100000"; -- 0
--		when x"70" => LookUp <= "1100000"; -- 0
		when x"16" => LookUp <= "1100001"; -- 1
--		when x"69" => LookUp <= "1100001"; -- 1
		when x"1e" => LookUp <= "1100010"; -- 2
--		when x"72" => LookUp <= "1100010"; -- 2
		when x"26" => LookUp <= "1100011"; -- 3
--		when x"7a" => LookUp <= "1100011"; -- 3
		when x"25" => LookUp <= "1100100"; -- 4
--		when x"6b" => LookUp <= "1100100"; -- 4
		when x"2e" => LookUp <= "1100101"; -- 5
--		when x"73" => LookUp <= "1100101"; -- 5
		when x"36" => LookUp <= "1100110"; -- 6
--		when x"74" => LookUp <= "1100110"; -- 6
		when x"3d" => LookUp <= "1100111"; -- 7
--		when x"6c" => LookUp <= "1100111"; -- 7
		when x"3e" => LookUp <= "1101000"; -- 8
--		when x"75" => LookUp <= "1101000"; -- 8
		when x"46" => LookUp <= "1101001"; -- 9
--		when x"7d" => LookUp <= "1101001"; -- 9
		when x"4c" => LookUp <= "1101010"; -- : ?
		when x"52" => LookUp <= "1101011"; -- ; ?
		when x"41" => LookUp <= "1101100"; -- ,
		when x"4e" => LookUp <= "1101101"; -- _ ?
		when x"49" => LookUp <= "1101110"; -- .
		when x"4a" => LookUp <= "1101111"; -- /
		when x"5a" => LookUp <= "1110000"; -- return
		when x"66" => LookUp <= "1110001"; -- clear ?
		when x"e1" => LookUp <= "1110010"; -- break ?
		when x"75" => LookUp <= "1110011"; -- Up
		when x"72" => LookUp <= "1110100"; -- Down
		when x"6b" => LookUp <= "1110101"; -- Left
		when x"74" => LookUp <= "1110110"; -- Right
		when x"29" => LookUp <= "1110111"; -- Space
		when x"12" => LookUp <= "1111000"; -- shift
		when x"59" => LookUp <= "1111000"; -- shift
		when others => LookUp <= "0000000";
		end case;
	end process;

	with LookUp(2 downto 0) select BitMask <= "00000001" when "000",
									"00000010" when "001",
									"00000100" when "010",
									"00001000" when "011",
									"00010000" when "100",
									"00100000" when "101",
									"01000000" when "110",
									"10000000" when others;

	process (Clk, Rst_n)
	begin
		if Rst_n = '0' then
			Matrix <= (others => (others => '0'));
		elsif Clk'event and Clk = '1' then
			if RX_ShiftReg = x"aa" and RX_Received = '1' then
				Matrix <= (others => (others => '0'));
			end if;
			if Matrix_Set = '1' then
				Matrix(to_integer(Matrix_Wr_Addr(5 downto 3))) <=
					Matrix(to_integer(Matrix_Wr_Addr(5 downto 3))) or
					std_logic_vector(BitMask);
			end if;
			if Matrix_Clear = '1' then
				Matrix(to_integer(Matrix_Wr_Addr(5 downto 3))) <=
					Matrix(to_integer(Matrix_Wr_Addr(5 downto 3))) and
					std_logic_vector(not BitMask);
			end if;
		end if;
	end process;

	g_out1 : for i in 0 to 7 generate
		Key_Data(i) <= (Matrix(0)(i) and Key_Addr(0)) or
					(Matrix(1)(i) and Key_Addr(1)) or
					(Matrix(2)(i) and Key_Addr(2)) or
					(Matrix(3)(i) and Key_Addr(3)) or
					(Matrix(4)(i) and Key_Addr(4)) or
					(Matrix(5)(i) and Key_Addr(5)) or
					(Matrix(6)(i) and Key_Addr(6)) or
					(Matrix(7)(i) and Key_Addr(7));
	end generate;

end;
