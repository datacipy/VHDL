----------------------------------------------------------
--  trs_vid.vhd
--		trs80 video
--		===========
--
--  04/14/02	Daniel Wallner	Creation
----------------------------------------------------------

-- Eur = 1, 10.4832MHz Tick for 50Hz video
-- Eur = 0, 10.64448MHz Tick for 60Hz video

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity trs_vid is
	port(
		Rst_n	: in std_logic;
		Clk		: in std_logic;
		Tick	: in std_logic;
		Eur		: in std_logic;
		CS_n	: in std_logic;
		Wr_n	: in std_logic;
		Addr	: in std_logic_vector(9 downto 0);
		DI		: in std_logic_vector(7 downto 0);
		DO		: out std_logic_vector(7 downto 0);
		Sync	: out std_logic;
		Video	: out std_logic);
end trs_vid;

architecture rtl of trs_vid is

	component SSRAM
	generic(
		AddrWidth	: integer := 16;
		DataWidth	: integer := 8
	);
	port(
		Clk			: in std_logic;
		CE_n		: in std_logic;
		WE_n		: in std_logic;
		A			: in std_logic_vector(AddrWidth - 1 downto 0);
		DIn			: in std_logic_vector(DataWidth - 1 downto 0);
		DOut		: out std_logic_vector(DataWidth - 1 downto 0)
	);
	end component;

	component trs_char
	port(
		A	: in std_logic_vector(10 downto 0);
		D	: out std_logic_vector(7 downto 0)
	);
	end component;

	signal ChrC_Cnt	: unsigned(2 downto 0);	-- Character column counter
	signal Hor_Cnt	: unsigned(6 downto 0);	-- Horizontal counter
	signal ChrR_Cnt	: unsigned(3 downto 0);	-- Character row counter
	signal Ver_Cnt	: unsigned(4 downto 0);	-- Vertical counter
	signal RAM_Addr	: std_logic_vector(9 downto 0);
	signal Chr		: std_logic_vector(7 downto 0);
	signal Chr_Addr	: std_logic_vector(10 downto 0);
	signal Chr_Data	: std_logic_vector(7 downto 0);
	signal Blank	: std_logic;
	signal Shift	: std_logic_vector(5 downto 0);
	signal HSync	: std_logic;
	signal VSync	: std_logic;

begin

	-- Timing/Counters
	process (Rst_n, Clk)
	begin
		if Rst_n = '0' then
			ChrC_Cnt <= (others => '0');
			Hor_Cnt <= (others => '0');
			ChrR_Cnt <= (others => '0');
			Ver_Cnt <= (others => '0');
		elsif Clk'event and Clk = '1' then
			if Tick = '1' then
				if ChrC_Cnt = 5 then
					ChrC_Cnt <= (others => '0');
					if Hor_Cnt = 111 then
						Hor_Cnt <= (others => '0');
						if ChrR_Cnt = 11 then
							ChrR_Cnt <= (others => '0');
							if (Eur = '0' and Ver_Cnt = 21) or
							   (Eur = '1' and Ver_Cnt = 25) then
								Ver_Cnt <= (others => '0');
							else
								Ver_Cnt <= Ver_Cnt + 1;
							end if;
						else
							ChrR_Cnt <= ChrR_Cnt + 1;
						end if;
					else
						Hor_Cnt <= Hor_Cnt + 1;
					end if;
				else
					ChrC_Cnt <= ChrC_Cnt + 1;
				end if;
			end if;
		end if;
	end process;

	RAM_Addr <= Addr when CS_n = '0' else
		std_logic_vector(Ver_Cnt(3 downto 0) & Hor_Cnt(5 downto 0));

	-- Video RAM
	z17_18 : SSRAM
		generic map(
			AddrWidth => 10)
		port map(
			Clk => Clk,
			CE_n => CS_n,
			WE_n => Wr_n,
			A => RAM_Addr,
			DIn => DI,
			DOut => Chr);

	DO <= Chr;

	-- Character ROM
	Chr_Addr <= Chr(6 downto 0) & std_logic_Vector(ChrR_Cnt);
	z25 : trs_char
		port map(
			A =>  Chr_Addr,
			D => Chr_Data);

	-- Video shift register
	process (Rst_n, Clk)
	begin
		if Rst_n = '0' then
			Shift <= (others => '0');
			Video <= '0';
			Blank <= '0';
		elsif Clk'event and Clk = '1' then
			if Tick = '1' then
				Blank <= not CS_n;
				if ChrC_Cnt = 1 then
					if Hor_Cnt(6) = '0' and Ver_Cnt(4) = '0' and Blank = '0' then
						if Chr(7) = '1' then
							if ChrR_Cnt < 4 then
								Shift(5 downto 3) <= (others => Chr(0));
								Shift(2 downto 0) <= (others => Chr(1));
							elsif ChrR_Cnt < 8 then
								Shift(5 downto 3) <= (others => Chr(2));
								Shift(2 downto 0) <= (others => Chr(3));
							else
								Shift(5 downto 3) <= (others => Chr(4));
								Shift(2 downto 0) <= (others => Chr(5));
							end if;
						else
							Shift(4 downto 0) <= Chr_Data(7 downto 3);
							Shift(5) <= '0';
						end if;
					else
						Shift <= (others => '0');
					end if;
				else
					Shift(5 downto 1) <= Shift(4 downto 0);
					Shift(0) <= '0';
				end if;
				Video <= Shift(5);
			end if;
		end if;
	end process;

	-- Sync
	process (Rst_n, Clk)
	begin
		if Rst_n = '0' then
			HSync <= '0';
			VSync <= '0';
			Sync <= '0';
		elsif Clk'event and Clk = '1' then
			if Tick = '1' then
				-- Hor_Cnt is 1774080/1747200Hz
				if Hor_Cnt = 64 + 7 * 3 then
					HSync <= '1';
				end if;
				if Hor_Cnt = 64 + 7 * 4 then
					HSync <= '0';
				end if;
				-- ChrR_Cnt is 15840/15600Hz
				-- Ver_Cnt is 1320/1300Hz
				if (Eur = '0' and Ver_Cnt = 18) or
				   (Eur = '1' and Ver_Cnt = 20) then
					if ChrR_Cnt = 0 then
						VSync <= '1';
					end if;
					if ChrR_Cnt = 7 then
						VSync <= '0';
					end if;
				end if;
				Sync <= HSync xor VSync;
			end if;
		end if;
	end process;

end;
