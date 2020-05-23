-- OMEN ALPHA

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY alpha IS
    PORT (
        clk : IN std_logic;
        --reset : IN std_logic;
        RxD : IN std_logic; -- Receive Data
        TxD : OUT std_logic -- Transmit Data
    );
END;

ARCHITECTURE main OF alpha IS
    SIGNAL wr : std_logic;
    SIGNAL rd : std_logic;
    SIGNAL iom : std_logic;
    SIGNAL cpuAddress : std_logic_vector(15 DOWNTO 0);
    SIGNAL cpuDataOut : std_logic_vector(7 DOWNTO 0);
    SIGNAL cpuDataIn : std_logic_vector(7 DOWNTO 0);

    SIGNAL cpuClock : std_logic;
    SIGNAL reset : std_logic := '1';
    SIGNAL memwr, memrd : std_logic;
    SIGNAL iowr, iord : std_logic;
    SIGNAL ramwr : std_logic;
    SIGNAL ramcs, romcs : std_logic;
    SIGNAL uartcs : std_logic;
    SIGNAL uartwr : std_logic;
    SIGNAL romDataOut : std_logic_vector(7 DOWNTO 0);

    SIGNAL ramDataOut : std_logic_vector(7 DOWNTO 0);

    SIGNAL uartDataOut : std_logic_vector(7 DOWNTO 0);
    SIGNAL uartClock : std_logic;

    SIGNAL cpuClkCount : unsigned(5 DOWNTO 0);

BEGIN

    -- cpu
    cpu : ENTITY work.light8080 PORT MAP (
        rd => rd, wr => wr,
        clk => cpuClock,
        data_out => cpuDataOut,
        data_in => cpuDataIn,
        addr_out => cpuAddress,
        io => iom,
        intr => '0', --bez preruseni
        reset => reset
        );
    cpuClk : ENTITY work.aciaClock GENERIC MAP (4, 1) PORT MAP(clk, cpuClock);
    --cpuClock <= clk;

    -- bus signals
    memrd <= rd AND NOT iom;
    memwr <= wr AND NOT iom;
    iord <= rd AND iom;
    iowr <= wr AND iom;

    -- ROM
    rom : ENTITY work.rom4k PORT MAP (
        address => cpuAddress(11 DOWNTO 0),
        clock => clk,
        q => romDataOut
        );

    -- RAM
    ram : ENTITY work.ram4k PORT MAP (
        address => cpuAddress(11 DOWNTO 0),
        clock => clk,
        data => cpuDataOut,
        wren => ramwr,
        q => ramDataOut
        );

    -- UART
    uart : ENTITY work.acia6850 PORT MAP (
        clk => cpuClock,
        rst => reset,
        cs => uartcs,
        addr => cpuAddress(0),
        rw => uartwr,
        data_in => cpuDataOut,
        data_out => uartDataOut,
        RxC => uartClock,
        TxC => uartClock,
        RxD => RxD,
        TxD => TxD,
        DCD_n => '0',
        CTS_n => '0'
        );
    -- baud 
    baud : ENTITY work.aciaClock GENERIC MAP (50_000_000, 5_000_000) PORT MAP(clk, uartClock);

    -- dekodery
    ramcs <= '1' WHEN cpuAddress(15 DOWNTO 12) = "1111" ELSE
        '0';
    romcs <= '1' WHEN cpuAddress(15 DOWNTO 12) = "0000" ELSE
        '0';
    uartcs <= '1' WHEN cpuAddress(7 DOWNTO 1) = "1101111" ELSE
        '0';

    ramwr <= memwr AND ramcs;
    uartwr <= NOT (iowr AND uartcs);

--    cpuDataIn <= romDataOut when (romcs and memrd)
--else ramDataOut when (ramcs and memrd)
--else uartDataOut when (uartcs and iord)
--else x"00";

    
    PROCESS (cpuClock)
    BEGIN
        IF rising_edge(cpuClock) THEN
            -- sbernice    
            IF (romcs = '1' AND memrd = '1') THEN
                cpuDataIn <= romDataOut;
            ELSIF (ramcs = '1' AND memrd = '1') THEN
                cpuDataIn <= ramDataOut;
            ELSIF (uartcs = '1' AND iord = '1') THEN
                cpuDataIn <= uartDataOut;
            ELSE
                cpuDataIn <= x"00";
            END IF;

        END IF;
    END PROCESS;
    

    PROCESS (cpuClock)
        VARIABLE resetDuration : INTEGER := 5;
    BEGIN
        IF rising_edge(cpuClock) THEN
            IF resetDuration = 0 THEN
                reset <= '0';
            ELSE
                resetDuration := resetDuration - 1;
                reset <= '1';
            END IF;
        END IF;
    END PROCESS;
END main;