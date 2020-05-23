--
-- A simulation model of PIA8255 PIA
-- Copyright (c) MikeJ - Feb 2007
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- You are responsible for any legal issues arising from your use of this code.
--
-- The latest version of this file can be found at: www.fpgaarcade.com
--
-- Email support@fpgaarcade.com
--
-- Revision list
--
-- version 001 initial release
--

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY PIA8255 IS
    PORT (

        I_ADDR : IN std_logic_vector(1 DOWNTO 0); -- A1-A0
        I_DATA : IN std_logic_vector(7 DOWNTO 0); -- D7-D0
        O_DATA : OUT std_logic_vector(7 DOWNTO 0);
        O_DATA_OE_L : OUT std_logic;

        I_CS_L : IN std_logic;
        I_RD_L : IN std_logic;
        I_WR_L : IN std_logic;

        I_PA : IN std_logic_vector(7 DOWNTO 0);
        O_PA : OUT std_logic_vector(7 DOWNTO 0);
        O_PA_OE_L : OUT std_logic_vector(7 DOWNTO 0);

        I_PB : IN std_logic_vector(7 DOWNTO 0);
        O_PB : OUT std_logic_vector(7 DOWNTO 0);
        O_PB_OE_L : OUT std_logic_vector(7 DOWNTO 0);

        I_PC : IN std_logic_vector(7 DOWNTO 0);
        O_PC : OUT std_logic_vector(7 DOWNTO 0);
        O_PC_OE_L : OUT std_logic_vector(7 DOWNTO 0);

        RESET : IN std_logic;
        ENA : IN std_logic; -- (CPU) clk enable
        CLK : IN std_logic
    );
END;

ARCHITECTURE RTL OF PIA8255 IS

    -- registers
    SIGNAL bit_mask : std_logic_vector(7 DOWNTO 0);
    SIGNAL r_porta : std_logic_vector(7 DOWNTO 0);
    SIGNAL r_portb : std_logic_vector(7 DOWNTO 0);
    SIGNAL r_portc : std_logic_vector(7 DOWNTO 0);
    SIGNAL r_control : std_logic_vector(7 DOWNTO 0);
    --
    SIGNAL porta_we : std_logic;
    SIGNAL portb_we : std_logic;
    SIGNAL porta_re : std_logic;
    SIGNAL portb_re : std_logic;
    --
    SIGNAL porta_we_t1 : std_logic;
    SIGNAL portb_we_t1 : std_logic;
    SIGNAL porta_re_t1 : std_logic;
    SIGNAL portb_re_t1 : std_logic;
    --
    SIGNAL porta_we_rising : BOOLEAN;
    SIGNAL portb_we_rising : BOOLEAN;
    SIGNAL porta_re_rising : BOOLEAN;
    SIGNAL portb_re_rising : BOOLEAN;
    --
    SIGNAL groupa_mode : std_logic_vector(1 DOWNTO 0); -- port a/c upper
    SIGNAL groupb_mode : std_logic; -- port b/c lower
    --
    SIGNAL porta_read : std_logic_vector(7 DOWNTO 0);
    SIGNAL portb_read : std_logic_vector(7 DOWNTO 0);
    SIGNAL portc_read : std_logic_vector(7 DOWNTO 0);
    SIGNAL control_read : std_logic_vector(7 DOWNTO 0);
    SIGNAL mode_clear : std_logic;
    --
    SIGNAL a_inte1 : std_logic;
    SIGNAL a_inte2 : std_logic;
    SIGNAL b_inte : std_logic;
    --
    SIGNAL a_intr : std_logic;
    SIGNAL a_obf_l : std_logic;
    SIGNAL a_ibf : std_logic;
    SIGNAL a_ack_l : std_logic;
    SIGNAL a_stb_l : std_logic;
    SIGNAL a_ack_l_t1 : std_logic;
    SIGNAL a_stb_l_t1 : std_logic;
    --
    SIGNAL b_intr : std_logic;
    SIGNAL b_obf_l : std_logic;
    SIGNAL b_ibf : std_logic;
    SIGNAL b_ack_l : std_logic;
    SIGNAL b_stb_l : std_logic;
    SIGNAL b_ack_l_t1 : std_logic;
    SIGNAL b_stb_l_t1 : std_logic;
    --
    SIGNAL a_ack_l_rising : BOOLEAN;
    SIGNAL a_stb_l_rising : BOOLEAN;
    SIGNAL b_ack_l_rising : BOOLEAN;
    SIGNAL b_stb_l_rising : BOOLEAN;
    --
    SIGNAL porta_ipreg : std_logic_vector(7 DOWNTO 0);
    SIGNAL portb_ipreg : std_logic_vector(7 DOWNTO 0);
