library ieee;
use ieee.std_logic_1164.all;
entity alphaDecoder is
	port (
		IOM, A15: in std_logic;
		nRAMCS, nROMCS: out std_logic
	);
end;	

architecture main of alphaDecoder is

begin

nROMCS <= '0' when (IOM='0' and A15='0') else '1';
nRAMCS <= '0' when (IOM='0' and A15='1') else '1';


end architecture;
