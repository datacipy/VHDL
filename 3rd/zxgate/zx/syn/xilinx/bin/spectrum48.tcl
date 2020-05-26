set process "5"
set part "2s200pq208"
set tristate_map "FALSE"
set opt_auto_mode "TRUE"
set opt_best_result "29223.458000"
set dont_lock_lcells "auto"
set input2output "20.000000"
set input2register "50.000000"
set register2output "50.000000"
set register2register "100.000000"
set wire_table "xis215-5_avg"
set encoding "auto"
set edifin_ground_port_names "GND"
set edifin_power_port_names "VCC"
set edif_array_range_extraction_style "%s\[%d:%d\]"

set_xilinx_eqn

load_library xis2

read -technology xis2 {
../../../../t80/rtl/vhdl/T80_Pack.vhd
../../../../t80/rtl/vhdl/T80_MCode.vhd
../../../../t80/rtl/vhdl/T80_ALU.vhd
../../../../t80/rtl/vhdl/T80_RegX.vhd
../../../../t80/rtl/vhdl/T80.vhd
../../../../t80/rtl/vhdl/T80se.vhd
../../../../t80/rtl/vhdl/SSRAM2.vhd
../../../spectrum/spectrum_ps2.vhd
../../../spectrum/spectrum_vid.vhd
../../../spectrum/spectrum48_glue.vhd
../../../spectrum/ddsrom.vhd
../../../spectrum/dds.vhd
../../../spectrum/qam.vhd
../../../spectrum/cvm.vhd
../../../spectrum/spectrum48.vhd
}

pre_optimize

optimize -area -hierarchy=auto -pass 1

optimize_timing

report_area

report_delay

write spectrum48_leo.edf
