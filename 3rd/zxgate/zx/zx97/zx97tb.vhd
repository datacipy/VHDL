----------------------------------------------------------
--  zx97tb.vhd
--		Testbench for ZX97 Simulation
--		=============================
--
--  11/17/97	Bodo Wenzel	Creation
--  11/27/97	Bodo Wenzel	Additional LCD output
--  03/18/98	Bodo Wenzel	HRG
--  02/08/99	Bodo Wenzel	New features
----------------------------------------------------------

-- this is the test bench --------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tb is
end;

architecture beh of tb is
  component zx97
  port (n_reset: out   std_ulogic;
        phi:     out   std_ulogic;
        n_modes: out   std_ulogic;
        a_mem_h: out   std_ulogic_vector(14 downto 13);
        a_mem_l: out   std_ulogic_vector(8 downto 0);
        d_mem:   inout std_logic_vector(7 downto 0);
        a_cpu:   in    std_ulogic_vector(15 downto 0);
        d_cpu:   inout std_logic_vector(7 downto 0);
        n_m1:    in    std_ulogic;
        n_mreq:  in    std_ulogic;
        n_iorq:  in    std_ulogic;
        n_wr:    in    std_ulogic;
        n_rd:    in    std_ulogic;
        n_rfsh:  in    std_ulogic;
        n_nmi:   out   std_ulogic;
        n_halt:  in    std_ulogic;
        n_wait:  out   std_ulogic;
        n_romcs: out   std_ulogic;
        n_ramcs: out   std_ulogic;
        kbd_col: inout std_logic_vector(4 downto 0);
        usa_uk:  inout std_logic;
        video:   out   std_ulogic;
        tape_in: in    std_ulogic;
        d_lcd:   out   std_ulogic_vector(3 downto 0);
        s:       out   std_ulogic;
        cp1:     out   std_ulogic;
        cp2:     out   std_ulogic);
  end component;

  component test
  port (phi:     in     std_ulogic;
        n_reset: in     std_ulogic;
        n_modes: in     std_ulogic;
        d_mem:   inout  std_logic_vector(7 downto 0);
        a_cpu:   buffer std_ulogic_vector(15 downto 0);
        d_cpu:   inout  std_logic_vector(7 downto 0);
        n_m1:    out    std_ulogic;
        n_mreq:  buffer std_ulogic;
        n_iorq:  buffer std_ulogic;
        n_wr:    buffer std_ulogic;
        n_rd:    buffer std_ulogic;
        n_rfsh:  out    std_ulogic;
        n_halt:  out    std_ulogic;
        n_wait:  in     std_ulogic;
        kbd_col: out    std_logic_vector(4 downto 0);
        usa_uk:  out    std_logic;
        tape_in: out    std_ulogic);
  end component;

  signal mode:    std_ulogic_vector(3 downto 0);
  signal n_reset: std_ulogic;
  signal phi:     std_ulogic;
  signal n_modes: std_ulogic;
  signal a_mem_h: std_ulogic_vector(14 downto 13);
  signal a_mem_l: std_ulogic_vector(8 downto 0);
  signal d_mem:   std_logic_vector(7 downto 0);
  signal a_cpu:   std_ulogic_vector(15 downto 0);
  signal d_cpu:   std_logic_vector(7 downto 0);
  signal n_m1:    std_ulogic;
  signal n_mreq:  std_ulogic;
  signal n_iorq:  std_ulogic;
  signal n_wr:    std_ulogic;
  signal n_rd:    std_ulogic;
  signal n_rfsh:  std_ulogic;
  signal n_nmi:   std_ulogic;
  signal n_halt:  std_ulogic;
  signal n_wait:  std_ulogic;
  signal n_romcs: std_ulogic;
  signal n_ramcs: std_ulogic;
  signal kbd_col: std_logic_vector(4 downto 0);
  signal usa_uk:  std_logic;
  signal video:   std_ulogic;
  signal tape_in: std_ulogic;
  signal d_lcd:   std_ulogic_vector(3 downto 0);
  signal s:       std_ulogic;
  signal cp1:     std_ulogic;
  signal cp2:     std_ulogic;
