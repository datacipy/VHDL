LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY test IS
END;

ARCHITECTURE bench OF test IS

    COMPONENT adder
        PORT (
            A, B : IN std_logic;
            Q, Cout : OUT std_logic
        );
    END COMPONENT;

    SIGNAL tA, tB, tQ, tCout : STD_LOGIC;

BEGIN

    tA <= '0',
        '1' AFTER 30 NS,
        '0' AFTER 60 NS,
        '1' AFTER 90 NS;

    tB <= '0',
        '1' AFTER 60 NS;
    UUT : adder PORT MAP(tA, tB, tQ, tCout);

END bench;