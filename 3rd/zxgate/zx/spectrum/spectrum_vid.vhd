----------------------------------------------------------
--  spectrum_vid.vhd
--		ZX Spectrum video
--		=================
--
--  10/01/02	Daniel Wallner	Creation
--  10/20/02	Daniel Wallner	Fixed blanking
----------------------------------------------------------

-- 7MHz Tick for spectrum 48k

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity spectrum_vid is
	generic(
		Is128k	: boolean := false);
	port(
		Rst_n		: in std_logic;
		Clk			: in std_logic;
		Tick		: in std_logic;
		VidCS_n		: in std_logic;
		Wr_n		: in std_logic;
		A			: in std_logic_vector(13 downto 0);
		D			: in std_logic_vector(7 downto 0);
		Border		: in std_logic_vector(2 downto 0);
		CPUEN		: out std_logic;
		HSync		: out std_logic;
		VSync		: out std_logic;
		Bright		: out std_logic;
		R			: out std_logic;
		G			: out std_logic;
		B			: out std_logic);
end spectrum_vid;

architecture rtl of spectrum_vid is

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

	signal ChrC_Cnt		: unsigned(2 downto 0);	-- Character column counter
	signal Hor_Cnt		: unsigned(5 downto 0);	-- Horizontal counter
	signal ChrR_Cnt		: unsigned(2 downto 0);	-- Character row counter
	signal Ver_Cnt		: unsigned(5 downto 0);	-- Vertical counter
	signal Invert		: unsigned(3 downto 0);
	signal VRAM_Addr	: std_logic_vector(12 downto 0);
	signal ARAM_Addr	: std_logic_vector(9 downto 0);
	signal VData		: std_logic_vector(7 downto 0);
	signal VData0		: std_logic_vector(7 downto 0);
	signal VData1		: std_logic_vector(7 downto 0);
	signal Attr			: std_logic_vector(7 downto 0);
	signal Attr_r		: std_logic_vector(7 downto 0);
	signal Blank_n		: std_logic;
	signal Wr_n_r		: std_logic;
	signal Wr_n_i		: std_logic;
	signal Shift		: std_logic_vector(7 downto 0);
	signal CSV0_n		: std_logic;
	signal CSV1_n		: std_logic;
	signal CSA_n		: std_logic;
	signal VideoRd		: std_logic;

begin

	CPUEN <= ChrC_Cnt(0) and Tick and (not VidCS_n nand VideoRd);
	Wr_n_i <= Wr_n or Wr_n_r;
	VideoRd <= ChrC_Cnt(2) and Blank_n;

	-- Counters
	process (Rst_n, Clk)
	begin
		if Rst_n = '0' then
			ChrC_Cnt <= (others => '0');
			Hor_Cnt <= (others => '0');
			ChrR_Cnt <= (others => '0');
			Ver_Cnt <= (others => '0');
			Invert <= (others => '0');
			Wr_n_r <= '1';
		elsif Clk'event and Clk = '1' then
			Wr_n_r <= Wr_n or VideoRd;
			if Tick = '1' then
				if ChrC_Cnt = 7 then
					if (Is128k and Hor_Cnt = 56) or
						(not Is128k and Hor_Cnt = 55) then
						Hor_Cnt <= (others => '0');
						ChrR_Cnt <= ChrR_Cnt + 1;
						if (Is128k and ChrR_Cnt = 6) or
							(not Is128k and ChrR_Cnt = 7) then
							if Ver_Cnt = 38 then
								ChrR_Cnt <= (others => '0');
								Ver_Cnt <= (others => '0');
								Invert <= Invert + 1;
							else
								Ver_Cnt <= Ver_Cnt + 1;
							end if;
						end if;
					else
						Hor_Cnt <= Hor_Cnt + 1;
					end if;
				end if;
				ChrC_Cnt <= ChrC_Cnt + 1;
			end if;
		end if;
	end process;

	VRAM_Addr <= A(12 downto 0) when VideoRd = '0' else
		std_logic_vector(Ver_Cnt(4 downto 3) & ChrR_Cnt & Ver_Cnt(2 downto 0) & Hor_Cnt(4 downto 0));
	ARAM_Addr <= A(9 downto 0) when VideoRd = '0' else
		std_logic_vector(Ver_Cnt(4 downto 0) & Hor_Cnt(4 downto 0));
	CSV0_n <= '0' when VidCS_n = '0' and A(13 downto 12) = "00" else '1';
	CSV1_n <= '0' when VidCS_n = '0' and A(13 downto 11) = "010" else '1';
	CSA_n <= '0' when VidCS_n = '0' and A(13 downto 10) = "0110" else '1';
	VData <= VData0 when VRAM_Addr(12) = '0' else VData1;

	-- Video RAMs
	u0 : SSRAM
		generic map(
			AddrWidth => 12)
		port map(
			Clk => Clk,
			CE_n => CSV0_n,
			WE_n => Wr_n_i,
			A => VRAM_Addr(11 downto 0),
			DIn => D,
			DOut => VData0);

	u1 : SSRAM
		generic map(
			AddrWidth => 11)
		port map(
			Clk => Clk,
			CE_n => CSV1_n,
			WE_n => Wr_n_i,
			A => VRAM_Addr(10 downto 0),
			DIn => D,
			DOut => VData1);

	-- Attribute RAM
	u2 : SSRAM
		generic map(
			AddrWidth => 10)
		port map(
			Clk => Clk,
			CE_n => CSA_n,
			WE_n => Wr_n_i,
			A => ARAM_Addr(9 downto 0),
			DIn => D,
			DOut => Attr);

	Blank_n <= (Hor_Cnt(5) nor Ver_Cnt(5)) and (Ver_Cnt(4) nand Ver_Cnt(3));

	-- Video shift register
	process (Rst_n, Clk)
		variable Blank_r : std_logic;
	begin
		if Rst_n = '0' then
			Shift <= (others => '0');
			Attr_r <= (others => '0');
			Blank_r := '0';
			R <= '0';
			G <= '0';
			B <= '0';
		elsif Clk'event and Clk = '1' then
			if Tick = '1' then
				if ChrC_Cnt = 7 and Blank_n = '1' then
					Shift <= VData;
					Attr_r <= Attr;
				else
					Shift(7 downto 1) <= Shift(6 downto 0);
					Shift(0) <= '0';
				end if;
				if Blank_r = '1' then
					Bright <= Attr_r(6);
					if (Shift(7) xor (Attr_r(7) and Invert(3))) = '1' then
						G <= Attr_r(2);
						R <= Attr_r(1);
						B <= Attr_r(0);
					else
						G <= Attr_r(5);
						R <= Attr_r(4);
						B <= Attr_r(3);
					end if;
				else
					Bright <= '0';
					G <= Border(2);
					R <= Border(1);
					B <= Border(0);
				end if;
				if ChrC_Cnt = 7 then
					Blank_r := Blank_n;
				end if;
			end if;
		end if;
	end process;

	-- Sync
	process (Rst_n, Clk)
	begin
		if Rst_n = '0' then
			HSync <= '0';
			VSync <= '0';
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
			end if;
		end if;
	end process;

end;
