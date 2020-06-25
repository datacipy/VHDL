LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY reset IS
  PORT (
    clk : IN std_logic;
    resb : IN std_logic;
    reset : OUT std_logic
  );
END ENTITY;
ARCHITECTURE main OF reset IS

  SIGNAL doReset : std_logic := '1';
  CONSTANT divider : NATURAL := 50000;
BEGIN

  PROCESS (clk) IS
    VARIABLE counter : INTEGER := 0;
  BEGIN
    IF (rising_edge(clk)) THEN
      IF (doReset = '1') THEN
        counter := counter + 1;
        IF (counter = divider) THEN
          counter := 0;
          doReset <= '0';
        END IF;
      ELSE
        IF (resb = '0') THEN
          doReset <= '1';
        END IF;
      END IF;
    END IF;
  END PROCESS;

  reset <= doReset;

END ARCHITECTURE;