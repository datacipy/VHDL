LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY delicka_tb IS
END ENTITY;

ARCHITECTURE bench OF delicka_tb IS

    SIGNAL tClk : std_logic := '0';
    SIGNAL sig : std_logic;

BEGIN

    clock : PROCESS BEGIN
        WAIT FOR 10 ns;
        tClk <= NOT tClk;
        --REPORT "Clock tick [" & std_logic'image(tClk) & "]";
    END PROCESS;

    timer : PROCESS BEGIN
        WAIT FOR 10 us;
        std.env.finish;
    END PROCESS;

    uut : ENTITY work.delicka GENERIC MAP (fout => 440000) PORT MAP (tClk, sig);

END ARCHITECTURE;