library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity barrel is
  Port ( 
    A : in  STD_LOGIC_VECTOR (7 downto 0);
	 S : in STD_LOGIC_VECTOR (2 downto 0);
    Q : out  STD_LOGIC_VECTOR (7 downto 0)
    );
end entity;

architecture mmux of Barrel is

component mux is
   port ( sel : in  STD_LOGIC;
           in1 : in  STD_LOGIC;
           in2 : in  STD_LOGIC;
           y: out STD_LOGIC
	);
end component;

signal I1:  STD_LOGIC_VECTOR (7 downto 0);
signal I2:  STD_LOGIC_VECTOR (7 downto 0);


begin

m1: entity work.mux port map (S(0),A(0),'0',I1(0));
mux1_loop: for i in 1 to 7 generate
	mux_L1: entity work.mux port map (S(0),A(i),A(i-1),I1(i));  
end generate;

m2a: entity work.mux port map (S(1),I1(0),'0',I2(0));
m2b: entity work.mux port map (S(1),I1(1),'0',I2(1));
mux2_loop: for i in 2 to 7 generate
	mux_L2: entity work.mux port map (S(1),I1(i),I1(i-2),I2(i));  
end generate;

mux3_loop1: for i in 0 to 3 generate
	mux_L3a: entity work.mux port map (S(2),I2(i),'0',Q(i));  
end generate;


mux3_loop2: for i in 4 to 7 generate
	mux_L3b: entity work.mux port map (S(2),I2(i),I2(i-4),Q(i));  
end generate;


end architecture;

architecture mux8r of barrel is

begin
mux0: entity work.mux8w port map (S,A(0),A(1),A(2),A(3),A(4),A(5),A(6),A(7),Q(0));
mux1: entity work.mux8w port map (S,A(1),A(2),A(3),A(4),A(5),A(6),A(7),'0',Q(1));
mux2: entity work.mux8w port map (S,A(2),A(3),A(4),A(5),A(6),A(7),'0','0',Q(2));
mux3: entity work.mux8w port map (S,A(3),A(4),A(5),A(6),A(7),'0','0','0',Q(3));
mux4: entity work.mux8w port map (S,A(4),A(5),A(6),A(7),'0','0','0','0',Q(4));
mux5: entity work.mux8w port map (S,A(5),A(6),A(7),'0','0','0','0','0',Q(5));
mux6: entity work.mux8w port map (S,A(6),A(7),'0','0','0','0','0','0',Q(6));
mux7: entity work.mux8w port map (S,A(7),'0','0','0','0','0','0','0',Q(7));

end architecture;

architecture mux8L of barrel is

begin
mux0: entity work.mux8w port map (S,A(0),'0','0','0','0','0','0','0',Q(0));
mux1: entity work.mux8w port map (S,A(1),A(0),'0','0','0','0','0','0',Q(1));
mux2: entity work.mux8w port map (S,A(2),A(1),A(0),'0','0','0','0','0',Q(2));
mux3: entity work.mux8w port map (S,A(3),A(2),A(1),A(0),'0','0','0','0',Q(3));
mux4: entity work.mux8w port map (S,A(4),A(3),A(2),A(1),A(0),'0','0','0',Q(4));
mux5: entity work.mux8w port map (S,A(5),A(4),A(3),A(2),A(1),A(0),'0','0',Q(5));
mux6: entity work.mux8w port map (S,A(6),A(5),A(4),A(3),A(2),A(1),A(0),'0',Q(6));
mux7: entity work.mux8w port map (S,A(7),A(6),A(5),A(4),A(3),A(2),A(1),A(0),Q(7));

end architecture;
