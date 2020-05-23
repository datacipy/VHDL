LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.bookUtility.ALL; -- for toString

ENTITY cpu_tb IS
END cpu_tb;

ARCHITECTURE bench OF cpu_tb IS

    SIGNAL instr, data : std_logic_vector(15 DOWNTO 0);
    SIGNAL clock, reset : std_logic;
    SIGNAL instraddr, dataaddr, result : std_logic_vector(15 DOWNTO 0);
    SIGNAL writes : std_logic;

BEGIN

    uut : ENTITY work.cpu PORT MAP(instr, data, clock, reset, instraddr, dataaddr, result, writes);

    PROCESS

        -- struktura testovacich vzorku
        TYPE pattern_type IS RECORD
            instr, data : std_logic_vector(15 DOWNTO 0);
            reset : std_logic;
            instraddr, dataaddr, result : std_logic_vector(15 DOWNTO 0);
            writes : std_logic;
        END RECORD;

        --  Vzorky
        TYPE pattern_array IS ARRAY (NATURAL RANGE <>) OF pattern_type;
        CONSTANT patterns : pattern_array :=
        ((x"8000", x"0000", '1', x"0000", x"0000", x"0000", '0'),
        (x"0000", x"0000", '0', x"0001", x"0000", x"0000", '0'),
        (x"0000", x"0000", '0', x"0002", x"0000", x"0000", '0'),
        (x"80FF", x"0000", '1', x"0000", x"0000", x"0000", '0'),
        (x"3C01", x"0000", '0', x"0001", x"00FF", x"0001", '0'),
        (x"0000", x"0000", '0', x"0002", x"00FF", x"0001", '0'),
        (x"4000", x"0000", '0', x"0003", x"00FF", x"0001", '0'),
        (x"7800", x"0000", '0', x"0004", x"0001", x"0001", '1'),
        (x"1020", x"0001", '0', x"0005", x"0001", x"0000", '0'),
        (x"1000", x"0001", '0', x"0001", x"0001", x"0000", '0'),
        (x"1000", x"0001", '0', x"0002", x"0001", x"0000", '0'));
    BEGIN

        clock <= '0';

        --  Testování vzorků
        FOR i IN patterns'RANGE LOOP
            --  nastavit vstupy
            WAIT FOR 1 ns;
            clock <= '1';

            instr <= patterns(i).instr;
            data <= patterns(i).data;
            reset <= patterns(i).reset;
            --  ustaleni vystupu

            WAIT FOR 1 ns;
            clock <= '0';

            REPORT "IA:" & toString(instraddr) &
                ", DA:" & toString(dataaddr) &
                ", Result:" & toString(result) &
                ", writes:" & std_logic'image(writes);

            --  kontrola
            ASSERT instraddr = patterns(i).instraddr
            REPORT "bad instraddr value" SEVERITY error;
            ASSERT dataaddr = patterns(i).dataaddr
            REPORT "bad dataaddr out value" SEVERITY error;
            ASSERT result = patterns(i).result
            REPORT "bad result out value" SEVERITY error;
            ASSERT writes = patterns(i).writes
            REPORT "bad writes out value" SEVERITY error;
        END LOOP;
        ASSERT false REPORT "end of test" SEVERITY note;
        --  konec
        WAIT;
    END PROCESS;
END bench;