begin
  c_zx97: zx97
    port map(n_reset,phi,n_modes,
             a_mem_h,a_mem_l,d_mem,
             a_cpu,d_cpu,
             n_m1,n_mreq,n_iorq,n_wr,n_rd,n_rfsh,
             n_nmi,n_halt,n_wait,
             n_romcs,n_ramcs,
             kbd_col,usa_uk,
             video,tape_in,
             d_lcd,s,cp1,cp2);

  c_test: test
    port map (phi,n_reset,n_modes,
              d_mem,a_cpu,d_cpu,
              n_m1,n_mreq,n_iorq,n_wr,n_rd,n_rfsh,
              n_halt,n_wait,
              kbd_col,usa_uk,tape_in);
end;

-- generating stimuli ------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity test is
  port (phi:     in     std_ulogic;
        n_reset: in     std_ulogic;
        n_modes: in     std_ulogic;
        d_mem:   inout  std_logic_vector(7 downto 0);
        a_cpu:   buffer std_ulogic_vector(15 downto 0);
        d_cpu:   inout  std_logic_vector(7 downto 0);
        n_m1:    out    std_ulogic;
        n_mreq:  buffer std_ulogic;
        n_iorq:  buffer std_ulogic;
        n_wr:    buffer std_ulogic;
        n_rd:    buffer std_ulogic;
        n_rfsh:  out    std_ulogic;
        n_halt:  out    std_ulogic;
        n_wait:  in     std_ulogic;
        kbd_col: out    std_logic_vector(4 downto 0);
        usa_uk:  out    std_logic;
        tape_in: out    std_ulogic);
end;

architecture beh of test is
  type TEST_STATE is (RESET,
                      MEMORY,VIDEO_IO,KEYB_IO,
                      SYNC,FAKE,TEXT,HRG,ROWS,
                      FINISH);

  signal state: TEST_STATE;
