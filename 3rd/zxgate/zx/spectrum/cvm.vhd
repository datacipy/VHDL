--
-- Color Video Modulator
--
-- 10/01/02 Daniel Wallner	Creation
-- 10/20/02 Daniel Wallner	Added RGB_En output

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CVM is
	generic(
		YWidth			: integer := 8;
		UVWidth			: integer := 4;
		OutputWidth		: integer := 8;
		DDS_OWidth		: integer := 4;
		DDS_TWidth		: integer := 6;
		DDS_AWidth		: integer := 19;
		DDS_Increment	: integer := 166035;
		BurstStart		: integer := 28;
		BurstStop		: integer := 91;
		LineStart		: integer := 168;
		CntBits			: integer := 8
	);
	port(
		Rst_n	: in std_logic;
		Clk		: in std_logic;
		HSync	: in std_logic;
		VSync	: in std_logic;
		Y		: in std_logic_vector(YWidth - 1 downto 0);
		U		: in std_logic_vector(UVWidth - 1 downto 0);
		V		: in std_logic_vector(UVWidth - 1 downto 0);
		RGB_En	: out std_logic;
		Chroma	: out std_logic_vector(OutputWidth - 1 downto 0);
		Luma	: out std_logic_vector(OutputWidth - 1 downto 0)
	);
end CVM;

architecture rtl of CVM is

	component DDS
	generic(
		OWidth		: integer := DDS_OWidth;	-- Output width
		TWidth		: integer := DDS_TWidth;	-- Sine table address width
		AWidth		: integer := DDS_AWidth;	-- Phase acc. width
		Increment	: integer := DDS_Increment	-- (2^AWidth)*Fout/Fs
	);
	port(
		Clk			: in std_logic;
		Rst			: in std_logic;
		Tick		: in std_logic;
		Phase		: in std_logic_vector(2 downto 0);
		SinOut		: out std_logic_vector(OWidth - 1 downto 0);
		CosOut		: out std_logic_vector(OWidth - 1 downto 0)
	);
	end component;

	component QAM
	generic(
		IWidth	: integer := UVWidth;		-- Input width
		QWidth	: integer := DDS_OWidth;	-- Quadrature width
		OWidth	: integer := OutputWidth	-- Output width
	);
	port(
		Clk		: in std_logic;
		Tick	: in std_logic;
		V		: in std_logic_vector(IWidth - 1 downto 0);
		U		: in std_logic_vector(IWidth - 1 downto 0);
		SinIn	: in std_logic_vector(QWidth - 1 downto 0);
		CosIn	: in std_logic_vector(QWidth - 1 downto 0);
		C		: out std_logic_vector(OWidth - 1 downto 0)
	);
	end component;

	signal Tick		: std_logic;
	signal Rst		: std_logic;
	signal Burst	: std_logic;
	signal Active	: std_logic;
	signal Phase	: std_logic_vector(2 downto 0);
	signal Mixer	: signed(OutputWidth downto 0);
	signal Cnt		: unsigned(CntBits - 1 downto 0);
	signal C		: std_logic_vector(OutputWidth - 1 downto 0);
	signal QSin		: std_logic_vector(DDS_OWidth - 1 downto 0);
	signal QSin0	: std_logic_vector(DDS_OWidth - 1 downto 0);
	signal QSin1	: std_logic_vector(DDS_OWidth - 1 downto 0);
	signal QCos		: std_logic_vector(DDS_OWidth - 1 downto 0);

begin

	RGB_En <= Active;

	Rst <= HSync;

	u_dds : DDS
		port map(
			Clk => Clk,
			Rst => Rst,
			Tick => Tick,
			Phase => Phase,
			SinOut => QSin,
			CosOut => QCos);

	u_qam : QAM
		port map(
			Clk => Clk,
			Tick => Tick,
			V => V,
			U => U,
			SinIn => QSin,
			CosIn => QCos,
			C => C);

	process (Rst_n, Clk)
	begin
		if Rst_n = '0' then
			Tick <= '0';
			Burst <= '0';
			Active <= '0';
			Phase <= "000";
			Cnt <= (others => '0');
		elsif Clk'event and Clk = '1' then
			Tick <= not Tick;
			if HSync = '1' then
				Burst <= '0';
				Active <= '0';
				Cnt <= (others => '0');
			else
				if Cnt = BurstStart then
					Burst <= '1';
				end if;
				if Cnt = BurstStop then
					Burst <= '0';
				end if;
				if Cnt /= LineStart then
					Cnt <= Cnt + 1;
				else
					Active <= '1';
				end if;
			end if;
			if VSync = '1' then
				Phase <= "000";
			end if;
		end if;
	end process;

	process (Clk)
	begin
		if Clk'event and Clk = '1' then
			if Tick = '1' then
				QSin0 <= QSin;
				QSin1 <= QSin0;
			end if;
		end if;
	end process;

	Mixer <= (others => '0') when (HSync xor VSync) = '1' else
			64 + signed("0" & Y) when Active = '1' else
			"001000000";

	Chroma <= "10000000" when VSync = '1' else
			not QSin1(DDS_OWidth - 1) & QSin1(DDS_OWidth - 2 downto 0) & "0000" when Burst = '1' else
			not C(OutputWidth - 1) & C(OutputWidth - 2 downto 0) when Active = '1' else
			"10000000";

	Luma <= (others => '1') when Mixer(OutputWidth) = '1' else
			std_logic_vector(Mixer(OutputWidth - 1 downto 0));

end;
