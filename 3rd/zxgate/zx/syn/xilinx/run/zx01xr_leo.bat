cd ..\out

xrom ROM81 13 8 -2 -z > ..\src\ROM81_leo.vhd
hex2rom -b ..\..\..\rom\zx81.bin ROM81 13b8l2 > ROM81_leo.ini
copy ..\bin\zx01_leo.pin + ..\out\ROM81_leo.ini zx01_leo.ucf

spectrum -file ..\bin\zx01xr.tcl
move exemplar.log ..\log\zx01xr_leo.srp

cd ..\run

zx01xr zx01xr_leo.edf xc2s200-pq208-5
