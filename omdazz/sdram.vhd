LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY sdram IS
   PORT (
      -- system
      clk_133 : IN std_logic; -- Master clock
      reset : IN std_logic := '0'; -- Reset, active high
      refresh : IN std_logic := '0'; -- Initiate a refresh cycle, active high
      rw : IN std_logic := '0'; -- Initiate a read or write operation, active high
      we : IN std_logic := '0'; -- Write enable, active low
      addr : IN std_logic_vector(21 DOWNTO 0); -- Address from host to SDRAM
      data_i : IN std_logic_vector(15 DOWNTO 0); -- Data from host to SDRAM
      ub : IN std_logic; -- Data upper byte enable, active low
      lb : IN std_logic; -- Data lower byte enable, active low
      ready : OUT std_logic := '0'; -- Set to '1' when the memory is ready
      done : OUT std_logic := '0'; -- Read, write, or refresh, operation is done
      data_o : OUT std_logic_vector(15 DOWNTO 0); -- Data from SDRAM to host

      -- SDRAM 
      sdCke : OUT std_logic; -- Clock-enable to SDRAM
      sdCs : OUT std_logic; -- Chip-select to SDRAM
      sdRas : OUT std_logic; -- SDRAM row address strobe
      sdCas : OUT std_logic; -- SDRAM column address strobe
      sdWe : OUT std_logic; -- SDRAM write enable
      sdBa : OUT std_logic_vector(1 DOWNTO 0); -- SDRAM bank address
      sdAddr : OUT std_logic_vector(11 DOWNTO 0); -- SDRAM row/column address
      sdData : INOUT std_logic_vector(15 DOWNTO 0); -- Data to/from SDRAM
      sdUdqm : OUT std_logic; -- Enable upper-byte of SDRAM databus if true
      sdLdqm : OUT std_logic -- Enable lower-byte of SDRAM databus if true
   );
END ENTITY;

ARCHITECTURE main OF sdram IS
   CONSTANT nsCycle : real := 7.5;

   -- SDRAM states
   TYPE fsm_state_type IS (
      ST_INIT_WAIT, ST_INIT_PRECHARGE, ST_INIT_REFRESH1, ST_INIT_MODE, ST_INIT_REFRESH2,
      ST_IDLE, ST_REFRESH, ST_ACTIVATE, ST_RCD, ST_RW, ST_RAS1, ST_RAS2, ST_PRECHARGE);
   SIGNAL state_r, state_x : fsm_state_type := ST_INIT_WAIT;
   -- SDRAM mode
   --
   -- | A11-A10 |    A9    | A8  A7 | A6 A5 A4 |    A3   | A2 A1 A0 |
   -- | reserved| wr burst |reserved| CAS Ltncy|addr mode| burst len|
   --    0  0        0       0   0    0  1  0       0      0  0  0

   CONSTANT MODE_REG : std_logic_vector(11 DOWNTO 0) := "00" & "0" & "00" & "010" & "0" & "000";

   -- prikazy SDRAM posilane na vstupy cs, ras, cas, we.

   SUBTYPE cmd_type IS unsigned(3 DOWNTO 0);
   CONSTANT CMD_ACTIVATE : cmd_type := "0011";
   CONSTANT CMD_PRECHARGE : cmd_type := "0010";
   CONSTANT CMD_WRITE : cmd_type := "0100";
   CONSTANT CMD_READ : cmd_type := "0101";
   CONSTANT CMD_MODE : cmd_type := "0000";
   CONSTANT CMD_NOP : cmd_type := "0111";
   CONSTANT CMD_REFRESH : cmd_type := "0001";

   SIGNAL cmd_r : cmd_type;
   SIGNAL cmd_x : cmd_type;

   SIGNAL bank_s : std_logic_vector(1 DOWNTO 0);
   SIGNAL row_s : std_logic_vector(11 DOWNTO 0);
   SIGNAL col_s : std_logic_vector(7 DOWNTO 0);
   SIGNAL addr_r : std_logic_vector(11 DOWNTO 0);
   SIGNAL addr_x : std_logic_vector(11 DOWNTO 0); -- SDRAM row/column address.
   SIGNAL sd_dout_r : std_logic_vector(15 DOWNTO 0);
   SIGNAL sd_dout_x : std_logic_vector(15 DOWNTO 0);
   SIGNAL sd_busdir_r : std_logic;
   SIGNAL sd_busdir_x : std_logic;

   SIGNAL timer_r, timer_x : NATURAL RANGE 0 TO 26666 := 0;
   SIGNAL refcnt_r, refcnt_x : NATURAL RANGE 0 TO 8 := 0;

   SIGNAL bank_r, bank_x : std_logic_vector(1 DOWNTO 0);
   SIGNAL cke_r, cke_x : std_logic;
   SIGNAL sd_udqm_r, sd_udqm_x : std_logic;
   SIGNAL sd_ldqm_r, sd_ldqm_x : std_logic;
   SIGNAL ready_r, ready_x : std_logic;

   -- Data buffer for SDRAM to Host.
   SIGNAL buf_dout_r, buf_dout_x : std_logic_vector(15 DOWNTO 0);