begin
  process
    procedure mem_m1(addr: in bit_vector(15 downto 0);
                     ir:   in bit_vector(15 downto 0)) is
    begin
      wait until phi='1';
      n_rfsh <= '1'        after 120 ns;
      d_cpu  <= "ZZZZZZZZ" after 90 ns;
      a_cpu  <= to_stdulogicvector(addr) after 100 ns;
      n_m1   <= '0'        after 100 ns;
      wait until phi='0';
      n_mreq <= '0'        after 85 ns;
      n_rd   <= '0'        after 95 ns;
      wait until phi='1';
      wait until phi='0';
      wait until phi='1';
      n_rd   <= '1'        after 85 ns;
      n_mreq <= '1'        after 85 ns;
      n_m1   <= '1'        after 100 ns;
      a_cpu  <= to_stdulogicvector(ir) after 110 ns;
      n_rfsh <= '0'        after 130 ns;
      wait until phi='0';
      n_mreq <= '0'        after 85 ns;
      wait until phi='1';
      wait until phi='0';
      n_mreq <= '1'        after 85 ns;
    end;

    procedure mem_rd(addr: in bit_vector(15 downto 0)) is
    begin
      wait until phi='1';
      n_rfsh <= '1'        after 120 ns;
      d_cpu  <= "ZZZZZZZZ" after 90 ns;
      a_cpu  <= to_stdulogicvector(addr) after 100 ns;
      wait until phi='0';
      n_mreq <= '0'        after 85 ns;
      n_rd   <= '0'        after 95 ns;
      wait until phi='1';
      wait until phi='0';
      wait until phi='1';
      wait until phi='0';
      n_rd   <= '1'        after 85 ns;
      n_mreq <= '1'        after 85 ns;
    end;

    procedure mem_wr(addr: in bit_vector(15 downto 0);
                     data: in bit_vector(7 downto 0)) is
    begin
      wait until phi='1';
      n_rfsh <= '1'        after 120 ns;
      d_cpu  <= "ZZZZZZZZ" after 90 ns;
      a_cpu  <= to_stdulogicvector(addr) after 100 ns;
      wait until phi='0';
      n_mreq <= '0'        after 85 ns;
      d_cpu  <= to_stdlogicvector(data) after 150 ns;
      wait until phi='1';
      wait until phi='0';
      n_wr   <= '0'        after 80 ns;
      wait until phi='1';
      wait until phi='0';
      n_wr   <= '1'        after 80 ns;
      n_mreq <= '1'        after 85 ns;
    end;

    procedure io_rd(addr: in bit_vector(15 downto 0)) is
    begin
      wait until phi='1';
      n_rfsh <= '1'        after 120 ns;
      d_cpu  <= "ZZZZZZZZ" after 90 ns;
      a_cpu  <= to_stdulogicvector(addr) after 100 ns;
      wait until phi='0';
      wait until phi='1';
      n_iorq <= '0'        after 75 ns;
      n_rd   <= '0'        after 85 ns;
      wait until phi='0';
      wait until phi='1';
      wait until phi='0';
      wait until phi='1';
      wait until phi='0';
      n_rd   <= '1'        after 85 ns;
      n_iorq <= '1'        after 85 ns;
    end;

    procedure io_wr(addr: in bit_vector(15 downto 0);
                    data: in bit_vector(7 downto 0)) is
    begin
      wait until phi='1';
      n_rfsh <= '1'        after 120 ns;
      d_cpu  <= "ZZZZZZZZ" after 90 ns;
      a_cpu  <= to_stdulogicvector(addr) after 100 ns;
      wait until phi='0';
      d_cpu  <= to_stdlogicvector(data) after 150 ns;
      wait until phi='1';
      n_iorq <= '0'        after 75 ns;
      n_wr   <= '0'        after 10 ns;
      wait until phi='0';
      wait until phi='1';
      wait until phi='0';
      wait until phi='1';
      wait until phi='0';
      n_wr   <= '1'        after 80 ns;
      n_iorq <= '1'        after 85 ns;
    end;

    procedure int_ack(ir: in bit_vector(15 downto 0)) is
    begin
      wait until phi='1';
      n_rfsh <= '1'        after 120 ns;
      d_cpu  <= "ZZZZZZZZ" after 90 ns;
      a_cpu  <= to_stdulogicvector(not IR) after 100 ns;
      n_m1   <= '0'        after 100 ns;
      wait until phi='0';
      wait until phi='1';
      wait until phi='0';
      wait until phi='1';
      wait until phi='0';
      n_iorq <= '0'        after 85 ns;
      wait until phi='1';
      wait until phi='0';
      wait until phi='1';
      n_iorq <= '1'        after 85 ns;
      n_m1   <= '1'        after 100 ns;
      a_cpu  <= to_stdulogicvector(ir) after 110 ns;
      wait until phi='0';
      n_mreq <= '0'        after 85 ns;
      wait until phi='1';
      wait until phi='0';
      n_mreq <= '1'        after 85 ns;
    end;
  begin
    state <= RESET;

    wait until n_reset='0';

    d_mem  <= "ZZZZZZZZ";
    a_cpu  <= "ZZZZZZZZZZZZZZZZ";
    d_cpu  <= "ZZZZZZZZ";
    n_m1   <= '1';
    n_mreq <= '1';
    n_iorq <= '1';
    n_wr   <= '1';
    n_rd   <= '1';
    n_rfsh <= '1';
    n_halt <= '1';

    usa_uk  <= '0';
    tape_in <= '0';

    kbd_col <= "Z00Z0";
    wait until n_modes/='0';
    kbd_col <= "ZZZZZ";
    wait until n_reset='1';

-- reset
    mem_wr(X"0007",X"80");
    wait until n_reset='0';
    wait until n_reset='1';

