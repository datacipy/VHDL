This directory contains the VHDL source code
for zx01 (single chip zx81 clone) and a zx spectrum clone.

Follow these steps to synthesize the source code for Xilinx FPGAs:

*** 1. Download the necessary files ***

There is no Z80 CPU included in the zx01/spectrum package,
the CPU must be downloded from:
http://www.opencores.org/projects/t80/

If you want to use the compile scripts the directory
structure must look like this:
"Your working directory"/zx/syn/xilinx/run
"Your working directory"/t80/rtl/vhdl

The easiest way to download the zx01 and t80 directories
is to use CVS.

If you are using Windows you can use the command line CVS
that comes with Cygwin or the CVSWin GUI. Just make sure to
include both CVS and SSH if you install Cygwin.
Linux distributions usually includes CVS.

Instructions for using cvs on sourceforge and opencores can be found at:
http://sourceforge.net/cvs/?group_id=40189
http://www.opencores.org/cvs.shtml

General CVS documentation can be found at:
http://www.cvshome.org/docs/manual/cvs.html

If you want to download the source code for read access only
and are using Cygwin or Linux, do the following:

1. Login to sourceforge:

cvs -d:pserver:anonymous@cvs.zxgate.sourceforge.net:/cvsroot/zxgate login
When prompted for a password for anonymous, simply press the Enter key.

2. Download zx01 to your current directory:

cvs -z3 -d:pserver:anonymous@cvs.zxgate.sourceforge.net:/cvsroot/zxgate co zx

3. Login to opencores:

cvs -d:pserver:cvs@cvs.opencores.org:/home/oc/cvs login
The password is: cvs

4. Download t80 to your current directory:

cvs -z3 -d:pserver:cvs@cvs.opencores.org:/home/oc/cvs co t80

5. Update the directories when necessary:

To update the directories to the latest version run:
cvs -z9 update -d -P
in zx and t80.

*** 2. Synthesize the design ***

You will need Xilinx Webpack to synthesize the files.
If you want to use the compile scripts you also need
to set the xilinx environment variables. There is a
check box that can be checked during installation that
does this. This can also be done after installation,
check WebPACK_setup.bat in the Webpack directory to
see how it should be done.

You also need the hex2rom and xrom utilities to
generate VHDL ROMs from the binary ROM file.
If you are using windows these can be downloaded from:
http://www.e.kth.se/~e93_daw/vhdl/download/hex2rom_0244_Win32.zip
If you are using Linux or Cygwin they can be compiled from the
source code in /t80/sw/.

Now you should be able to run the compile scripts:

/zx/syn/xilinx/run/zx01.bat
This script synthesizes zx01 with Xilinx XST

/zx/syn/xilinx/run/zx01_leo.bat
This script synthesizes zx01 with Leonardo Spectrum

/zx/syn/xilinx/run/zx01_edf.bat
This script runs place and route on a precompiled netlist
Place the netlist in /zx/syn/xilinx/src

/zx/syn/xilinx/run/zx01xr.bat
This script synthesizes zx01 for external RAM with Xilinx XST

/zx/syn/xilinx/run/zx01xr_leo.bat
This script synthesizes zx01 for external RAM with Leonardo Spectrum

/zx/syn/xilinx/run/spectrum48.bat
This script synthesizes zx spectrum with Xilinx XST

/zx/syn/xilinx/run/spectrum48_leo.bat
This script synthesizes zx spectrum with Leonardo Spectrum

If you want to change the target FPGA you must modify the
batch file you are running and if you are using XST also the
.scr file in /zx/syn/xilinx/bin/

If you want to change the pin placement you need to modify the
.pin file in /zx/syn/xilinx/bin/

Also note that hex2rom/xrom can split ROM between Select and Block RAM
so depending on how much of the ROM that fits in Block RAM, you will
need to change the parameters for hex2rom/xrom in the .bat files.

*** 3. Configure the FPGA ***

Run Xilinx Impact from the command line or from the start menu.
1. Select Configure Devices
2. Select Slave Serial Mode
3. Select the .bit file in /syn/xilinx/out that you just compiled
4. Run Operations->Program...

Enjoy!
