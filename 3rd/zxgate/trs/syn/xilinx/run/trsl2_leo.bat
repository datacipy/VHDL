cd ..\out

spectrum -file ..\bin\trsl2.tcl
move exemplar.log ..\log\trsl2_leo.srp

cd ..\run

trsl2 trsl2_leo.edf xc2s200-pq208-5