-- memory selects
    state <= MEMORY;
    mem_wr(X"0007",X"00");
    mem_m1(X"0123",X"CDEF");
    mem_wr(X"0123",X"55");
    mem_rd(X"2345");
    mem_rd(X"ABCD");
    mem_wr(X"4567",X"55");
    mem_rd(X"89AB");
    mem_rd(X"CDEF");
    mem_wr(X"0007",X"11");
    mem_m1(X"0123",X"CDEF");
    mem_wr(X"0123",X"55");
    mem_rd(X"2345");
    mem_rd(X"ABCD");
    mem_wr(X"4567",X"55");
    mem_rd(X"89AB");
    mem_rd(X"CDEF");
    mem_wr(X"0007",X"22");
    mem_m1(X"0123",X"CDEF");
    mem_wr(X"0123",X"55");
    mem_rd(X"2345");
    mem_rd(X"ABCD");
    mem_wr(X"4567",X"55");
    mem_rd(X"89AB");
    mem_rd(X"CDEF");
    mem_wr(X"0007",X"33");
    mem_m1(X"0123",X"CDEF");
    mem_wr(X"0123",X"55");
    mem_rd(X"2345");
    mem_rd(X"ABCD");
    mem_wr(X"4567",X"55");
    mem_rd(X"89AB");
    mem_rd(X"CDEF");
    mem_wr(X"0007",X"44");
    mem_m1(X"0123",X"CDEF");
    mem_wr(X"0123",X"55");
    mem_rd(X"2345");
    mem_rd(X"ABCD");
    mem_wr(X"4567",X"55");
    mem_rd(X"89AB");
    mem_rd(X"CDEF");
    mem_wr(X"0007",X"55");
    mem_m1(X"0123",X"CDEF");
    mem_wr(X"0123",X"55");
    mem_rd(X"2345");
    mem_rd(X"ABCD");
    mem_wr(X"4567",X"55");
    mem_rd(X"89AB");
    mem_rd(X"CDEF");
    mem_wr(X"0007",X"66");
    mem_m1(X"0123",X"CDEF");
    mem_wr(X"0123",X"55");
    mem_rd(X"2345");
    mem_rd(X"ABCD");
    mem_wr(X"4567",X"55");
    mem_rd(X"89AB");
    mem_rd(X"CDEF");
    mem_wr(X"0007",X"77");
    mem_m1(X"0123",X"CDEF");
    mem_wr(X"0123",X"55");
    mem_rd(X"2345");
    mem_rd(X"ABCD");
    mem_wr(X"4567",X"55");
    mem_rd(X"89AB");
    mem_rd(X"CDEF");

-- video io ports
    state <= VIDEO_IO;
    io_wr(X"01FD",X"AA");
    io_rd(X"23FC");
    io_wr(X"45FF",X"AA");
    io_rd(X"67FE");
    io_wr(X"89FF",X"AA");
    io_wr(X"ABFE",X"AA");
    io_rd(X"CDFE");
    io_wr(X"EFFD",X"AA");

-- keyboard io port
    state <= KEYB_IO;
    io_rd(X"FEFE");
    kbd_col <= "ZZZZ0";
    tape_in <= '1';
    io_rd(X"DCFE");
    kbd_col <= "ZZZ0Z";
    usa_uk  <= '1';
    io_rd(X"BAFE");
    kbd_col <= "ZZ0ZZ";
    usa_uk  <= '0';
    io_rd(X"98FE");
    kbd_col <= "Z0ZZZ";
    io_rd(X"76FE");
    kbd_col <= "0ZZZZ";
    tape_in <= '0';
    io_rd(X"54FE");
    kbd_col <= "Z0Z0Z";
    io_rd(X"32FE");
    kbd_col <= "0Z0Z0";
    io_rd(X"10FE");

-- sync and nmi
    state <= SYNC;
    io_rd(X"FEFE");
    io_wr(X"FEFE",X"55");
    for i in 1 to 49 loop
      mem_m1(X"8000",X"1E12");
    end loop;
    io_wr(X"FDFD",X"55");
    for i in 1 to 5 loop
      mem_m1(X"8000",X"1E34");
    end loop;
    int_ack(X"1E45");
    for i in 1 to 15 loop
      mem_m1(X"8000",X"1E56");
    end loop;

-- fake signal
    state <= FAKE;
    mem_rd(X"DABC");
    mem_wr(X"DABC",X"DE");
    mem_m1(X"5ABC",X"1EF0");
    mem_m1(X"9ABC",X"1EF0");
    n_halt <= '0';
    mem_m1(X"DABC",X"1EDE");
    n_halt <= '1';
    mem_m1(X"DA55",X"1EBC");
    mem_m1(X"DAAA",X"1E9A");

