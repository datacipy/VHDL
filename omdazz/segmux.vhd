LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY segmux IS
    PORT (
		clk: in std_logic;
		inseg: in std_logic_vector(31 downto 0);
		  
		  --fyzicky displej LED
		  --seg = segment, 0=aktivni
		  segA : OUT std_logic; --128
		  segB : OUT std_logic; --121
		  segC : OUT std_logic; --125
		  segD : OUT std_logic; --129
		  segE : OUT std_logic; --132
		  segF : OUT std_logic; --126
		  segG : OUT std_logic;
		  segH : OUT std_logic;
		  dig1 : OUT std_logic; --133
		  dig2 : OUT std_logic; --135
		  dig3 : OUT std_logic; --136
		  dig4 : OUT std_logic --137
		  
    );
END ENTITY;

architecture main of segmux is

begin

    PROCESS (clk) IS
        VARIABLE counter : INTEGER range 0 to 3 := 0;
    BEGIN
        IF (rising_edge(clk)) THEN
            counter := counter + 1;
        END IF;
		  case counter is
		  when 0 =>
		    segA<=inseg(0);
		    segB<=inseg(1);
		    segC<=inseg(2);
		    segD<=inseg(3);
		    segE<=inseg(4);
		    segF<=inseg(5);
		    segG<=inseg(6);
		    segH<=inseg(7);
			 dig1<='0';	 
			 dig2<='1';	 
			 dig3<='1';	 
			 dig4<='1';	
			 
		  when 1 =>
		    segA<=inseg(8);
		    segB<=inseg(9);
		    segC<=inseg(10);
		    segD<=inseg(11);
		    segE<=inseg(12);
		    segF<=inseg(13);
		    segG<=inseg(14);
		    segH<=inseg(15);
			 dig1<='1';	 
			 dig2<='0';	 
			 dig3<='1';	 
			 dig4<='1';	
			 
		  when 2 =>
		    segA<=inseg(16);
		    segB<=inseg(17);
		    segC<=inseg(18);
		    segD<=inseg(19);
		    segE<=inseg(20);
		    segF<=inseg(21);
		    segG<=inseg(22);
		    segH<=inseg(23);
			 dig1<='1';	 
			 dig2<='1';	 
			 dig3<='0';	 
			 dig4<='1';	
			 
		  when 3 =>
		    segA<=inseg(24);
		    segB<=inseg(25);
		    segC<=inseg(26);
		    segD<=inseg(27);
		    segE<=inseg(28);
		    segF<=inseg(29);
		    segG<=inseg(30);
		    segH<=inseg(31);
			 dig1<='1';	 
			 dig2<='1';	 
			 dig3<='1';	 
			 dig4<='0';	
			 end case;
			 
			 
    END PROCESS;

end architecture;