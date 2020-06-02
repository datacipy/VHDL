LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY resolved_tb IS
END;

ARCHITECTURE bench OF resolved_tb IS

    SIGNAL tA, tB : STD_ULOGIC;
    SIGNAL tQ : std_logic;

BEGIN
    testing : PROCESS

        PROCEDURE vypis IS
        BEGIN
            REPORT std_ulogic'image(tA) & " + " & std_ulogic'image(tB) &
                " = " & std_ulogic'image(tQ);
        END PROCEDURE;

    BEGIN
        tA <= '0';
        tB <= '0';
        WAIT FOR 10 ns;
        vypis;
        tA <= '0';
        tB <= '1';
        WAIT FOR 10 ns;
        vypis;
        tA <= '1';
        tB <= '0';
        WAIT FOR 10 ns;
        vypis;
        tA <= '1';
        tB <= '1';
        WAIT FOR 10 ns;
        vypis;

        tA <= 'H';
        tB <= '0';
        WAIT FOR 10 ns;
        vypis;
        tA <= 'H';
        tB <= '1';
        WAIT FOR 10 ns;
        vypis;
        tA <= 'H';
        tB <= 'L';
        WAIT FOR 10 ns;
        vypis;
        tA <= 'H';
        tB <= 'H';
        WAIT FOR 10 ns;
        vypis;

        REPORT "Test OK";
        WAIT;
    END PROCESS;

    UUT : ENTITY work.resolved PORT MAP(tA, tB, tQ);

END bench;