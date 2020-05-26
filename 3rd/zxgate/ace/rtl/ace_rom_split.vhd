library IEEE,work;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity ace_rom is
	port(
		Clk	: in std_logic;
		A	: in std_logic_vector(12 downto 0);
		D	: out std_logic_vector(7 downto 0)
	);
end ace_rom;

architecture rtl of ace_rom is

	signal Ar	: std_logic_vector(12 downto 0);
	signal Dhll	: std_logic_vector(7 downto 0);
	signal Dhlh	: std_logic_vector(7 downto 0);
	signal Dhh	: std_logic_vector(7 downto 0);
	signal Dl	: std_logic_vector(7 downto 0);

begin

	process (Clk)
	begin
		if Clk'event and Clk = '1' then
			Ar <= A;
		end if;
	end process;

	entity_ace_rom_hll : entity ace_rom_hll(rtl)
		port map(
			Clk	=> Clk,
			AIn	=> A(11 downto 0),
			D => Dhll);

	entity_ace_rom_hlh : entity ace_rom_hlh(rtl)
		port map(
			Clk	=> Clk,
			AIn	=> Ar(11 downto 0),
			D => Dhlh);

	entity_ace_rom_hh : entity ace_rom_hh(rtl)
		port map(
			Clk	=> Clk,
			AIn	=> Ar(11 downto 0),
			D => Dhh);

	entity_ace_rom_l : entity ace_rom_l(rtl)
		port map(
			Clk	=> Clk,
			AIn	=> A(11 downto 0),
			D => Dl);

	D <= Dhll when Ar(12 downto 10) = "100" else
		Dhlh when Ar(12 downto 10) = "101" else
		Dhh when Ar(12 downto 11) = "11" else Dl;

end;