BEGIN
    --
    -- mode 0   - basic input/output
    -- mode 1   - strobed input/output
    -- mode 2/3 - bi-directional bus
    --
    -- control word (write)
    --
    -- D7    mode set flag        1 = active
    -- D6..5 GROUPA mode selection (mode 0,1,2)
    -- D4    GROUPA porta         1 = input, 0 = output
    -- D3    GROUPA portc upper   1 = input, 0 = output
    -- D2    GROUPB mode selection (mode 0 ,1)
    -- D1    GROUPB portb         1 = input, 0 = output
    -- D0    GROUPB portc lower   1 = input, 0 = output
    --
    -- D7    bit set/reset        0 = active
    -- D6..4 x
    -- D3..1 bit select
    -- d0    1 = set, 0 - reset
    --
    -- all output registers including status are reset when mode is changed
    --1. Port A:
    --All Modes: Output data is cleared, input data is not cleared.

    --2. Port B:
    --Mode 0: Output data is cleared, input data is not cleared.
    --Mode 1 and 2: Both output and input data are cleared.

    --3. Port C:
    --Mode 0:Output data is cleared, input data is not cleared.
    --Mode 1 and 2: IBF and INTR are cleared and OBF# is set.
    --Outputs in Port C which are not used for handshaking or interrupt signals are cleared.
    --Inputs such as STB#, ACK#, or "spare" inputs are not affected. The interrupts for Ports A and B are disabled.

    p_bit_mask : PROCESS (I_DATA)
    BEGIN
        bit_mask <= x"01";
        CASE I_DATA(3 DOWNTO 1) IS
            WHEN "000" => bit_mask <= x"01";
            WHEN "001" => bit_mask <= x"02";
            WHEN "010" => bit_mask <= x"04";
            WHEN "011" => bit_mask <= x"08";
            WHEN "100" => bit_mask <= x"10";
            WHEN "101" => bit_mask <= x"20";
            WHEN "110" => bit_mask <= x"40";
            WHEN "111" => bit_mask <= x"80";
            WHEN OTHERS => NULL;
        END CASE;
    END PROCESS;

    p_write_reg_reset : PROCESS (RESET, CLK)
        VARIABLE r_portc_masked : std_logic_vector(7 DOWNTO 0);
        VARIABLE r_portc_setclr : std_logic_vector(7 DOWNTO 0);
    BEGIN
        IF (RESET = '1') THEN
            r_porta <= x"00";
            r_portb <= x"00";
            r_portc <= x"00";
            r_control <= x"9B"; -- 10011011
            mode_clear <= '1';
        ELSIF rising_edge(CLK) THEN

            r_portc_masked := (NOT bit_mask) AND r_portc;
            FOR i IN 0 TO 7 LOOP
                r_portc_setclr(i) := bit_mask(i) AND I_DATA(0);
            END LOOP;

            IF (ENA = '1') THEN
                mode_clear <= '0';
                IF (I_CS_L = '0') AND (I_WR_L = '0') THEN
                    CASE I_ADDR IS
                        WHEN "00" => r_porta <= I_DATA;
                        WHEN "01" => r_portb <= I_DATA;
                        WHEN "10" => r_portc <= I_DATA;

                        WHEN "11" => IF (I_DATA(7) = '0') THEN -- set/clr
                            r_portc <= r_portc_masked OR r_portc_setclr;
                        ELSE
                            --mode_clear <= '1';
                            --r_porta    <= x"00";
                            --r_portb    <= x"00"; -- clear port b input reg
                            --r_portc    <= x"00"; -- clear control sigs
                            r_control <= I_DATA; -- load new mode
                    END IF;
                    WHEN OTHERS => NULL;
                END CASE;
            END IF;
        END IF;
    END IF;
END PROCESS;

p_decode_control : PROCESS (r_control)
BEGIN
    groupa_mode <= r_control(6 DOWNTO 5);
    groupb_mode <= r_control(2);
END PROCESS;

