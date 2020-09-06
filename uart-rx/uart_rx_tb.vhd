LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY uart_rx_tb IS
END ENTITY;

ARCHITECTURE bench OF uart_rx_tb IS
    SIGNAL clk : std_logic := '0';
    SIGNAL rst, tx, send, ready : std_logic;
    SIGNAL rxdata, data : std_logic_vector(7 DOWNTO 0);
    SIGNAL rxready : std_logic;
BEGIN

    data <= x"55", x"aa" AFTER 7 us;

    uut : ENTITY work.uart_tx GENERIC MAP (fBAUD => 1000000) PORT MAP (clk, rst, tx, send, ready, data);
    rec : ENTITY work.uart_rx GENERIC MAP (fBAUD => 1000000) PORT MAP (clk, rst, tx, rxready, rxdata);

    main_clock_generation : PROCESS
    BEGIN
        WAIT FOR 10 ns;
        clk <= NOT clk;
    END PROCESS;

    rst <= '1', '0' AFTER 100 ns;
    --rst    <=    '0'; 

    send <= '0', '1' AFTER 200 ns, '0' AFTER 1 us, '1' AFTER 7 us, '0' AFTER 15 us;
END ARCHITECTURE;