BEGIN

   -- All signals to SDRAM buffered.

   (sdCs, sdRas, sdCas, sdWe) <= cmd_r; -- SDRAM operation control bits
   sdCke <= cke_r; -- SDRAM clock enable
   sdBa <= bank_r; -- SDRAM bank address
   sdAddr <= addr_r; -- SDRAM address
   sdData <= sd_dout_r WHEN sd_busdir_r = '1' ELSE
      (OTHERS => 'Z'); -- SDRAM data bus.
   sdUdqm <= sd_udqm_r; -- SDRAM high data byte enable, active low
   sdLdqm <= sd_ldqm_r; -- SDRAM low date byte enable, active low

   -- Signals back to host.
   ready <= ready_r;
   data_o <= buf_dout_r;

   --   21 20 | 19 18 17 16 15 14 13 12 11 10 09 08 | 07 06 05 04 03 02 01 00 |
   -- BS0 BS1 |   ROW (A11-A0)  4096 rows           | COL (A7-A0)  256 cols   |
   bank_s <= addr(21 DOWNTO 20);
   row_s <= addr(19 DOWNTO 8);
   col_s <= addr(7 DOWNTO 0);
   PROCESS (
      state_r, timer_r, refcnt_r, cke_r, addr_r, sd_dout_r, sd_busdir_r, sd_udqm_r, sd_ldqm_r, ready_r,
      bank_s, row_s, col_s,
      rw, refresh, addr, data_i, we, ub, lb,
      buf_dout_r, sdData)
   BEGIN

      state_x <= state_r; -- Stay in the same state unless changed.
      timer_x <= timer_r; -- Hold the cycle timer by default.
      refcnt_x <= refcnt_r; -- Hold the refresh timer by default.
      cke_x <= cke_r; -- Stay in the same clock mode unless changed.
      cmd_x <= CMD_NOP; -- Default to NOP unless changed.
      bank_x <= bank_r; -- Register the SDRAM bank.
      addr_x <= addr_r; -- Register the SDRAM address.
      sd_dout_x <= sd_dout_r; -- Register the SDRAM write data.
      sd_busdir_x <= sd_busdir_r; -- Register the SDRAM bus tristate control.
      sd_udqm_x <= sd_udqm_r;
      sd_ldqm_x <= sd_ldqm_r;
      buf_dout_x <= buf_dout_r; -- SDRAM to host data buffer.

      ready_x <= ready_r; -- Always ready unless performing initialization.
      done <= '0'; -- Done tick, single cycle.

      IF timer_r /= 0 THEN
         timer_x <= timer_r - 1;
      ELSE

         cke_x <= '1';
         bank_x <= bank_s;
         -- A10 low for rd/wr commands to suppress auto-precharge.
         addr_x <= "0000" & col_s;
         sd_udqm_x <= '0';
         sd_ldqm_x <= '0';

         CASE state_r IS

            WHEN ST_INIT_WAIT =>

               -- 1. Wait 200us with DQM signals high, cmd NOP.
               -- 2. Precharge all banks.
               -- 3. Eight refresh cycles.
               -- 4. Set mode register.
               -- 5. Eight refresh cycles.

               state_x <= ST_INIT_PRECHARGE;
               --timer_x <= 26666; -- Wait 200us (26,666 cycles). - 200 * 133
               timer_x <= 2; -- for simulation
               sd_udqm_x <= '1';
               sd_ldqm_x <= '1';

            WHEN ST_INIT_PRECHARGE =>

               state_x <= ST_INIT_REFRESH1;
               --refcnt_x <= 8; -- Do 8 refresh cycles in the next state.
               refcnt_x <= 2; -- for simulation
               cmd_x <= CMD_PRECHARGE;
               timer_x <= 3; -- Wait 3 cycles plus state overhead for 20ns Trp.
               bank_x <= "00";
               addr_x(10) <= '1'; -- Precharge all banks.

            WHEN ST_INIT_REFRESH1 =>

               IF refcnt_r = 0 THEN
                  state_x <= ST_INIT_MODE;
               ELSE
                  refcnt_x <= refcnt_r - 1;
                  cmd_x <= CMD_REFRESH;
                  timer_x <= 9; -- Wait 7 cycles plus state overhead for 70ns refresh. x133/1000
               END IF;

            WHEN ST_INIT_MODE =>

               state_x <= ST_INIT_REFRESH2;
               --refcnt_x <= 8; -- Do 8 refresh cycles in the next state.
               refcnt_x <= 2; -- for simulation
               bank_x <= "00";
               addr_x <= MODE_REG;
               cmd_x <= CMD_MODE;
               timer_x <= 3; -- Trsc == 2 cycles after issuing MODE command.

            WHEN ST_INIT_REFRESH2 =>

               IF refcnt_r = 0 THEN
                  state_x <= ST_IDLE;
                  ready_x <= '1';
               ELSE
                  refcnt_x <= refcnt_r - 1;
                  cmd_x <= CMD_REFRESH;
                  timer_x <= 9; -- Wait 7 cycles plus state overhead for 70ns refresh.
               END IF;

               --
               -- Normal Operation
               --
               -- Trc  - 70ns - Activate to activate command.
               -- Trcd - 20ns - Activate to read/write command.
               -- Tras - 50ns - Activate to precharge command.
               -- Trp  - 20ns - Precharge to activate command.
               -- TCas - 2clk - Read/write to data out.
               --
               --         |<-----------       Trc      ------------>|
               --         |<----------- Tras ---------->|
               --         |<- Trcd  ->|<- TCas  ->|     |<-  Trp  ->|
               --  T0__  T1__  T2__  T3__  T4__  T5__  T6__  T0__  T1__
               -- __/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__
               -- IDLE  ACTVT  NOP  RD/WR  NOP   NOP  PRECG IDLE  ACTVT
               --     --<Row>-------------------------------------<Row>--
               --                ---<Col>---
               --                ---<A10>-------------<A10>---
               --                                  ---<Bank>---
               --                ---<DQM>---
               --                ---<Din>---
               --                                  ---<Dout>---
               --   ---<Refsh>-----------------------------------<Refsh>---
               --
               -- A10 during rd/wr : 0 = disable auto-precharge, 1 = enable auto-precharge.
               -- A10 during precharge: 0 = single bank, 1 = all banks.

               -- Next State vs Current State Guide
               --
               --  T0__  T1__  T2__  T3__  T4__  T5__  T6__  T0__  T1__  T2__
               -- __/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__
               -- IDLE  ACTVT  NOP  RD/WR  NOP   NOP  PRECG IDLE  ACTVT
               --       IDLE  ACTVT  NOP  RD/WR  NOP   NOP  PRECG IDLE  ACTVT
            WHEN ST_IDLE =>
               -- 60ns since activate when coming from PRECHARGE state.
               -- 10ns since PRECHARGE.  Trp == 20ns min.
               IF rw = '1' THEN
                  state_x <= ST_ACTIVATE;
                  cmd_x <= CMD_ACTIVATE;
                  addr_x <= row_s; -- Set bank select and row on activate command.
               ELSIF refresh = '1' THEN
                  state_x <= ST_REFRESH;
                  cmd_x <= CMD_REFRESH;
                  timer_x <= 9; -- Wait 7 cycles plus state overhead for 70ns refresh.
               END IF;

            WHEN ST_REFRESH =>

               state_x <= ST_IDLE;
               done <= '1';

            WHEN ST_ACTIVATE =>
               -- Trc (Active to Active Command Period) is 65ns min.
               -- 70ns since activate when coming from PRECHARGE -> IDLE states.
               -- 20ns since PRECHARGE.
               -- ACTIVATE command is presented to the SDRAM.  The command out of this
               -- state will be NOP for one cycle.
               state_x <= ST_RCD;
               sd_dout_x <= data_i; -- Register any write data, even if not used.

            WHEN ST_RCD =>
               -- 10ns since activate.
               -- Trcd == 20ns min.  The clock is 10ns, so the requirement is satisfied by this state.
               -- READ or WRITE command will be active in the next cycle.
               state_x <= ST_RW;

               IF we = '0' THEN
                  cmd_x <= CMD_WRITE;
                  sd_busdir_x <= '1'; -- The SDRAM latches the input data with the command.
                  sd_udqm_x <= ub;
                  sd_ldqm_x <= lb;
               ELSE
                  cmd_x <= CMD_READ;
               END IF;

            WHEN ST_RW =>
               -- 20ns since activate.
               -- READ or WRITE command presented to SDRAM.
               state_x <= ST_RAS1;
               sd_busdir_x <= '0';

            WHEN ST_RAS1 =>
               -- 30ns since activate.
               -- Data from the SDRAM will be registered on the next clock.
               state_x <= ST_RAS2;
               buf_dout_x <= sdData;

            WHEN ST_RAS2 =>
               -- 40ns since activate.
               -- Tras (Active to precharge Command Period) 45ns min.
               -- PRECHARGE command will be active in the next cycle.
               state_x <= ST_PRECHARGE;
               cmd_x <= CMD_PRECHARGE;
               addr_x(10) <= '1'; -- Precharge all banks.

            WHEN ST_PRECHARGE =>
               -- 50ns since activate.
               -- PRECHARGE presented to SDRAM.
               state_x <= ST_IDLE;
               done <= '1'; -- Read data is ready and should be latched by the host.
               timer_x <= 1; -- Buffer to make sure host takes down memory request before going IDLE.

         END CASE;
      END IF;
   END PROCESS;

   PROCESS (clk_133)
   BEGIN
      IF rising_edge(clk_133) THEN
         IF reset = '1' THEN
            state_r <= ST_INIT_WAIT;
            timer_r <= 0;
            cmd_r <= CMD_NOP;
            cke_r <= '0';
            ready_r <= '0';
         ELSE
            state_r <= state_x;
            timer_r <= timer_x;
            refcnt_r <= refcnt_x;
            cke_r <= cke_x; -- CKE to SDRAM.
            cmd_r <= cmd_x; -- Command to SDRAM.
            bank_r <= bank_x; -- Bank to SDRAM.
            addr_r <= addr_x; -- Address to SDRAM.
            sd_dout_r <= sd_dout_x; -- Data to SDRAM.
            sd_busdir_r <= sd_busdir_x; -- SDRAM bus direction.
            sd_udqm_r <= sd_udqm_x; -- Upper byte enable to SDRAM.
            sd_ldqm_r <= sd_ldqm_x; -- Lower byte enable to SDRAM.
            ready_r <= ready_x;
            buf_dout_r <= buf_dout_x;

         END IF;
      END IF;
   END PROCESS;

END ARCHITECTURE;