p_oe : PROCESS (I_CS_L, I_RD_L)
BEGIN
    O_DATA_OE_L <= '1';
    IF (I_CS_L = '0') AND (I_RD_L = '0') THEN
        O_DATA_OE_L <= '0';
    END IF;
END PROCESS;

p_read : PROCESS (I_ADDR, porta_read, portb_read, portc_read, control_read)
BEGIN
    O_DATA <= x"00"; -- default
    --if (I_CS_L = '0') and (I_RD_L = '0') then -- not required
    CASE I_ADDR IS
        WHEN "00" => O_DATA <= porta_read;
        WHEN "01" => O_DATA <= portb_read;
        WHEN "10" => O_DATA <= portc_read;
        WHEN "11" => O_DATA <= control_read;
        WHEN OTHERS => NULL;
    END CASE;
    --end if;
END PROCESS;
control_read(7) <= '1'; -- always 1
control_read(6 DOWNTO 0) <= r_control(6 DOWNTO 0);

p_rw_control : PROCESS (I_CS_L, I_RD_L, I_WR_L, I_ADDR)
BEGIN
    porta_we <= '0';
    portb_we <= '0';
    porta_re <= '0';
    portb_re <= '0';

    IF (I_CS_L = '0') AND (I_ADDR = "00") THEN
        porta_we <= NOT I_WR_L;
        porta_re <= NOT I_RD_L;
    END IF;

    IF (I_CS_L = '0') AND (I_ADDR = "01") THEN
        portb_we <= NOT I_WR_L;
        portb_re <= NOT I_RD_L;
    END IF;
END PROCESS;

p_rw_control_reg : PROCESS
BEGIN
    WAIT UNTIL rising_edge(CLK);
    IF (ENA = '1') THEN
        porta_we_t1 <= porta_we;
        portb_we_t1 <= portb_we;
        porta_re_t1 <= porta_re;
        portb_re_t1 <= portb_re;

        a_stb_l_t1 <= a_stb_l;
        a_ack_l_t1 <= a_ack_l;
        b_stb_l_t1 <= b_stb_l;
        b_ack_l_t1 <= b_ack_l;
    END IF;
END PROCESS;

porta_we_rising <= (porta_we = '0') AND (porta_we_t1 = '1'); -- falling as inverted
portb_we_rising <= (portb_we = '0') AND (portb_we_t1 = '1'); --  "
porta_re_rising <= (porta_re = '0') AND (porta_re_t1 = '1'); -- falling as inverted
portb_re_rising <= (portb_re = '0') AND (portb_re_t1 = '1'); --  "
--
a_stb_l_rising <= (a_stb_l = '1') AND (a_stb_l_t1 = '0');
a_ack_l_rising <= (a_ack_l = '1') AND (a_ack_l_t1 = '0');
b_stb_l_rising <= (b_stb_l = '1') AND (b_stb_l_t1 = '0');
b_ack_l_rising <= (b_ack_l = '1') AND (b_ack_l_t1 = '0');
--
-- GROUP A
-- in mode 1
--
-- d4=1 (porta = input)
--   pc7,6 io (d3=1 input, d3=0 output)
--   pc5 output a_ibf
--   pc4 input  a_stb_l
--   pc3 output a_intr
--
-- d4=0 (porta = output)
--   pc7 output a_obf_l
--   pc6 input  a_ack_l
--   pc5,4 io (d3=1 input, d3=0 output)
--   pc3 output a_intr
--
-- GROUP B
-- in mode 1
-- d1=1 (portb = input)
--   pc2 input  b_stb_l
--   pc1 output b_ibf
--   pc0 output b_intr
--
-- d1=0 (portb = output)
--   pc2 input  b_ack_l
--   pc1 output b_obf_l
--   pc0 output b_intr
-- WHEN AN INPUT
--
-- stb_l a low on this input latches input data
-- ibf   a high on this output indicates data latched. set by stb_l and reset by rising edge of RD_L
-- intr  a high on this output indicates interrupt. set by stb_l high, ibf high and inte high. reset by falling edge of RD_L
-- inte A controlled by bit/set PC4
-- inte B controlled by bit/set PC2

-- WHEN AN OUTPUT
--
-- obf_l output will go low when cpu has written data
-- ack_l input - a low on this clears obf_l
-- intr  output set when ack_l is high, obf_l is high and inte is one. reset by falling edge of WR_L
-- inte A controlled by bit/set PC6
-- inte B controlled by bit/set PC2

