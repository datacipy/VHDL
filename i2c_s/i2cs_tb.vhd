LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE std.textio.ALL;

ENTITY i2cs_tb IS
END;

ARCHITECTURE bench OF i2cs_tb IS
  COMPONENT i2cs IS
    PORT (
      scl : IN std_logic;
      sda : INOUT std_logic;
      cStart, cStop : OUT std_logic);
  END COMPONENT;

  SIGNAL tscl, tsda : std_logic;
  SIGNAL tStart, tStop : STD_LOGIC;

BEGIN
  testing : PROCESS

    --type t_inp is 

    FILE test_stimul : text OPEN read_mode IS "i2cs_stim.txt";
    VARIABLE row : line;
    VARIABLE fscl, fsda : std_logic;

    --FILE test_log : text OPEN write_mode IS "adder4b_log.txt";
    --VARIABLE orow : line;
  BEGIN

    IF (NOT endfile(test_stimul)) THEN
      readline(test_stimul, row);
    ELSE
      WAIT;
    END IF;
    read(row, fscl);
    read(row, fsda);

    tscl <= fscl;
    tsda <= fsda;
    WAIT FOR 10 ns;
    --ASSERT (tCout & tQ) = result REPORT "failed" SEVERITY failure;
    --vypis;
  END PROCESS;

  UUT : i2cs PORT MAP(tscl, tsda, tStart, tStop);

END bench;