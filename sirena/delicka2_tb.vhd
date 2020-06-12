LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY delicka2_tb IS
END ENTITY;

ARCHITECTURE bench OF delicka2_tb IS

    SIGNAL tClk : std_logic := '0';
    SIGNAL sig : std_logic;
    SIGNAL div : unsigned (22 DOWNTO 0) := to_unsigned(10, 23);

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

    uut : ENTITY work.delicka2 PORT MAP (tClk, sig, div);

END ARCHITECTURE;