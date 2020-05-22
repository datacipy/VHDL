library ieee;
use ieee.std_logic_1164.all;

entity adder4B is
 port (A, B: in std_logic_vector (3 downto 0);
 Cin: in std_logic;
 Q: out std_logic_vector (3 downto 0);
 Cout: out std_logic);
end entity;

architecture main of adder4B is

component fullAdder is
 port (
 A, B, Cin: in std_logic;
 Q, Cout: out std_logic
 );
end component; 

signal C0, C1, C2, C3: std_logic;
begin
A0: fulladder port map (A(0),B(0), Cin, Q(0), C0);
A1: fulladder port map (A(1),B(1), C0,  Q(1), C1);
A2: fulladder port map (A(2),B(2), C1,  Q(2), C2);
A3: fulladder port map (A(3),B(3), C2,  Q(3), C3);
Cout<=C3;
end architecture;
