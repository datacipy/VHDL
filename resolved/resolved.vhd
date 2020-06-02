LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY resolved IS
    PORT (
        A, B : IN std_ulogic;
        Q : OUT std_logic
    );
END ENTITY;

ARCHITECTURE main OF resolved IS
BEGIN
    Q <= A;
    Q <= B;
END ARCHITECTURE;