-- kontrola děliče frekvence

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY aciaclock_tb IS
END;

ARCHITECTURE bench OF aciaclock_tb IS
    SIGNAL tAciaClk : STD_LOGIC;
    SIGNAL tClk : STD_LOGIC := '0';
    SIGNAL clockEnable : STD_LOGIC := '1';

BEGIN

    clock : PROCESS

    BEGIN
        WHILE clockEnable = '1' LOOP
            WAIT FOR 10 ns; --50 MHz
            tClk <= NOT tClk;
        END LOOP;
        WAIT;
    END PROCESS;

    testing : PROCESS
    BEGIN
        WAIT FOR 20 ms; --count up
        -- end
        clockEnable <= '0';
        REPORT "Test OK";
        WAIT;

    END PROCESS;

    UUT : ENTITY work.aciaClock GENERIC MAP (50_000_000, 115_200) PORT MAP(tClk, tAciaClk);

END bench;