LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.bookUtility.ALL; -- for toString

ENTITY counter4B_tb IS
END;

ARCHITECTURE bench OF counter4B_tb IS
  SIGNAL tD, tQ : std_logic_vector (3 DOWNTO 0);
  SIGNAL tLoad, tReset : STD_LOGIC;
  SIGNAL tClk : STD_LOGIC := '0';
  SIGNAL clockEnable : STD_LOGIC := '1';

BEGIN

  clock : PROCESS

  BEGIN
    WHILE clockEnable = '1' LOOP
      WAIT FOR 5 ns;
      tClk <= NOT tClk;
      REPORT "Clock tick [" & std_logic'image(tClk) & "]";
    END LOOP;
    WAIT;
  END PROCESS;

  testing : PROCESS

    PROCEDURE vypis IS
    BEGIN
      REPORT toString(tD) &
        " => " & toString(tQ);
    END PROCEDURE;

  BEGIN
    tReset <= '1';
    tLoad <= '0';
    tD <= "1110";
    WAIT FOR 1 ns;
    tReset <= '0';
    WAIT FOR 1 ns;
    vypis;

    ASSERT tQ = "0000" REPORT "reset failed" SEVERITY failure;

    WAIT FOR 10 ns; --count up
    vypis;
    ASSERT tQ = "0001" REPORT "count 0001" SEVERITY failure;

    WAIT FOR 10 ns; --count up
    vypis;
    ASSERT tQ = "0010" REPORT "count 0001" SEVERITY failure;

    tLoad <= '1';
    WAIT FOR 10 ns; --wait for clock
    tLoad <= '0';
    vypis;
    ASSERT tQ = "1110" REPORT "count 0001" SEVERITY failure;
    WAIT FOR 10 ns; --count up
    vypis;
    ASSERT tQ = "1111" REPORT "count 0001" SEVERITY failure;

    WAIT FOR 10 ns; --count up
    vypis;
    ASSERT tQ = "0000" REPORT "count 0001" SEVERITY failure;

    -- end
    clockEnable <= '0';
    REPORT "Test OK";
    WAIT;

  END PROCESS;

  UUT : ENTITY work.counter4B PORT MAP(tD, tLoad, tClk, tReset, tQ);

END bench;