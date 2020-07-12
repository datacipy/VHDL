library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY bitmux IS

port (
 pixel: in std_logic_vector(2 downto 0);
 -- data byte
 byte: in std_logic_vector(7 downto 0); 
 load: in std_logic;
 clk: in std_logic;
 p: out std_logic
);

END bitmux;

architecture main of bitmux is

signal byte_i: std_logic_vector(7 downto 0); 

begin

process(clk)
 begin
 if rising_edge(clk) then
   if load='1' then
		byte_i<=byte;
	end if;
	end if;
end process;	

with pixel select
 p <= byte_i(7) when "000",
		byte_i(6) when "001",
		byte_i(5) when "010",
		byte_i(4) when "011",
		byte_i(3) when "100",
		byte_i(2) when "101",
		byte_i(1) when "110",
		byte_i(0) when others;
			
end architecture;