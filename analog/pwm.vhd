LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY PWM IS
    PORT (
        Q : OUT std_logic := '0';
        D : IN unsigned(3 DOWNTO 0);
        Clk : IN std_logic
    );
END ENTITY;

ARCHITECTURE main OF PWM IS
    SIGNAL cnt : unsigned(3 DOWNTO 0) := (OTHERS => '0');
BEGIN
    PROCESS (Clk) IS

    BEGIN
        IF (rising_edge(Clk)) THEN
            cnt <= cnt + 1;
        END IF;
    END PROCESS;

    Q <= '1' WHEN D > cnt ELSE
        '0';
END ARCHITECTURE;