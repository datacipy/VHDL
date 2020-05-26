----------------------------------------------------------
--  trs_glue.vhd
--		trs80 glue logic
--		================
--
--  04/14/02	Daniel Wallner	Creation
--  09/29/02	Daniel Wallner	Changed RAM size
----------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity trs_glue is
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
end trs_glue;

architecture rtl of trs_glue is

	signal RAMCS_n_i	: std_logic;
	signal ROMCS_n_i	: std_logic;
	signal VidCS_n_i	: std_logic;
	signal KeyCS_n_i	: std_logic;
	signal Rst_n_i		: std_logic;

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
		variable Cnt : unsigned(2 downto 0);
	begin
		if Rst_n_i = '0' then
			Cnt := "000";
			Tick1us <= '0';
		elsif Clk'event and Clk = '1' then
			Tick1us <= '0';
			if Cnt = "000" then
				Tick1us <= '1';
			end if;
			Cnt := Cnt - 1;
		end if;
	end process;

	MWr_n <= MReq_n or Wr_n;

	ROMCS_n_i <= '0' when A(15 downto 14) = "00" and (A(13) and A(12)) = '0' else '1';
	g16 : if RAMWidth = 16 generate
		RAMCS_n_i <= '0' when (A(15) or A(14)) = '1' else '1';
	end generate;
	g15 : if RAMWidth = 15 generate
		RAMCS_n_i <= '0' when (A(15) xor A(14)) = '1' else '1';
	end generate;
	g14 : if RAMWidth = 14 generate
		RAMCS_n_i <= '0' when A(15 downto 14) = "01" else '1';
	end generate;
	g13 : if RAMWidth < 14 generate
		RAMCS_n_i <= '0' when A(15 downto 14) = "01" and unsigned(A(13 downto RAMWidth)) = 0 else '1';
	end generate;
	VidCS_n_i <= '0' when A(15 downto 10) = "001111" else '1';
	KeyCS_n_i <= '0' when A(15 downto 10) = "001110" else '1';

	RAMCS_n <= RAMCS_n_i;
	ROMCS_n <= ROMCS_n_i;
	VidCS_n <= VidCS_n_i;

	DI_CPU <= DO_RAM when RAMCS_n_i = '0'
-- pragma translate_off
			and not is_x(DO_RAM) else
			"10100101" when RAMCS_n_i = '0'
-- pragma translate_on
			else
		DO_ROM when ROMCS_n_i = '0' else
		DO_Vid when VidCS_n_i = '0' else
		DO_Key when KeyCS_n_i = '0' else
		"11111111";

end;
