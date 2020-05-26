cd ..\out

spectrum -file ..\bin\zx97.tcl
move exemplar.log ..\log\zx97_leo.srp

cd ..\run

zx97 zx97_leo.edf
