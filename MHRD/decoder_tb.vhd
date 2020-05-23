LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY decoder_tb IS
END decoder_tb;

ARCHITECTURE bench OF decoder_tb IS

    SIGNAL instr : std_logic_vector(15 DOWNTO 0);
    SIGNAL cToM, loadA, loadD, loadM, op1, jmpIfZ : std_logic;
    SIGNAL op2 : std_logic_vector(1 DOWNTO 0);
    SIGNAL OpCode : std_logic_vector(3 DOWNTO 0);
    SIGNAL const : std_logic_vector(14 DOWNTO 0);

BEGIN

    uut : ENTITY work.decoder PORT MAP (instr, cToM, loadA, loadD, loadM, op1, jmpIfZ, op2, OpCode, const);

    PROCESS
        TYPE pattern_type IS RECORD
            instr : std_logic_vector(15 DOWNTO 0);
            cToM, loadA, loadD, loadM, op1, jmpIfZ : std_logic;
            op2 : std_logic_vector(1 DOWNTO 0);
            OpCode : std_logic_vector(3 DOWNTO 0);
            const : std_logic_vector(15 DOWNTO 0);
        END RECORD;

        TYPE pattern_array IS ARRAY (NATURAL RANGE <>) OF pattern_type;
        CONSTANT patterns : pattern_array :=
        ((x"0000", '0', '0', '0', '0', '0', '0', "00", "0000", x"0000"),
        (x"8000", '1', '0', '0', '1', '0', '0', "00", "0000", x"0000"),
        (x"FFFF", '1', '0', '0', '1', '1', '0', "11", "1111", x"7FFF"),
        (x"7FFF", '0', '0', '1', '0', '1', '1', "11", "1111", x"7FFF"),
        (x"7C1F", '0', '0', '1', '0', '1', '0', "11", "0000", x"7C1F"),
        (x"7C0F", '0', '0', '1', '0', '1', '0', "11", "0000", x"7C0F"));

    BEGIN

        FOR i IN patterns'RANGE LOOP

            instr <= patterns(i).instr;

            WAIT FOR 1 ns;

            ASSERT cToM = patterns(i).cToM
            REPORT "Bad cToM" SEVERITY error;
            ASSERT loadA = patterns(i).loadA
            REPORT "Bad LoadA" SEVERITY error;
            ASSERT loadD = patterns(i).loadD
            REPORT "Bad LoadD" SEVERITY error;
            ASSERT loadM = patterns(i).loadM
            REPORT "Bad LoadM" SEVERITY error;
            ASSERT op1 = patterns(i).op1
            REPORT "Bad op1" SEVERITY error;
            ASSERT jmpIfZ = patterns(i).jmpIfZ
            REPORT "Bad jump if zero" SEVERITY error;
            ASSERT op2 = patterns(i).op2
            REPORT "Bad op2" SEVERITY error;
            ASSERT OpCode = patterns(i).OpCode
            REPORT "Bad opcode" SEVERITY error;
            ASSERT const = patterns(i).const(14 DOWNTO 0)
            REPORT "Bad const" SEVERITY error;
        END LOOP;
        ASSERT false REPORT "end of test" SEVERITY note;
        WAIT;
    END PROCESS;
END bench;