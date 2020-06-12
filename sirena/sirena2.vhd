LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY sirena2 IS
    GENERIC (
        fmain : INTEGER := 50_000_000;
        f1 : INTEGER := 5274;
        f2 : INTEGER := 7040;
        fslow : INTEGER := 1
    );
    PORT (
        clk : IN std_logic;
        sound : OUT std_logic
    );
END ENTITY;

ARCHITECTURE main OF sirena2 IS

    CONSTANT wide : INTEGER := 23;

    SIGNAL sel : std_logic := '0';
    SIGNAL div : unsigned (wide - 1 DOWNTO 0) := to_unsigned(1, wide);

BEGIN

    tone : ENTITY work.delicka2 GENERIC MAP (wide => wide) PORT MAP (clk => clk, sound => sound, div => div);
    lfo : ENTITY work.delicka GENERIC MAP (fmain => fmain, fout => fslow) PORT MAP (clk => clk, sound => sel);
    div <= to_unsigned(fmain/f1/2, wide) WHEN sel = '0' ELSE
        to_unsigned(fmain/f2/2, wide);

END ARCHITECTURE;