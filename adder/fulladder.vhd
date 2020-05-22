library ieee;
use ieee.std_logic_1164.all;

entity fullAdder is
 port (
 A, B, Cin: in std_logic;
 Q, Cout: out std_logic
 );
end entity;




architecture trivial of fulladder is

component adder is
 port (
 A, B: in std_logic;
 Q, Cout: out std_logic
 );
end component;

signal Subtotal, C1, C2: std_logic;

begin
  ADDER1: adder port map (A, B, Subtotal, C1);
  ADDER2: adder port map (Cin, Subtotal, Q, C2);
  Cout <= C1 or C2;
end architecture;