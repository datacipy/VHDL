library IEEE,work;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity ROM81 is
	port(
		Clk	: in std_logic;
		A	: in std_logic_vector(12 downto 0);
		D	: out std_logic_vector(7 downto 0)
	);
end ROM81;

architecture rtl of ROM81 is
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

	entity_ROM81hll : entity ROM81hll(rtl)
		port map(
			Clk	=> Clk,
			AIn	=> A(11 downto 0),
			D => Dhll);

	entity_ROM81hlh : entity ROM81hlh(rtl)
		port map(
			Clk	=> Clk,
			AIn	=> Ar(11 downto 0),
			D => Dhlh);

	entity_ROM81hh : entity ROM81hh(rtl)
		port map(
			Clk	=> Clk,
			AIn	=> Ar(11 downto 0),
			D => Dhh);

	entity_ROM81l : entity ROM81l(rtl)
		port map(
			Clk	=> Clk,
			AIn	=> A(11 downto 0),
			D => Dl);

	D <= Dhll when Ar(12 downto 10) = "100" else
		Dhlh when Ar(12 downto 10) = "101" else
		Dhh when Ar(12 downto 11) = "11" else Dl;

end;
