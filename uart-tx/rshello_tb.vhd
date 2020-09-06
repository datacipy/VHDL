LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY rshello_tb IS
END ENTITY;

ARCHITECTURE rtl OF rshello_tb IS

  SIGNAL tClk : std_logic := '0';
  SIGNAL tx : std_logic;
  SIGNAL clockEnable : STD_LOGIC := '1';

BEGIN
  clock : PROCESS

  BEGIN
    WHILE clockEnable = '1' LOOP
      WAIT FOR 2 ps;
      tClk <= NOT tClk;
      -- REPORT "Clock tick [" & std_logic'image(tClk) & "]";
    END LOOP;
    WAIT;
  END PROCESS;

  uut : ENTITY work.rshello PORT MAP (clk => tClk, tx => tx);
END ARCHITECTURE;