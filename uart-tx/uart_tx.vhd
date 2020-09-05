library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- no parity, 1 stop bit

entity uart_tx is generic (
    fCLK : integer := 50_000_000;
    fBAUD : integer := 9600
);

port (
    clk, rst: in std_logic;
    tx: out std_logic:='1';

    tx_send: in std_logic; --send data
    tx_ready: out std_logic:='1'; -- transmitter ready
    tx_data: in std_logic_vector(7 downto 0)

);
end entity;

architecture main of uart_tx is
    constant baudrate: integer:=(fCLK / fBAUD); --5208
    signal baudclk: std_logic;
	type state is (idle, data, stop);
    signal fsm: state:=idle;

    signal data_temp: std_logic_vector(7 downto 0);
    signal datacount: unsigned(2 downto 0);

    signal txen:std_logic:='0';

    begin
        clock: process(clk)
        variable counter: integer range 0 to baudrate-1 :=0;
        begin
            if rising_edge(clk) then
                if counter = baudrate-1 then
                    baudclk <= '1';
                    counter := 0;
                else
                    baudclk <= '0';
                    counter := counter + 1;
                end if;
                if rst='1' then
                    baudclk <= '0';
                    counter := 0;
                end if;
            end if;
        end process;
transmit: process(clk)
        begin
            if rising_edge(clk) then
                if tx_send='1' and fsm=idle then
                    txen <='1';
                    data_temp<=tx_data;
                end if;    


                if baudclk='1' then

                    tx<='1';
                    case fsm is

                        when idle =>
                            tx_ready<='1';
                            if txen='1' then
                                datacount<=(others=>'1');
                                tx<='0'; --start bit
                                fsm <= data;
                                tx_ready<='0';
                                txen<='0';
                            end if;

                        when data =>
                            tx<=data_temp(0);
                            tx_ready<='0';
                            if datacount=0 then
                                fsm<=stop;
                                datacount<=(others=>'1');
                            else 
                                datacount<=datacount-1;
                                data_temp<='0' & data_temp(7 downto 1);
                            end if;    

                        when stop =>
                            tx<='1'; --stop bit
                            txen<='0';
                            fsm<=idle;
                            tx_ready<='0';

                        when others => null;
                    end case;    

                    if rst='1' then
                        fsm <= idle;
                        tx<='1';
                        txen<='0';
                    end if;    

                end if; --baudclk
            end if; --rising_edge(clk)
        end process;

end architecture;        
