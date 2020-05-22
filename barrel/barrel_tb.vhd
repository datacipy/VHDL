/*
Barrel testbench
*/

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity barrel_tb is

end;

architecture test of barrel_tb is

signal a: STD_LOGIC_VECTOR (7 downto 0);
signal q: STD_LOGIC_VECTOR (7 downto 0);
signal s: std_LOGIC_VECTOR(2 downto 0);


component barrel is
  Port ( 
    A : in  STD_LOGIC_VECTOR (7 downto 0);
	 S : in STD_LOGIC_VECTOR (2 downto 0);
    Q : out  STD_LOGIC_VECTOR (7 downto 0)
	 );
end component;

begin

A <= "00010011";
s <= "000",
  "001" after 10 ps,
  "010" after 20 ps,
  "011" after 30 ps,
  "100" after 40 ps,
  "101" after 50 ps,
  "110" after 60 ps,
  "111" after 70 ps;

UUT: entity work.barrel(mux8L) port map (a,s,Q);

end architecture;
