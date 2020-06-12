LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY delicka2 IS
    GENERIC (wide : INTEGER := 23);
    PORT (
        clk : IN std_logic;
        sound : OUT std_logic;
        div : IN unsigned (wide - 1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE main OF delicka2 IS
    SIGNAL divider : unsigned (wide - 1 DOWNTO 0) := div;

BEGIN
    PROCESS (clk) IS
        VARIABLE counter : INTEGER := 0;
        VARIABLE blik : std_logic := '0';
    BEGIN
        IF (rising_edge(clk)) THEN
            counter := counter + 1;
            IF (to_unsigned(counter, wide) = divider) THEN
                counter := 0;
                blik := NOT blik;
                IF (blik = '0') THEN
                    divider <= div;
                END IF;
            END IF;
        END IF;
        sound <= blik;
    END PROCESS;
END ARCHITECTURE;