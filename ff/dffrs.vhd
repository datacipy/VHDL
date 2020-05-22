library ieee;
use ieee.std_logic_1164.all;

entity dffRS is
    port (
        D, C: in std_logic;
        R, S: in std_logic;
        Q: out std_logic
    );
end entity;    

architecture main of dffRS is
begin


process (C, R, S) is
begin
  if (R = '1') then
    Q <= '0';
  elsif (S = '1') then
    Q <= '1';
  elsif (rising_edge(C)) then
    Q <= D;
  end if;
end process;


end architecture;