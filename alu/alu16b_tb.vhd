LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.bookUtility.ALL; -- for toString

ENTITY alu16B_tb IS
END;

ARCHITECTURE bench OF alu16B_tb IS
  SIGNAL tA, tB, tQ : std_logic_vector (15 DOWNTO 0);
  SIGNAL opcode : std_logic_vector(3 DOWNTO 0);
  SIGNAL tZ, tN : STD_LOGIC;

BEGIN
  testing : PROCESS

    PROCEDURE vypis IS
    BEGIN
      REPORT toString(tA) & " + " & toString(tB) & ", op:" & toString(opcode) &
        " = " & toString(tQ);
    END PROCEDURE;

  BEGIN
    tA <= "0000000000000000";
    tB <= "0000000000000000";
    opcode <= "0000";
    WAIT FOR 10 ns;
    vypis;
    ASSERT tQ = "0000000000000000" REPORT "0+0+0 failed" SEVERITY failure;
    tA <= "0000000000000001";
    tB <= "0000000000000000";
    WAIT FOR 10 ns;
    vypis;
    ASSERT tQ = "0000000000000001" REPORT "1+0+0 failed" SEVERITY failure;
    tA <= "1111111111111111";
    tB <= "0000000000000000";
    WAIT FOR 10 ns;
    vypis;
    ASSERT tQ = "1111111111111111" REPORT "15+0+0 failed" SEVERITY failure;
    tA <= "1111111111111111";
    tB <= "0000000000000001";
    WAIT FOR 10 ns;
    vypis;
    ASSERT tQ = "0000000000000000" REPORT "15+1+0 failed" SEVERITY failure;

    tA <= "0000000000000000";
    tB <= "0000000000000000";
    WAIT FOR 10 ns;
    vypis;
    ASSERT tQ = "0000000000000001" REPORT "0+0+1 failed" SEVERITY failure;
    tA <= "0000000000000001";
    tB <= "0000000000000000";
    WAIT FOR 10 ns;
    vypis;
    ASSERT tQ = "0000000000000010" REPORT "1+0+1 failed" SEVERITY failure;
    tA <= "1111111111111111";
    tB <= "0000000000000000";
    WAIT FOR 10 ns;
    vypis;
    ASSERT tQ = "0000000000000000" REPORT "15+0+1 failed" SEVERITY failure;
    tA <= "1111111111111111";
    tB <= "0000000000000001";
    WAIT FOR 10 ns;
    vypis;
    ASSERT tQ = "0000000000000001" REPORT "15+1+1 failed" SEVERITY failure;
    REPORT "Test OK";
    WAIT;
  END PROCESS;

  UUT : ENTITY work.alu16B PORT MAP (tA, tB, opcode, tQ, tZ, tN);

END bench;