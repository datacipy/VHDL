----------------------------------------------------------
--  trsl2_tb.vhd
--		Level II testbench
--		==================
--
--  09/29/02	Daniel Wallner	Creation
----------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity trsl2_tb is
end trsl2_tb;

architecture tb of trsl2_tb is

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

	component trs80xm
	port(
		Rst_n		: in std_logic;
		Clk			: in std_logic;
		Eur			: in std_logic;
		PS2_Clk		: in std_logic;
		PS2_Data	: in std_logic;
		CVBS		: out std_logic;
		OE_n		: out std_logic;
		WE_n		: out std_logic;
		RAMCS_n		: out std_logic;
		ROMCS_n		: out std_logic;
		PGM_n		: out std_logic;
		A			: out std_logic_vector(16 downto 0);
		D			: inout std_logic_vector(7 downto 0));
	end component;

	component level2_rom
	port(
		CE_n	: in std_logic;
		OE_n	: in std_logic;
		A	: in std_logic_vector(13 downto 0);
		D	: out std_logic_vector(7 downto 0));
	end component;

	component sram
	generic (
		AddrWidth: integer :=  15;	-- number of address bits
		DataWidth: integer :=  8	-- number of bits per memory word
	);
	port (
		A		: in std_logic_vector(AddrWidth - 1 downto 0);
		D		: inout std_logic_vector(DataWidth - 1 downto 0);
		CE_n	: in  std_logic;
		WE_n	: in std_logic;
		OE_n	: in std_logic);
	end component;

	signal Rst_n	: std_logic := '0';
	signal Clk		: std_logic := '0';
	signal PS2_Clk	: std_logic := '1';
	signal PS2_Data	: std_logic := '1';
	signal CVBS		: std_logic;
	signal OE_n		: std_logic;
	signal WE_n		: std_logic;
	signal RAMCS_n	: std_logic;
	signal ROMCS_n	: std_logic;
	signal A		: std_logic_vector(16 downto 0);
	signal D		: std_logic_vector(7 downto 0);

begin

	Rst_n <= '1' after 90 ns;

	Clk <= not Clk after 36 ns;

	u_s48 : trs80xm
		port map(
			Rst_n => Rst_n,
			Clk => Clk,
			Eur => '1',
			PS2_Clk => PS2_Clk,
			PS2_Data => PS2_Data,
			CVBS => CVBS,
			OE_n => OE_n,
			WE_n => WE_n,
			RAMCS_n => RAMCS_n,
			ROMCS_n => ROMCS_n,
			PGM_n => open,
			A => A,
			D => D);

	u_rom : level2_rom
		port map(
			CE_n => ROMCS_n,
			OE_n => OE_n,
			A => A(13 downto 0),
			D => D);

	u_ram : sram
		port map(
			A => A(14 downto 0),
			D => D,
			CE_n => RAMCS_n,
			WE_n => WE_n,
			OE_n => OE_n);

	-- Generate keyboard signals
	process
	begin
		wait for 7 ms;
		PS2Byte(x"5a", PS2_Clk, PS2_Data);
		wait for 100 ms;
		PS2Byte(x"f0", PS2_Clk, PS2_Data);
		PS2Byte(x"5a", PS2_Clk, PS2_Data);
		wait;
	end process;

end;