-- GROUP A
-- in mode 2
--
-- porta = IO
--
--  control bits 2..0 still control groupb/c lower 2..0
--
--
--  PC7 output a_obf
--  PC6 input  a_ack_l
--  PC5 output a_ibf
--  PC4 input  a_stb_l
--  PC3 is still interrupt out
p_control_flags : PROCESS (RESET, CLK)
    VARIABLE we : BOOLEAN;
    VARIABLE set1 : BOOLEAN;
    VARIABLE set2 : BOOLEAN;
BEGIN
    IF (RESET = '1') THEN
        a_obf_l <= '1';
        a_inte1 <= '0';
        a_ibf <= '0';
        a_inte2 <= '0';
        a_intr <= '0';
        --
        b_inte <= '0';
        b_obf_l <= '1';
        b_ibf <= '0';
        b_intr <= '0';
    ELSIF rising_edge(CLK) THEN
        we := (I_CS_L = '0') AND (I_WR_L = '0') AND (I_ADDR = "11") AND (I_DATA(7) = '0');

        IF (ENA = '1') THEN
            IF (mode_clear = '1') THEN
                a_obf_l <= '1';
                a_inte1 <= '0';
                a_ibf <= '0';
                a_inte2 <= '0';
                a_intr <= '0';
                --
                b_inte <= '0';
                b_obf_l <= '1';
                b_ibf <= '0';
                b_intr <= '0';
            ELSE
                IF (bit_mask(7) = '1') AND we THEN
                    a_obf_l <= I_DATA(0);
                ELSE
                    IF porta_we_rising THEN
                        a_obf_l <= '0';
                    ELSIF (a_ack_l = '0') THEN
                        a_obf_l <= '1';
                    END IF;
                END IF;
                --
                IF (bit_mask(6) = '1') AND we THEN
                    a_inte1 <= I_DATA(0);
                END IF; -- bus set when mode1 & input?
                --
                IF (bit_mask(5) = '1') AND we THEN
                    a_ibf <= I_DATA(0);
                ELSE
                    IF porta_re_rising THEN
                        a_ibf <= '0';
                    ELSIF (a_stb_l = '0') THEN
                        a_ibf <= '1';
                    END IF;
                END IF;
                --
                IF (bit_mask(4) = '1') AND we THEN
                    a_inte2 <= I_DATA(0);
                END IF; -- bus set when mode1 & output?
                --
                set1 := a_ack_l_rising AND (a_obf_l = '1') AND (a_inte1 = '1');
                set2 := a_stb_l_rising AND (a_ibf = '1') AND (a_inte2 = '1');
                --
                IF (bit_mask(3) = '1') AND we THEN
                    a_intr <= I_DATA(0);
                ELSE
                    IF (groupa_mode(1) = '1') THEN
                        IF (porta_we = '1') OR (porta_re = '1') THEN
                            a_intr <= '0';
                        ELSIF set1 OR set2 THEN
                            a_intr <= '1';
                        END IF;
                    ELSE
                        IF (r_control(4) = '0') THEN -- output
                            IF (porta_we = '1') THEN -- falling ?
                                a_intr <= '0';
                            ELSIF set1 THEN
                                a_intr <= '1';
                            END IF;
                        ELSIF (r_control(4) = '1') THEN -- input
                            IF (porta_re = '1') THEN -- falling ?
                                a_intr <= '0';
                            ELSIF set2 THEN
                                a_intr <= '1';
                            END IF;
                        END IF;
                    END IF;
                END IF;
                --
                IF (bit_mask(2) = '1') AND we THEN
                    b_inte <= I_DATA(0);
                END IF; -- bus set?

                IF (bit_mask(1) = '1') AND we THEN
                    b_obf_l <= I_DATA(0);
                ELSE
                    IF (r_control(1) = '0') THEN -- output
                        IF portb_we_rising THEN
                            b_obf_l <= '0';
                        ELSIF (b_ack_l = '0') THEN
                            b_obf_l <= '1';
                        END IF;
                    ELSE
                        IF portb_re_rising THEN
                            b_ibf <= '0';
                        ELSIF (b_stb_l = '0') THEN
                            b_ibf <= '1';
                        END IF;
                    END IF;
                END IF;

                IF (bit_mask(0) = '1') AND we THEN
                    b_intr <= I_DATA(0);
                ELSE
                    IF (r_control(1) = '0') THEN -- output
                        IF (portb_we = '1') THEN -- falling ?
                            b_intr <= '0';
                        ELSIF b_ack_l_rising AND (b_obf_l = '1') AND (b_inte = '1') THEN
                            b_intr <= '1';
                        END IF;
                    ELSE
                        IF (portb_re = '1') THEN -- falling ?
                            b_intr <= '0';
                        ELSIF b_stb_l_rising AND (b_ibf = '1') AND (b_inte = '1') THEN
                            b_intr <= '1';
                        END IF;
                    END IF;
                END IF;

            END IF;
        END IF;
    END IF;
