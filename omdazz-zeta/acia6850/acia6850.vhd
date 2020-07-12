--===========================================================================--
--                                                                           --
--                  Synthesizable 6850 compatible ACIA                       --
--                                                                           --
--===========================================================================--
--
--  File name      : acia6850.vhd
--
--  Entity name    : acia6850
--
--  Purpose        : Implements a RS232 6850 compatible 
--                   Asynchronous Communications Interface Adapter (ACIA)
--                  
--  Dependencies   : ieee.std_logic_1164
--                   ieee.numeric_std
--                   ieee.std_logic_unsigned
--
--  Author         : John E. Kent
--
--  Email          : dilbert57@opencores.org      
--
--  Web            : http://opencores.org/project,system09
--
--  Origins        : miniUART written by Ovidiu Lupas olupas@opencores.org
--
--  Registers      :
--
--  IO address + 0 Read - Status Register
--
--     Bit[7] - Interrupt Request Flag
--     Bit[6] - Receive Parity Error (parity bit does not match)
--     Bit[5] - Receive Overrun Error (new character received before last read)
--     Bit[4] - Receive Framing Error (bad stop bit)
--     Bit[3] - Clear To Send level
--     Bit[2] - Data Carrier Detect (lost modem carrier)
--     Bit[1] - Transmit Buffer Empty (ready to accept next transmit character)
--     Bit[0] - Receive Data Ready (character received)
-- 
--  IO address + 0 Write - Control Register
--
--     Bit[7]     - Rx Interupt Enable
--          0     - disabled
--          1     - enabled
--     Bits[6..5] - Transmit Control
--        0 0     - TX interrupt disabled, RTS asserted
--        0 1     - TX interrupt enabled,  RTS asserted
--        1 0     - TX interrupt disabled, RTS cleared
--        1 1     - TX interrupt disabled, RTS asserted, Send Break
--     Bits[4..2] - Word Control
--      0 0 0     - 7 data, even parity, 2 stop
--      0 0 1     - 7 data, odd  parity, 2 stop
--      0 1 0     - 7 data, even parity, 1 stop
--      0 1 1     - 7 data, odd  parity, 1 stop
--      1 0 0     - 8 data, no   parity, 2 stop
--      1 0 1     - 8 data, no   parity, 1 stop
--      1 1 0     - 8 data, even parity, 1 stop
--      1 1 1     - 8 data, odd  parity, 1 stop
--     Bits[1..0] - Baud Control
--        0 0     - Baud Clk divide by 1
--        0 1     - Baud Clk divide by 16
--        1 0     - Baud Clk divide by 64
--        1 1     - Reset
--
--  IO address + 1 Read - Receive Data Register
--
--     Read when Receive Data Ready bit set
--     Read resets Receive Data Ready bit 
--
--  IO address + 1 Write - Transmit Data Register
--
--     Write when Transmit Buffer Empty bit set
--     Write resets Transmit Buffer Empty Bit
--
--
--  Copyright (C) 2002 - 2010 John Kent
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
--===========================================================================--
--                                                                           --
--                              Revision  History                            --
--                                                                           --
--===========================================================================--
--
-- Version Author        Date         Changes
--
-- 0.1     Ovidiu Lupas  2000-01-15   New model
-- 1.0     Ovidiu Lupas  2000-01      Synthesis optimizations
-- 2.0     Ovidiu Lupas  2000-04      Bugs removed - the RSBusCtrl did not
--                                    process all possible situations
--
-- 3.0     John Kent     2002-10      Changed Status bits to match MC6805
--                                    Added CTS, RTS, Baud rate control & Software Reset
-- 3.1     John Kent     2003-01-05   Added Word Format control a'la mc6850
-- 3.2     John Kent     2003-07-19   Latched Data input to UART
-- 3.3     John Kent     2004-01-16   Integrated clkunit in rxunit & txunit
--                                    TX / RX Baud Clock now external
--                                    also supports x1 clock and DCD. 
-- 3.4     John Kent     2005-09-13   Removed LoadCS signal. 
--                                    Fixed ReadCS and Read 
--                                    in miniuart_DCD_Init process
-- 3.5     John Kent     2006-11-28   Cleaned up code.
--
-- 4.0     John Kent     2007-02-03   Renamed ACIA6850
-- 4.1     John Kent     2007-02-06   Made software reset synchronous
-- 4.2     John Kent     2007-02-25   Changed sensitivity lists
--                                    Rearranged Reset process.
-- 4.3     John Kent     2010-06-17   Updated header
-- 4.4     John Kent     2010-08-27   Combined with ACIA_RX & ACIA_TX
--                                    Renamed to acia6850
--         Martin Maly   2020-05-23   Remove deprecated std_logic_unsigned
--

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-----------------------------------------------------------------------
-- Entity for ACIA_6850                                              --
-----------------------------------------------------------------------

