library ieee;
use ieee.std_logic_1164.all;

entity reg8B is
    port (
        C, E: in std_logic;
        D: in std_logic_vector (7 downto 0);
        Q: out std_logic_vector (7 downto 0)
    );
end entity;    

architecture main of reg8B is
begin


process (C) is
begin
  if (rising_edge(C)) then
    if (E = '1') then
      Q <= D;
    end if;
  end if;
end process;

end architecture;