END PROCESS;

p_porta : PROCESS (r_porta, r_control, groupa_mode, r_porta, I_PA, porta_ipreg, a_ack_l)
BEGIN
    -- D4    GROUPA porta         1 = input, 0 = output
    O_PA <= x"FF"; -- if not driven, float high
    O_PA_OE_L <= x"FF";
    porta_read <= x"00";

    IF (groupa_mode = "00") THEN -- simple io
        IF (r_control(4) = '0') THEN -- output
            O_PA <= r_porta;
            O_PA_OE_L <= x"00";
        END IF;
        porta_read <= I_PA;
    ELSIF (groupa_mode = "01") THEN -- strobed
        IF (r_control(4) = '0') THEN -- output
            O_PA <= r_porta;
            O_PA_OE_L <= x"00";
        END IF;
        porta_read <= porta_ipreg;
    ELSE -- if (groupa_mode(1) = '1') then -- bi dir
        IF (a_ack_l = '0') THEN -- output enable
            O_PA <= r_porta;
            O_PA_OE_L <= x"00";
        END IF;
        porta_read <= porta_ipreg; -- latched data
    END IF;

END PROCESS;

p_portb : PROCESS (r_portb, r_control, groupb_mode, r_portb, I_PB, portb_ipreg)
BEGIN
    O_PB <= x"FF"; -- if not driven, float high
    O_PB_OE_L <= x"FF";
    portb_read <= x"00";

    IF (groupb_mode = '0') THEN -- simple io
        IF (r_control(1) = '0') THEN -- output
            O_PB <= r_portb;
            O_PB_OE_L <= x"00";
        END IF;
        portb_read <= I_PB;
    ELSE -- strobed mode
        IF (r_control(1) = '0') THEN -- output
            O_PB <= r_portb;
            O_PB_OE_L <= x"00";
        END IF;
        portb_read <= portb_ipreg;
    END IF;
END PROCESS;

p_portc_out : PROCESS (r_portc, r_control, groupa_mode, groupb_mode,
    a_obf_l, a_ibf, a_intr, b_obf_l, b_ibf, b_intr)
BEGIN
    O_PC <= x"FF"; -- if not driven, float high
    O_PC_OE_L <= x"FF";

    -- bits 7..4
    IF (groupa_mode = "00") THEN -- simple io
        IF (r_control(3) = '0') THEN -- output
            O_PC (7 DOWNTO 4) <= r_portc(7 DOWNTO 4);
            O_PC_OE_L(7 DOWNTO 4) <= x"0";
        END IF;
    ELSIF (groupa_mode = "01") THEN -- mode1

        IF (r_control(4) = '0') THEN -- port a output
            O_PC (7) <= a_obf_l;
            O_PC_OE_L(7) <= '0';
            -- 6 is ack_l input
            IF (r_control(3) = '0') THEN -- port c output
                O_PC (5 DOWNTO 4) <= r_portc(5 DOWNTO 4);
                O_PC_OE_L(5 DOWNTO 4) <= "00";
            END IF;
        ELSE -- port a input
            IF (r_control(3) = '0') THEN -- port c output
                O_PC (7 DOWNTO 6) <= r_portc(7 DOWNTO 6);
                O_PC_OE_L(7 DOWNTO 6) <= "00";
            END IF;
            O_PC (5) <= a_ibf;
            O_PC_OE_L(5) <= '0';
            -- 4 is stb_l input
        END IF;

    ELSE -- if (groupa_mode(1) = '1') then -- mode2
        O_PC (7) <= a_obf_l;
        O_PC_OE_L(7) <= '0';
        -- 6 is ack_l input
        O_PC (5) <= a_ibf;
        O_PC_OE_L(5) <= '0';
        -- 4 is stb_l input
    END IF;

    -- bit 3 (controlled by group a)
    IF (groupa_mode = "00") THEN -- group a steals this bit
        --if (groupb_mode = '0') then -- we will let bit 3 be driven, data sheet is a bit confused about this
        IF (r_control(0) = '0') THEN -- ouput (note, groupb control bit)
            O_PC (3) <= r_portc(3);
            O_PC_OE_L(3) <= '0';
        END IF;
        --
    ELSE -- stolen
        O_PC (3) <= a_intr;
        O_PC_OE_L(3) <= '0';
    END IF;

    -- bits 2..0
    IF (groupb_mode = '0') THEN -- simple io
        IF (r_control(0) = '0') THEN -- output
            O_PC (2 DOWNTO 0) <= r_portc(2 DOWNTO 0);
            O_PC_OE_L(2 DOWNTO 0) <= "000";
        END IF;
    ELSE
        -- mode 1
        -- 2 is input
        IF (r_control(1) = '0') THEN -- output
            O_PC (1) <= b_obf_l;
            O_PC_OE_L(1) <= '0';
        ELSE -- input
            O_PC (1) <= b_ibf;
            O_PC_OE_L(1) <= '0';
        END IF;
        O_PC (0) <= b_intr;
        O_PC_OE_L(0) <= '0';
    END IF;
