LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.bookUtility.ALL; -- for toString

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

    PROCEDURE vypis IS
    BEGIN
      REPORT toString(tA) & " + " & toString(tB) & " + " & std_logic'image(tC) &
        " = " & std_logic'image(tCout) & toString(tQ);
    END PROCEDURE;

  BEGIN
    tC <= '0';
    tA <= "0000";
    tB <= "0000";
    WAIT FOR 10 ns;
    vypis;
    ASSERT tCout = '0' AND tQ = "0000" REPORT "0+0+0 failed" SEVERITY failure;
    tA <= "0001";
    tB <= "0000";
    WAIT FOR 10 ns;
    vypis;
    ASSERT tCout = '0' AND tQ = "0001" REPORT "1+0+0 failed" SEVERITY failure;
    tA <= "1111";
    tB <= "0000";
    WAIT FOR 10 ns;
    vypis;
    ASSERT tCout = '0' AND tQ = "1111" REPORT "15+0+0 failed" SEVERITY failure;
    tA <= "1111";
    tB <= "0001";
    WAIT FOR 10 ns;
    vypis;
    ASSERT tCout = '1' AND tQ = "0000" REPORT "15+1+0 failed" SEVERITY failure;

    tC <= '1';
    tA <= "0000";
    tB <= "0000";
    WAIT FOR 10 ns;
    vypis;
    ASSERT tCout = '0' AND tQ = "0001" REPORT "0+0+1 failed" SEVERITY failure;
    tA <= "0001";
    tB <= "0000";
    WAIT FOR 10 ns;
    vypis;
    ASSERT tCout = '0' AND tQ = "0010" REPORT "1+0+1 failed" SEVERITY failure;
    tA <= "1111";
    tB <= "0000";
    WAIT FOR 10 ns;
    vypis;
    ASSERT tCout = '1' AND tQ = "0000" REPORT "15+0+1 failed" SEVERITY failure;
    tA <= "1111";
    tB <= "0001";
    WAIT FOR 10 ns;
    vypis;
    ASSERT tCout = '1' AND tQ = "0001" REPORT "15+1+1 failed" SEVERITY failure;
    REPORT "Test OK";
    WAIT;
  END PROCESS;

  UUT : adder4B PORT MAP(tA, tB, tC, tQ, tCout);

END bench;