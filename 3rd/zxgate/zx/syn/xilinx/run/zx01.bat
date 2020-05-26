set name=zx01
set target=xc2s300e-pq208-6

if "%2" == "" goto default
set target=%2
:default

cd ..\out

if "%1" == "" goto xst

set name=zx01_leo

ngdbuild -p %target% %1 %name%.ngd

goto builddone

:xst

xrom ROM81 13 8 -4 > ..\src\ROM81.vhd
hex2rom -b ..\..\..\rom\zx81.bin rom81 13b8u4 > ROM81.ini
copy ..\bin\%name%.pin + ..\out\ROM81.ini %name%.ucf

xst -ifn ../bin/%name%.scr -ofn ../log/%name%.srp
ngdbuild -p %target% %name%.ngc

:builddone

move %name%.bld ..\log

map -p %target% -cm area -c 100 -pr b -timing -tx on -o %name%_map %name%
move %name%_map.mrp ..\log\%name%.mrp

par -ol 3 -t 1 %name%_map -w %name%
move %name%.par ..\log

trce %name%.ncd -o ../log/%name%.twr %name%_map.pcf

bitgen -w %name%
move %name%.bgn ..\log

cd ..\run
