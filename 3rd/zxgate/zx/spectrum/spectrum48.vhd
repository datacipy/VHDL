----------------------------------------------------------
--  spectrum48.vhd
--		ZX Spectrum top level
--		=====================
--
--  10/01/02	Daniel Wallner	Creation
--  10/20/02	Daniel Wallner	Fixed RGB output
----------------------------------------------------------

-- 28MHz Clock

library IEEE;
use IEEE.std_logic_1164.all;

entity spectrum48 is
	port(
		Rst_n		: in std_logic;
		Clk			: in std_logic;
		PS2_Clk		: in std_logic;
		PS2_Data	: in std_logic;
		Tape_In		: in std_logic;
		Tape_Out	: out std_logic;
		Sound		: out std_logic;
		CVBS		: out std_logic;
		CSync		: out std_logic;
		R			: out std_logic_vector(1 downto 0);
		G			: out std_logic_vector(1 downto 0);
		B			: out std_logic_vector(1 downto 0);
		OE_n		: out std_logic;
		WE_n		: out std_logic;
		RAMCS_n		: out std_logic;
		ROMCS_n		: out std_logic;
		PGM_n		: out std_logic;
		A			: out std_logic_vector(16 downto 0);
		D			: inout std_logic_vector(7 downto 0));
end spectrum48;

architecture struct of spectrum48 is

	component spectrum_ps2
	port(
		Clk			: in std_logic;
		Rst_n		: in std_logic;
		Tick1us		: in std_logic;
		PS2_Clk		: in std_logic;
		PS2_Data	: in std_logic;
		Key_Addr	: in std_logic_vector(7 downto 0);
		Key_Data	: out std_logic_vector(4 downto 0));
	end component;

	component T80se
	generic(
		Mode : integer := 0;
		T2Write : integer := 1);
	port (
		RESET_n		: in std_logic;
		CLK_n		: in std_logic;
		CLKEN		: in std_logic;
		WAIT_n		: in std_logic;
		INT_n		: in std_logic;
		NMI_n		: in std_logic;
		BUSRQ_n		: in std_logic;
		M1_n		: out std_logic;
		MREQ_n		: out std_logic;
		IORQ_n		: out std_logic;
		RD_n		: out std_logic;
		WR_n		: out std_logic;
		RFSH_n		: out std_logic;
		HALT_n		: out std_logic;
		BUSAK_n		: out std_logic;
		A			: out std_logic_vector(15 downto 0);
		DI			: in std_logic_vector(7 downto 0);
		DO			: out std_logic_vector(7 downto 0));
	end component;

	component spectrum_vid
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
	end component;

	component spectrum48_glue
	port(
		Rst_n		: in std_logic;
		Clk			: in std_logic;
		TapeIn		: in std_logic;
		Rd_n		: in std_logic;
		Wr_n		: in std_logic;
		MReq_n		: in std_logic;
		IORq_n		: in std_logic;
		Bright		: in std_logic;
		R			: in std_logic;
		G			: in std_logic;
		B			: in std_logic;
		A			: in std_logic_vector(15 downto 0);
		DO_CPU		: in std_logic_vector(7 downto 0);
		DO_MEM		: in std_logic_vector(7 downto 0);
		DO_Key		: in std_logic_vector(4 downto 0);
		DI_CPU		: out std_logic_vector(7 downto 0);
		Border		: out std_logic_vector(2 downto 0);
		Y			: out std_logic_vector(7 downto 0);
		U			: out std_logic_vector(3 downto 0);
		V			: out std_logic_vector(3 downto 0);
		Rst_n_s		: out std_logic;
		VidTick		: out std_logic;
		Tick1us		: out std_logic;
		TapeOut		: out std_logic;
		Sound		: out std_logic;
		RAMCS_n		: out std_logic;
		ROMCS_n		: out std_logic;
		VidCS_n		: out std_logic);
	end component;

	component CVM
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
	end component;

	signal MReq_n		: std_logic;
	signal IORq_n		: std_logic;
	signal Rd_n			: std_logic;
	signal Wr_n			: std_logic;
	signal Int_n		: std_logic;
	signal Rst_n_s		: std_logic;
	signal HSync		: std_logic;
	signal VSync		: std_logic;
	signal Bright		: std_logic;
	signal R_i			: std_logic;
	signal G_i			: std_logic;
	signal B_i			: std_logic;
	signal VidTick		: std_logic;
	signal Tick1us		: std_logic;
	signal VidCS_n		: std_logic;
	signal RGB_En		: std_logic;
	signal Y			: std_logic_vector(7 downto 0);
	signal U			: std_logic_vector(3 downto 0);
	signal V			: std_logic_vector(3 downto 0);
	signal Chroma		: std_logic_vector(7 downto 0);
	signal Luma			: std_logic_vector(7 downto 0);
	signal A_i			: std_logic_vector(15 downto 0);
	signal DI_CPU		: std_logic_vector(7 downto 0);
	signal DO_CPU		: std_logic_vector(7 downto 0);
	signal DO_Key		: std_logic_vector(4 downto 0);
	signal Border		: std_logic_vector(2 downto 0);
	signal CPUEN		: std_logic;
	signal One			: std_logic;

