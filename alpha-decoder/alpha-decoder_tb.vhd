library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity testbench is
end;

architecture bench of testbench is

component alphaDecoder is
    port (
        IOM, A15: in std_logic;
        nRAMCS, nROMCS: out std_logic
    );
end component;

  signal io, addr, ram, rom: STD_LOGIC;

begin


testing: process

    procedure vypis is
    begin
        report "IO/M:" & std_logic'image(io) & 
               ", A15:" & std_logic'image(addr) & 
               " => nRAMCS=" & std_logic'image(ram) &
               " => nROMCS=" & std_logic'image(rom);
    end procedure;

    begin
        io <= '0'; addr <= '0'; wait for 10 ns; 
        vypis;
        io <= '0'; addr <= '1'; wait for 10 ns; 
        vypis;
        io <= '1'; addr <= '0'; wait for 10 ns; 
        vypis;
        io <= '1'; addr <= '1'; wait for 10 ns; 
        vypis;
        wait;
    end process;

UUT: alphaDecoder port map (io,addr,ram,rom);

end bench;
