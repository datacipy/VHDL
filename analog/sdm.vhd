LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY SDM IS
    PORT (
        Q : OUT std_logic;
        D : IN unsigned(3 DOWNTO 0);
        Clk : IN std_logic
    );
END ENTITY;

ARCHITECTURE main OF SDM IS
    SIGNAL accumulator : unsigned (4 DOWNTO 0) := (OTHERS => '0');
BEGIN
    PROCESS (Clk, D) IS
    BEGIN
        IF (rising_edge(Clk)) THEN
            accumulator <= ('0' & accumulator(3 DOWNTO 0)) + ('0' & D);
        END IF;
    END PROCESS;
    Q <= accumulator(4);
END ARCHITECTURE;