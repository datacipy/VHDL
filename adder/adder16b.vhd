library ieee;
use ieee.std_logic_1164.all;

entity adder16B is
 port (A, B: in std_logic_vector (15 downto 0);
 Cin: in std_logic;
 Q: out std_logic_vector (15 downto 0);
 Cout: out std_logic);
end entity;

architecture main of adder16B is

    constant wide: integer := 16;

component fullAdder is
 port (
 A, B, Cin: in std_logic;
 Q, Cout: out std_logic
 );
end component; 

signal C: std_logic_vector(wide downto 0);

begin
adders: for N in 0 to wide-1 generate
 myadder: fulladder port map (
 A(N),B(N), C(N), Q(N), C(N+1)
 );
end generate;
C(0) <= Cin;
Cout <= C(wide);
end architecture;
