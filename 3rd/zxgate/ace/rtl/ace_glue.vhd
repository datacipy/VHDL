----------------------------------------------------------
--  ace_glue.vhd
--		Jupiter ACE glue logic
--		======================
--
--  04/14/02	Daniel Wallner	Creation
--  09/16/02	Daniel Wallner	Major overhaul
--  09/29/02	Daniel Wallner	Changed RAM decoding
--  10/20/02	Daniel Wallner	Changed video decoding
--  10/24/02	Daniel Wallner	Fixed sound
----------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ace_glue is
	port(
		Rst_n	: in std_logic;
		Clk		: in std_logic;
		TapeIn	: in std_logic;
		Rd_n	: in std_logic;
		Wr_n	: in std_logic;
		MReq_n	: in std_logic;
		IORq_n	: in std_logic;
		VidEn	: in std_logic;
		A		: in std_logic_vector(15 downto 0);
		DO_CPU	: in std_logic_vector(7 downto 0);
		DO_RAM	: in std_logic_vector(7 downto 0);
		DO_ROM	: in std_logic_vector(7 downto 0);
		DO_Vid	: in std_logic_vector(7 downto 0);
		DO_Key	: in std_logic_vector(4 downto 0);
		DI_CPU	: out std_logic_vector(7 downto 0);
		Rst_n_s	: out std_logic;
		Tick1us	: out std_logic;
		TapeOut	: out std_logic;
		Sound	: out std_logic;
		Wait_n	: out std_logic;
		VidWr_n	: out std_logic;
		RAMCS_n	: out std_logic;
		ROMCS_n	: out std_logic;
		VidCS_n	: out std_logic;
		CSV_n	: out std_logic;
		CSC_n	: out std_logic);
end ace_glue;

architecture rtl of ace_glue is

	signal RAMCS_n_i	: std_logic;
	signal ROMCS_n_i	: std_logic;
	signal VidCS_n_i	: std_logic;
	signal VidCS_n_t	: std_logic;
	signal Wr_r			: std_logic;
	signal Wait_n_i		: std_logic;
	signal Rst_n_i		: std_logic;

begin

	VidCS_n <= VidCS_n_i;
	VidCS_n_i <= VidCS_n_t or (A(10) and VidEn);
	VidWr_n <= VidCS_n_i or Wr_n or Wr_r;

	Wait_n <= Wait_n_i;

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
			Wait_n_i <= '1';
			Wr_r <= '1';
			TapeOut <= '0';
			Sound <= '0';
		elsif Clk'event and Clk = '1' then
			Tick1us <= '0';
			if Cnt = "000" then
				Tick1us <= '1';
			end if;
			Cnt := Cnt - 1;

			if VidCS_n_i = '0' then
				Wr_r <= Wr_n;
			else
				Wr_r <= '1';
			end if;

			if (VidCS_n_t or not (A(10) and VidEn))  = '0' then
				Wait_n_i <= '0';
			end if;
			if ((VidCS_n_i nor A(11)) or (VidCS_n_i nor (VidCS_n_i nor A(11)))) = '1' then
				Wait_n_i <= '1';
			end if;

			if IORq_n = '0' and A(0) = '0' then
				if Wr_n = '0' then
					TapeOut <= DO_CPU(0);
					Sound <= '1';
				end if;
				if Rd_n <= '0' then
					Sound <= '0';
				end if;
			end if;
		end if;
	end process;

	ROMCS_n_i <= '0' when A(15 downto 13) = "000" and MReq_n = '0' else '1';
	RAMCS_n_i <= '0' when A(15) = '0' and (A(14) = '1' or A(14 downto 12) = "011") and MReq_n = '0' else '1';
	VidCS_n_t <= '0' when A(15 downto 12) = "0010" and MReq_n = '0' else '1';

	RAMCS_n <= RAMCS_n_i;
	ROMCS_n <= ROMCS_n_i;
	CSC_n <= VidCS_n_i nor A(11);
	CSV_n <= VidCS_n_i nor (VidCS_n_i nor A(11));

	DI_CPU <= DO_RAM when RAMCS_n_i = '0' else
		DO_ROM when ROMCS_n_i = '0' else
		DO_Vid when VidCS_n_t = '0' else
		"11" & TapeIn & DO_Key when IORq_n = '0' else
		"11111111";

end;
