----------------------------------------------------------
--  trs80.vhd
--		trs80 top level
--		===============
--
--  04/14/02	Daniel Wallner	Creation
--  09/29/02	Daniel Wallner	Changed RAM size
----------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity trs80 is
	port(
		Rst_n		: in std_logic;
		Clk			: in std_logic;
		Eur			: in std_logic;
		PS2_Clk		: in std_logic;
		PS2_Data	: in std_logic;
		CVBS		: out std_logic);
end trs80;

architecture struct of trs80 is

	component trs_ps2
	port(
		Clk			: in std_logic;
		Rst_n		: in std_logic;
		Tick1us		: in std_logic;
		PS2_Clk		: in std_logic;
		PS2_Data	: in std_logic;
		Key_Addr	: in std_logic_vector(7 downto 0);
		Key_Data	: out std_logic_vector(7 downto 0)
	);
	end component;

	component T80s
	generic(
		Mode : integer := 0);
	port (
		RESET_n		: in std_logic;
		CLK_n		: in std_logic;
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

	component trs_rom1
	port (
		Clk	: in std_logic;
		A	: in std_logic_vector(11 downto 0);
		D	: out std_logic_vector(7 downto 0));
	end component;

	component trs_vid
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
	end component;

	component trs_glue
	generic(
		RAMWidth : integer := 15);
	port(
		Rst_n	: in std_logic;
		Clk		: in std_logic;
		Rd_n	: in std_logic;
		Wr_n	: in std_logic;
		MReq_n	: in std_logic;
		IORq_n	: in std_logic;
		A		: in std_logic_vector(15 downto 0);
		DO_RAM	: in std_logic_vector(7 downto 0);
		DO_ROM	: in std_logic_vector(7 downto 0);
		DO_Vid	: in std_logic_vector(7 downto 0);
		DO_Key	: in std_logic_vector(7 downto 0);
		DI_CPU	: out std_logic_vector(7 downto 0);
		Rst_n_s	: out std_logic;
		Tick1us	: out std_logic;
		MWr_n	: out std_logic;
		RAMCS_n	: out std_logic;
		ROMCS_n	: out std_logic;
		VidCS_n	: out std_logic);
	end component;

	signal MREQ_n	: std_logic;
	signal IORQ_n	: std_logic;
	signal RD_n		: std_logic;
	signal WR_n		: std_logic;
	signal MWr_n	: std_logic;
	signal Rst_n_s	: std_logic;
	signal Sync		: std_logic;
	signal Video	: std_logic;
	signal Tick1us	: std_logic;
	signal RAMCS_n	: std_logic;
	signal VidCS_n	: std_logic;
	signal A		: std_logic_vector(15 downto 0);
	signal DI_CPU	: std_logic_vector(7 downto 0);
	signal DO_CPU	: std_logic_vector(7 downto 0);
	signal DO_RAM	: std_logic_vector(7 downto 0);
	signal DO_ROM	: std_logic_vector(7 downto 0);
	signal DO_Vid	: std_logic_vector(7 downto 0);
	signal DO_Key	: std_logic_vector(7 downto 0);
	signal One		: std_logic;

begin

	One <= '1';

	u_Z80: T80s
		generic map (Mode => 0)
		port map (
			M1_n => open,
			MREQ_n => MReq_n,
			IORQ_n => IORq_n,
			RD_n => Rd_n,
			WR_n => Wr_n,
			RFSH_n => open,
			HALT_n => open,
			WAIT_n => One,
			INT_n => One,
			NMI_n => One,
			RESET_n => Rst_n_s,
			BUSRQ_n => One,
			BUSAK_n => open,
			CLK_n => Clk,
			A => A,
			DI => DI_CPU,
			DO => DO_CPU);

	u_SSRAM: SSRAM
		generic map (AddrWidth => 11)
		port map (
			Clk => Clk,
			CE_n => RAMCS_n,
			WE_n => MWr_n,
			A => A(10 downto 0),
			DIn => DO_CPU,
			DOut => DO_RAM);

	u_ROM: trs_rom1
		port map (
			Clk => Clk,
			A => A(11 downto 0),
			D => DO_ROM);

	u_glue: trs_glue
		generic map (
			RAMWidth => 11)
		port map (
			Rst_n => Rst_n,
			Clk => Clk,
			Rd_n => Rd_n,
			Wr_n => Wr_n,
			MReq_n => MReq_n,
			IORq_n => IORq_n,
			A => A,
			DO_RAM => DO_RAM,
			DO_ROM => DO_ROM,
			DO_Vid => DO_Vid,
			DO_Key => DO_Key,
			DI_CPU => DI_CPU,
			Rst_n_s => Rst_n_s,
			Tick1us => Tick1us,
			MWr_n => MWr_n,
			RAMCS_n => RAMCS_n,
			ROMCS_n => open,
			VidCS_n => VidCS_n);

	vid : trs_vid
		port map(
			Rst_n => Rst_n_s,
			Clk => Clk,
			Tick => One,
			Eur => Eur,
			CS_n => VidCS_n,
			Wr_n => MWr_n,
			Addr => A(9 downto 0),
			DI => DO_CPU,
			DO => DO_Vid,
			Sync => Sync,
			Video => Video);

	u_ps2 : trs_ps2
		port map(
			Rst_n => Rst_n_s,
			Clk => Clk,
			Tick1us => Tick1us,
			PS2_Clk => PS2_Clk,
			PS2_Data => PS2_Data,
			Key_Addr => A(7 downto 0),
			Key_Data => DO_Key);

	CVBS <= '0' when Sync = '1'
		else 'Z' when Video = '0'
		else '1';

end;
