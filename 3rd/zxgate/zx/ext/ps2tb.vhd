library IEEE, work;
use IEEE.std_logic_1164.all;
use work.all;

entity PS2TB is
end PS2TB;

architecture behaviour of PS2TB is

	procedure PS2Byte(Byte : in std_logic_vector(7 downto 0);
					signal Clk : out std_logic;
					signal Data : out std_logic) is
	begin
		for i in 0 to 10 loop
			if i = 0 then
				Data <= '0';
			elsif i = 9 then
				Data <= not Byte(0) xor
							Byte(1) xor
							Byte(2) xor
							Byte(3) xor
							Byte(4) xor
							Byte(5) xor
							Byte(6) xor
							Byte(7);
			elsif i = 10 then
				Data <= '1';
			else
				Data <= Byte(i - 1);
			end if;
			wait for 20 us;
			Clk <= '0';
			wait for 20 us;
			Clk <= '1';
		end loop;
	end;

	signal	Clk			: std_logic := '0';
	signal	Reset_n		: std_logic := '0';
	signal	Tick1us		: std_logic := '1';
	signal	PS2_Clk		: std_logic := '1';
	signal	PS2_Data	: std_logic := '1';
	signal	Key_Addr	: std_logic_vector(7 downto 0) := "00000000";
	signal	Key_Data	: std_logic_vector(4 downto 0);

begin

	Clk <= not Clk after 500 ns;
	Reset_n <= '1' after 200 ns;

	u0 : entity PS2_MatrixEncoder(rtl)
		port map(Clk, Reset_n, Tick1us, PS2_Clk, PS2_Data, Key_Addr, Key_Data);

	-- Generate AT keyboard signals
	process
	begin
		PS2Byte(x"5a", PS2_Clk, PS2_Data);
		wait for 100 us;
		PS2Byte(x"f0", PS2_Clk, PS2_Data);
		PS2Byte(x"5a", PS2_Clk, PS2_Data);
		wait;
	end process;

end;
