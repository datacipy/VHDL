LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mko IS
    GENERIC (
        delay : INTEGER := 10000); -- pocet cyklu
    PORT (
        clk : IN STD_LOGIC; --hodiny
        trig : IN STD_LOGIC; --trigger
        q : OUT STD_LOGIC); --vystup
END ENTITY;

ARCHITECTURE main OF mko IS

BEGIN
    PROCESS (clk)
        VARIABLE cntr : INTEGER := delay;
    BEGIN
        IF (rising_edge(clk)) THEN
            IF trig = '1' THEN
                cntr := delay;
                q <= '1';
            ELSIF cntr = 0 THEN
                q <= '0';
            ELSE
                q <= '1';
                cntr := cntr - 1;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;