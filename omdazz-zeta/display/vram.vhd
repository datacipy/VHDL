library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY vram IS

port (
 addr: in std_logic_vector(12 downto 0); 
 data: out std_logic_vector(7 downto 0); 
 clk: in std_logic;
 saddr: in std_logic_vector(12 downto 0); 
 sdatain: in std_logic_vector(7 downto 0); 
 sdataout: out std_logic_vector(7 downto 0); 
 swe: in std_logic;
 sclk: in std_logic
);

END vram;

architecture main of vram is

component dpram2k
	GENERIC (romfile: STRING);
	PORT
	(
		address_a		: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
		address_b		: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
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
signal ram0,ram1,ram2:std_logic_vector(7 downto 0);
signal di0,di1,di2:std_logic_vector(7 downto 0);
signal do0,do1,do2:std_logic_vector(7 downto 0);
signal we0,we1,we2:std_logic;

begin

c0: dpram2k generic map (romfile => "scr.mif") port map (
	saddr(10 downto 0),
	addr(10 downto 0), 
	sclk,
	clk,
	di0, 
	addr(7 downto 0), 
	we0,
	'0',
	do0,
	ram0
	);
c1: dpram2k generic map (romfile => "scr2.mif") port map (
	saddr(10 downto 0),
	addr(10 downto 0), 
	sclk,
	clk,
	di1, 
	addr(7 downto 0), 
	we1,
	'0',
	do1,
	ram1
	);
c2: dpram2k generic map (romfile => "scr3.mif") port map (
	saddr(10 downto 0),
	addr(10 downto 0), 
	sclk,
	clk,
	di2, 
	addr(7 downto 0), 
	we2,
	'0',
	do2,
	ram2
	);

with addr(12 downto 11) select
data <= ram0 when "00",
		  ram1 when "01",
		  ram2 when others;

with saddr(12 downto 11) select
sdataout <= do0 when "00",
		  do1 when "01",
		  do2 when others;
		  
di0 <= sdatain when saddr(12 downto 11)="00" else (others=>'Z');
di1 <= sdatain when saddr(12 downto 11)="01" else (others=>'Z');	  
di2 <= sdatain when saddr(12 downto 11)="10" else (others=>'Z');	  

we0 <= swe when saddr(12 downto 11)="00" else '0';
we1 <= swe when saddr(12 downto 11)="01" else '0';
we2 <= swe when saddr(12 downto 11)="10" else '0';
	
	
end architecture;