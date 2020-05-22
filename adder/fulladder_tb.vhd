library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity fulladder_tb is
end;

architecture bench of fulladder_tb is

component fullAdder
    port (
        A, B, Cin:  in std_logic;
        Q, Cout:  out std_logic
    );
end component;

  signal tA,tB,tC,tQ,tCout: STD_LOGIC;

begin


testing: process

procedure vypis is
    begin
        report std_logic'image(tA) & " + " & std_logic'image(tB) & " + " & std_logic'image(tC) & 
               " = " & std_logic'image(tCout) & std_logic'image(tQ);
    end procedure;

    begin
        tC <= '0';
        tA <= '0'; tB <= '0'; wait for 10 ns; assert tQ = '0' and tCout = '0' report "0+0+0 failed" severity failure;
        vypis;
        tA <= '0'; tB <= '1'; wait for 10 ns; assert tQ = '1' and tCout = '0' report "0+1+0 failed"  severity failure;
        vypis;
        tA <= '1'; tB <= '0'; wait for 10 ns; assert tQ = '1' and tCout = '0' report "1+0+0 failed" severity failure;
        vypis;
        tA <= '1'; tB <= '1'; wait for 10 ns; assert tQ = '0' and tCout = '1' report "1+1+0 failed" severity failure;
        vypis;

        tC <= '1';
        tA <= '0'; tB <= '0'; wait for 10 ns; assert tQ = '1' and tCout = '0' report "0+0+1 failed" severity failure;
        vypis;
        tA <= '0'; tB <= '1'; wait for 10 ns; assert tQ = '0' and tCout = '1' report "0+1+1 failed"  severity failure;
        vypis;
        tA <= '1'; tB <= '0'; wait for 10 ns; assert tQ = '0' and tCout = '1' report "1+0+1 failed" severity failure;
        vypis;
        tA <= '1'; tB <= '1'; wait for 10 ns; assert tQ = '1' and tCout = '1' report "1+1+1 failed" severity failure;
        vypis;

        report "Test OK";
        wait;
    end process;

UUT: fullAdder port map (tA,tB,tC,tQ,tCout);

end bench;