library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.bookUtility.all; -- for toString

entity adder16B_tb is
end;

architecture bench of adder16B_tb is


  signal tA,tB, tQ:std_logic_vector (15 downto 0);
  signal tC,tCout: STD_LOGIC;

begin


testing: process

procedure vypis is
  begin
    report toString(tA) & " + " & toString(tB) & " + " & std_logic'image(tC) & 
           " = " & std_logic'image(tCout) & toString(tQ);
end procedure;

    begin


        tC <= '0';
        tA <= "0000000000000000"; tB <= "0000000000000000"; wait for 10 ns; 
        vypis;
        assert tCout = '0' and tQ = "0000000000000000" report "0+0+0 failed" severity failure;
        tA <= "0000000000000001"; tB <= "0000000000000000"; wait for 10 ns; 
        vypis;
        assert tCout = '0' and tQ = "0000000000000001" report "1+0+0 failed" severity failure;
        tA <= "1111111111111111"; tB <= "0000000000000000"; wait for 10 ns; 
        vypis;
        assert tCout = '0' and tQ = "1111111111111111" report "15+0+0 failed" severity failure;
        tA <= "1111111111111111"; tB <= "0000000000000001"; wait for 10 ns; 
        vypis;
        assert tCout = '1' and tQ = "0000000000000000" report "15+1+0 failed" severity failure;

        tC <= '1';
        tA <= "0000000000000000"; tB <= "0000000000000000"; wait for 10 ns; 
        vypis;
        assert tCout = '0' and tQ = "0000000000000001" report "0+0+1 failed" severity failure;
        tA <= "0000000000000001"; tB <= "0000000000000000"; wait for 10 ns; 
        vypis;
        assert tCout = '0' and tQ = "0000000000000010" report "1+0+1 failed" severity failure;
        tA <= "1111111111111111"; tB <= "0000000000000000"; wait for 10 ns; 
        vypis;
        assert tCout = '1' and tQ = "0000000000000000" report "15+0+1 failed" severity failure;
        tA <= "1111111111111111"; tB <= "0000000000000001"; wait for 10 ns; 
        vypis;
        assert tCout = '1' and tQ = "0000000000000001" report "15+1+1 failed" severity failure;


        report "Test OK";
        wait;
    end process;

UUT: entity work.adder16B port map (tA,tB,tC,tQ,tCout);

end bench;