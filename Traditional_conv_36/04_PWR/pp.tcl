#======================================================
#
# PrimeTime  Scripts (dctcl mode)
#
#======================================================

#======================================================
#  1. Set the Power Analysis Mode
#======================================================

set power_enable_analysis true
set power_analysis_mode time_based

# report intrinsic leakage and gate leakage and total leakage as well
set power_report_leakage_breakdowns true 
# exclude from clock_network power
set power_clock_network_include_register_clock_pin_power false 

#======================================================
#  2. Read and link the design
#======================================================

set search_path {./ \
                 /home/raid7_1/userd/d06001/faraday_U18/CBDK/Synthesis}


set link_library {* fsa0m_a_generic_core_ss1p62v125c.db fsa0m_a_generic_core_ff1p98vm40c.db }
set target_library { fsa0m_a_generic_core_ss1p62v125c.db fsa0m_a_generic_core_ff1p98vm40c.db }
set synthetic_library {dw_foundation.sldb}


#======================================================
#  3. Read designs, .sdf, .sdc file
#======================================================

#set DESIGN "alu"
read_verilog ../02_SYN/Netlist/conv_syn.v
current_design conv
link

#read_sdc Lab4_alu.sdc
read_sdf -load_delay net ../02_SYN/Netlist/conv_syn.sdf

#======================================================
#  4. Read Switching Activity File
#======================================================
read_vcd -strip_path TESTBED/conv_CORE ../03_GATESIM/conv_GATE.vcd

#======================================================
#  5. Perform power analysis
#======================================================
check_power
update_power

#======================================================
#  6. Generate Power Report
#======================================================
# BUG command

# set the options for power analysis, sampling interval: 1 timescale, outputfile: vcd.out
set_power_analysis_options -waveform_interval 1 -waveform_format out -waveform_output vcd

report_power > conv.power

