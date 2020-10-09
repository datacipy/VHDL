--------------------------------------------------------------------------------
--
--   FileName:         pmod_temp_sensor_tcn75a.vhd
--   Dependencies:     i2c_master.vhd (Version 2.2)
--   Design Software:  Quartus Prime Version 17.0.0 Build 595 SJ Lite Edition
--   See: https://www.digikey.com/eewiki/pages/viewpage.action?pageId=86278365
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 07/31/2019 Scott Larson
--     Initial Public Release
-- 
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY pmod_temp_sensor_tcn75a IS
  GENERIC (
    sys_clk_freq : INTEGER := 50_000_000; --input clock speed from user logic in Hz
    resolution : INTEGER := 9; --desired resolution of temperature data in bits
    temp_sensor_addr : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1001000"); --I2C address of the temp sensor pmod
  PORT (
    clk : IN STD_LOGIC; --system clock
    reset_n : IN STD_LOGIC; --asynchronous active-low reset
    scl : INOUT STD_LOGIC; --I2C serial clock
    sda : INOUT STD_LOGIC; --I2C serial data
    i2c_ack_err : OUT STD_LOGIC; --I2C slave acknowledge error flag
    temperature : OUT STD_LOGIC_VECTOR(resolution - 1 DOWNTO 0)); --temperature value obtained
END pmod_temp_sensor_tcn75a;

ARCHITECTURE behavior OF pmod_temp_sensor_tcn75a IS
  TYPE machine IS(start, set_resolution, set_reg_pointer, read_data, output_result); --needed states
  SIGNAL state : machine; --state machine
  SIGNAL config : STD_LOGIC_VECTOR(7 DOWNTO 0); --value to set the Sensor Configuration Register
  SIGNAL i2c_ena : STD_LOGIC; --i2c enable signal
  SIGNAL i2c_addr : STD_LOGIC_VECTOR(6 DOWNTO 0); --i2c address signal
  SIGNAL i2c_rw : STD_LOGIC; --i2c read/write command signal
  SIGNAL i2c_data_wr : STD_LOGIC_VECTOR(7 DOWNTO 0); --i2c write data
  SIGNAL i2c_data_rd : STD_LOGIC_VECTOR(7 DOWNTO 0); --i2c read data
  SIGNAL i2c_busy : STD_LOGIC; --i2c busy signal
  SIGNAL busy_prev : STD_LOGIC; --previous value of i2c busy signal
  SIGNAL temp_data : STD_LOGIC_VECTOR(15 DOWNTO 0); --temperature data buffer

  COMPONENT i2c_master IS
    GENERIC (
      input_clk : INTEGER; --input clock speed from user logic in Hz
      bus_clk : INTEGER); --speed the i2c bus (scl) will run at in Hz
    PORT (
      clk : IN STD_LOGIC; --system clock
      reset_n : IN STD_LOGIC; --active low reset
      ena : IN STD_LOGIC; --latch in command
      addr : IN STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
      rw : IN STD_LOGIC; --'0' is write, '1' is read
      data_wr : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
      busy : OUT STD_LOGIC; --indicates transaction in progress
      data_rd : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
      ack_error : BUFFER STD_LOGIC; --flag if improper acknowledge from slave
      sda : INOUT STD_LOGIC; --serial data output of i2c bus
      scl : INOUT STD_LOGIC); --serial clock output of i2c bus
  END COMPONENT;

BEGIN

  --instantiate the i2c master
  i2c_master_0 : i2c_master
  GENERIC MAP(input_clk => sys_clk_freq, bus_clk => 400_000)
  PORT MAP(
    clk => clk, reset_n => reset_n, ena => i2c_ena, addr => i2c_addr,
    rw => i2c_rw, data_wr => i2c_data_wr, busy => i2c_busy,
    data_rd => i2c_data_rd, ack_error => i2c_ack_err, sda => sda,
    scl => scl);

  --set the resolution bits for the Sensor Configuration Register value
  WITH resolution SELECT
    config <= "00100000" WHEN 10, --10 bits of resolution
    "01000000" WHEN 11, --11 bits of resolution
    "01100000" WHEN 12, --12 bits of resolution
    "00000000" WHEN OTHERS; --9 bits of resolution (default)

  PROCESS (clk, reset_n)
    VARIABLE busy_cnt : INTEGER RANGE 0 TO 2 := 0; --counts the busy signal transistions during one transaction
    VARIABLE counter : INTEGER RANGE 0 TO sys_clk_freq/10 := 0; --counts 100ms to wait before communicating
  BEGIN
    IF (reset_n = '0') THEN --reset activated
      counter := 0; --clear wait counter
      i2c_ena <= '0'; --clear i2c enable
      busy_cnt := 0; --clear busy counter
      temperature <= (OTHERS => '0'); --clear temperature result output
      state <= start; --return to start state
    ELSIF (clk'EVENT AND clk = '1') THEN --rising edge of system clock
      CASE state IS --state machine

          --give temp sensor 100ms to power up before communicating
        WHEN start =>
          IF (counter < sys_clk_freq/10) THEN --100ms not yet reached
            counter := counter + 1; --increment counter
          ELSE --100ms reached
            counter := 0; --clear counter
            state <= set_resolution; --advance to setting the resolution
          END IF;

          --set the resolution of the temperature data
        WHEN set_resolution =>
          busy_prev <= i2c_busy; --capture the value of the previous i2c busy signal
          IF (busy_prev = '0' AND i2c_busy = '1') THEN --i2c busy just went high
            busy_cnt := busy_cnt + 1; --counts the times busy has gone from low to high during transaction
          END IF;
          CASE busy_cnt IS --busy_cnt keeps track of which command we are on
            WHEN 0 => --no command latched in yet
              i2c_ena <= '1'; --initiate the transaction
              i2c_addr <= temp_sensor_addr; --set the address of the temp sensor
              i2c_rw <= '0'; --command 1 is a write
              i2c_data_wr <= "00000001"; --set the Register Pointer to the Configuration Register
            WHEN 1 => --1st busy high: command 1 latched, okay to issue command 2
              i2c_data_wr <= config; --write the new configuration value to the Configuration Register
            WHEN 2 => --2nd busy high: command 2 latched
              i2c_ena <= '0'; --deassert enable to stop transaction after command 2
              IF (i2c_busy = '0') THEN --transaction complete
                busy_cnt := 0; --reset busy_cnt for next transaction
                state <= set_reg_pointer; --advance to setting the Register Pointer for data reads
              END IF;
            WHEN OTHERS => NULL;
          END CASE;

          --set the register pointer to the Ambient Temperature Register  
        WHEN set_reg_pointer =>
          busy_prev <= i2c_busy; --capture the value of the previous i2c busy signal
          IF (busy_prev = '0' AND i2c_busy = '1') THEN --i2c busy just went high
            busy_cnt := busy_cnt + 1; --counts the times busy has gone from low to high during transaction
          END IF;
          CASE busy_cnt IS --busy_cnt keeps track of which command we are on
            WHEN 0 => --no command latched in yet
              i2c_ena <= '1'; --initiate the transaction
              i2c_addr <= temp_sensor_addr; --set the address of the temp sensor
              i2c_rw <= '0'; --command 1 is a write
              i2c_data_wr <= "00000000"; --set the Register Pointer to the Ambient Temperature Register
            WHEN 1 => --1st busy high: command 1 latched
              i2c_ena <= '0'; --deassert enable to stop transaction after command 1
              IF (i2c_busy = '0') THEN --transaction complete
                busy_cnt := 0; --reset busy_cnt for next transaction
                state <= read_data; --advance to reading the data
              END IF;
            WHEN OTHERS => NULL;
          END CASE;

          --read ambient temperature data
        WHEN read_data =>
          busy_prev <= i2c_busy; --capture the value of the previous i2c busy signal
          IF (busy_prev = '0' AND i2c_busy = '1') THEN --i2c busy just went high
            busy_cnt := busy_cnt + 1; --counts the times busy has gone from low to high during transaction
          END IF;
          CASE busy_cnt IS --busy_cnt keeps track of which command we are on
            WHEN 0 => --no command latched in yet
              i2c_ena <= '1'; --initiate the transaction
              i2c_addr <= temp_sensor_addr; --set the address of the temp sensor
              i2c_rw <= '1'; --command 1 is a read
            WHEN 1 => --1st busy high: command 1 latched, okay to issue command 2
              IF (i2c_busy = '0') THEN --indicates data read in command 1 is ready
                temp_data(15 DOWNTO 8) <= i2c_data_rd; --retrieve MSB data from command 1
              END IF;
            WHEN 2 => --2nd busy high: command 2 latched
              i2c_ena <= '0'; --deassert enable to stop transaction after command 2
              IF (i2c_busy = '0') THEN --indicates data read in command 2 is ready
                temp_data(7 DOWNTO 0) <= i2c_data_rd; --retrieve LSB data from command 2
                busy_cnt := 0; --reset busy_cnt for next transaction
                state <= output_result; --advance to output the result
              END IF;
            WHEN OTHERS => NULL;
          END CASE;

          --output the temperature data
        WHEN output_result =>
          temperature <= temp_data(15 DOWNTO 16 - resolution); --write temperature data to output
          state <= read_data; --retrieve the next temperature data

          --default to start state
        WHEN OTHERS =>
          state <= start;

      END CASE;
    END IF;
  END PROCESS;
END behavior;