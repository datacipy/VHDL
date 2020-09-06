LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- no parity, 1 stop bit

ENTITY uart_rx IS GENERIC (
    fCLK : INTEGER := 50_000_000;
    fBAUD : INTEGER := 9600
);

PORT (
    clk, rst : IN std_logic;
    rx : IN std_logic := '1';

    rx_valid : OUT std_logic := '0'; -- data valid
    rx_data : OUT std_logic_vector(7 DOWNTO 0) := (OTHERS => '0')

);
END ENTITY;

ARCHITECTURE main OF uart_rx IS
    TYPE state IS (idle, start, data, stop);

    CONSTANT baudrate : INTEGER := (fCLK / fBAUD); --5208
    CONSTANT halfbaudrate : INTEGER := (baudrate / 2); --2604

    SIGNAL fsm : state := idle;
    SIGNAL baudclk : std_logic;
    SIGNAL data_temp : std_logic_vector(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL datacount : unsigned(2 DOWNTO 0) := (OTHERS => '1');
    SIGNAL rxflt : std_logic := '1';
    SIGNAL clken : std_logic := '0';

BEGIN

    filter : PROCESS (clk) IS
        VARIABLE flt : std_logic_vector(3 DOWNTO 0);
    BEGIN
        IF rising_edge(clk) THEN
            IF flt = "0000" THEN
                rxflt <= '0';
            ELSIF flt = "1111" THEN
                rxflt <= '1';
            END IF;

            flt := flt(2 DOWNTO 0) & rx; -- flt <<< rx
        END IF;
    END PROCESS;

    clock : PROCESS (clk)
        VARIABLE counter : INTEGER RANGE 0 TO baudrate - 1 := 0;
    BEGIN
        IF rising_edge(clk) THEN
            IF counter = baudrate - 1 THEN
                baudclk <= '1';
                counter := 0;
            ELSE
                baudclk <= '0';
                counter := counter + 1;
            END IF;
            IF rst = '1' THEN
                baudclk <= '0';
                counter := 0;
            END IF;
            IF clken = '0' THEN
                baudclk <= '0';
                counter := halfbaudrate;
            END IF;
        END IF;
    END PROCESS;

    detect : PROCESS (clk) IS
        VARIABLE old_rx : std_logic := '0';
    BEGIN
        IF rising_edge(clk) THEN
            --detekce sestupné hrany
            --pokud předtím bylo 1 a teď je 0 a stav je idle
            IF old_rx = '1' AND rxflt = '0' AND fsm = idle THEN
                clken <= '1'; --zasynchronizujeme hodiny. První cyklus poloviční
            END IF;
            IF old_rx = '1' AND rxflt = '1' AND fsm = idle THEN
                clken <= '0'; --vypneme hodiny.
            END IF;
            old_rx := rxflt;

            IF rst = '1' THEN
                clken <= '0';
                old_rx := '0';
            END IF;
        END IF;
    END PROCESS;
    receive : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN

            IF baudclk = '1' THEN
                CASE fsm IS

                    WHEN idle =>

                        IF rxflt = '0' THEN
                            datacount <= (OTHERS => '1');
                            fsm <= data;
                            rx_valid <= '0';
                        END IF;

                    WHEN data =>
                        data_temp <= rxflt & data_temp(7 DOWNTO 1);
                        IF datacount = 0 THEN
                            fsm <= stop;
                            datacount <= (OTHERS => '1');
                        ELSE
                            datacount <= datacount - 1;
                        END IF;

                    WHEN stop =>
                        fsm <= idle;
                        rx_valid <= '1';
                        rx_data <= data_temp;

                    WHEN OTHERS => NULL;
                END CASE;
            END IF; --baudclk
            IF rst = '1' THEN
                fsm <= idle;
                rx_valid <= '0';
            END IF;

        END IF; --rising_edge(clk)
    END PROCESS;

END ARCHITECTURE;