----------------------------------------------------------
--  ace_vid.vhd
--		Jupiter ACE video
--		=================
--
--  04/14/02	Daniel Wallner	Creation
--  09/16/02	Daniel Wallner	Mayor overhaul
----------------------------------------------------------

-- 6.5MHz Tick for 50Hz video

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ace_vid is
	port(
		Rst_n	: in std_logic;
		Clk		: in std_logic;
		CSV_n	: in std_logic;
		CSC_n	: in std_logic;
		VidCS_n	: in std_logic;
		Wr_n	: in std_logic;
		Addr	: in std_logic_vector(9 downto 0);
		DI		: in std_logic_vector(7 downto 0);
		DO		: out std_logic_vector(7 downto 0);
		VidEn	: out std_logic;
		Cnt0	: out std_logic;
		Int_n	: out std_logic;
		Sync	: out std_logic;
		Video	: out std_logic);
end ace_vid;

architecture rtl of ace_vid is

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

	signal ChrC_Cnt	: unsigned(2 downto 0);	-- Character column counter
	signal Hor_Cnt	: unsigned(5 downto 0);	-- Horizontal counter
	signal ChrR_Cnt	: unsigned(2 downto 0);	-- Character row counter
	signal Ver_Cnt	: unsigned(5 downto 0);	-- Vertical counter
	signal RAM_Addr	: std_logic_vector(9 downto 0);
	signal Chr		: std_logic_vector(7 downto 0);
	signal Chr_Addr	: std_logic_vector(9 downto 0);
	signal Chr_Data	: std_logic_vector(7 downto 0);
	signal Blank_n	: std_logic;
	signal Invert	: std_logic;
	signal Shift	: std_logic_vector(7 downto 0);
	signal HSync	: std_logic;
	signal VSync	: std_logic;
	signal Tick		: std_logic;

begin

	Tick <= '1';
	Cnt0 <= ChrC_Cnt(0);
	VidEn <= Blank_n;

	-- Counters
	process (Rst_n, Clk)
	begin
		if Rst_n = '0' then
			ChrC_Cnt <= (others => '0');
			Hor_Cnt <= (others => '0');
			ChrR_Cnt <= (others => '0');
			Ver_Cnt <= (others => '0');
		elsif Clk'event and Clk = '1' then
			if Tick = '1' then
				if ChrC_Cnt = 7 then
					if Hor_Cnt = 51 then
						Hor_Cnt <= (others => '0');
						if ChrR_Cnt = 7 then
							if Ver_Cnt = 38 then
								Ver_Cnt <= (others => '0');
							else
								Ver_Cnt <= Ver_Cnt + 1;
							end if;
						end if;
						ChrR_Cnt <= ChrR_Cnt + 1;
					else
						Hor_Cnt <= Hor_Cnt + 1;
					end if;
				end if;
				ChrC_Cnt <= ChrC_Cnt + 1;
			end if;
		end if;
	end process;

	RAM_Addr <= Addr when VidCS_n = '0' else
		std_logic_vector(Ver_Cnt(4 downto 0) & Hor_Cnt(4 downto 0));

	-- Video RAM
	u0 : SSRAM
		generic map(
			AddrWidth => 10)
		port map(
			Clk => Clk,
			CE_n => CSV_n,
			WE_n => Wr_n,
			A => RAM_Addr,
			DIn => DI,
			DOut => Chr);

	Chr_Addr <= Addr when CSV_n = '1' else
		Chr(6 downto 0) & std_logic_Vector(ChrR_Cnt);

	-- Character RAM
	u1 : SSRAM
		generic map(
			AddrWidth => 10)
		port map(
			Clk => Clk,
			CE_n => CSC_n,
			WE_n => Wr_n,
			A => Chr_Addr,
			DIn => DI,
			DOut => Chr_Data);

	DO <= Chr when CSV_n = '0' else Chr_Data;

	Blank_n <= (Hor_Cnt(5) nor Ver_Cnt(5)) and (Ver_Cnt(4) nand Ver_Cnt(3));

	-- Video shift register
	process (Rst_n, Clk)
	begin
		if Rst_n = '0' then
			Shift <= (others => '0');
			Video <= '0';
			Invert <= '0';
		elsif Clk'event and Clk = '1' then
			if Tick = '1' then
				if ChrC_Cnt = 7 and Blank_n = '1' then
					Shift(7 downto 0) <= Chr_Data(7 downto 0);
				else
					Shift(7 downto 1) <= Shift(6 downto 0);
					Shift(0) <= '0';
				end if;
				if ChrC_Cnt = 7 then
					Invert <= Chr(7) and Blank_n;
				end if;
				Video <= Shift(7) xor Invert;
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
				if Hor_Cnt(5) = '1' and Hor_Cnt(3) = '1' and (Hor_Cnt(4) = '1' nor Hor_Cnt(2) = '1') then
					HSync <= '1';
				else
					HSync <= '0';
				end if;
				if Ver_Cnt(4 downto 0) = "11111" then
					VSync <= '1';
				else
					VSync <= '0';
				end if;
				Sync <= HSync or VSync;
			end if;
		end if;
	end process;

	Int_n <= not VSync;

end;
