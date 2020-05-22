library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.bookUtility.all; -- for toString

entity reg8b_tb is
end;

architecture bench of reg8b_tb is

  signal tE,tC: STD_LOGIC;
  signal tD,tQ: std_logic_vector (7 downto 0);

begin


testing: process

procedure vypis is
    begin
        report toString(tQ);
    end procedure;

    begin
        tE <= '1'; tD <= "00000000"; tC <= '0'; wait for 10 ns;



        --pulse
        tC <= '1'; wait for 1 ns; tC<= '0'; wait for 9 ns; assert tQ = "00000000" report "store 0"  severity failure;
        vypis;

        tD <= "01010101";
        --pulse
        tC <= '1'; wait for 1 ns; tC<= '0'; wait for 9 ns; assert tQ = "01010101" report "store 1"  severity failure;
        vypis;

        tD <= "00000000";wait for 10 ns; assert tQ = "01010101" report "store 1"  severity failure;
        vypis;

        tC <= '1'; wait for 1 ns; tC<= '0'; wait for 9 ns; assert tQ = "00000000" report "store 0 again"  severity failure;
        vypis;


        report "Test OK";
        wait;
    end process;

UUT: entity work.reg8b port map (tC,tE,tD,tQ);

end bench;