----------------------------------------------------------
--  spectrum48_glue.vhd
--		ZX Spectrum glue logic
--		======================
--
--  10/01/02	Daniel Wallner	Creation
--  10/20/02	Daniel Wallner	Fixed border write and tape read
--  10/24/02	Daniel Wallner	Added tape in sound
----------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity spectrum48_glue is
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
end spectrum48_glue;

architecture rtl of spectrum48_glue is

	signal Rst_n_i	: std_logic;
	signal UR		: signed(3 downto 0);
	signal UG		: signed(3 downto 0);
	signal UB		: signed(3 downto 0);
	signal VR		: signed(3 downto 0);
	signal VG		: signed(3 downto 0);
	signal VB		: signed(3 downto 0);

begin

	Rst_n_s <= Rst_n_i;

	process (Rst_n, Clk)
	begin
		if Rst_n = '0' then
			Rst_n_i <= '0';
		elsif Clk'event and Clk = '1' then
			Rst_n_i <= '1';
		end if;
	end process;

	process (Rst_n_i, Clk)
		variable Cnt : unsigned(4 downto 0);
	begin
		if Rst_n_i = '0' then
			Cnt := "00000";
			VidTick <= '0';
			Tick1us <= '0';
			TapeOut <= '0';
			Sound <= '0';
			Border <= "000";
		elsif Clk'event and Clk = '1' then
			VidTick <= Cnt(1) and Cnt(0);
			Tick1us <= '0';
			if Cnt = "00000" then
				Tick1us <= '1';
			end if;
			Cnt := Cnt - 1;

			if IORq_n = '0' and A(0) = '0' then
				if Wr_n = '0' then
					TapeOut <= DO_CPU(3);
					Sound <= DO_CPU(4) xor TapeIn;
					Border <= DO_CPU(2 downto 0);
				end if;
			end if;
		end if;
	end process;

	ROMCS_n <= '0' when A(15 downto 14) = "00" and MReq_n = '0' else '1';
	RAMCS_n <= '0' when (A(15) xor A(14)) = '1' and MReq_n = '0' else '1';
	VidCS_n <= '0' when A(15 downto 14) = "01" and MReq_n = '0' else '1';

	DI_CPU <= DO_MEM when MReq_n = '0' else
		"1" & TapeIn & "1" & DO_Key when IORq_n = '0' and A(0) = '0' else
		"11111111";

	-- [ Y ]   [  0.299  0.587  0.114 ]  [ R ]
	-- [ U ] = [ -0.147 -0.289  0.437 ]  [ G ]
	-- [ V ]   [  0.615 -0.515 -0.100 ]  [ B ]

	Y <= G & R & B & "00000" when Bright = '1' else "0" & G & R & B & "0000";
	UR <= R & R & R & R;
	UG <= G & G & G & "0";
	UB <= "0" & B & "00";
	U <= std_logic_vector(UR + UG + UB);
	VR <= "0" & R & "00";
	VG <= G & G & "00";
	VB <= B & B & B & B;
	V <= std_logic_vector(VR + VG + VB);

end;
