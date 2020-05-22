LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY alu16b IS
    PORT (
        in1, in2 : IN std_logic_vector(15 DOWNTO 0);
        opcode : IN std_logic_vector(3 DOWNTO 0);
        y : OUT std_logic_vector(15 DOWNTO 0);
        zero, negative : OUT std_logic);
END alu16b;

ARCHITECTURE main OF alu16b IS
    --FOR adder16b_0 : adder16b USE ENTITY work.adder16b;
    --FOR mux16b_0 : mux16b USE ENTITY work.mux16b;

    SIGNAL in1_work : std_logic_vector(15 DOWNTO 0);
    SIGNAL in2_work : std_logic_vector(15 DOWNTO 0);
    SIGNAL out_work : std_logic_vector(15 DOWNTO 0);
    SIGNAL nandout : std_logic_vector(15 DOWNTO 0);
    SIGNAL addout : std_logic_vector(15 DOWNTO 0);
    SIGNAL out_mux : std_logic_vector(15 DOWNTO 0);

BEGIN

    in1_work <= (in1 XOR x"0000") WHEN opcode(3) = '0' ELSE
        (in1 XOR x"FFFF");
    in2_work <= (in2 XOR x"0000") WHEN opcode(2) = '0' ELSE
        (in2 XOR x"FFFF");

    -- Vypocet obou mezivýsledků
    nandout <= in1_work NAND in2_work;
    adder16b_0 : ENTITY work.adder16b PORT MAP(in1_work, in2_work, '0', addout, OPEN);

    -- Výber mezivýsledku
    mux16b_0 : ENTITY work.mux16b PORT MAP(opcode(1), nandout, addout, out_mux);

    -- Negace výstupu? 
    out_work <= (out_mux XOR x"0000") WHEN opcode(0) = '0' ELSE
        (out_mux XOR x"FFFF");

    -- Výsledkové príznaky
    negative <= out_work(15);
    zero <= '1' WHEN out_work = x"0000" ELSE
        '0';

    y <= out_work;
END main;