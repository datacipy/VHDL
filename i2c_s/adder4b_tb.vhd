LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE std.textio.ALL;

ENTITY adder4b_tb IS
END;

ARCHITECTURE bench OF adder4b_tb IS
  COMPONENT adder4B IS
    PORT (
      A, B : IN std_logic_vector (3 DOWNTO 0);
      Cin : IN std_logic;
      Q : OUT std_logic_vector (3 DOWNTO 0);
      Cout : OUT std_logic);
  END COMPONENT;

  SIGNAL tA, tB, tQ : std_logic_vector (3 DOWNTO 0);
  SIGNAL tC, tCout : STD_LOGIC;

BEGIN
  testing : PROCESS

    --type t_inp is 

    FILE test_stimul : text OPEN read_mode IS "adder4b_stim.txt";
    VARIABLE row : line;
    VARIABLE inp1, inp2 : std_logic_vector (3 DOWNTO 0);
    VARIABLE result : std_logic_vector (4 DOWNTO 0);
    VARIABLE carryIn : std_logic;

    FILE test_log : text OPEN write_mode IS "adder4b_log.txt";
    VARIABLE orow : line;
  BEGIN

    IF (NOT endfile(test_stimul)) THEN
      readline(test_stimul, row);
    ELSE
      WAIT;
    END IF;
    read(row, inp1);
    read(row, inp2);
    read(row, carryIn);
    read(row, result);

    write(orow, inp1, left, 5);
    write(orow, inp2, left, 5);
    write(orow, carryIn, left, 2);
    write(orow, result, left, 6);
    tA <= inp1;
    tB <= inp2;
    tC <= carryIn;
    WAIT FOR 10 ns;
    --ASSERT (tCout & tQ) = result REPORT "failed" SEVERITY failure;
    write(orow, (tCout & tQ), left, 6);
    IF (tCout & tQ) = result THEN
      swrite(orow, "OK", left, 2);
    ELSE
      swrite(orow, "FAIL", left, 4);
    END IF;
    writeline(test_log, orow);
    --vypis;
  END PROCESS;

  UUT : adder4B PORT MAP(tA, tB, tC, tQ, tCout);

END bench;