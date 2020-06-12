LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY sirena_tb IS
END ENTITY;

ARCHITECTURE bench OF sirena_tb IS

    SIGNAL tClk : std_logic := '0';
    SIGNAL sig : std_logic;

BEGIN

    clock : PROCESS BEGIN
        WAIT FOR 1 ns;
        tClk <= NOT tClk;
        --REPORT "Clock tick [" & std_logic'image(tClk) & "]";
    END PROCESS;

    timer : PROCESS BEGIN
        WAIT FOR 10 us;
        std.env.finish;
    END PROCESS;

    uut : ENTITY work.sirena GENERIC MAP (fmain => 50000, fslow => 100) PORT MAP (tClk, sig);

END ARCHITECTURE;