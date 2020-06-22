LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.bookUtility.ALL; -- for toString

ENTITY pwm_tb IS
END;

ARCHITECTURE bench OF pwm_tb IS
    SIGNAL tQ : std_logic;
    SIGNAL tClk : STD_LOGIC := '0';
    SIGNAL tD : unsigned(3 DOWNTO 0);
    SIGNAL clockEnable : STD_LOGIC := '1';
BEGIN

    clock : PROCESS

    BEGIN
        WHILE clockEnable = '1' LOOP
            WAIT FOR 2 ns;
            tClk <= NOT tClk;
        END LOOP;
        WAIT;
    END PROCESS;

    testing : PROCESS

    BEGIN
        tD <= x"1";
        WAIT FOR 100 ns;
        tD <= x"7";
        WAIT FOR 100 ns;

        tD <= x"F";
        WAIT FOR 100 ns;

        -- end
        clockEnable <= '0';
        REPORT "Test OK";
        WAIT;

    END PROCESS;

    UUT : ENTITY work.pwm PORT MAP(tQ, tD, tClk);

END bench;