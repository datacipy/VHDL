LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.bookUtility.ALL; -- for toString
USE std.textio.ALL;

ENTITY bcd_tb IS
END;

ARCHITECTURE bench OF bcd_tb IS

    SIGNAL tB : std_logic_vector (7 DOWNTO 0);
    SIGNAL tD : std_logic_vector (9 DOWNTO 0);

BEGIN
    testing : PROCESS

        PROCEDURE vypis IS
        BEGIN
            REPORT toString(tb) & " => " & toString(tD);
        END PROCEDURE;

    BEGIN
        tB <= "00000000";
        WAIT FOR 10 ns;
        vypis;

        tB <= "00001001";
        WAIT FOR 10 ns;
        vypis;
        tB <= "00001010";
        WAIT FOR 10 ns;
        vypis;

        tB <= "00001011";
        WAIT FOR 10 ns;
        vypis;

        tB <= "00001111";
        WAIT FOR 10 ns;
        vypis;

        tB <= x"14";
        WAIT FOR 10 ns;
        vypis;

        tB <= x"64";
        WAIT FOR 10 ns;
        vypis;
        --        tA <= '0'; tB <= '1'; wait for 10 ns; assert tQ = '1' and tCout = '0' report "0+1+0 failed"  severity failure;

        REPORT "Test OK";
        WAIT;
    END PROCESS;

    UUT : ENTITY work.bcd PORT MAP(tB, tD);

END bench;