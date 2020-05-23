--===========================================================================--
--                                                                           --
--  ACIA_Clock.vhd - Synthesizable Baud Rate Clock Divider                   --
--                                                                           --
--===========================================================================--
--
--  File name      : ACIA_Clock.vhd
--
--  Purpose        : Implements a baud rate clock divider for a 6850 compatible
--                   Asynchronous Communications Interface Adapter 
--                  
--  Dependencies   : ieee.std_logic_1164
--                   ieee.std_logic_arith
--                   ieee.std_logic_unsigned
--                   ieee.numeric_std
--                   work.bit_funcs
--
--  Author         : John E. Kent
--
--  Email          : dilbert57@opencores.org      
--
--  Web            : http://opencores.org/project,system09
--
--  ACIA_Clock.vhd is baud rate clock divider for a 6850 compatible ACIA core.
-- 
--  Copyright (C) 2003 - 2010 John Kent
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
-- Revision Name          Date             Description
-- 0.1      John Kent     unknown          Initial version
-- 1.0      John Kent     30th May 2010    Added GPL header 
--          Martin Maly   2020-05-23       Removed deprecated libraries
--      

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
--library unisim;
--	use unisim.vcomponents.all;

ENTITY aciaClock IS
    GENERIC (
        SYS_CLK_FREQ : INTEGER;
        ACIA_CLK_FREQ : INTEGER
    );
    PORT (
        clk : IN Std_Logic; -- System Clock input
        acia_clk : OUT Std_Logic -- ACIA Clock output
    );
END ENTITY;

-------------------------------------------------------------------------------
-- Architecture for ACIA_Clock
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF ACIAClock IS

    FUNCTION log2 (v : IN NATURAL) RETURN NATURAL IS
        VARIABLE temp, log : NATURAL;
    BEGIN
        temp := v / 2;
        log := 0;
        WHILE (temp /= 0) LOOP
            temp := temp/2;
            log := log + 1;
        END LOOP;
        RETURN log;
    END FUNCTION log2;

    CONSTANT FULL_CYCLE : INTEGER := (SYS_CLK_FREQ / ACIA_CLK_FREQ);
    CONSTANT HALF_CYCLE : INTEGER := (FULL_CYCLE / 2);
    SIGNAL acia_count : Std_Logic_Vector(log2(FULL_CYCLE) DOWNTO 0) := (OTHERS => '0');

BEGIN
    --
    -- Baud Rate Clock Divider
    --
    -- 25MHz / 27  = 926,000 KHz = 57,870Bd * 16
    -- 50MHz / 54  = 926,000 KHz = 57,870Bd * 16
    --
    my_acia_clock : PROCESS (clk)
    BEGIN
        IF (clk'event AND clk = '0') THEN
            IF (to_integer(unsigned(acia_count)) = (FULL_CYCLE - 1)) THEN
                acia_clk <= '0';
                acia_count <= (OTHERS => '0'); --"000000";
            ELSE
                IF (to_integer(unsigned(acia_count)) = (HALF_CYCLE - 1)) THEN
                    acia_clk <= '1';
                END IF;
                acia_count <= std_logic_vector(unsigned(acia_count) + 1);
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE;