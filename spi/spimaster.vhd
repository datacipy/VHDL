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
        sck : BUFFER STD_LOGIC; --spi clock
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

    cpolVectorize(0) <= cpol; --hack kvuli aritmetice
    PROCESS (clock, reset)
    BEGIN

        IF (reset = '1') THEN --reset
            busy <= '1';
            mosi <= 'Z';
            RxD <= (OTHERS => '0');
            state <= ready;

        ELSIF (rising_edge(clock)) THEN
            CASE state IS --state FSM

                WHEN ready =>
                    busy <= '0';
                    mosi <= 'Z';
                    continue <= '0';
                    count <= 1;

                    --zacina transakce
                    IF (cs = '1') THEN
                        busy <= '1';
                        sck <= cpol;
                        txrx <= NOT cpha;
                        txBuffer <= TxD;
                        clkToggle <= 0;
                        -- posledni zmena hodin, ve ktere se prijimaji data
                        lastBitRx <= 15 + to_integer(unsigned(cpolVectorize));
                        state <= execute;
                        count <= CLKDIV; -- aby zmena probehla hned
                    ELSE
                        state <= ready;
                    END IF;

                WHEN execute =>
                    busy <= '1';

                    --pokud je delicka kmitoctu na nejvyssi hodnote
                    IF (count = CLKDIV) THEN
                        count <= 1; --nulujeme delicku
                        txrx <= NOT txrx;

                        --pocet prepnuti hodinoveho pulsu
                        IF (clkToggle = 17) THEN
                            clkToggle <= 0; --uz jsme skoncili
                        ELSE
                            clkToggle <= clkToggle + 1;
                        END IF;

                        --je potreba zmenit SCK?
                        IF (clkToggle < 16) THEN
                            sck <= NOT sck;
                        END IF;

                        --prijem
                        IF (txrx = '0' AND clkToggle < lastBitRx + 1) THEN
                            rxBuffer <= rxBuffer(6 DOWNTO 0) & miso;
                        END IF;

                        --vysilani
                        IF (txrx = '1' AND clkToggle < lastBitRx) THEN
                            mosi <= txBuffer(7);
                            txBuffer <= txBuffer(6 DOWNTO 0) & '0';
                        END IF;

                        --posledni bit, ale pokracuje se
                        IF (clkToggle = lastBitRx AND cont = '1') THEN
                            txBuffer <= TxD; --nacist novou hodnotu
                            clkToggle <= lastBitRx - 17;
                            continue <= '1';
                        END IF;

                        --prenos byte skoncil, ale pokracuje se
                        IF (continue = '1') THEN
                            continue <= '0';
                            busy <= '0'; --puls na vystupu busy dava signal pro dalsi prenos
                            RxD <= rxBuffer;
                        END IF;

                        --konec transakce?
                        IF ((clkToggle = 17) AND cont = '0') THEN
                            busy <= '0'; --busy zrusit
                            mosi <= 'Z';
                            RxD <= rxBuffer; --precteny byte
                            state <= ready; --zpet do stavu ready
                        ELSE --jeste neni konec?
                            state <= execute; --zustavame ve stavu execute
                        END IF;

                    ELSE --delicka kmitoctu jeste nedopocitala k maximu?
                        count <= count + 1; --zvysime jeji hodnotu
                        state <= execute; --zustavame ve stavu execute
                    END IF;

            END CASE;
        END IF;
    END PROCESS;
END ARCHITECTURE;