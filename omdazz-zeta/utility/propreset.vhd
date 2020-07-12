--spravny reset

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY propreset IS
    GENERIC (
        delay1 : INTEGER := 5; --first reset
        delay2 : INTEGER := 10000); -- second reset
    PORT (
        clk : IN STD_LOGIC; --hodiny
        reset_n : IN STD_LOGIC; --tlacitko
        reset1 : OUT STD_LOGIC;
        reset2 : OUT STD_LOGIC); --vystup
END ENTITY;

ARCHITECTURE main OF propreset IS

BEGIN
    PROCESS (clk)
        VARIABLE resetDuration : INTEGER := delay1;
        VARIABLE cntr : INTEGER := delay2;
    BEGIN
        IF rising_edge(clk) THEN
            IF resetDuration = 0 THEN
                reset1 <= '0';
            ELSE
                resetDuration := resetDuration - 1;
                reset1 <= '1';
            END IF;

            IF cntr = 0 THEN
                reset2 <= '0';
            ELSE
                reset2 <= '1';
                cntr := cntr - 1;
            END IF;

            IF reset_n = '0' THEN
                resetDuration := delay1;
                cntr := delay2;
                reset1 <= '1';
                reset2 <= '1';
            END IF;

        END IF;
    END PROCESS;
END ARCHITECTURE;