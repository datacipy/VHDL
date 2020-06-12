LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY delicka IS
    GENERIC (
        fmain : INTEGER := 50_000_000;
        fout : INTEGER := 440
    );
    PORT (
        clk : IN std_logic;
        sound : OUT std_logic
    );
END ENTITY;

ARCHITECTURE main OF delicka IS

    CONSTANT divider : INTEGER := fmain / fout / 2;

BEGIN
    PROCESS (clk) IS
        VARIABLE counter : INTEGER := 0;
        VARIABLE blik : std_logic := '0';
    BEGIN
        IF (rising_edge(clk)) THEN
            counter := counter + 1;
            IF (counter = divider) THEN
                counter := 0;
                blik := NOT blik;
            END IF;
        END IF;
        sound <= blik;
    END PROCESS;
END ARCHITECTURE;