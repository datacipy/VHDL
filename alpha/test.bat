rem @echo off
ghdl -a ../utility/bookutility.vhd

rem dependencies

ghdl -a ../3rd/light8080/src/vhdl/rtl/light8080_ucode_pkg.vhdl
ghdl -a ../3rd/light8080/src/vhdl/rtl/light8080.vhdl
ghdl -a ../acia6850/acia6850.vhdl
ghdl -a ../acia6850/aciaclock.vhdl

rem this

ghdl -a %1.vhd
ghdl -a %1_tb.vhd
ghdl -r %1_tb --wave=%1.ghw --vcd=%1.vcd