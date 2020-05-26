LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.bookUtility.ALL; -- for toString

ENTITY spimaster_tb IS
END;

ARCHITECTURE bench OF spimaster_tb IS
    SIGNAL tD, tQ : std_logic_vector (7 DOWNTO 0);
    SIGNAL cs, tReset, mosi, sclk, busy, cont : STD_LOGIC;
    SIGNAL tClk : STD_LOGIC := '0';
    SIGNAL miso : STD_LOGIC := '0';
    SIGNAL clockEnable : STD_LOGIC := '1';

BEGIN

    clock : PROCESS

    BEGIN
        WHILE clockEnable = '1' LOOP
            WAIT FOR 2 ns;
            tClk <= NOT tClk;
            --REPORT "Clock tick [" & std_logic'image(tClk) & "]";
        END LOOP;
        WAIT;
    END PROCESS;

    datain : PROCESS BEGIN
        WHILE clockEnable = '1' LOOP
            WAIT FOR 3 ns;
            miso <= NOT miso;
        END LOOP;
        WAIT;
    END PROCESS;

    testing : PROCESS

    BEGIN
        tReset <= '1';
        cont <= '1';
        cs <= '0';
        WAIT FOR 5 ns;
        tReset <= '0';
        WAIT FOR 5 ns;

        tD <= "10100011";
        cs <= '1';
        WAIT FOR 9 ns;
        tD <= "11110000";

        WAIT UNTIL busy = '0';

        WAIT FOR 9 ns;
        cont <= '0';
        cs <= '0';

        WAIT UNTIL busy = '0';

        -- end
        clockEnable <= '0';
        REPORT "Test OK";
        WAIT;

    END PROCESS;

    UUT : ENTITY work.spimaster GENERIC MAP (CLKDIV => 2, cpha => '0', cpol => '0') PORT MAP(tClk, tReset, cs, '0', tD, miso, sclk, mosi, busy, tQ);

END bench;