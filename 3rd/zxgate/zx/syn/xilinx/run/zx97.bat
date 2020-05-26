set name=zx97
set target=xc2s200-pq208-5

cd ..\out

if "%1" == "" goto xst

set name=zx97_leo

copy ..\bin\%name%.pin %name%.ucf

ngdbuild -p %target% %1 %name%.ngd

goto builddone

:xst

copy ..\bin\%name%.pin %name%.ucf

xst -ifn ../bin/%name%.scr -ofn ../log/%name%.srp
ngdbuild -p %target% %name%.ngc

:builddone

move %name%.bld ..\log

map -p %target% -cm speed -c 100 -tx on -o %name%_map %name%
move %name%_map.mrp ..\log\%name%.mrp

par -ol 3 -t 1 -c 0 %name%_map -w %name%
move %name%.par ..\log

trce %name%.ncd -o ../log/%name%.twr %name%_map.pcf

bitgen -w %name%
move %name%.bgn ..\log

cd ..\run
