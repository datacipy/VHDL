LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY seg7 IS
	PORT (
		D : IN unsigned(3 DOWNTO 0);
		--displej LED
		--seg = segment, 0=aktivni
		segA : OUT std_logic; --128
		segB : OUT std_logic; --121
		segC : OUT std_logic; --125
		segD : OUT std_logic; --129
		segE : OUT std_logic; --132
		segF : OUT std_logic; --126
		segG : OUT std_logic
	);
END ENTITY;

ARCHITECTURE combi OF seg7 IS

	TYPE decoderT IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR(6 DOWNTO 0);
	CONSTANT decoder : decoderT := (
	"1000000",
	"1111001",
	"0100100",
	"0110000",
	"0011001",
	"0010010",
	"0000010",
	"1111000",
	"0000000",
	"0010000",
	"0001000",
	"0000011",
	"1000110",
	"0100001",
	"0000110",
	"0001110"
	);

	SIGNAL segments : std_logic_vector(6 DOWNTO 0);

BEGIN

	segments <= decoder(to_integer(D));

	segA <= segments(0);
	segB <= segments(1);
	segC <= segments(2);
	segD <= segments(3);
	segE <= segments(4);
	segF <= segments(5);
	segG <= segments(6);

END ARCHITECTURE;