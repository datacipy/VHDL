set name=trsl1
set target=xc2s300e-pq208-6

if "%2" == "" goto default
set target=%2
:default

cd ..\out

if "%1" == "" goto xst

set name=trsl1_leo

copy ..\bin\%name%.pin %name%.ucf

ngdbuild -p %target% %1 %name%.ngd

goto builddone

:xst

xrom trs_rom1 12 8 > ..\src\level1.vhd
hex2rom -b ..\..\..\rom\level1.bin trs_rom1 12b8u > level1.ini
copy ..\out\level1.ini + ..\bin\%name%.pin %name%.ucf

xst -ifn ../bin/%name%.scr -ofn ../log/%name%.srp
ngdbuild -p %target% %name%.ngc

:builddone

move %name%.bld ..\log

map -p %target% -cm area -c 100 -pr b -timing -tx on -o %name%_map %name%
move %name%_map.mrp ..\log\%name%.mrp

par -ol 3 -t 1 -c 0 %name%_map -w %name%
move %name%.par ..\log

trce %name%.ncd -o ../log/%name%.twr %name%_map.pcf

bitgen -w %name%
move %name%.bgn ..\log

cd ..\run
