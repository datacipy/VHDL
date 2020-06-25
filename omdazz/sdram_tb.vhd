-- Released under the 3-Clause BSD License:
--
-- Copyright 2010-2019 Matthew Hagerty (matthew <at> dnotq <dot> io)
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- 2. Redistributions in binary form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- 3. Neither the name of the copyright holder nor the names of its
-- contributors may be used to endorse or promote products derived from this
-- software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.

-- Matthew Hagerty
-- March 18, 2014
--
-- Testbench for Simple SDRAM Controller for Winbond W9812G6JH-75

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY sdram_tb IS
END sdram_tb;

ARCHITECTURE behavior OF sdram_tb IS

    -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT sdram
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
    END COMPONENT;
    --Inputs
    SIGNAL clk_133 : std_logic := '0';
    SIGNAL reset_i : std_logic := '0';
    SIGNAL refresh_i : std_logic := '0';
    SIGNAL rw_i : std_logic := '0';
    SIGNAL we_i : std_logic := '0';
    SIGNAL addr_i : std_logic_vector(21 DOWNTO 0) := (OTHERS => '0');
    SIGNAL data_i : std_logic_vector(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ub_i : std_logic := '0';
    SIGNAL lb_i : std_logic := '0';

    --BiDirs
    SIGNAL sdData_io : std_logic_vector(15 DOWNTO 0);

    --Outputs
    SIGNAL ready_o : std_logic;
    SIGNAL done_o : std_logic;
    SIGNAL data_o : std_logic_vector(15 DOWNTO 0);
    SIGNAL sdCke_o : std_logic;
    SIGNAL sdCe_bo : std_logic;
    SIGNAL sdRas_bo : std_logic;
    SIGNAL sdCas_bo : std_logic;
    SIGNAL sdWe_bo : std_logic;
    SIGNAL sdBs_o : std_logic_vector(1 DOWNTO 0);
    SIGNAL sdAddr_o : std_logic_vector(11 DOWNTO 0);
    SIGNAL sdDqmh_o : std_logic;
    SIGNAL sdDqml_o : std_logic;

    -- Clock period definitions
    CONSTANT clk_133_period : TIME := 7.5 ns;

    TYPE state_type IS (ST_WAIT, ST_IDLE, ST_READ, ST_WRITE, ST_REREAD, ST_REFRESH);
    SIGNAL state_r, state_x : state_type := ST_WAIT;
BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut : sdram PORT MAP(
        clk_133 => clk_133,
        reset => reset_i,
        refresh => refresh_i,
        rw => rw_i,
        we => we_i,
        addr => addr_i,
        data_i => data_i,
        ub => ub_i,
        lb => lb_i,
        ready => ready_o,
        done => done_o,
        data_o => data_o,
        sdCke => sdCke_o,
        sdCs => sdCe_bo,
        sdRas => sdRas_bo,
        sdCas => sdCas_bo,
        sdWe => sdWe_bo,
        sdBa => sdBs_o,
        sdAddr => sdAddr_o,
        sdData => sdData_io,
        sdUdqm => sdDqmh_o,
        sdLdqm => sdDqml_o
    );

    -- Clock process definitions
    clk_133_process : PROCESS
    BEGIN
        clk_133 <= '0';
        WAIT FOR clk_133_period/2;
        clk_133 <= '1';
        WAIT FOR clk_133_period/2;
    END PROCESS;

    PROCESS (clk_133)
    BEGIN
        IF rising_edge(clk_133) THEN
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
                    addr_i <= "0000000000011000000001";
                ELSE
                    state_x <= ST_WRITE;
                END IF;

            WHEN ST_WRITE =>
                IF done_o = '0' THEN
                    rw_i <= '1';
                    we_i <= '0';
                    addr_i <= "0000000000011000000011";
                    data_i <= X"ADCD";
                    ub_i <= '1';
                    lb_i <= '0';
                ELSE
                    state_x <= ST_REREAD;
                END IF;

            WHEN ST_REREAD =>
                IF done_o = '0' THEN
                    rw_i <= '1';
                    addr_i <= "0000000000011000000011";
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

    -- Stimulus process
    stim_proc : PROCESS
    BEGIN
        -- hold reset state for 100 ns.
        reset_i <= '1';
        WAIT FOR 20 ns;
        reset_i <= '0';
        WAIT;
    END PROCESS;
END;