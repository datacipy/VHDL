LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY freqdiv IS
    GENERIC (
        freqin : NATURAL := 50_000_000;
        freqout : NATURAL := 1000
    );
    PORT (
        clk : IN std_logic;
        clkout : OUT std_logic);
END ENTITY;

ARCHITECTURE main OF freqdiv IS

    SIGNAL clki : std_logic := '0'; --interni

    CONSTANT divider : NATURAL := freqin / freqout / 2;
BEGIN

    PROCESS (clk) IS
        VARIABLE counter : INTEGER := 0;
    BEGIN
        IF (rising_edge(clk)) THEN
            counter := counter + 1;
            IF (counter = divider) THEN
                counter := 0;
                clki <= NOT clki;
            END IF;
        END IF;
    END PROCESS;

    clkout <= clki;

END ARCHITECTURE;