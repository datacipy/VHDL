cd ..\out

rem hex2rom -b ..\..\..\rom\spectrum48.bin spectrum48_rom 14b8s > ..\src\spectrum48_rom_leo.vhd

spectrum -file ..\bin\spectrum48.tcl
move exemplar.log ..\log\spectrum48_leo.srp

cd ..\run

spectrum48 spectrum48_leo.edf xc2s200-pq208-5
