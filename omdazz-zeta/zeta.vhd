-- OMEN ALPHA / SDRAM / Terminal / T80

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- baltera message_level Level1 
-- baltera message_off 10034 10035 10036 10037 10230 10240 10030 

ENTITY zeta IS
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

ARCHITECTURE main OF zeta IS
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
    SIGNAL ramcs, romcs, vramcs : std_logic;
    SIGNAL uartcs : std_logic;
    SIGNAL uartwr : std_logic;
    SIGNAL vramwr : std_logic;
    SIGNAL romDataOut : std_logic_vector(7 DOWNTO 0);

    SIGNAL ramDataOut : std_logic_vector(7 DOWNTO 0);
    SIGNAL vramDataOut : std_logic_vector(7 DOWNTO 0);
    SIGNAL border : std_logic_vector(3 DOWNTO 0);

    SIGNAL uartDataOut : std_logic_vector(7 DOWNTO 0);
    SIGNAL uartClock : std_logic;

    SIGNAL virq : std_logic;
    SIGNAL s_irq : std_logic;
	 
	 
    SIGNAL cpuClkCount : unsigned(5 DOWNTO 0);

    SIGNAL mhz133 : std_logic;
    SIGNAL khz : std_logic;
    SIGNAL rfsh_n : std_logic;
    SIGNAL doWait : std_logic := '0';
    SIGNAL dramReset : std_logic := '1';
    SIGNAL dramReady : std_logic;
    SIGNAL dramDone : std_logic;
    SIGNAL dramDataOut : std_logic_vector(15 DOWNTO 0);
    SIGNAL dramWait : std_logic := '0';

    --test
    SIGNAL dispLatch : std_logic_vector(15 DOWNTO 0);
    SIGNAL hz1 : std_logic;

BEGIN

    -- cpu
    cpu1 : ENTITY work.t80s
        GENERIC MAP(mode => 1, t2write => 0, iowait => 0)
        PORT MAP(
            reset_n => NOT reset,
            clk_n => NOT cpuClock,
            wait_n => NOT doWait, --dramDone,
            int_n => s_irq,
            nmi_n => '1', --s_irq,
            busrq_n => '1',
            mreq_n => n_MREQ,
            iorq_n => n_IORQ,
            rd_n => n_RD,
            wr_n => n_WR,
            rfsh_n => rfsh_n,
            a => cpuAddress,
            di => cpuDataIn,
            do => cpuDataOut);

--    cpuClk : ENTITY work.aciaClock GENERIC MAP (500, 25) PORT MAP(clk, cpuClock);
    cpuClk : ENTITY work.freqdiv GENERIC MAP (500, 25) PORT MAP(clk, cpuClock);
    --cpuClock <= clk;
	 
	 --sync irq
	 process (cpuclock) 
	 begin
	 if falling_edge(cpuclock) then
	 s_irq <= not virq;
	 end if;
	 end process;

    -- dekodovani ridicich signalu

    ioWR <= n_WR NOR n_IORQ;
    memWR <= n_WR NOR n_MREQ;
    ioRD <= n_RD NOR n_IORQ;
    memRD <= n_RD NOR n_MREQ;

    -- ROM                          
    rom : ENTITY work.rom8k PORT MAP (
        address => cpuAddress(12 DOWNTO 0),
        clock => clk,
        q => romDataOut
        );

    -- RAM

    dram : ENTITY work.sdram PORT MAP(
        clk => mhz133,
        reset_n => NOT dramReset,
        az_cs => ramcs,
        az_rd_n => NOT memrd,
        az_wr_n => NOT ramwr,
        az_addr => "000000" & cpuAddress,
        az_data => x"00" & cpuDataOut,
        az_be_n => "00",
        za_waitrequest => dramWait,
        za_valid => dramDone,
        --ready => dramReady,
        --done => dramDone,
        za_data => dramDataOut,

        --fyzicke rozhrani
        zs_cke => s_cke,
        zs_cs_n => s_cs,
        zs_ras_n => s_ras,
        zs_cas_n => s_cas,
        zs_we_n => s_we,
        zs_ba => s_bs,
        zs_addr => s_a,
        zs_dq => s_dq,
        zs_dqm(1) => s_udqm,
        zs_dqm(0) => s_ldqm
        );

    s_clk <= mhz133;
    ramclock : ENTITY work.pll PORT MAP (clk, mhz133);
    --mhz133 <= clk;
    ramDataOut <= dramDataOut(7 DOWNTO 0); --15 to 1

    wdog : ENTITY work.propreset PORT MAP (cpuclock, reset_b, dramreset, reset);

    -- SDRAM wait states
    PROCESS (cpuClock)
    BEGIN
        IF rising_edge(cpuClock) THEN
            IF ramcs = '1' THEN
                doWait <= '1';
            ELSE
                doWait <= doWait;
            END IF;
            IF dramWait = '1' THEN
                doWait <= '1';
            ELSE
                doWait <= doWait;
            END IF;

            IF dramDone = '1' THEN
                doWait <= '0';
            ELSE
                doWait <= doWait;
            END IF;
        END IF;

    END PROCESS;
	 
	 
    -- UART / terminal
	 
	 --zuludisplay is a ram
	 zulu: entity work.zuludisplay port map (
	 clock50 => clk,
	 vga_hs=>vga_hs,
	 vga_vs=>vga_vs,
	 vga_r=>vga_r,
	 vga_g=>vga_g,
	 vga_b=>vga_b,
	 virq=>virq,
	 border=>border,
	 ram_addr => cpuAddress(12 DOWNTO 0),
	 ram_di=>cpuDataOut,
	 ram_do=>vramDataOut,
	 ram_we=>vramwr, --todo
	 ram_clk=>clk);
	 
	 
