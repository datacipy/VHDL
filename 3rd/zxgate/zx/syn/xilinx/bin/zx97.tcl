set process "5"
set part "2s200pq208"
set tristate_map "TRUE"
set opt_auto_mode "TRUE"
set opt_best_result "29223.458000"
set dont_lock_lcells "auto"
set input2output "20.000000"
set input2register "20.000000"
set register2output "20.000000"
set register2register "20.000000"
set wire_table "xis215-5_avg"
set encoding "auto"
set edifin_ground_port_names "GND"
set edifin_power_port_names "VCC"
set edif_array_range_extraction_style "%s\[%d:%d\]"

set_xilinx_eqn

load_library xis2

read -technology xis2 {
../../../zx97/busses.vhd
../../../zx97/io81.vhd
../../../zx97/lcd97.vhd
../../../zx97/modes97.vhd
../../../zx97/res_clk.vhd
../../../zx97/video81.vhd
../../../zx97/top.vhd
../../../zx97/zx97.vhd
}

pre_optimize

optimize -hierarchy=auto

optimize_timing

report_area

report_delay

write zx97_leo.edf
