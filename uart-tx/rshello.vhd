LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY rshello IS
    PORT (
        clk : IN std_logic;
        tx : OUT std_logic);
END ENTITY;

ARCHITECTURE fsm OF rshello IS
    TYPE msg IS ARRAY(0 TO 7) OF std_logic_vector(7 DOWNTO 0);
    SIGNAL str : msg := (X"48", X"65", X"6C", X"6C", X"6F", X"21", X"0D", X"0A"); --hello
    SIGNAL data : std_logic_vector(7 DOWNTO 0);
    SIGNAL ready : std_logic;
    SIGNAL send : std_logic := '0';

BEGIN
    PROCESS (clk) IS
        VARIABLE cnt : unsigned(2 DOWNTO 0) := "111";
    BEGIN
        IF rising_edge(clk) THEN
            IF ready = '1' THEN
                IF send = '0' THEN
                    cnt := cnt + 1;
                    data <= str(to_integer(cnt));
                    --data<=x"41";
                    send <= '1';
                END IF;
            ELSE
                send <= '0';
            END IF;
        END IF;

    END PROCESS;

    transmitter : ENTITY work.uart_tx PORT MAP (clk, '0', tx, send, ready, data);
END ARCHITECTURE;