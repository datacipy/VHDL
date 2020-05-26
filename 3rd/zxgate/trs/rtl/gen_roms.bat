rem Generates vhdl roms for simulation
hex2rom -b ../rom/level1.bin trs_rom1 12b8s > level1_rom.vhd
hex2rom -b ../rom/level2.bin level2_rom 14b8z > level2_rom.vhd
