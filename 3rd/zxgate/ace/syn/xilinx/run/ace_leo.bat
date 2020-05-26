cd ..\out

rem hex2rom -b ..\..\..\rom\ace.bin ace_rom 13b8s > ..\src\acerom_leo.vhd

spectrum -file ..\bin\ace.tcl
move exemplar.log ..\log\ace_leo.srp

cd ..\run

ace ace_leo.edf xc2s200-pq208-5
