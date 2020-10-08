LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY segmuxnum IS
	PORT (
		clk : IN std_logic;
		data : IN unsigned(15 DOWNTO 0);

		--fyzicky displej LED
		--seg = segment, 0=aktivni
		segA : OUT std_logic;
		segB : OUT std_logic;
		segC : OUT std_logic;
		segD : OUT std_logic;
		segE : OUT std_logic;
		segF : OUT std_logic;
		segG : OUT std_logic;
		segH : OUT std_logic;
		dig1 : OUT std_logic;
		dig2 : OUT std_logic;
		dig3 : OUT std_logic;
		dig4 : OUT std_logic

	);
END ENTITY;

ARCHITECTURE main OF segmuxnum IS

	SIGNAL D : unsigned(3 DOWNTO 0) := "0000";
	SIGNAL counter : INTEGER RANGE 0 TO 3 := 0;

BEGIN

	PROCESS (clk) IS
	BEGIN
		IF (rising_edge(clk)) THEN
			counter <= counter + 1;
		END IF;
	END PROCESS;

	D <= data(3 DOWNTO 0) WHEN counter = 0
		ELSE
		data(7 DOWNTO 4) WHEN counter = 1
		ELSE
		data(11 DOWNTO 8) WHEN counter = 2
		ELSE
		data(15 DOWNTO 12);

	dig1 <= '0' WHEN counter = 0 ELSE
		'1';
	dig2 <= '0' WHEN counter = 1 ELSE
		'1';
	dig3 <= '0' WHEN counter = 2 ELSE
		'1';
	dig4 <= '0' WHEN counter = 3 ELSE
		'1';

	decoder : ENTITY work.seg7 PORT MAP (D, segA, segB, segC, segD, segE, segF, segG);
	segH <= '1';

END ARCHITECTURE;