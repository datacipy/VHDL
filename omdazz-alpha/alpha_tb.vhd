-- kontrola funkce pocitace

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY alpha_tb IS
END;

ARCHITECTURE bench OF alpha_tb IS
    SIGNAL tAciaClk : STD_LOGIC;
    SIGNAL tClk : STD_LOGIC := '0';
    --SIGNAL reset : STD_LOGIC := '0';
    SIGNAL clockEnable : STD_LOGIC := '1';
    SIGNAL RxD : STD_LOGIC := '1';
    SIGNAL TxD : STD_LOGIC;

BEGIN

    clock : PROCESS

    BEGIN
        WHILE clockEnable = '1' LOOP
            WAIT FOR 10 ns; --50 MHz
            tClk <= NOT tClk;
        END LOOP;
        WAIT;
    END PROCESS;
    UUT : ENTITY work.omdazzalpha PORT MAP(clk => tClk, uart_rxd => RxD, uart_txd => TxD, reset_b => '1',
        ckey1 => '1', ckey2 => '1', ckey3 => '1', ckey4 => '1', ir => '1');

END bench;