/*
    io1 : ENTITY work.SBCTextDisplayRGB
        GENERIC MAP(
            EXTENDED_CHARSET => 1
        )
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
--*/
    -- dekodery
    --ramcs <= '1' WHEN cpuAddress(15 DOWNTO 15) = "1" ELSE
    --    '0';
    romcs <= '1' WHEN cpuAddress(15 DOWNTO 13) = "000" ELSE
        '0';
    vramcs <= '1' WHEN cpuAddress(15 DOWNTO 13) = "001" ELSE
        '0';
	ramcs <=  romcs nor vramcs;  
--    uartcs <= '1' WHEN cpuAddress(7 DOWNTO 1) = "1101111" ELSE
    uartcs <= '1' WHEN cpuAddress(7 DOWNTO 0) = "01111111" ELSE
        '0';

    ramwr <= memwr AND ramcs;
    vramwr <= memwr AND vramcs;
    uartwr <= NOT (iowr AND uartcs);
	 
	 --border latch
	 process(cpuclock)
	 begin
	 if rising_edge(cpuclock) then
	   if uartwr='1' then 
		  border<=cpuDataOut(3 downto 0);
      end if;
end if;
end process;		

    cpuDataIn <= romDataOut WHEN (romcs AND memrd)
        ELSE
        vramDataOut WHEN (vramcs AND memrd)
        ELSE
        ramDataOut WHEN (ramcs AND memrd)
        ELSE
        uartDataOut WHEN (uartcs AND iord)
        ELSE
        x"00";
    --testing
    --leds
    led1 <= NOT reset;
    led2 <= NOT romcs;
    led3 <= NOT ramcs;
    led4 <= NOT uartcs;
    div_khz : ENTITY work.aciaClock GENERIC MAP (50_000_000, 1_000) PORT MAP(clk, khz);
    div_hz : ENTITY work.aciaClock GENERIC MAP (50_000_000, 3) PORT MAP(clk, hz1);
    dis : ENTITY work.segmuxnum PORT MAP (khz, unsigned(dispLatch), segA, segB, segC, segD, segE, segF, segG, segH, dig1, dig2, dig3, dig4);
    PROCESS (hz1) BEGIN
        IF rising_edge(hz1) THEN
            --dispLatch <= cpuAddress;
            dispLatch <= cpuAddress(7 DOWNTO 0) & doWait & "000" & reset & dramDone & dramReady & dramReset;
        END IF; --latch
    END PROCESS;

END main;