END PROCESS;

p_portc_in : PROCESS (r_portc, I_PC, r_control, groupa_mode, groupb_mode, a_ibf, b_obf_l,
    a_obf_l, a_inte1, a_inte2, a_intr, b_inte, b_ibf, b_intr)
BEGIN
    portc_read <= x"00";

    a_stb_l <= '1';
    a_ack_l <= '1';
    b_stb_l <= '1';
    b_ack_l <= '1';

    IF (groupa_mode = "01") THEN -- mode1 or 2
        IF (r_control(4) = '0') THEN -- port a output
            a_ack_l <= I_PC(6);
        ELSE -- port a input
            a_stb_l <= I_PC(4);
        END IF;
    ELSIF (groupa_mode(1) = '1') THEN -- mode 2
        a_ack_l <= I_PC(6);
        a_stb_l <= I_PC(4);
    END IF;

    IF (groupb_mode = '1') THEN
        IF (r_control(1) = '0') THEN -- output
            b_ack_l <= I_PC(2);
        ELSE -- input
            b_stb_l <= I_PC(2);
        END IF;
    END IF;

    IF (groupa_mode = "00") THEN -- simple io
        portc_read(7 DOWNTO 3) <= I_PC(7 DOWNTO 3);
    ELSIF (groupa_mode = "01") THEN
        IF (r_control(4) = '0') THEN -- port a output
            portc_read(7 DOWNTO 3) <= a_obf_l & a_inte1 & I_PC(5 DOWNTO 4) & a_intr;
        ELSE -- input
            portc_read(7 DOWNTO 3) <= I_PC(7 DOWNTO 6) & a_ibf & a_inte2 & a_intr;
        END IF;
    ELSE -- mode 2
        portc_read(7 DOWNTO 3) <= a_obf_l & a_inte1 & a_ibf & a_inte2 & a_intr;
    END IF;

    IF (groupb_mode = '0') THEN -- simple io
        portc_read(2 DOWNTO 0) <= I_PC(2 DOWNTO 0);
    ELSE
        IF (r_control(1) = '0') THEN -- output
            portc_read(2 DOWNTO 0) <= b_inte & b_obf_l & b_intr;
        ELSE -- input
            portc_read(2 DOWNTO 0) <= b_inte & b_ibf & b_intr;
        END IF;
    END IF;
END PROCESS;

p_ipreg : PROCESS
BEGIN
    WAIT UNTIL rising_edge(CLK);
    --   pc4 input  a_stb_l
    --   pc2 input  b_stb_l

    IF (ENA = '1') THEN
        IF (a_stb_l = '0') THEN
            porta_ipreg <= I_PA;
        END IF;

        IF (mode_clear = '1') THEN
            portb_ipreg <= (OTHERS => '0');
        ELSIF (b_stb_l = '0') THEN
            portb_ipreg <= I_PB;
        END IF;
    END IF;
END PROCESS;

END ARCHITECTURE RTL;