library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux16b is
   port ( sel : in  STD_LOGIC;
           in1 : in  STD_LOGIC_VECTOR (15 downto 0);
           in2 : in  STD_LOGIC_VECTOR (15 downto 0);
           y: out STD_LOGIC_VECTOR (15 downto 0)
	);
end mux16b;

architecture main of mux16b is
begin
    y <= in1 when (sel = '1') else in2;
end main;