ENTITY acia6850 IS
    PORT (
        --
        -- CPU Interface signals
        --
        clk : IN std_logic; -- System Clock
        rst : IN std_logic; -- Reset input (active high)
        cs : IN std_logic; -- miniUART Chip Select
        addr : IN std_logic; -- Register Select
        rw : IN std_logic; -- Read / Not Write
        data_in : IN std_logic_vector(7 DOWNTO 0); -- Data Bus In 
        data_out : OUT std_logic_vector(7 DOWNTO 0); -- Data Bus Out
        irq : OUT std_logic; -- Interrupt Request out
        --
        -- RS232 Interface Signals
        --
        RxC : IN std_logic; -- Receive Baud Clock
        TxC : IN std_logic; -- Transmit Baud Clock
        RxD : IN std_logic; -- Receive Data
        TxD : OUT std_logic; -- Transmit Data
        DCD_n : IN std_logic; -- Data Carrier Detect
        CTS_n : IN std_logic; -- Clear To Send
        RTS_n : OUT std_logic -- Request To send
    );
END acia6850; --================== End of entity ==============================--

-------------------------------------------------------------------------------
-- Architecture for ACIA_6850 Interface registees
-------------------------------------------------------------------------------

ARCHITECTURE rtl OF acia6850 IS

    TYPE DCD_State_Type IS (DCD_State_Idle, DCD_State_Int, DCD_State_Reset);

    -----------------------------------------------------------------------------
    -- Signals
    -----------------------------------------------------------------------------
    --
    -- Reset signals
    --
    SIGNAL ac_rst : std_logic; -- Reset (Software & Hardware)
    SIGNAL rx_rst : std_logic; -- Receive Reset (Software & Hardware)
    SIGNAL tx_rst : std_logic; -- Transmit Reset (Software & Hardware)

    --------------------------------------------------------------------
    --  Status Register: StatReg 
    ----------------------------------------------------------------------
    --
    -- IO address + 0 Read
    --
    -----------+--------+-------+--------+--------+--------+--------+--------+
    --  Irq    | PErr   | OErr  | FErr   |  CTS   |  DCD   | TxRdy  | RxRdy  |
    -----------+--------+-------+--------+--------+--------+--------+--------+
    --
    -- Irq   - Bit[7] - Interrupt request
    -- PErr  - Bit[6] - Receive Parity error (parity bit does not match)
    -- OErr  - Bit[5] - Receive Overrun error (new character received before last read)
    -- FErr  - Bit[4] - Receive Framing Error (bad stop bit)
    -- CTS   - Bit[3] - Clear To Send level
    -- DCD   - Bit[2] - Data Carrier Detect (lost modem carrier)
    -- TxRdy - Bit[1] - Transmit Buffer Empty (ready to accept next transmit character)
    -- RxRdy - Bit[0] - Receive Data Ready (character received)
    -- 

    SIGNAL StatReg : std_logic_vector(7 DOWNTO 0) := (OTHERS => '0'); -- status register

    ----------------------------------------------------------------------
    --  Control Register: CtrlReg
    ----------------------------------------------------------------------
    --
    -- IO address + 0 Write
    --
    -----------+--------+--------+--------+--------+--------+--------+--------+
    --  RXIEnb |TxCtl(1)|TxCtl(0)|WdFmt(2)|WdFmt(1)|WdFmt(0)|BdCtl(1)|BdCtl(0)|
    -----------+--------+--------+--------+--------+--------+--------+--------+
    -- RxIEnb - Bit[7]
    -- 0       - Rx Interrupt disabled
    -- 1       - Rx Interrupt enabled
    -- TxCtl - Bits[6..5]
    -- 0 1     - Tx Interrupt Enable
    -- 1 0     - RTS high
    -- WdFmt - Bits[4..2]
    -- 0 0 0   - 7 data, even parity, 2 stop
    -- 0 0 1   - 7 data, odd  parity, 2 stop
    -- 0 1 0   - 7 data, even parity, 1 stop
    -- 0 1 1   - 7 data, odd  parity, 1 stop
    -- 1 0 0   - 8 data, no   parity, 2 stop
    -- 1 0 1   - 8 data, no   parity, 1 stop
    -- 1 1 0   - 8 data, even parity, 1 stop
    -- 1 1 1   - 8 data, odd  parity, 1 stop
    -- BdCtl - Bits[1..0]
    -- 0 0     - Baud Clk divide by 1
    -- 0 1     - Baud Clk divide by 16
    -- 1 0     - Baud Clk divide by 64
    -- 1 1     - reset
    SIGNAL CtrlReg : std_logic_vector(7 DOWNTO 0) := (OTHERS => '0'); -- control register

    ----------------------------------------------------------------------
    -- Receive Register
    ----------------------------------------------------------------------
    --
    -- IO address + 1     Read
    --
    SIGNAL RxReg : std_logic_vector(7 DOWNTO 0) := (OTHERS => '0');

    ----------------------------------------------------------------------
    -- Transmit Register
    ----------------------------------------------------------------------
    --
    -- IO address + 1     Write
    --
    SIGNAL TxReg : std_logic_vector(7 DOWNTO 0) := (OTHERS => '0');

    SIGNAL TxDat : std_logic := '1'; -- Transmit data bit
    SIGNAL TxRdy : std_logic := '0'; -- Transmit buffer empty
    SIGNAL RxRdy : std_logic := '0'; -- Receive Data ready
    --
    SIGNAL FErr : std_logic := '0'; -- Frame error
    SIGNAL OErr : std_logic := '0'; -- Output error
    SIGNAL PErr : std_logic := '0'; -- Parity Error
    --
    SIGNAL TxIE : std_logic := '0'; -- Transmit interrupt enable
    SIGNAL RxIE : std_logic := '0'; -- Receive interrupt enable
    --
    SIGNAL RxRd : std_logic := '0'; -- Read receive buffer
    SIGNAL TxWr : std_logic := '0'; -- Write Transmit buffer
    SIGNAL StRd : std_logic := '0'; -- Read status register
    --
    SIGNAL DCDState : DCD_State_Type; -- DCD Reset state sequencer
    SIGNAL DCDDel : std_logic := '0'; -- Delayed DCD_n
    SIGNAL DCDEdge : std_logic := '0'; -- Rising DCD_N Edge Pulse
    SIGNAL DCDInt : std_logic := '0'; -- DCD Interrupt

    SIGNAL BdFmt : std_logic_vector(1 DOWNTO 0) := "00"; -- Baud Clock Format
    SIGNAL WdFmt : std_logic_vector(2 DOWNTO 0) := "000"; -- Data Word Format

    -----------------------------------------------------------------------------
    -- RX Signals
    -----------------------------------------------------------------------------

    TYPE RxStateType IS (RxState_Wait, RxState_Data, RxState_Parity, RxState_Stop);

    SIGNAL RxState : RxStateType; -- receive bit state

    SIGNAL RxDatDel0 : Std_Logic := '0'; -- Delayed Rx Data
    SIGNAL RxDatDel1 : Std_Logic := '0'; -- Delayed Rx Data
    SIGNAL RxDatDel2 : Std_Logic := '0'; -- Delayed Rx Data
    SIGNAL RxDatEdge : Std_Logic := '0'; -- Rx Data Edge pulse

    SIGNAL RxClkDel : Std_Logic := '0'; -- Delayed Rx Input Clock
    SIGNAL RxClkEdge : Std_Logic := '0'; -- Rx Input Clock Edge pulse
    SIGNAL RxStart : Std_Logic := '0'; -- Rx Start request
    SIGNAL RxEnable : Std_Logic := '0'; -- Rx Enabled
    SIGNAL RxClkCnt : Std_Logic_Vector(5 DOWNTO 0) := (OTHERS => '0'); -- Rx Baud Clock Counter
    SIGNAL RxBdClk : Std_Logic := '0'; -- Rx Baud Clock
    SIGNAL RxBdDel : Std_Logic := '0'; -- Delayed Rx Baud Clock

    SIGNAL RxReq : Std_Logic := '0'; -- Rx Data Valid
    SIGNAL RxAck : Std_Logic := '0'; -- Rx Data Valid
    SIGNAL RxParity : Std_Logic := '0'; -- Calculated RX parity bit
    SIGNAL RxBitCount : Std_Logic_Vector(2 DOWNTO 0) := (OTHERS => '0'); -- Rx Bit counter
    SIGNAL RxShiftReg : Std_Logic_Vector(7 DOWNTO 0) := (OTHERS => '0'); -- Shift Register

    -----------------------------------------------------------------------------
    -- TX Signals
    -----------------------------------------------------------------------------
    TYPE TxStateType IS (TxState_Idle, TxState_Start, TxState_Data, TxState_Parity, TxState_Stop);

    SIGNAL TxState : TxStateType; -- Transmitter state

    SIGNAL TxClkDel : Std_Logic := '0'; -- Delayed Tx Input Clock
    SIGNAL TxClkEdge : Std_Logic := '0'; -- Tx Input Clock Edge pulse
    SIGNAL TxClkCnt : Std_Logic_Vector(5 DOWNTO 0) := (OTHERS => '0'); -- Tx Baud Clock Counter
    SIGNAL TxBdClk : Std_Logic := '0'; -- Tx Baud Clock
    SIGNAL TxBdDel : Std_Logic := '0'; -- Delayed Tx Baud Clock

    SIGNAL TxReq : std_logic := '0'; -- Request transmit start
    SIGNAL TxAck : std_logic := '0'; -- Acknowledge transmit start
    SIGNAL TxParity : Std_logic := '0'; -- Parity Bit
    SIGNAL TxBitCount : Std_Logic_Vector(2 DOWNTO 0) := (OTHERS => '0'); -- Data Bit Counter
    SIGNAL TxShiftReg : Std_Logic_Vector(7 DOWNTO 0) := (OTHERS => '0'); -- Transmit shift register

