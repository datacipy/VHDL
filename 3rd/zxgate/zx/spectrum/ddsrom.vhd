-- This file was created by ddsrom by Daniel Wallner

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity DDSROM is
	port(
		Addr	: in std_logic_vector(5 downto 0);
		Data	: out std_logic_vector(3 downto 0)
	);
end DDSROM;

architecture rtl of DDSROM is
	subtype ROM_WORD is std_logic_vector(3 downto 0);
	type ROM_TABLE is array(0 to 63) of ROM_WORD;
	constant ROM: ROM_TABLE := ROM_TABLE'(
		ROM_WORD(to_signed(0, 4)),	-- 0x0000
		ROM_WORD(to_signed(1, 4)),	-- 0x0001
		ROM_WORD(to_signed(1, 4)),	-- 0x0002
		ROM_WORD(to_signed(2, 4)),	-- 0x0003
		ROM_WORD(to_signed(3, 4)),	-- 0x0004
		ROM_WORD(to_signed(3, 4)),	-- 0x0005
		ROM_WORD(to_signed(4, 4)),	-- 0x0006
		ROM_WORD(to_signed(4, 4)),	-- 0x0007
		ROM_WORD(to_signed(5, 4)),	-- 0x0008
		ROM_WORD(to_signed(5, 4)),	-- 0x0009
		ROM_WORD(to_signed(6, 4)),	-- 0x000A
		ROM_WORD(to_signed(6, 4)),	-- 0x000B
		ROM_WORD(to_signed(6, 4)),	-- 0x000C
		ROM_WORD(to_signed(7, 4)),	-- 0x000D
		ROM_WORD(to_signed(7, 4)),	-- 0x000E
		ROM_WORD(to_signed(7, 4)),	-- 0x000F
		ROM_WORD(to_signed(7, 4)),	-- 0x0010
		ROM_WORD(to_signed(7, 4)),	-- 0x0011
		ROM_WORD(to_signed(7, 4)),	-- 0x0012
		ROM_WORD(to_signed(7, 4)),	-- 0x0013
		ROM_WORD(to_signed(6, 4)),	-- 0x0014
		ROM_WORD(to_signed(6, 4)),	-- 0x0015
		ROM_WORD(to_signed(6, 4)),	-- 0x0016
		ROM_WORD(to_signed(5, 4)),	-- 0x0017
		ROM_WORD(to_signed(5, 4)),	-- 0x0018
		ROM_WORD(to_signed(4, 4)),	-- 0x0019
		ROM_WORD(to_signed(4, 4)),	-- 0x001A
		ROM_WORD(to_signed(3, 4)),	-- 0x001B
		ROM_WORD(to_signed(3, 4)),	-- 0x001C
		ROM_WORD(to_signed(2, 4)),	-- 0x001D
		ROM_WORD(to_signed(1, 4)),	-- 0x001E
		ROM_WORD(to_signed(1, 4)),	-- 0x001F
		ROM_WORD(to_signed(0, 4)),	-- 0x0020
		ROM_WORD(to_signed(-1, 4)),	-- 0x0021
		ROM_WORD(to_signed(-1, 4)),	-- 0x0022
		ROM_WORD(to_signed(-2, 4)),	-- 0x0023
		ROM_WORD(to_signed(-3, 4)),	-- 0x0024
		ROM_WORD(to_signed(-3, 4)),	-- 0x0025
		ROM_WORD(to_signed(-4, 4)),	-- 0x0026
		ROM_WORD(to_signed(-4, 4)),	-- 0x0027
		ROM_WORD(to_signed(-5, 4)),	-- 0x0028
		ROM_WORD(to_signed(-5, 4)),	-- 0x0029
		ROM_WORD(to_signed(-6, 4)),	-- 0x002A
		ROM_WORD(to_signed(-6, 4)),	-- 0x002B
		ROM_WORD(to_signed(-6, 4)),	-- 0x002C
		ROM_WORD(to_signed(-7, 4)),	-- 0x002D
		ROM_WORD(to_signed(-7, 4)),	-- 0x002E
		ROM_WORD(to_signed(-7, 4)),	-- 0x002F
		ROM_WORD(to_signed(-7, 4)),	-- 0x0030
		ROM_WORD(to_signed(-7, 4)),	-- 0x0031
		ROM_WORD(to_signed(-7, 4)),	-- 0x0032
		ROM_WORD(to_signed(-7, 4)),	-- 0x0033
		ROM_WORD(to_signed(-6, 4)),	-- 0x0034
		ROM_WORD(to_signed(-6, 4)),	-- 0x0035
		ROM_WORD(to_signed(-6, 4)),	-- 0x0036
		ROM_WORD(to_signed(-5, 4)),	-- 0x0037
		ROM_WORD(to_signed(-5, 4)),	-- 0x0038
		ROM_WORD(to_signed(-4, 4)),	-- 0x0039
		ROM_WORD(to_signed(-4, 4)),	-- 0x003A
		ROM_WORD(to_signed(-3, 4)),	-- 0x003B
		ROM_WORD(to_signed(-3, 4)),	-- 0x003C
		ROM_WORD(to_signed(-2, 4)),	-- 0x003D
		ROM_WORD(to_signed(-1, 4)),	-- 0x003E
		ROM_WORD(to_signed(-1, 4)));	-- 0x003F
begin
	Data <= ROM(to_integer(unsigned(Addr)));
end;