-- catch character code and combined video output
    state <= TEXT;
    mem_wr(X"0007",X"00");
    mem_rd(X"FEDC");
    mem_m1(X"FE15",X"1E55");
    mem_m1(X"FEAA",X"3EAA");
    mem_m1(X"FE76",X"3E69");
    mem_rd(X"FE00");
    mem_wr(X"0007",X"04");
    mem_rd(X"FEDC");
    mem_m1(X"FE15",X"1E55");
    mem_m1(X"FEAA",X"3EAA");
    mem_m1(X"FE76",X"3E69");
    mem_rd(X"FE00");

-- HRG and combined video output
    state <= HRG;
    mem_wr(X"0007",X"08");
    mem_rd(X"FEDC");
    mem_m1(X"FE15",X"20AA");
    mem_m1(X"FEAA",X"6055");
    mem_m1(X"FE76",X"FFFF");
    mem_rd(X"FE00");
    mem_wr(X"0007",X"0C");
    mem_rd(X"FEDC");
    mem_m1(X"FE15",X"20AA");
    mem_m1(X"FEAA",X"6055");
    mem_m1(X"FE76",X"FFFF");
    mem_rd(X"FE00");

-- row counter
-- it would be too long to simulate a whole pic!
    state <= ROWS;
    io_rd(X"FEFE");
    io_wr(X"FEFE",X"FE");
    for i in 1 to 8 loop
      mem_m1(X"4567",X"1234");
      mem_rd(X"4568");
      mem_rd(X"4569");
      for j in 1 to 32 loop
        mem_m1(to_bitvector(
               conv_std_logic_vector(32768+j,16)),
               to_bitvector(
               conv_std_logic_vector(12288+j,16)));
      end loop;
      mem_m1(X"8076",X"5678");
      n_halt <= '0';
      mem_m1(X"8076",X"5678");
      mem_m1(X"8076",X"5678");
      mem_m1(X"8076",X"5678");
      mem_m1(X"8076",X"5678");
      n_halt <= '1';
      int_ack(X"5678");
      while n_wait='1' loop
        mem_m1(X"5678",X"0123");
      end loop;
      while n_wait='0' loop
        wait until phi='1';
        wait until phi='0';
      end loop;
      mem_m1(X"6789",X"3FFF");
      mem_wr(X"678A",X"75");
      mem_wr(X"678B",X"74");
    end loop;

    assert FALSE report "test finished." severity NOTE;
    state <= FINISH;
    wait;
  end process;

  d_mem <= "ZZZZZZZZ" when n_mreq='1' or n_wr='0'
      else std_logic_vector(a_cpu(7 downto 0));
end;

-- implied parts of the fpga -----------------------------

-- crystal oscillator  - - - - - - - - - - - - - - - - - -

library ieee;
use ieee.std_logic_1164.all;

entity gxtl is
  port (o: out std_ulogic);
end;

architecture beh of gxtl is
begin
  process
  begin
    o <= '1';
    wait for 76 ns;
    o <= '0';
    wait for 76 ns;
  end process;
end;

-- clock buffer  - - - - - - - - - - - - - - - - - - - - -

library ieee;
use ieee.std_logic_1164.all;

entity gclk is
  port (i: in  std_ulogic;
        o: out std_ulogic);
end;

architecture beh of gclk is
begin
  o <= i;
end;

-- pullup resistor - - - - - - - - - - - - - - - - - - - -

library ieee;
use ieee.std_logic_1164.all;

entity pullup is
  port (o: out std_ulogic);
end;

architecture beh of pullup is
begin
  o <= 'H';
end;

-- input buffer  - - - - - - - - - - - - - - - - - - - - -

library ieee;
use ieee.std_logic_1164.all;

entity ibuf is
  port (i: in  std_ulogic;
        o: out std_ulogic);
end;

architecture beh of ibuf is
begin
  o <= std_ulogic(to_X01(i));
end;

-- end ---------------------------------------------------
