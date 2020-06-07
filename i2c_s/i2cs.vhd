LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY i2cs IS
    PORT (
        scl : IN std_logic;
        sda : INOUT std_logic := 'Z';
        cStart, cStop : OUT std_logic);
END ENTITY;

ARCHITECTURE main OF i2cs IS
    TYPE tstate IS (S_IDLE, S_START, S_GET8, S_WAITFORSTOP, S_ACTIVE, S_SENDACK);
    SIGNAL state : tstate := S_IDLE;

    SIGNAL start_cond : std_logic := '0';
    SIGNAL stop_cond : std_logic;

    SIGNAL start_prob : std_logic := '0';

    SIGNAL dataIn : std_logic_vector (7 DOWNTO 0) := x"00";

    SIGNAL slaveAddr : std_logic_vector (6 DOWNTO 0) := "1011010";

BEGIN

    startbit1 : PROCESS (sda)
    BEGIN
        IF (falling_edge(sda)) THEN
            IF (state = S_IDLE) THEN
                start_prob <= '1' WHEN (scl = '1')
                    ELSE
                    '0';
            END IF;
        END IF;
    END PROCESS;

    mainMachine : PROCESS (scl)
        VARIABLE count : INTEGER := 0;

    BEGIN
        --scl fall
        IF (falling_edge(scl)) THEN
            IF state = S_IDLE THEN
                IF start_prob = '1' THEN
                    start_cond <= '1';
                    state <= S_START;
                    count := 0;
                ELSE
                    start_cond <= '0';
                END IF;

            ELSIF state = s_get8 THEN
                IF (slaveAddr = dataIn(7 DOWNTO 1)) THEN
                    state <= S_SENDACK;
                    sda <= '0';
                ELSE
                    state <= S_WAITFORSTOP;
                END IF;
            END IF;

        END IF;
        --scl rise

        IF (rising_edge(scl)) THEN
            IF state = S_START THEN
                --
                dataIn(7 DOWNTO 1) <= dataIn(6 DOWNTO 0);
                dataIn(0) <= sda;
                count := count + 1;
                IF (count = 8) THEN
                    count := 0;
                    state <= S_GET8;
                END IF;
            END IF;
        END IF;

    END PROCESS;
    cStart <= start_cond;

END ARCHITECTURE;