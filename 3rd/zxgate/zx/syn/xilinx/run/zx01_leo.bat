cd ..\out

rem xrom ROM81 13 8 -6 -z > ..\src\ROM81_leo.vhd
rem hex2rom -b ..\..\..\rom\zx81.bin ROM81 13b8l6 > ROM81_leo.ini
rem copy ..\bin\zx01_leo.pin + ..\out\ROM81_leo.ini zx01_leo.ucf
copy ..\bin\zx01_leo.pin zx01_leo.ucf

spectrum -file ..\bin\zx01.tcl
move exemplar.log ..\log\zx01_leo.srp

cd ..\run

zx01 zx01_leo.edf xc2s200-pq208-5
