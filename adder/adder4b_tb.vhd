library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity adder4b_tb is
end;

architecture bench of adder4b_tb is

    
component adder4B is
  port (A, B: in std_logic_vector (3 downto 0);
  Cin: in std_logic;
  Q: out std_logic_vector (3 downto 0);
  Cout: out std_logic);
end component;

  signal tA,tB, tQ:std_logic_vector (3 downto 0);
  signal tC,tCout: STD_LOGIC;

begin


testing: process

function toString ( a: std_logic_vector) return string is
  variable b : string (1 to a'length) := (others => NUL);
  variable stri : integer := 1; 
  begin
    for i in a'range loop
      b(stri) := std_logic'image(a((i)))(2);
    stri := stri+1;
    end loop;
  return b;
end function;

procedure vypis is
  begin
    report toString(tA) & " + " & toString(tB) & " + " & std_logic'image(tC) & 
           " = " & std_logic'image(tCout) & toString(tQ);
end procedure;

    begin


        tC <= '0';
        tA <= "0000"; tB <= "0000"; wait for 10 ns; 
        vypis;
        assert tCout = '0' and tQ = "0000" report "0+0+0 failed" severity failure;
        tA <= "0001"; tB <= "0000"; wait for 10 ns; 
        vypis;
        assert tCout = '0' and tQ = "0001" report "1+0+0 failed" severity failure;
        tA <= "1111"; tB <= "0000"; wait for 10 ns; 
        vypis;
        assert tCout = '0' and tQ = "1111" report "15+0+0 failed" severity failure;
        tA <= "1111"; tB <= "0001"; wait for 10 ns; 
        vypis;
        assert tCout = '1' and tQ = "0000" report "15+1+0 failed" severity failure;

        tC <= '1';
        tA <= "0000"; tB <= "0000"; wait for 10 ns; 
        vypis;
        assert tCout = '0' and tQ = "0001" report "0+0+1 failed" severity failure;
        tA <= "0001"; tB <= "0000"; wait for 10 ns; 
        vypis;
        assert tCout = '0' and tQ = "0010" report "1+0+1 failed" severity failure;
        tA <= "1111"; tB <= "0000"; wait for 10 ns; 
        vypis;
        assert tCout = '1' and tQ = "0000" report "15+0+1 failed" severity failure;
        tA <= "1111"; tB <= "0001"; wait for 10 ns; 
        vypis;
        assert tCout = '1' and tQ = "0001" report "15+1+1 failed" severity failure;


        report "Test OK";
        wait;
    end process;

UUT: adder4B port map (tA,tB,tC,tQ,tCout);

end bench;