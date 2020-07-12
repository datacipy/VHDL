library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY vga IS

port (
 clock50: in std_logic;
 vgaclock: out std_logic;
 vga_hs,vga_vs: out std_logic;
 vga_r: out std_logic;
 vga_g : out std_logic;
 vga_b: out std_logic;
 
 border: in std_logic_vector(3 downto 0);
 
 
 vram_addr: out std_logic_vector(12 downto 0); 
 vram_data: in std_logic_vector(7 downto 0);  
 aram_addr: out std_logic_vector(9 downto 0); 
 aram_data: in std_logic_vector(7 downto 0);
 virq: out std_logic
);

END vga;

architecture main of vga is

signal vgaclk, reset:std_logic:='0';
signal dbus: std_logic_vector(7 downto 0);
signal ledcount: integer range 0 to 50000000:=0;
signal x:integer range 0 to 799;
signal y:integer range 0 to 599;
signal blank,border_v: std_logic;


signal r,g,b,i: std_logic;
signal dr,dg,db,di: std_logic;
--signal border: std_logic_vector(3 downto 0);

-- 9 bits H, 9 bits V
		-- 0 - subpixel
		-- 1, 2, 3 - pixel
		-- 4-8 - byte in a line
		-- 9 - subline
		-- 10 - 17 - line
signal rawaddr: std_logic_vector(17 downto 0);
signal rawaddr_pre: std_logic_vector(17 downto 0);

signal p: std_logic; --pixel

signal ramattr,ramdat: std_logic_vector(7 downto 0);
signal cnt_r,cnt_up,cnt_up_pre,ramload,ramload_s:std_logic;

signal addr_a: std_logic_vector(9 downto 0);
signal addr_v: std_logic_vector(12 downto 0);

signal hv,vv,hv_pre:std_logic;

-------------
    component PLL1 is
        port (
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC 
        );
    end component PLL1;
-------------
component sync is
port (
clk: in std_logic;
posx:out integer range 0 to 799;
posy:out integer range 0 to 599;
hsync,vsync: out std_logic;
blank: out std_logic
);
end component sync;

---
component encoder IS

port (
 blank: in std_logic;
 r,g,b,i: in std_logic;
 vga_r: out std_logic;
 vga_g : out std_logic;
 vga_b: out std_logic;
 clk: in std_logic
);

END component;

component bitmux IS

port (
 pixel: in std_logic_vector(2 downto 0);
 -- data byte
 byte: in std_logic_vector(7 downto 0); 
 load: in std_logic;
 clk: in std_logic;
 p: out std_logic
);

END component;

component bitcolor IS

port (
 pixel: in std_logic;
 -- attribute byte
 attr: in std_logic_vector(7 downto 0); 
 load: in std_logic;
 clk: in std_logic;
 r,g,b,i: out std_logic
);

END component;

component counter is
    port (
        cout   :out std_logic_vector (17 downto 0);  -- Output of the counter
		  enable :in  std_logic;                      -- Enable counting
        clk    :in  std_logic;                      -- Input clock
        reset  :in  std_logic                       -- Input reset
    );
end component;

constant offset_x:integer := 144;
constant offset_y:integer := 108;
constant offset_xe:integer := offset_x+512;
constant offset_ye:integer := offset_y+384;



begin
c1: sync port map (vgaclk, x, y, vga_hs, vga_vs, blank);
--c2: pll1 port map (clock50, vgaclk);
vgaclk <= clock50;
enc: encoder port map (blank, r,g,b,i,vga_r, vga_g, vga_b,vgaclk);
bitcol: bitcolor port map (p, ramattr, ramload_s, vgaclk, dr,dg,db,di);
bitmx: bitmux port map (rawaddr(3 downto 1),ramdat,ramload_s,vgaclk,p);
--ram: vram port map (addr_v,ramdat,not vgaclk);
cnt: counter port map (rawaddr,cnt_up,vgaclk,cnt_r);
precnt: counter port map (rawaddr_pre,cnt_up_pre,vgaclk,cnt_r);
--rama: aram port map (addr_a,ramattr,not vgaclk);


addr_a <= rawaddr_pre(17 downto 13) & rawaddr_pre(8 downto 4);
addr_v <= rawaddr_pre(17 downto 10) & rawaddr_pre(8 downto 4);
ramload_s<=ramload; -- and vgaclk;
vgaclock <= vgaclk;

vram_addr <= addr_v;
ramdat <= vram_data;
aram_addr <= addr_a;
ramattr <= aram_data;

virq <= '1' when (y=0 and x<5) else '0';


hv<='1' when (x >= offset_x and x<offset_xe) else '0';
hv_pre<='1' when (x >= (offset_x-3) and x<(offset_xe-3)) else '0';
vv<='1' when (y >= offset_y and y<offset_ye) else '0';
border_v<= (hv nand vv) and not blank;
cnt_up<=hv and vv;
cnt_up_pre<=hv_pre and vv;
		i<= ((di and not border_v) or (border(3) and border_v)) and not blank; 
		r<= ((dr and not border_v) or (border(2) and border_v)) and not blank; 
		g<= ((dg and not border_v) or (border(1) and border_v)) and not blank; 
		b<= ((db and not border_v) or (border(0) and border_v)) and not blank; 
cnt_r<='1' when (x = 0 and y = 0) else '0';		
--ramload <= ramload_force or '1' when rawaddr(3 downto 0)="0000" else ('0' or cnt_r);
--ramload <=  '1' when rawaddr(3 downto 0)="0000" else ('0' or cnt_r);
ramload <=  '1' when rawaddr_pre(3 downto 0)="0010" else '0';

-- i<='0';
--border<="0001";
--ramattr<="11110000" when rawaddr(13)='0' else "00001111";
--ramattr<="11110"& rawaddr(15 downto 13);
--ramattr<="11110"& rawaddr(6 downto 4);
-- ramattr<="11110000";
end main;