begin

	One <= '1';

	OE_n <= Rd_n;
	WE_n <= Wr_n;
	PGM_n <= One;
	A(14 downto 0) <= A_i(14 downto 0);
	A(16 downto 15) <= "00";
	D <= DO_CPU when Wr_n = '0' else "ZZZZZZZZ";
	CSync <= not (HSync xor VSync);
	R(1) <= R_i and RGB_En;
	R(0) <= R_i and Bright and RGB_En;
	G(1) <= G_i and RGB_En;
	G(0) <= G_i and Bright and RGB_En;
	B(1) <= B_i and RGB_En;
	B(0) <= B_i and Bright and RGB_En;

	u_Z80: T80se
		generic map (Mode => 0, T2Write => 1)
		port map (
			CLKEN => CPUEN,
			M1_n => open,
			MREQ_n => MReq_n,
			IORQ_n => IORq_n,
			RD_n => Rd_n,
			WR_n => Wr_n,
			RFSH_n => open,
			HALT_n => open,
			WAIT_n => One,
			INT_n => Int_n,
			NMI_n => One,
			RESET_n => Rst_n_s,
			BUSRQ_n => One,
			BUSAK_n => open,
			CLK_n => Clk,
			A => A_i,
			DI => DI_CPU,
			DO => DO_CPU);

	u_glue: spectrum48_glue
		port map (
			Rst_n => Rst_n,
			Clk => Clk,
			TapeIn => Tape_In,
			Rd_n => Rd_n,
			Wr_n => Wr_n,
			MReq_n => MReq_n,
			IORq_n => IORq_n,
			Bright => Bright,
			R => R_i,
			G => G_i,
			B => B_i,
			A => A_i,
			DO_CPU => DO_CPU,
			DO_MEM => D,
			DO_Key => DO_Key,
			DI_CPU => DI_CPU,
			Border => Border,
			Y => Y,
			U => U,
			V => V,
			Rst_n_s => Rst_n_s,
			VidTick => VidTick,
			Tick1us => Tick1us,
			TapeOut => Tape_Out,
			Sound => Sound,
			RAMCS_n => RAMCS_n,
			ROMCS_n => ROMCS_n,
			VidCS_n => VidCS_n);

	u_vid : spectrum_vid
		port map(
			Rst_n => Rst_n_s,
			Clk => Clk,
			Tick => VidTick,
			VidCS_n => VidCS_n,
			Wr_n => Wr_n,
			A => A_i(13 downto 0),
			D => DO_CPU,
			Border => Border,
			CPUEN => CPUEN,
			HSync => HSync,
			VSync => VSync,
			Bright => Bright,
			R => R_i,
			G => G_i,
			B => B_i);

	u_ps2 : spectrum_ps2
		port map(
			Rst_n => Rst_n_s,
			Clk => Clk,
			Tick1us => Tick1us,
			PS2_Clk => PS2_Clk,
			PS2_Data => PS2_Data,
			Key_Addr => A_i(15 downto 8),
			Key_Data => DO_Key);

	u_cvm : CVM
		port map(
			Rst_n => Rst_n,
			Clk => Clk,
			HSync => HSync,
			VSync => VSync,
			Y => Y,
			U => U,
			V => V,
			RGB_En => RGB_En,
			Chroma => Chroma,
			Luma => Luma);

	CVBS <= '0' when (HSync xor VSync) = '1'
		else 'Z' when R_i = '0' or RGB_En = '0'
		else '1';

	Int_n <= not VSync;

end;
