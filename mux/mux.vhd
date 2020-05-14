library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux is
   port ( sel : in  STD_LOGIC;
           in1 : in  STD_LOGIC;
           in2 : in  STD_LOGIC;
           y: out STD_LOGIC
	);
end entity;

architecture main of mux is
begin
    y <= in2 when (sel = '1') else in1;
end main;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux8W is
   port ( sel : in  STD_LOGIC_VECTOR (2 downto 0);
           in0 : in  STD_LOGIC;
           in1 : in  STD_LOGIC;
           in2 : in  STD_LOGIC;
           in3 : in  STD_LOGIC;
           in4 : in  STD_LOGIC;
           in5 : in  STD_LOGIC;
           in6 : in  STD_LOGIC;
           in7 : in  STD_LOGIC;
           y: out STD_LOGIC
	);
end entity;

architecture main of mux8w is
begin
with sel select
    y <= in0 when "000", 
	 in1 when "001",
	 in2 when "010",
	 in3 when "011",
	 in4 when "100",
	 in5 when "101",
	 in6 when "110",
	 in7 when others;
end main;