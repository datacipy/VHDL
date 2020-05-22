library ieee;
use ieee.std_logic_1164.all;


entity adder is
    port (
        A, B: in std_logic;
        Q, Cout: out std_logic
    );
end entity;    

architecture main of adder is
begin
   Q <= A xor B;
   Cout <= A and B;
end architecture;
