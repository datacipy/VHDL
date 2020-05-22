LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- reg16b with RESET

ENTITY reg16BR IS
  PORT (
    C, E, RESET : IN std_logic;
    D : IN std_logic_vector (15 DOWNTO 0);
    Q : OUT std_logic_vector (15 DOWNTO 0)
  );
END ENTITY;

ARCHITECTURE main OF reg16BR IS
BEGIN
  PROCESS (C) IS
  BEGIN
    IF (RESET = '1') THEN
      q <= (OTHERS => '0');
    ELSIF (rising_edge(C)) THEN
      IF (E = '1') THEN
        Q <= D;
      END IF;
    END IF;
  END PROCESS;

END ARCHITECTURE;