BEGIN

    ---------------------------------------------------------------
    -- ACIA Reset may be hardware or software
    ---------------------------------------------------------------

    acia_reset : PROCESS (clk, rst, ac_rst, dcd_n)
    BEGIN
        --
        -- ACIA reset Synchronous 
        -- Includes software reset
        --
        IF falling_edge(clk) THEN
            ac_rst <= (CtrlReg(1) AND CtrlReg(0)) OR rst;
        END IF;
        -- Receiver reset
        rx_rst <= ac_rst OR DCD_n;
        -- Transmitter reset
        tx_rst <= ac_rst;

    END PROCESS;

    -----------------------------------------------------------------------------
    -- Generate Read / Write strobes.
    -----------------------------------------------------------------------------

    acia_read_write : PROCESS (clk, ac_rst)
    BEGIN
        IF falling_edge(clk) THEN
            IF rst = '1' THEN
                CtrlReg(1 DOWNTO 0) <= "11";
                CtrlReg(7 DOWNTO 2) <= (OTHERS => '0');
                TxReg <= (OTHERS => '0');
                RxRd <= '0';
                TxWr <= '0';
                StRd <= '0';
            ELSE
                RxRd <= '0';
                TxWr <= '0';
                StRd <= '0';
                IF cs = '1' THEN
                    IF Addr = '0' THEN -- Control / Status register
                        IF rw = '0' THEN -- write control register
                            CtrlReg <= data_in;
                        ELSE -- read status register
                            StRd <= '1';
                        END IF;
                    ELSE -- Data Register
                        IF rw = '0' THEN -- write transmiter register
                            TxReg <= data_in;
                            TxWr <= '1';
                        ELSE -- read receiver register
                            RxRd <= '1';
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -----------------------------------------------------------------------------
    -- ACIA Status Register
    -----------------------------------------------------------------------------

    acia_status : PROCESS (clk)
    BEGIN
        IF falling_edge(clk) THEN
            StatReg(0) <= RxRdy; -- Receive Data Ready
            StatReg(1) <= TxRdy AND (NOT CTS_n); -- Transmit Buffer Empty
            StatReg(2) <= DCDInt; -- Data Carrier Detect
            StatReg(3) <= CTS_n; -- Clear To Send
            StatReg(4) <= FErr; -- Framing error
            StatReg(5) <= OErr; -- Overrun error
            StatReg(6) <= PErr; -- Parity error
            StatReg(7) <= (RxIE AND RxRdy) OR
            (RxIE AND DCDInt) OR
            (TxIE AND TxRdy);
        END IF;
    END PROCESS;

    -----------------------------------------------------------------------------
    -- ACIA Transmit Control
    -----------------------------------------------------------------------------

    acia_control : PROCESS (CtrlReg, TxDat)
    BEGIN
        CASE CtrlReg(6 DOWNTO 5) IS
            WHEN "00" => -- Disable TX Interrupts, Assert RTS
                TxD <= TxDat;
                TxIE <= '0';
                RTS_n <= '0';
            WHEN "01" => -- Enable TX interrupts, Assert RTS
                TxD <= TxDat;
                TxIE <= '1';
                RTS_n <= '0';
            WHEN "10" => -- Disable Tx Interrupts, Clear RTS
                TxD <= TxDat;
                TxIE <= '0';
                RTS_n <= '1';
            WHEN "11" => -- Disable Tx interrupts, Assert RTS, send break
                TxD <= '0';
                TxIE <= '0';
                RTS_n <= '0';
            WHEN OTHERS =>
                NULL;
        END CASE;

        RxIE <= CtrlReg(7);
        WdFmt <= CtrlReg(4 DOWNTO 2);
        BdFmt <= CtrlReg(1 DOWNTO 0);
    END PROCESS;

    ---------------------------------------------------------------
    -- Set Data Output Multiplexer
    --------------------------------------------------------------

    acia_data_mux : PROCESS (Addr, RxReg, StatReg)
    BEGIN
        IF Addr = '1' THEN
            data_out <= RxReg; -- read receiver register
        ELSE
            data_out <= StatReg; -- read status register
        END IF;
    END PROCESS;

    irq <= StatReg(7);

    ---------------------------------------------------------------
    -- Data Carrier Detect Edge rising edge detect
    ---------------------------------------------------------------

    acia_dcd_edge : PROCESS (clk, ac_rst)
    BEGIN
        IF falling_edge(clk) THEN
            IF ac_rst = '1' THEN
                DCDDel <= '0';
                DCDEdge <= '0';
            ELSE
                DCDDel <= DCD_n;
                DCDEdge <= DCD_n AND (NOT DCDDel);
            END IF;
        END IF;
    END PROCESS;

    ---------------------------------------------------------------
    -- Data Carrier Detect Interrupt
    ---------------------------------------------------------------
    -- If Data Carrier is lost, an interrupt is generated
    -- To clear the interrupt, first read the status register
    --      then read the data receive register

    acia_dcd_int : PROCESS (clk, ac_rst)
    BEGIN
        IF falling_edge(clk) THEN
            IF ac_rst = '1' THEN
                DCDInt <= '0';
                DCDState <= DCD_State_Idle;
            ELSE
                CASE DCDState IS
                    WHEN DCD_State_Idle =>
                        -- DCD Edge activates interrupt
                        IF DCDEdge = '1' THEN
                            DCDInt <= '1';
                            DCDState <= DCD_State_Int;
                        END IF;
                    WHEN DCD_State_Int =>
                        -- To reset DCD interrupt, 
                        -- First read status
                        IF StRd = '1' THEN
                            DCDState <= DCD_State_Reset;
                        END IF;
                    WHEN DCD_State_Reset =>
                        -- Then read receive register
                        IF RxRd = '1' THEN
                            DCDInt <= '0';
                            DCDState <= DCD_State_Idle;
                        END IF;
                    WHEN OTHERS =>
                        NULL;
                END CASE;
            END IF;
        END IF;
    END PROCESS;

    ---------------------------------------------------------------------
    -- Receiver Clock Edge Detection
    ---------------------------------------------------------------------
    -- A rising edge will produce a one clock cycle pulse

    acia_rx_clock_edge : PROCESS (clk, rx_rst)
    BEGIN
        IF falling_edge(clk) THEN
            IF rx_rst = '1' THEN
                RxClkDel <= '0';
                RxClkEdge <= '0';
            ELSE
                RxClkDel <= RxC;
                RxClkEdge <= (NOT RxClkDel) AND RxC;
            END IF;
        END IF;
    END PROCESS;

    ---------------------------------------------------------------------
    -- Receiver Data Edge Detection
    ---------------------------------------------------------------------
    -- A falling edge will produce a pulse on RxClk wide

    acia_rx_data_edge : PROCESS (clk, rx_rst)
    BEGIN
        IF falling_edge(clk) THEN
            IF rx_rst = '1' THEN
                RxDatDel0 <= '0';
                RxDatDel1 <= '0';
                RxDatDel2 <= '0';
                RxDatEdge <= '0';
            ELSE
                RxDatDel0 <= RxD;
                RxDatDel1 <= RxDatDel0;
                RxDatDel2 <= RxDatDel1;
                RxDatEdge <= RxDatDel0 AND (NOT RxD);
            END IF;
        END IF;
    END PROCESS;

    ---------------------------------------------------------------------
    -- Receiver Start / Stop
    ---------------------------------------------------------------------
    -- Enable the receive clock on detection of a start bit
    -- Disable the receive clock after a byte is received.

    acia_rx_start_stop : PROCESS (clk, rx_rst)
    BEGIN
        IF falling_edge(clk) THEN
            IF rx_rst = '1' THEN
                RxEnable <= '0';
                RxStart <= '0';
            ELSIF (RxEnable = '0') AND (RxDatEdge = '1') THEN
                -- Data Edge detected 
                RxStart <= '1'; -- Request Start and
                RxEnable <= '1'; -- Enable Receive Clock
            ELSIF (RxStart = '1') AND (RxAck = '1') THEN
                -- Data is being received
                RxStart <= '0'; -- Reset Start Request
            ELSIF (RxStart = '0') AND (RxAck = '0') THEN
                -- Data has now been received
                RxEnable <= '0'; -- Disable Receiver until next Start Bit
            END IF;
        END IF;
    END PROCESS;

    ---------------------------------------------------------------------
    -- Receiver Clock Divider
    ---------------------------------------------------------------------
    -- Hold the Rx Clock divider in reset when the receiver is disabled
    -- Advance the count only on a rising Rx clock edge

    acia_rx_clock_divide : PROCESS (clk, rx_rst)
    BEGIN
        IF falling_edge(clk) THEN
            IF rx_rst = '1' THEN
                RxClkCnt <= (OTHERS => '0');
            ELSIF RxDatEdge = '1' THEN
                -- reset on falling data edge
                RxClkCnt <= (OTHERS => '0');
            ELSIF RxClkEdge = '1' THEN
                -- increment count on Clock edge
                RxClkCnt <= std_logic_vector(unsigned(RxClkCnt) + 1);
            END IF;
        END IF;
    END PROCESS;

    ---------------------------------------------------------------------
    -- Receiver Baud Clock Selector
    ---------------------------------------------------------------------
    -- BdFmt
    -- 0 0     - Baud Clk divide by 1
    -- 0 1     - Baud Clk divide by 16
    -- 1 0     - Baud Clk divide by 64
    -- 1 1     - Reset
    --
    acia_rx_baud_clock_select : PROCESS (BdFmt, RxC, RxClkCnt)
    BEGIN
        CASE BdFmt IS
            WHEN "00" => -- Div by 1
                RxBdClk <= RxC;
            WHEN "01" => -- Div by 16
                RxBdClk <= RxClkCnt(3);
            WHEN "10" => -- Div by 64
                RxBdClk <= RxClkCnt(5);
            WHEN OTHERS => -- Software Reset
                RxBdClk <= '0';
        END CASE;
    END PROCESS;

    ---------------------------------------------------------------------
    -- Receiver process
    ---------------------------------------------------------------------
    -- WdFmt - Bits[4..2]
    -- 0 0 0   - 7 data, even parity, 2 stop
    -- 0 0 1   - 7 data, odd  parity, 2 stop
    -- 0 1 0   - 7 data, even parity, 1 stop
    -- 0 1 1   - 7 data, odd  parity, 1 stop
    -- 1 0 0   - 8 data, no   parity, 2 stop
    -- 1 0 1   - 8 data, no   parity, 1 stop
    -- 1 1 0   - 8 data, even parity, 1 stop
    -- 1 1 1   - 8 data, odd  parity, 1 stop

    acia_rx_receive : PROCESS (clk, rst)
    BEGIN
        IF falling_edge(clk) THEN
            IF rx_rst = '1' THEN
                FErr <= '0';
                OErr <= '0';
                PErr <= '0';
                RxShiftReg <= (OTHERS => '0'); -- Reset Shift register
                RxReg <= (OTHERS => '0');
                RxParity <= '0'; -- reset Parity bit
                RxAck <= '0'; -- Receiving data
                RxBitCount <= (OTHERS => '0');
                RxState <= RxState_Wait;
            ELSE
                RxBdDel <= RxBdClk;
                IF RxBdDel = '0' AND RxBdClk = '1' THEN
                    CASE RxState IS
                        WHEN RxState_Wait =>
                            RxShiftReg <= (OTHERS => '0'); -- Reset Shift register
                            RxParity <= '0'; -- Reset Parity bit
                            IF WdFmt(2) = '0' THEN -- WdFmt(2) = '0' => 7 data bits
                                RxBitCount <= "110";
                            ELSE -- WdFmt(2) = '1' => 8 data bits
                                RxBitCount <= "111";
                            END IF;
                            IF RxDatDel2 = '0' THEN -- look for start bit
                                RxState <= RxState_Data; -- if low, start reading data
                            END IF;

                        WHEN RxState_Data => -- Receiving data bits 
                            RxShiftReg <= RxDatDel2 & RxShiftReg(7 DOWNTO 1);
                            RxParity <= RxParity XOR RxDatDel2;
                            RxAck <= '1'; -- Flag receive in progress
                            RxBitCount <= std_logic_vector(unsigned(RxBitCount) - 1);
                            IF RxBitCount = "000" THEN
                                IF WdFmt(2) = '0' THEN -- WdFmt(2) = '0' => 7 data
                                    RxState <= RxState_Parity; -- 7 bits always has parity
                                ELSIF WdFmt(1) = '0' THEN -- WdFmt(2) = '1' => 8 data			         
                                    RxState <= RxState_Stop; -- WdFmt(1) = '0' => no parity
                                    PErr <= '0'; -- Reset Parity Error
                                ELSE
                                    RxState <= RxState_Parity; -- WdFmt(1) = '1' => 8 data + parity
                                END IF;
                            END IF;

                        WHEN RxState_Parity => -- Receive Parity bit
                            IF WdFmt(2) = '0' THEN -- if 7 data bits, shift parity into MSB
                                RxShiftReg <= RxDatDel2 & RxShiftReg(7 DOWNTO 1); -- 7 data + parity
                            END IF;
                            IF RxParity = (RxDatDel2 XOR WdFmt(0)) THEN
                                PErr <= '1'; -- If parity not the same flag error
                            ELSE
                                PErr <= '0';
                            END IF;
                            RxState <= RxState_Stop;

                        WHEN RxState_Stop => -- stop bit (Only one required for RX)
                            RxAck <= '0'; -- Flag Receive Complete
                            RxReg <= RxShiftReg;
                            IF RxDatDel2 = '1' THEN -- stop bit expected
                                FErr <= '0'; -- yes, no framing error
                            ELSE
                                FErr <= '1'; -- no, framing error
                            END IF;
                            IF RxRdy = '1' THEN -- Has previous data been read ? 
                                OErr <= '1'; -- no, overrun error
                            ELSE
                                OErr <= '0'; -- yes, no over run error
                            END IF;
                            RxState <= RxState_Wait;

                        WHEN OTHERS =>
                            RxAck <= '0'; -- Flag Receive Complete
                            RxState <= RxState_Wait;
                    END CASE;
                END IF;
            END IF;
        END IF;

    END PROCESS;

    ---------------------------------------------------------------------
    -- Receiver Read process
    ---------------------------------------------------------------------

    acia_rx_read : PROCESS (clk, rst, RxRdy)
    BEGIN
        IF falling_edge(clk) THEN
            IF rx_rst = '1' THEN
                RxRdy <= '0';
                RxReq <= '0';
            ELSIF RxRd = '1' THEN
                -- Data was read,        
                RxRdy <= '0'; -- Reset receive full
                RxReq <= '1'; -- Request more data
            ELSIF RxReq = '1' AND RxAck = '1' THEN
                -- Data is being received
                RxReq <= '0'; -- reset receive request
            ELSIF RxReq = '0' AND RxAck = '0' THEN
                -- Data now received
                RxRdy <= '1'; -- Flag RxRdy and read Shift Register
            END IF;
        END IF;
    END PROCESS;

    ---------------------------------------------------------------------
    -- Transmit Clock Edge Detection
    -- A falling edge will produce a one clock cycle pulse
    ---------------------------------------------------------------------

    acia_tx_clock_edge : PROCESS (Clk, tx_rst)
    BEGIN
        IF falling_edge(clk) THEN
            IF tx_rst = '1' THEN
                TxClkDel <= '0';
                TxClkEdge <= '0';
            ELSE
                TxClkDel <= TxC;
                TxClkEdge <= TxClkDel AND (NOT TxC);
            END IF;
        END IF;
    END PROCESS;

    ---------------------------------------------------------------------
    -- Transmit Clock Divider
    -- Advance the count only on an input clock pulse
    ---------------------------------------------------------------------

    acia_tx_clock_divide : PROCESS (clk, tx_rst)
    BEGIN
        IF falling_edge(clk) THEN
            IF tx_rst = '1' THEN
                TxClkCnt <= (OTHERS => '0');
            ELSIF TxClkEdge = '1' THEN
                TxClkCnt <= std_logic_vector(unsigned(TxClkCnt) + 1);
            END IF;
        END IF;
    END PROCESS;

    ---------------------------------------------------------------------
    -- Transmit Baud Clock Selector
    ---------------------------------------------------------------------

    acia_tx_baud_clock_select : PROCESS (BdFmt, TxClkCnt, TxC)
    BEGIN
        -- BdFmt
        -- 0 0     - Baud Clk divide by 1
        -- 0 1     - Baud Clk divide by 16
        -- 1 0     - Baud Clk divide by 64
        -- 1 1     - reset
        CASE BdFmt IS
            WHEN "00" => -- Div by 1
                TxBdClk <= TxC;
            WHEN "01" => -- Div by 16
                TxBdClk <= TxClkCnt(3);
            WHEN "10" => -- Div by 64
                TxBdClk <= TxClkCnt(5);
            WHEN OTHERS => -- Software reset
                TxBdClk <= '0';
        END CASE;
    END PROCESS;

    -----------------------------------------------------------------------------
    -- Implements the Tx unit
    -----------------------------------------------------------------------------
    -- WdFmt - Bits[4..2]
    -- 0 0 0   - 7 data, even parity, 2 stop
    -- 0 0 1   - 7 data, odd  parity, 2 stop
    -- 0 1 0   - 7 data, even parity, 1 stop
    -- 0 1 1   - 7 data, odd  parity, 1 stop
    -- 1 0 0   - 8 data, no   parity, 2 stop
    -- 1 0 1   - 8 data, no   parity, 1 stop
    -- 1 1 0   - 8 data, even parity, 1 stop
    -- 1 1 1   - 8 data, odd  parity, 1 stop

    acia_tx_transmit : PROCESS (clk, tx_rst)
    BEGIN
        IF falling_edge(clk) THEN
            IF tx_rst = '1' THEN
                TxDat <= '1';
                TxShiftReg <= (OTHERS => '0');
                TxParity <= '0';
                TxBitCount <= (OTHERS => '0');
                TxAck <= '0';
                TxState <= TxState_Idle;
            ELSE

                TxBdDel <= TxBdClk;
                -- On rising edge of baud clock, run the state machine
                IF TxBdDel = '0' AND TxBdClk = '1' THEN

                    CASE TxState IS
                        WHEN TxState_Idle =>
                            TxDat <= '1';
                            IF TxReq = '1' THEN
                                TxShiftReg <= TxReg; -- Load Shift reg with Tx Data
                                TxAck <= '1';
                                TxState <= TxState_Start;
                            END IF;

                        WHEN TxState_Start =>
                            TxDat <= '0'; -- Start bit
                            TxParity <= '0';
                            IF WdFmt(2) = '0' THEN
                                TxBitCount <= "110"; -- 7 data + parity
                            ELSE
                                TxBitCount <= "111"; -- 8 data
                            END IF;
                            TxState <= TxState_Data;

                        WHEN TxState_Data =>
                            TxDat <= TxShiftReg(0);
                            TxShiftReg <= '1' & TxShiftReg(7 DOWNTO 1);
                            TxParity <= TxParity XOR TxShiftReg(0);
                            TxBitCount <= std_logic_vector(unsigned(TxBitCount) - 1);
                            IF TxBitCount = "000" THEN
                                IF (WdFmt(2) = '1') AND (WdFmt(1) = '0') THEN
                                    IF WdFmt(0) = '0' THEN -- 8 data bits
                                        TxState <= TxState_Stop; -- 2 stops
                                    ELSE
                                        TxAck <= '0';
                                        TxState <= TxState_Idle; -- 1 stop
                                    END IF;
                                ELSE
                                    TxState <= TxState_Parity; -- parity
                                END IF;
                            END IF;

                        WHEN TxState_Parity => -- 7/8 data + parity bit
                            IF WdFmt(0) = '0' THEN
                                TxDat <= NOT(TxParity); -- even parity
                            ELSE
                                TxDat <= TxParity; -- odd parity
                            END IF;
                            IF WdFmt(1) = '0' THEN
                                TxState <= TxState_Stop; -- 2 stops
                            ELSE
                                TxAck <= '0';
                                TxState <= TxState_Idle; -- 1 stop
                            END IF;

                        WHEN TxState_Stop => -- first of two stop bits
                            TxDat <= '1';
                            TxAck <= '0';
                            TxState <= TxState_Idle;

                    END CASE;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    ---------------------------------------------------------------------
    -- Transmitter Write process
    ---------------------------------------------------------------------

    acia_tx_write : PROCESS (clk, tx_rst, TxWr, TxReq, TxAck)
    BEGIN
        IF falling_edge(clk) THEN
            IF tx_rst = '1' THEN
                TxRdy <= '0';
                TxReq <= '0';
            ELSIF TxWr = '1' THEN
                -- Data was read,        
                TxRdy <= '0'; -- Reset transmit empty
                TxReq <= '1'; -- Request data transmit
            ELSIF TxReq = '1' AND TxAck = '1' THEN -- Data is being transmitted
                TxReq <= '0'; -- reset transmit request
            ELSIF TxReq = '0' AND TxAck = '0' THEN -- Data transmitted
                TxRdy <= '1'; -- Flag TxRdy
            END IF;
        END IF;
    END PROCESS;

END rtl;