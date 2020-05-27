LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY debouncer IS
  GENERIC (
    stableTime : INTEGER := 10); -- pocet cyklu
  PORT (
    clk : IN STD_LOGIC; --input clock
    reset : IN STD_LOGIC; --asynchronous active low reset
    d : IN STD_LOGIC; --input signal to be debounced
    q : OUT STD_LOGIC); --debounced signal
END ENTITY;

ARCHITECTURE main OF debouncer IS
  SIGNAL delays : STD_LOGIC_VECTOR(1 DOWNTO 0); --input flip flops
  SIGNAL edge : STD_LOGIC; --sync reset to zero
BEGIN

  edge <= delays(0) XOR delays(1); --hrana

  PROCESS (clk, reset)
    VARIABLE count : INTEGER RANGE 0 TO stableTime; --counter for timing
  BEGIN
    IF (reset = '1') THEN
      delays(1 DOWNTO 0) <= "00";
      q <= '0';
    ELSIF (rising_edge(clk)) THEN
      delays(0) <= d;
      delays(1) <= delays(0);
      IF (edge = '1') THEN
        count := 0;
      ELSIF (count < stableTime) THEN
        count := count + 1;
      ELSE
        q <= delays(1);
      END IF;
    END IF;
  END PROCESS;

END ARCHITECTURE;