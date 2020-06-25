LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY omdazz IS
    PORT (
        clk : IN std_logic; --23
		  reset_b: IN std_logic; --25
		  
		  --LED
        led1 : OUT std_logic :='1'; --87
        led2 : OUT std_logic :='1'; --86
        led3 : OUT std_logic :='1'; --85
        led4 : OUT std_logic :='1'; --84
		  
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
		  uart_txd: OUT std_logic :='1'; --114
		  uart_rxd: IN std_logic;  --115

		  --I2C
		  i2c_scl: OUT std_logic :='1'; --99
		  i2c_sda: INOUT std_logic; --98
		  
		  --I2C pro teplotni cidlo LM75
		  temp_scl: OUT std_logic :='1'; --112
		  temp_sda: INOUT std_logic; --113
		  
		  --PS2
		  ps2_clock: INOUT std_logic; --119
		  ps2_data: INOUT std_logic; --120
		  
		  --VGA
		  vga_hs: OUT std_logic :='1'; --101
		  vga_vs: OUT std_logic :='1'; --103
		  vga_r: OUT std_logic :='1'; --104
		  vga_g: OUT std_logic :='1'; --105
		  vga_b: OUT std_logic :='1'; --106
		  
		  --LCD 1602 / 12864
		  lcd_rs : OUT std_logic :='1'; --141
		  lcd_rw : OUT std_logic :='1'; --138
		  lcd_e  : OUT std_logic :='1'; --143
		  lcd_d : OUT std_logic_vector(7 downto 0); --142, 1, 144, 3, 2, 10, 7, 11
		  
		  --SDRAM 
		  s_dq : INOUT std_logic_vector(15 downto 0);
		  s_a : OUT std_logic_vector(11 downto 0);
		  s_bs : OUT std_logic_vector(1 downto 0);
		  s_ldqm : OUT std_logic :='1'; --42
		  s_udqm : OUT std_logic :='1'; --55

		  s_cke : OUT std_logic :='1'; --58
		  s_clk : OUT std_logic :='1'; --43
		  s_cs : OUT std_logic :='1'; --72
		  s_ras : OUT std_logic :='1'; --71
		  s_cas : OUT std_logic :='1'; --70
		  s_we : OUT std_logic :='1'; --69
		  
		  
		  
		  --bzucak
		  beep : OUT std_logic :='1'; --110
		  
		  --irDA senzor
		  ir: IN std_logic --100
    );
END ENTITY;

ARCHITECTURE struct OF omdazz IS

constant f_in: natural := 50_000_000; --System clock

signal khz:std_logic;
signal hz1:std_logic;
signal mhz133:std_logic;

signal cntr:std_logic_vector (15 DOWNTO 0);

signal reset_int: std_logic;

--FSM RAM

    TYPE state_type IS (ST_WAIT, ST_IDLE, ST_READ, ST_WRITE, ST_REREAD, ST_REFRESH);
    SIGNAL state_r, state_x : state_type := ST_WAIT;
	     SIGNAL ready_o : std_logic;
    SIGNAL done_o : std_logic;
	 SIGNAL refresh_i : std_logic := '0';
	     SIGNAL rw_i : std_logic := '0';
    SIGNAL we_i : std_logic := '0';
	     SIGNAL ub_i : std_logic := '0';
    SIGNAL lb_i : std_logic := '0';

BEGIN



    PROCESS (clk) IS
        VARIABLE counter : INTEGER := 0;
        VARIABLE blik : std_logic := '0';
    BEGIN
        IF (rising_edge(clk)) THEN
            counter := counter + 1;
            IF (counter = 50000000) THEN
                counter := 0;
                blik := NOT blik;
            END IF;
        END IF;
        led1 <= blik;
    END PROCESS;
	 
	 
	 led2<=ckey2;
	 led3<=not ckey3;
	 
div_hz1: entity work.freqdiv generic map(f_in,4) port map (clk, hz1);
--cnt16: entity work.counter16b port map (x"0000",'0', hz1, not reset_b, cntr);

div_khz: entity work.freqdiv generic map(f_in,1000) port map (clk, khz);
	 
dis: entity work.segmuxnum port map (khz,unsigned(cntr),segA, segB, segC, segD, segE, segF, segG, segH, dig1, dig2, dig3, dig4);

pll133: entity work.pll port map (clk, mhz133);

rst: entity work.reset port map (clk, reset_b, reset_int);

--sdram test
memo : entity work.sdram PORT MAP(
        clk_133 => mhz133,
        reset => reset_int,
        refresh => refresh_i,
        rw => rw_i,
        we => we_i,
        addr => "0000000000011000000001",
        data_i => x"babe",
        ub => '0',
        lb => '0',
        ready => ready_o,
        done => done_o,
        data_o => cntr,
        sdCke => s_cke,
        sdCs => s_cs,
        sdRas => s_ras,
        sdCas => s_cas,
        sdWe => s_we,
        sdBa => s_bs,
        sdAddr => s_a,
        sdData => s_dq,
        sdUdqm => s_udqm,
        sdLdqm => s_ldqm
    );
s_clk<=mhz133;	 


-- FSM pro RAM
    PROCESS (mhz133)
    BEGIN
        IF rising_edge(mhz133) THEN
            state_r <= state_x;
        END IF;
    END PROCESS;
    PROCESS (state_r, ready_o, done_o)
    BEGIN

        state_x <= state_r;
        rw_i <= '0';
        we_i <= '1';
        ub_i <= '0';
        lb_i <= '0';
        CASE (state_r) IS

            WHEN ST_WAIT =>
                IF ready_o = '1' THEN
                    state_x <= ST_READ;
                END IF;

            WHEN ST_IDLE =>
                state_x <= ST_IDLE;

            WHEN ST_READ =>
                IF done_o = '0' THEN
                    rw_i <= '1';
                    --addr_i <= "0000000000011000000001";
                ELSE
                    state_x <= ST_WRITE;
                END IF;

            WHEN ST_WRITE =>
                IF done_o = '0' THEN
                    rw_i <= '1';
                    we_i <= '0';
                    --addr_i <= "0000000000011000000011";
                    --data_i <= X"ADCD";
                    ub_i <= '1';
                    lb_i <= '0';
                ELSE
                    state_x <= ST_REREAD;
                END IF;

            WHEN ST_REREAD =>
                IF done_o = '0' THEN
                    rw_i <= '1';
                    --addr_i <= "0000000000011000000011";
                ELSE
                    state_x <= ST_REFRESH;
                END IF;

            WHEN ST_REFRESH =>
                IF done_o = '0' THEN
                    refresh_i <= '1';
                ELSE
                    state_x <= ST_IDLE;
                END IF;
        END CASE;

    END PROCESS;

-- beep <= hz1;	 
END ARCHITECTURE;