LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY bcd IS
    PORT (
        binary : IN std_logic_vector(7 DOWNTO 0);
        decimal : OUT std_logic_vector(9 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE main OF bcd IS

    PROCEDURE add3 (SIGNAL bin : IN std_logic_vector (3 DOWNTO 0);
    SIGNAL ibcd : OUT std_logic_vector (3 DOWNTO 0)) IS
    VARIABLE is_gt_4 : std_logic;
BEGIN
    is_gt_4 := bin(3) OR (bin(2) AND (bin(1) OR bin(0)));

    IF is_gt_4 = '1' THEN
        ibcd <= std_logic_vector(unsigned(bin) + "0011");
    ELSE
        ibcd <= bin;
    END IF;
END PROCEDURE;

SIGNAL U0bin, U1bin, U2bin, U3bin, U4bin, U5bin, U6bin :
std_logic_vector (3 DOWNTO 0);

SIGNAL U0bcd, U1bcd, U2bcd, U3bcd, U4bcd, U5bcd, U6bcd :
std_logic_vector (3 DOWNTO 0);
BEGIN
U0bin <= '0' & binary(7 DOWNTO 5);
U1bin <= U0bcd(2 DOWNTO 0) & binary(4);
U2bin <= U1bcd(2 DOWNTO 0) & binary(3);
U3bin <= U2bcd(2 DOWNTO 0) & binary(2);
U4bin <= U3bcd(2 DOWNTO 0) & binary(1);

U5bin <= '0' & U0bcd(3) & U1bcd(3) & U2bcd(3);
U6bin <= U5bcd(2 DOWNTO 0) & U3bcd(3);

U0 : add3(U0bin, U0bcd);

U1 : add3(U1bin, U1bcd);

U2 : add3(U2bin, U2bcd);

U3 : add3(U3bin, U3bcd);

U4 : add3(U4bin, U4bcd);

U5 : add3(U5bin, U5bcd);

U6 : add3(U6bin, U6bcd);

decimal <= U5bcd(3) & U6bcd & U4bcd & binary(0);
END ARCHITECTURE;