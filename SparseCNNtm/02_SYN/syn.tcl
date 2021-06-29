
set search_path [list ./ ../01_RTL/ /home/raid7_1/userd/d06001/faraday_U18/CBDK/Synthesis $search_path]
set link_library {"fsa0m_a_generic_core_ss1p62v125c.db" "fsa0m_a_generic_core_ff1p98vm40c.db" "dw_foundation.sldb" }
set target_library { "fsa0m_a_generic_core_ss1p62v125c.db" "fsa0m_a_generic_core_ff1p98vm40c.db" }
set symbol_library { "generic.sdb"}
set synthetic_library {"dw_foundation.sldb"}
set default_schematic_options {-size infinite}

set hdlin_translate_off_skip_text "TRUE"
set edifout_netlist_only "TRUE"
set verilogout_no_tri true
set plot_command {lpr -Plw}
set hdlin_auto_save_templates "TRUE"
set compile_fix_multiple_port_nets "TRUE"

set DESIGN "SparseCNN"
set CLOCK "clk"
set CLOCK_PERIOD 10.0
read_file -format verilog $DESIGN\.v

current_design $DESIGN
link

create_clock $CLOCK -period $CLOCK_PERIOD
set_ideal_network -no_propagate $CLOCK
set_dont_touch_network [get_ports clk]

set_clock_uncertainty  0.1  $CLOCK
set_input_delay  [ expr $CLOCK_PERIOD*0.5 ] -clock $CLOCK [all_inputs]
set_output_delay [ expr $CLOCK_PERIOD*0.5 ] -clock $CLOCK [all_outputs]
set_drive 1 [all_inputs]
set_load  0.05 [all_outputs]

set_operating_conditions -max WCCOM -min BCCOM
set_min_library fsa0m_a_generic_core_ss1p62v125c.db -min_version fsa0m_a_generic_core_ff1p98vm40c.db
set_wire_load_model -name G5K -library fsa0m_a_generic_core_ss1p62v125c
set_wire_load_mode top

check_design

uniquify
set_fix_multiple_port_nets -all -buffer_constants  [get_designs *]
set_fix_hold [all_clocks]

compile_ultra

report_area > Report/$DESIGN\.area
report_power > Report/$DESIGN\.power
report_timing -path full -delay max > Report/$DESIGN\.timing

set bus_inference_style "%s\[%d\]"
set bus_naming_style "%s\[%d\]"
set hdlout_internal_busses true
change_names -hierarchy -rule verilog
define_name_rules name_rule -allowed "a-z A-Z 0-9 _" -max_length 255 -type cell
define_name_rules name_rule -allowed "a-z A-Z 0-9 _[]" -max_length 255 -type net
define_name_rules name_rule -map {{"\\*cell\\*" "cell"}}
define_name_rules name_rule -case_insensitive

write -format verilog -hierarchy -output Netlist/$DESIGN\_syn.v
write_sdf -version 2.1 -context verilog Netlist/$DESIGN\_syn.sdf
write_sdc Netlist/$DESIGN\_syn.sdc

exit
