LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY helloBlink IS
    PORT (
        clk : IN std_logic;
        led : OUT std_logic
    );
END ENTITY;

ARCHITECTURE cntr OF helloBlink IS

BEGIN
    PROCESS (clk) IS
        VARIABLE counter : INTEGER := 0;
        VARIABLE blik : std_logic := '0';
    BEGIN
        IF (rising_edge(clk)) THEN
            counter := counter + 1;
            IF (counter = 50000000) THEN
                counter := 0;
                blik := NOT blik;
            END IF;
        END IF;
        led <= blik;
    END PROCESS;
END ARCHITECTURE;