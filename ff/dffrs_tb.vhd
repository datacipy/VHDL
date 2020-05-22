library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity dffrs_tb is
end;

architecture bench of dffrs_tb is

component dffrs
    port (
        D, C: in std_logic;
        R, S: in std_logic;
        Q: out std_logic
    );
end component;

  signal tD,tC,tQ, tR, tS: STD_LOGIC;

begin


testing: process

procedure vypis is
    begin
        report std_logic'image(tQ);
    end procedure;

    begin
        tR <= '0'; tS <= '0';
        tD <= '0'; tC <= '0'; wait for 10 ns;

        --reset
        tR <= '1'; wait for 1 ns; tR<= '0'; wait for 9 ns; assert tQ = '0' report "reset"  severity failure;
        vypis;

        --set
        tS <= '1'; wait for 1 ns; tS<= '0'; wait for 9 ns; assert tQ = '1' report "set"  severity failure;
        vypis;


        --pulse
        tC <= '1'; wait for 1 ns; tC<= '0'; wait for 9 ns; assert tQ = '0' report "store 0"  severity failure;
        vypis;

        tD <= '1';
        --pulse
        tC <= '1'; wait for 1 ns; tC<= '0'; wait for 9 ns; assert tQ = '1' report "store 1"  severity failure;
        vypis;

        tD <= '0';wait for 10 ns; assert tQ = '1' report "store 1"  severity failure;
        vypis;

        tC <= '1'; wait for 1 ns; tC<= '0'; wait for 9 ns; assert tQ = '0' report "store 0 again"  severity failure;
        vypis;


        report "Test OK";
        wait;
    end process;

UUT: dffrs port map (tD,tC,tR,tS,tQ);

end bench;