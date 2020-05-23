LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY decoder IS
    PORT (
        instr : IN std_logic_vector(15 DOWNTO 0);
        cToM, loadA, loadD, loadM, op1, jmpIfZ : OUT std_logic;
        op2 : OUT std_logic_vector(1 DOWNTO 0);
        OpCode : OUT std_logic_vector(3 DOWNTO 0);
        const : OUT std_logic_vector(14 DOWNTO 0));
END decoder;

ARCHITECTURE main OF decoder IS

    SIGNAL loads : std_logic_vector(2 DOWNTO 0);

BEGIN
    loads <= "000" WHEN instr(14 DOWNTO 13) = "00" ELSE
        "001" WHEN instr(14 DOWNTO 13) = "01" ELSE
        "010" WHEN instr(14 DOWNTO 13) = "10" ELSE
        "100" WHEN instr(14 DOWNTO 13) = "11";

    loadA <= '0' WHEN instr(15) = '1' ELSE
        loads(0);
    loadM <= '1' WHEN instr(15) = '1' ELSE
        loads(1);
    loadD <= '0' WHEN instr(15) = '1' ELSE
        loads(2);
    jmpIfZ <= '0' WHEN instr(15) = '1' ELSE
        instr(5);

    cToM <= instr(15);
    const <= instr(14 DOWNTO 0);
    op1 <= instr(12);
    op2 <= instr(11 DOWNTO 10);
    OpCode <= instr(9 DOWNTO 6);
END ARCHITECTURE;