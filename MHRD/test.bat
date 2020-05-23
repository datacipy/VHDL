rem @echo off
ghdl -a ../utility/bookutility.vhd

rem dependencies

ghdl -a ../adder/adder.vhd
ghdl -a ../adder/fulladder.vhd
ghdl -a ../adder/adder16b.vhd
ghdl -a ../mux/mux16b.vhd
ghdl -a ../alu/alu16b.vhd
ghdl -a ../counter/counter16b.vhd
ghdl -a ../ff/reg16br.vhd

rem this

ghdl -a %1.vhd
ghdl -a %1_tb.vhd
ghdl -r %1_tb --wave=%1.ghw --vcd=%1.vcd