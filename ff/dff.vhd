library ieee;
use ieee.std_logic_1164.all;

entity dff is
    port (
        D, C: in std_logic;
        Q: out std_logic
    );
end entity;    

architecture main of dff is
begin


process (C) is
begin
  if (rising_edge(C)) then
    Q<=D;
  end if;
end process;

end architecture;