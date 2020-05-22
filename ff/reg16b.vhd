LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY reg16B IS
  PORT (
    C, E : IN std_logic;
    D : IN std_logic_vector (15 DOWNTO 0);
    Q : OUT std_logic_vector (15 DOWNTO 0)
  );
END ENTITY;

ARCHITECTURE main OF reg16B IS
BEGIN
  PROCESS (C) IS
  BEGIN
    IF (rising_edge(C)) THEN
      IF (E = '1') THEN
        Q <= D;
      END IF;
    END IF;
  END PROCESS;

END ARCHITECTURE;