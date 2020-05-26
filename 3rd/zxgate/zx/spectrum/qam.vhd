--
-- QAM for Color Video Modulator
--
-- 10/01/02 Daniel Wallner	Creation

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity QAM is
	generic(
		IWidth	: integer := 4;	-- Input width
		QWidth	: integer := 6;	-- Quadrature width
		OWidth	: integer := 7	-- Output width
	);
	port(
		Clk		: in std_logic;
		Tick	: in std_logic;
		V		: in std_logic_vector(IWidth - 1 downto 0);
		U		: in std_logic_vector(IWidth - 1 downto 0);
		SinIn	: in std_logic_vector(QWidth - 1 downto 0);
		CosIn	: in std_logic_vector(QWidth - 1 downto 0);
		C		: out std_logic_vector(OWidth - 1 downto 0)
	);
end QAM;

architecture rtl of QAM is

	signal Acc : signed(IWidth + QWidth - 1 downto 0);

begin

	process (Clk)
	begin
		if Clk'event and Clk = '1' then
			if Tick = '1' then
				Acc <= resize(signed(SinIn) * signed(V), IWidth + QWidth);
				C <= std_logic_vector(Acc(IWidth + QWidth - 1 downto IWidth + QWidth - OWidth));
			else
				Acc <= resize(signed(CosIn) * signed(U), IWidth + QWidth) + Acc;
			end if;
		end if;
	end process;

end;
