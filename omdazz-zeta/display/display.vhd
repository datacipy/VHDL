library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY zuludisplay IS

port (
 clock50: in std_logic;
 clock_vga: out std_logic;
 vga_hs,vga_vs: out std_logic;
 vga_r: out std_logic;
 vga_g : out std_logic;
 vga_b: out std_logic;
 ram_addr: in std_logic_vector(12 downto 0); 
 ram_do: out std_logic_vector(7 downto 0);
 ram_di: in std_logic_vector(7 downto 0);
 ram_we: in std_logic := '0';
 ram_clk: in std_logic := '0';
 virq: out std_logic;
 border: std_logic_vector(3 downto 0):="0000"
 
);

END zuludisplay;

architecture main of zuludisplay is

signal dbus: std_logic_vector(7 downto 0);
signal ledcount: integer range 0 to 50000000:=0;
signal vgaclk: std_logic;

signal vram_addr: std_logic_vector(12 downto 0); 
signal vram_data: std_logic_vector(7 downto 0);  
signal aram_addr: std_logic_vector(9 downto 0); 
signal aram_data: std_logic_vector(7 downto 0);
signal aram_do: std_logic_vector(7 downto 0);
signal aram_di: std_logic_vector(7 downto 0);
signal aram_we: std_logic := '0';
signal vram_do: std_logic_vector(7 downto 0);
signal vram_di: std_logic_vector(7 downto 0);
signal vram_we: std_logic := '0';

-- signal ram_addr: std_logic_vector(12 downto 0); 
-- signal ram_do: std_logic_vector(7 downto 0);
-- signal ram_di: std_logic_vector(7 downto 0);
-- signal ram_we: std_logic := '0';

--signal border: std_logic_vector(3 downto 0):="0000";
signal bordCE: std_logic;

component vga IS

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

END component;


component vram IS

port (
 addr: in std_logic_vector(12 downto 0); 
 data: out std_logic_vector(7 downto 0); 
 clk: in std_logic;
 saddr: in std_logic_vector(12 downto 0); 
 sdatain: in std_logic_vector(7 downto 0); 
 sdataout: out std_logic_vector(7 downto 0); 
 swe: in std_logic;
 sclk: in std_logic
);

END component;

component aram IS

port (
 addr: in std_logic_vector(9 downto 0); 
 data: out std_logic_vector(7 downto 0); 
 clk: in std_logic;
 saddr: in std_logic_vector(9 downto 0); 
 sdatain: in std_logic_vector(7 downto 0); 
 sdataout: out std_logic_vector(7 downto 0); 
 swe: in std_logic;
 sclk: in std_logic 
);

END component;


begin
ram: vram port map (vram_addr,vram_data,vgaclk,ram_addr(12 downto 0),vram_di,vram_do,vram_we,ram_clk);
rama: aram port map (aram_addr,aram_data,vgaclk,ram_addr(9 downto 0),aram_di,aram_do,aram_we,ram_clk);
main_vga: vga port map (clock50,vgaclk,vga_hs,vga_vs,vga_r,vga_g,vga_b, border,
	vram_addr,vram_data,aram_addr,aram_data,virq
);


-- special registers

-- border = attr/bff
--bordCE <= '1' when ram_addr = "1101111111111" else '0'; --1bff

clock_vga<=vgaclk;

/*
process(ram_clk)
 begin
 if rising_edge(ram_clk) then
   if bordCE='1' then
		border<=ram_di(3 downto 0);
	end if;
 end if;
end process;
--*/

-- memory mapping 8kB 
vram_we <= ram_we when ram_addr(12 downto 11)="00" else
			  ram_we when ram_addr(12 downto 11)="01" else
			  ram_we when ram_addr(12 downto 11)="10" else
			  '0';

aram_we <= ram_we when ram_addr(12 downto 10)="110" else
			  '0';

vram_di <= ram_di when ram_addr(12 downto 11)="00" else
			  ram_di when ram_addr(12 downto 11)="01" else
			  ram_di when ram_addr(12 downto 11)="10" else
			  (others=>'Z');

aram_di <= ram_di when ram_addr(12 downto 10)="110" else
			  (others=>'Z');
			  
with ram_addr(12 downto 10) select
				ram_do <= aram_do when "110",
				(others=>'Z') when "111",
				vram_do when others;			  
			  
end main;