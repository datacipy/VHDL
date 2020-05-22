LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY adder16B IS
    PORT (
        A, B : IN std_logic_vector (15 DOWNTO 0);
        Cin : IN std_logic;
        Q : OUT std_logic_vector (15 DOWNTO 0);
        Cout : OUT std_logic);
END ENTITY;

ARCHITECTURE main OF adder16B IS

    CONSTANT wide : INTEGER := 16;

    COMPONENT fullAdder IS
        PORT (
            A, B, Cin : IN std_logic;
            Q, Cout : OUT std_logic
        );
    END COMPONENT;

    SIGNAL C : std_logic_vector(wide DOWNTO 0);

BEGIN
    adders : FOR N IN 0 TO wide - 1 GENERATE
        myadder : fulladder PORT MAP(
            A(N), B(N), C(N), Q(N), C(N + 1)
        );
    END GENERATE;
    C(0) <= Cin;
    Cout <= C(wide);
END ARCHITECTURE;