LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY sirena IS
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

ARCHITECTURE main OF sirena IS

    SIGNAL s1, s2 : std_logic;
    SIGNAL sel : std_logic := '0';
    SIGNAL lfoSel, reset : std_logic;

BEGIN

    tone1 : ENTITY work.delicka GENERIC MAP (fmain => fmain, fout => f1) PORT MAP (clk => clk, sound => s1);
    tone2 : ENTITY work.delicka GENERIC MAP (fmain => fmain, fout => f2) PORT MAP (clk => clk, sound => s2);
    lfo : ENTITY work.delicka GENERIC MAP (fmain => fmain, fout => fslow) PORT MAP (clk => clk, sound => lfoSel);

    PROCESS (sound) IS
    BEGIN
        IF (falling_edge(sound)) THEN
            sel <= lfoSel;
        ELSE
            sel <= sel; --neni nutne
        END IF;
        IF (sel /= lfoSel) THEN
            reset <= '1';
        ELSE
            reset <= '0';
        END IF;

    END PROCESS;

    sound <= s1 WHEN sel = '0' ELSE
        s2;

END ARCHITECTURE;