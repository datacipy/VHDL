:<<"::CMDLITERAL"
@echo off
ghdl -a --std=08 ../utility/bookutility.vhd

ghdl -a --std=08 %1.vhd
ghdl -a --std=08 %1_tb.vhd 
ghdl -r --std=08 %1_tb --wave=%1.ghw --vcd=%1.vcd
exit /b
::CMDLITERAL

ghdl -a --std=08 ../utility/bookutility.vhd

ghdl -a --std=08 $1.vhd
ghdl -a --std=08 $1_tb.vhd

ghdl -r --std=08 $1_tb --wave=$1.ghw --vcd=$1.vcd