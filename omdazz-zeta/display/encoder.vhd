library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY encoder IS

port (
 blank: in std_logic;
 r,g,b,i: in std_logic;
 vga_r: out std_logic;
 vga_g : out std_logic;
 vga_b: out std_logic;
 clk: in std_logic
);

END encoder;

architecture main of encoder is


signal sub_i: std_logic;
begin

sub_i <= '0' when (r='0' and g='0' and b='0') else i;

process(clk)
 begin
 if rising_edge(clk) then
vga_r <= r;
vga_g <= g;			
vga_b <= b;			
	end if;
end process;
--vga_r <= r & sub_i & r & r & r;			
			
end architecture;