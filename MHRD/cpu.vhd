LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY cpu IS
    PORT (
        instr, data : IN std_logic_vector(15 DOWNTO 0);
        clock, reset : IN std_logic;
        instraddr, dataaddr, result : OUT std_logic_vector(15 DOWNTO 0);
        writes : OUT std_logic);
END cpu;

ARCHITECTURE main OF cpu IS

    SIGNAL alu_out : std_logic_vector(15 DOWNTO 0);
    SIGNAL alu_in1 : std_logic_vector(15 DOWNTO 0);
    SIGNAL alu_in2 : std_logic_vector(15 DOWNTO 0);
    SIGNAL mr, pc, ar : std_logic_vector(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mrout, arout : std_logic_vector(15 DOWNTO 0);
    SIGNAL mrmux : std_logic_vector(15 DOWNTO 0);
    SIGNAL ldpc, zero : std_logic;
    SIGNAL cToM, loadA, loadD, loadM, op1, jmpIfZ : std_logic;
    SIGNAL op2 : std_logic_vector(1 DOWNTO 0);
    SIGNAL OpCode : std_logic_vector(3 DOWNTO 0);
    SIGNAL const : std_logic_vector(14 DOWNTO 0);
    SIGNAL constse : std_logic_vector(15 DOWNTO 0);
BEGIN

    counter_0 : ENTITY work.counter16b PORT MAP(mr, ldpc, clock, reset, pc);
    decoder_0 : ENTITY work.decoder PORT MAP(instr, cToM, loadA, loadD, loadM, op1, jmpIfZ, op2, OpCode, const);

    constse(15 DOWNTO 4) <= "111111111111" WHEN const(4) = '1' ELSE
    "000000000000";
    constse(3 DOWNTO 0) <= const(3 DOWNTO 0);

    alu_in1 <= constse WHEN op1 = '1' ELSE
        arout;

    alu_in2 <= constse WHEN op2 = "00" ELSE
        arout WHEN op2 = "01" ELSE
        mr WHEN op2 = "10" ELSE
        data WHEN op2 = "11";

    alu_0 : ENTITY work.alu16b PORT MAP(alu_in1, alu_in2, OpCode, alu_out, zero);
    ldpc <= (zero AND jmpIfZ);

    mrmux <= alu_out WHEN cToM = '0' ELSE
        ('0' & const);
    mr <= mrmux WHEN loadM = '1' ELSE
        mr;
    ar <= alu_out WHEN loadA = '1' ELSE
        arout;

    reg_mr : ENTITY work.reg16br PORT MAP(clock, '1', reset, mr, mrout);
    reg_ar : ENTITY work.reg16br PORT MAP(clock, '1', reset, ar, arout);

    result <= alu_out;
    writes <= loadD;
    instraddr <= pc;
    dataaddr <= mrout;

END main;