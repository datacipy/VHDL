----------------------------------------------------------
--  zx01tb.vhd
--		Testbench for ZX01 Simulation
--		=============================
--
--  12/15/01	Daniel Wallner : Rewrite of Bodo Wenzels test bench zx97 to zx01
--  02/23/02	Daniel Wallner : Assigned all inputs
----------------------------------------------------------

-- this is the test bench --------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tb is
end;

architecture beh of tb is
  component zx01
  port (n_reset:  in    std_ulogic;
        clock:    in    std_ulogic;
        kbd_clk:  in    std_ulogic;
        kbd_data: in    std_ulogic;
        v_inv:    in    std_ulogic;
        usa_uk:   in    std_logic;
        video:    out   std_ulogic;
        tape_in:  in    std_ulogic;
        d_lcd:    out   std_ulogic_vector(3 downto 0);
        s:        out   std_ulogic;
        cp1:      out   std_ulogic;
        cp2:      out   std_ulogic);
  end component;

  signal n_reset:  std_ulogic := '0';
  signal clock:    std_ulogic := '0';
  signal v_inv:    std_ulogic;
  signal kbd_clk:  std_ulogic;
  signal kbd_data: std_ulogic;
  signal usa_uk:   std_logic;
  signal video:    std_ulogic;
  signal tape_in:  std_ulogic;
  signal d_lcd:    std_ulogic_vector(3 downto 0);
  signal s:        std_ulogic;
  signal cp1:      std_ulogic;
  signal cp2:      std_ulogic;

begin
  c_zx01: zx01
    port map(n_reset,clock,
             kbd_clk,kbd_data,v_inv,usa_uk,
             video,tape_in,
             d_lcd,s,cp1,cp2);

  clock <= not clock after 76 ns;

  n_reset <= '1' after 10 ns;

  kbd_clk <= '1';
  kbd_data <= '1';
  tape_in <= '1';
  v_inv <= '0';
  usa_uk <= '1';

end;

-- end ---------------------------------------------------
