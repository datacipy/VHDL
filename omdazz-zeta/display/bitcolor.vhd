library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY bitcolor IS

port (
 pixel: in std_logic;
 -- attribute byte
 attr: in std_logic_vector(7 downto 0); 
 load: in std_logic;
 clk: in std_logic;
 r,g,b,i: out std_logic
);

END bitcolor;

architecture main of bitcolor is
signal attr_i: std_logic_vector(7 downto 0);


begin

process(clk)
 begin
 if rising_edge(clk) then
	if load='1' then
	attr_i<=attr;
	end if;
	end if;
end process;


i <= attr_i(7) when (pixel='1') else attr_i(3);
r <= attr_i(6) when (pixel='1') else attr_i(2);
g <= attr_i(5) when (pixel='1') else attr_i(1);
b <= attr_i(4) when (pixel='1') else attr_i(0);
			
end architecture;