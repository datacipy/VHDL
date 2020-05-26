LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY spiMaster IS
    GENERIC (
        CLKDIV : INTEGER := 4; -- delitel hodin
        CPOL : STD_LOGIC := '0'; -- polarita
        CPHA : STD_LOGIC := '0' -- faze
    );
    PORT (
        clock : IN STD_LOGIC; --hlavni hodiny
        reset : IN STD_LOGIC; --asynchronni reset
        cs : IN STD_LOGIC; --zacatek prenosu
        cont : IN STD_LOGIC; --pokracovani prenosu
        TxD : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --vstup dat
        miso : IN STD_LOGIC; --master in, slave out
        sclk : BUFFER STD_LOGIC; --spi clock
        mosi : OUT STD_LOGIC; --master out, slave in
        busy : OUT STD_LOGIC := '1'; --vysilac pracuje / data nejsou pripravena
        RxD : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)); --vystup dat
END ENTITY;

ARCHITECTURE main OF spiMaster IS
    TYPE FSM IS(ready, execute); --state machine
    SIGNAL state : FSM; --aktivni stav
    SIGNAL count : INTEGER;
    SIGNAL clkToggle : INTEGER RANGE 0 TO 17; --pocita prepnuti hodin
    SIGNAL txrx : STD_LOGIC; --'1' vysila se, '0' prijima se
    SIGNAL continue : STD_LOGIC; --pokracovani
    SIGNAL rxBuffer : STD_LOGIC_VECTOR(7 DOWNTO 0); --buffer prijimace
    SIGNAL txBuffer : STD_LOGIC_VECTOR(7 DOWNTO 0); --buffer vysilace
    SIGNAL lastBitRx : INTEGER RANGE 0 TO 16; --ktery bit je posledni
    SIGNAL cpolVectorize : std_logic_vector(0 TO 0);
BEGIN

    cpolVectorize(0) <= cpol; --hack
    PROCESS (clock, reset)
    BEGIN

        IF (reset = '1') THEN --reset system
            busy <= '1'; --set busy signal
            mosi <= 'Z'; --set master out to high impedance
            RxD <= (OTHERS => '0'); --clear receive data port
            state <= ready; --go to ready state when reset is exited

        ELSIF (rising_edge(clock)) THEN
            CASE state IS --state FSM

                WHEN ready =>
                    busy <= '0'; --clock out not busy signal
                    mosi <= 'Z'; --set mosi output high impedance
                    continue <= '0'; --clear continue flag
                    count <= 1;

                    --user input to initiate transaction
                    IF (cs = '1') THEN
                        busy <= '1'; --set busy signal
                        sclk <= cpol; --set spi clock polarity
                        txrx <= NOT cpha; --set spi clock phase
                        txBuffer <= TxD; --clock in data for transmit into buffer
                        clkToggle <= 0; --initiate clock toggle counter
                        lastBitRx <= 15 + to_integer(unsigned(cpolVectorize)); --set last rx data bit
                        state <= execute; --proceed to execute state
                        count <= CLKDIV;
                    ELSE
                        state <= ready; --remain in ready state
                    END IF;

                WHEN execute =>
                    busy <= '1'; --set busy signal

                    --system clock to sclk ratio is met
                    IF (count = CLKDIV) THEN
                        count <= 1; --reset system-to-spi clock counter
                        txrx <= NOT txrx; --switch transmit/receive indicator
                        IF (clkToggle = 17) THEN
                            clkToggle <= 0; --reset spi clock toggles counter
                        ELSE
                            clkToggle <= clkToggle + 1; --increment spi clock toggles counter
                        END IF;

                        --spi clock toggle needed
                        IF (clkToggle < 16) THEN
                            sclk <= NOT sclk; --toggle spi clock
                        END IF;

                        --receive spi clock toggle
                        IF (txrx = '0' AND clkToggle < lastBitRx + 1) THEN
                            rxBuffer <= rxBuffer(6 DOWNTO 0) & miso; --shift in received bit
                        END IF;

                        --transmit spi clock toggle
                        IF (txrx = '1' AND clkToggle < lastBitRx) THEN
                            mosi <= txBuffer(7); --clock out data bit
                            txBuffer <= txBuffer(6 DOWNTO 0) & '0'; --shift data transmit buffer
                        END IF;

                        --last data receive, but continue
                        IF (clkToggle = lastBitRx AND cont = '1') THEN
                            txBuffer <= TxD; --reload transmit buffer
                            clkToggle <= lastBitRx - 17; --reset spi clock toggle counter
                            continue <= '1'; --set continue flag
                        END IF;

                        --normal end of transaction, but continue
                        IF (continue = '1') THEN
                            continue <= '0'; --clear continue flag
                            busy <= '0'; --clock out signal that first receive data is ready
                            RxD <= rxBuffer; --clock out received data to output port    
                        END IF;

                        --end of transaction
                        IF ((clkToggle = 17) AND cont = '0') THEN
                            busy <= '0'; --clock out not busy signal
                            mosi <= 'Z'; --set mosi output high impedance
                            RxD <= rxBuffer; --clock out received data to output port
                            state <= ready; --return to ready state
                        ELSE --not end of transaction
                            state <= execute; --remain in execute state
                        END IF;

                    ELSE --system clock to sclk ratio not met
                        count <= count + 1; --increment counter
                        state <= execute; --remain in execute state
                    END IF;

            END CASE;
        END IF;
    END PROCESS;
END ARCHITECTURE;