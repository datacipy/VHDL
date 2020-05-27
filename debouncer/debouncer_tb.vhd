LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.bookUtility.ALL; -- for toString

ENTITY debouncer_tb IS
END;

ARCHITECTURE bench OF debouncer_tb IS
  SIGNAL tD, tQ : std_logic;
  SIGNAL tReset : STD_LOGIC;
  SIGNAL tClk : STD_LOGIC := '0';
  SIGNAL clockEnable : STD_LOGIC := '1';

BEGIN

  clock : PROCESS

  BEGIN
    WHILE clockEnable = '1' LOOP
      WAIT FOR 3 ps;
      tClk <= NOT tClk;
      -- REPORT "Clock tick [" & std_logic'image(tClk) & "]";
    END LOOP;
    WAIT;
  END PROCESS;

  testing : PROCESS

  BEGIN
    tReset <= '1';
    tD <= '0';
    WAIT FOR 1 ns;
    tReset <= '0';
    WAIT FOR 1 ns;

    tD<='1'; wait for 10 ps;
    tD<='0'; wait for 10 ps;
    tD<='1'; wait for 10 ps;
    tD<='0'; wait for 10 ps;
    tD<='1'; 
    wait for 10 ns;

    tD<='0'; wait for 10 ps;
    tD<='1'; wait for 10 ps;
    tD<='0'; wait for 10 ps;
    tD<='1'; wait for 10 ps;
    tD<='0'; 
    wait for 10 ns;


    tD<='1'; wait for 10 ps;
    tD<='0'; wait for 10 ps;
    tD<='1'; wait for 10 ps;
    tD<='0'; wait for 10 ps;
    tD<='1'; 
    wait for 14 ns;

    tD<='0'; wait for 10 ps;
    tD<='1'; wait for 10 ps;
    tD<='0'; wait for 10 ps;
    tD<='1'; wait for 10 ps;
    tD<='0'; 
    wait for 5 ns;

    -- end
    clockEnable <= '0';
    REPORT "Test OK";
    WAIT;

  END PROCESS;

  UUT : ENTITY work.debouncer PORT MAP(tClk, tReset, tD, tQ);

END bench;