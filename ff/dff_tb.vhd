library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity dff_tb is
end;

architecture bench of dff_tb is

component dff
port (
        D, C: in std_logic;
        Q: out std_logic
    );
end component;

  signal tD,tC,tQ: STD_LOGIC;

begin


testing: process

procedure vypis is
    begin
        report std_logic'image(tD) & " + " & std_logic'image(tC) & " => " & std_logic'image(tQ);
    end procedure;

    begin
        tD <= '0'; tC <= '0'; wait for 10 ns;

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

UUT: dff port map (tD,tC,tQ);

end bench;