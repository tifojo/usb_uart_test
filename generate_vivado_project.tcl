# Creates a Vivado project and opens the IDE
# Usage: vivado -source generate_vivado_project.tcl

# Set the reference directory to be the location of this script
set origin_dir [file dirname [info script]]

# Set the project directory
set proj_dir "[file normalize "$origin_dir/vivado_project"]"

# Create project
create_project usb_uart_test $proj_dir -part xc7a35tcpg236-1

# Set project properties
set proj [get_projects usb_uart_test]
set_property "board_part" "digilentinc.com:cmod_a7-35t:part0:1.1" $proj
set_property "default_lib" "xil_defaultlib" $proj
set_property "ip_cache_permissions" "read write" $proj
set_property "ip_output_repo" "$proj_dir/usb_uart_test.cache/ip" $proj
set_property "sim.ip.auto_export_scripts" "1" $proj
set_property "simulator_language" "Mixed" $proj
set_property "xsim.array_display_limit" "64" $proj
set_property "xsim.trace_limit" "65536" $proj
set_property "target_language" "VHDL" $proj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set 'sources_1' fileset object
set source_fileset [get_filesets sources_1]
set files [list \
 "[file normalize "$origin_dir/fpga_sources/rtl/hw_interface.vhd"]"\
 "[file normalize "$origin_dir/fpga_sources/rtl/clocking.vhd"]"\
 "[file normalize "$origin_dir/fpga_sources/rtl/sync.vhd"]"\
]
read_vhdl $files

# Set the toplevel entity
set_property "top" "hw_interface" $source_fileset

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

# Add/Import constrs file and set constrs file properties
set file "[file normalize "$origin_dir/fpga_sources/constraints/CmodA7_Master.xdc"]"
set file_added [add_files -norecurse -fileset $obj $file]

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

# Set 'sim_1' fileset object
set obj [get_filesets sim_1]
# Empty (no sources present)

# Set 'sim_1' fileset properties
set obj [get_filesets sim_1]
set_property "transport_int_delay" "0" $obj
set_property "transport_path_delay" "0" $obj
set_property "xelab.nosort" "1" $obj
set_property "xelab.unifast" "" $obj

# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
  create_run -name synth_1 -part xc7a35tcpg236-1 -flow {Vivado Synthesis 2016} -strategy "Vivado Synthesis Defaults" -constrset constrs_1
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
  set_property flow "Vivado Synthesis 2016" [get_runs synth_1]
}
set obj [get_runs synth_1]

# set the current synth run
current_run -synthesis [get_runs synth_1]

# Create 'impl_1' run (if not found)
if {[string equal [get_runs -quiet impl_1] ""]} {
  create_run -name impl_1 -part xc7a35tcpg236-1 -flow {Vivado Implementation 2016} -strategy "Vivado Implementation Defaults" -constrset constrs_1 -parent_run synth_1
} else {
  set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
  set_property flow "Vivado Implementation 2016" [get_runs impl_1]
}
set obj [get_runs impl_1]
set_property "steps.write_bitstream.args.readback_file" "0" $obj
set_property "steps.write_bitstream.args.verbose" "0" $obj

# set the current impl run
current_run -implementation [get_runs impl_1]

puts "INFO: Project created:usb_uart_test"
