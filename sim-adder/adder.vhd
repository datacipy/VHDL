library ieee;
use ieee.std_logic_1164.all;

-- neúplná sčítačka

entity adder is
    port (
        A, B: in std_logic;
        Q, Cout: out std_logic
    );
end entity adder;    

architecture main of adder is
begin
   Q <= A xor B;
   Cout <= A and B;
end architecture;
