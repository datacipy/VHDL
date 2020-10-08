LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY segmuxnum_fast IS
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

ARCHITECTURE main OF segmuxnum_fast IS

	SIGNAL sA1, sB1, sC1, sD1, sE1, sF1, sG1 : std_logic;
	SIGNAL sA2, sB2, sC2, sD2, sE2, sF2, sG2 : std_logic;
	SIGNAL sA3, sB3, sC3, sD3, sE3, sF3, sG3 : std_logic;
	SIGNAL sA4, sB4, sC4, sD4, sE4, sF4, sG4 : std_logic;
	SIGNAL counter : INTEGER RANGE 0 TO 3 := 0;
BEGIN

	PROCESS (clk) IS
	BEGIN
		IF (rising_edge(clk)) THEN
			counter <= counter + 1;
		END IF;
	END PROCESS;

	segA <= sA1 WHEN counter = 0
		ELSE
		sA2 WHEN counter = 1
		ELSE
		sA3 WHEN counter = 2
		ELSE
		sA4;

	segB <= sB1 WHEN counter = 0
		ELSE
		sB2 WHEN counter = 1
		ELSE
		sB3 WHEN counter = 2
		ELSE
		sB4;

	segC <= sC1 WHEN counter = 0
		ELSE
		sC2 WHEN counter = 1
		ELSE
		sC3 WHEN counter = 2
		ELSE
		sC4;

	segD <= sD1 WHEN counter = 0
		ELSE
		sD2 WHEN counter = 1
		ELSE
		sD3 WHEN counter = 2
		ELSE
		sD4;

	segE <= sE1 WHEN counter = 0
		ELSE
		sE2 WHEN counter = 1
		ELSE
		sE3 WHEN counter = 2
		ELSE
		sE4;

	segF <= sF1 WHEN counter = 0
		ELSE
		sF2 WHEN counter = 1
		ELSE
		sF3 WHEN counter = 2
		ELSE
		sF4;

	segG <= sG1 WHEN counter = 0
		ELSE
		sG2 WHEN counter = 1
		ELSE
		sG3 WHEN counter = 2
		ELSE
		sG4;

	dig1 <= '0' WHEN counter = 0 ELSE
		'1';
	dig2 <= '0' WHEN counter = 1 ELSE
		'1';
	dig3 <= '0' WHEN counter = 2 ELSE
		'1';
	dig4 <= '0' WHEN counter = 3 ELSE
		'1';

	decoder1 : ENTITY work.seg7 PORT MAP (data(3 DOWNTO 0), sA1, sB1, sC1, sD1, sE1, sF1, sG1);
	decoder2 : ENTITY work.seg7 PORT MAP (data(7 DOWNTO 4), sA2, sB2, sC2, sD2, sE2, sF2, sG2);
	decoder3 : ENTITY work.seg7 PORT MAP (data(11 DOWNTO 8), sA3, sB3, sC3, sD3, sE3, sF3, sG3);
	decoder4 : ENTITY work.seg7 PORT MAP (data(15 DOWNTO 12), sA4, sB4, sC4, sD4, sE4, sF4, sG4);
	segH <= '1';

END ARCHITECTURE;