library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY aram IS

port (
 addr: in std_logic_vector(9 downto 0); 
 data: out std_logic_vector(7 downto 0); 
 clk: in std_logic;
 saddr: in std_logic_vector(9 downto 0); 
 sdatain: in std_logic_vector(7 downto 0); 
 sdataout: out std_logic_vector(7 downto 0); 
 swe: in std_logic;
 sclk: in std_logic 
);

END aram;

architecture main of aram is

component testram1k
	PORT
	(
		address_a		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		address_b		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock_a		: IN STD_LOGIC  := '1';
		clock_b		: IN STD_LOGIC ;
		data_a		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		data_b		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren_a		: IN STD_LOGIC  := '0';
		wren_b		: IN STD_LOGIC  := '0';
		q_a		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		q_b		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
end component;

signal dummy: std_logic_vector(7 downto 0);

begin

c0: testram1k port map (
	saddr(9 downto 0),
	addr(9 downto 0), 
	sclk,
	clk,
	sdatain, 
	addr(7 downto 0), 
	swe,
	'0',
	sdataout,
	data
	);
			
end architecture;