----------------------------------------------------------
--  trs80_tb.vhd
--		Testbench for trs80
--		===================
--
--  04/14/02	Daniel Wallner	Creation
--  09/29/02	Daniel Wallner	Interface changes
----------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity trs80_tb is
end trs80_tb;

architecture tb of trs80_tb is

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

	component trs80
	port(
		Rst_n		: in std_logic;
		Clk			: in std_logic;
		Eur			: in std_logic;
		PS2_Clk		: in std_logic;
		PS2_Data	: in std_logic;
		CVBS		: out std_logic);
	end component;

	signal Rst_n	: std_logic := '0';
	signal Clk		: std_logic := '0';
	signal PS2_Clk	: std_logic := '1';
	signal PS2_Data	: std_logic := '1';
	signal CVBS		: std_logic;

begin

	Rst_n <= '1' after 90 ns;

	Clk <= not Clk after 50 ns;

	trs : trs80
		port map(
			Rst_n => Rst_n,
			Clk => Clk,
			Eur => '1',
			PS2_Clk => PS2_Clk,
			PS2_Data => PS2_Data,
			CVBS => CVBS);

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
