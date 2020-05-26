cd ..\out

hex2rom -b ..\..\..\rom\level1.bin trs_rom1 12b8s > ..\src\level1_leo.vhd

spectrum -file ..\bin\trsl1.tcl
move exemplar.log ..\log\trsl1_leo.srp

cd ..\run

trsl1 trsl1_leo.edf xc2s200-pq208-5
