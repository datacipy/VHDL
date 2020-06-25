-- OMEN ALPHA

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY omdazzalpha IS
    PORT (
        clk : IN std_logic; --23
        reset_b : IN std_logic; --25

        --LED
        led1 : OUT std_logic := '1'; --87
        led2 : OUT std_logic := '1'; --86
        led3 : OUT std_logic := '1'; --85
        led4 : OUT std_logic := '1'; --84

        --displej LED
        --dig = pozice, 0=aktivni
        segA : OUT std_logic; --128
        segB : OUT std_logic; --121
        segC : OUT std_logic; --125
        segD : OUT std_logic; --129
        segE : OUT std_logic; --132
        segF : OUT std_logic; --126
        segG : OUT std_logic; --124
        segH : OUT std_logic; --127
        --dig1 je vpravo, dig4 vlevo
        dig1 : OUT std_logic; --133
        dig2 : OUT std_logic; --135
        dig3 : OUT std_logic; --136
        dig4 : OUT std_logic; --137

        --DIP prepinac
        ckey1 : IN std_logic; --88
        ckey2 : IN std_logic; --89
        ckey3 : IN std_logic; --90
        ckey4 : IN std_logic; --91

        --UART
        uart_txd : OUT std_logic := '1'; --114
        uart_rxd : IN std_logic; --115

        --I2C
        i2c_scl : OUT std_logic := '1'; --99
        i2c_sda : INOUT std_logic; --98

        --I2C pro teplotni cidlo LM75
        temp_scl : OUT std_logic := '1'; --112
        temp_sda : INOUT std_logic; --113

        --PS2
        ps2_clock : INOUT std_logic; --119
        ps2_data : INOUT std_logic; --120

        --VGA
        vga_hs : OUT std_logic := '1'; --101
        vga_vs : OUT std_logic := '1'; --103
        vga_r : OUT std_logic := '1'; --104
        vga_g : OUT std_logic := '1'; --105
        vga_b : OUT std_logic := '1'; --106

        --LCD 1602 / 12864
        lcd_rs : OUT std_logic := '1'; --141
        lcd_rw : OUT std_logic := '1'; --138
        lcd_e : OUT std_logic := '1'; --143
        lcd_d : OUT std_logic_vector(7 DOWNTO 0); --142, 1, 144, 3, 2, 10, 7, 11

        --SDRAM 
        s_dq : INOUT std_logic_vector(15 DOWNTO 0);
        s_a : OUT std_logic_vector(11 DOWNTO 0);
        s_bs : OUT std_logic_vector(1 DOWNTO 0);
        s_ldqm : OUT std_logic := '1'; --42
        s_udqm : OUT std_logic := '1'; --55

        s_cke : OUT std_logic := '1'; --58
        s_clk : OUT std_logic := '1'; --43
        s_cs : OUT std_logic := '1'; --72
        s_ras : OUT std_logic := '1'; --71
        s_cas : OUT std_logic := '1'; --70
        s_we : OUT std_logic := '1'; --69

        --bzucak
        beep : OUT std_logic := '1'; --110

        --irDA senzor
        ir : IN std_logic --100

    );
END;

ARCHITECTURE main OF omdazzalpha IS
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

    SIGNAL n_MREQ, n_IORQ, n_RD, n_WR : std_logic;

    SIGNAL ramwr : std_logic;
    SIGNAL ramcs, romcs : std_logic;
    SIGNAL uartcs : std_logic;
    SIGNAL uartwr : std_logic;
    SIGNAL romDataOut : std_logic_vector(7 DOWNTO 0);

    SIGNAL ramDataOut : std_logic_vector(7 DOWNTO 0);

    SIGNAL uartDataOut : std_logic_vector(7 DOWNTO 0);
    SIGNAL uartClock : std_logic;

    SIGNAL cpuClkCount : unsigned(5 DOWNTO 0);

    SIGNAL trig : STD_LOGIC_VECTOR (0 DOWNTO 0);
BEGIN

    -- debug
    -- cpu
    /*
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
    --*/
    cpu1 : ENTITY work.t80s
        GENERIC MAP(mode => 0, t2write => 1, iowait => 0)
        PORT MAP(
            reset_n => NOT reset,
            clk_n => NOT cpuClock,
            wait_n => '1',
            int_n => '1',
            nmi_n => '1',
            busrq_n => '1',
            mreq_n => n_MREQ,
            iorq_n => n_IORQ,
            rd_n => n_RD,
            wr_n => n_WR,
            a => cpuAddress,
            di => cpuDataIn,
            do => cpuDataOut);
    cpuClk : ENTITY work.aciaClock GENERIC MAP (50, 2) PORT MAP(clk, cpuClock);
    --cpuClock <= clk;

    -- bus signals
    /*
    memrd <= rd AND NOT iom;
    memwr <= wr AND NOT iom;
    iord <= rd AND iom;
    iowr <= wr AND iom;
    --*/

    ioWR <= n_WR NOR n_IORQ;
    memWR <= n_WR NOR n_MREQ;
    ioRD <= n_RD NOR n_IORQ;
    memRD <= n_RD NOR n_MREQ;

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
    /*
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
        RxD => uart_RxD,
        TxD => uart_TxD,
        DCD_n => '0',
        CTS_n => '0'
        );

    -- baud 
    baud : ENTITY work.aciaClock GENERIC MAP (50_000_000, 5_000_000) PORT MAP(clk, uartClock);
    --*/
    io1 : ENTITY work.SBCTextDisplayRGB
        PORT MAP(
            n_reset => NOT reset,
            clk => clk,

            -- RGB video signals
            hSync => vga_hs,
            vSync => vga_vs,
            --videoR0 => videoR0,
            videoR1 => vga_r,
            --videoG0 => videoG0,
            videoG1 => vga_g,
            --videoB0 => videoB0,
            videoB1 => vga_b,

            -- Monochrome video signals (when using TV timings only)
            --sync => videoSync,
            --video => video,

            n_wr => NOT uartwr,
            n_rd => uartcs NAND iord,
            --n_int => n_int1,
            regSel => cpuAddress(0),
            dataIn => cpuDataOut,
            dataOut => uartDataOut,
            ps2Clk => ps2_clock,
            ps2Data => ps2_data
        );

    -- dekodery
    ramcs <= '1' WHEN cpuAddress(15 DOWNTO 12) = "1111" ELSE
        '0';
    romcs <= '1' WHEN cpuAddress(15 DOWNTO 12) = "0000" ELSE
        '0';
    uartcs <= '1' WHEN cpuAddress(7 DOWNTO 1) = "1101111" ELSE
        '0';

    ramwr <= memwr AND ramcs;
    uartwr <= NOT (iowr AND uartcs);

    cpuDataIn <= romDataOut WHEN (romcs AND memrd)
        ELSE
        ramDataOut WHEN (ramcs AND memrd)
        ELSE
        uartDataOut WHEN (uartcs AND iord)
        ELSE
        x"00";
    /*
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            -- sbernice    
            IF (romcs = '1' AND memrd = '1') THEN
                cpuDataIn <= romDataOut;
            ELSIF (ramcs = '1' AND memrd = '1') THEN
                cpuDataIn <= ramDataOut;
            ELSIF (uartcs = '1' AND iord = '1') THEN
                cpuDataIn <= uartDataOut;
            ELSE
                cpuDataIn <= cpuDataIn;
            END IF;

        END IF;
    END PROCESS;
    --*/

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
            IF reset_b = '0' THEN
                resetDuration := 7;
            END IF;
        END IF;
    END PROCESS;
END main;