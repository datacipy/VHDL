--
-- DDS for Color Video Modulator
--
-- 10/01/02 Daniel Wallner	Creation

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity DDS is
	generic(
		OWidth		: integer := 4;	-- Output width
		TWidth		: integer := 6;	-- Sine table address width
		AWidth		: integer := 19;	-- Phase acc. width
		Increment	: integer := 166035	-- (2^AWidth)*Fout/Fs
	);
	port(
		Clk			: in std_logic;
		Rst			: in std_logic;
		Tick		: in std_logic;
		Phase		: in std_logic_vector(2 downto 0);
		SinOut		: out std_logic_vector(OWidth - 1 downto 0);
		CosOut		: out std_logic_vector(OWidth - 1 downto 0)
	);
end DDS;

architecture rtl of DDS is

	component ddsrom
	port(
		Addr	: in std_logic_vector(TWidth - 1 downto 0);
		Data	: out std_logic_vector(OWidth - 1 downto 0)
	);
	end component;

	constant CosPhase	: integer := 2 ** (TWidth - 2);

	signal Acc			: unsigned(AWidth - 1 downto 0);
	signal SinAddr		: unsigned(TWidth - 1 downto 0);
	signal SinAddrSLV	: std_logic_vector(TWidth - 1 downto 0);
	signal SinData		: std_logic_vector(OWidth - 1 downto 0);

begin

	process (Clk)
		variable AccP1 : unsigned(AWidth - 1 downto 0);
		variable PhaseFull : unsigned(TWidth - 1 downto 0);
	begin
		if Clk'event and Clk = '1' then
			PhaseFull := (others => '0');
			PhaseFull(TWidth - 1 downto TWidth - 3) := unsigned(Phase);
			if Rst = '1' then
				Acc <= (others => '0');
				SinAddr <= (others => '0');
			elsif Tick = '1' then
				AccP1 :=  Acc + Increment;
				Acc <= AccP1;
				SinAddr <= AccP1(AWidth - 1 downto AWidth - TWidth) + PhaseFull;
			else
				SinAddr <= Acc(AWidth - 1 downto AWidth - TWidth) + PhaseFull + CosPhase;
			end if;
		end if;
	end process;

	SinAddrSLV <= std_logic_vector(SinAddr);

	st : ddsrom
		port map(
			Addr => SinAddrSLV,
			Data => SinData);

	process (Clk)
	begin
		if Clk'event and Clk = '1' then
			if Rst = '1' then
				SinOut <= (others => '0');
				CosOut <= (others => '0');
			elsif Tick = '1' then
				CosOut <= SinData;
			else
				SinOut <= SinData;
			end if;
		end if;
	end process;

end;
