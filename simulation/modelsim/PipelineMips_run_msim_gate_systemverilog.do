transcript on
if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vlog -sv -work work +incdir+. {PipelineMips.svo}

vlog -sv -work work +incdir+C:/altera/13.1/PipelineMips {C:/altera/13.1/PipelineMips/TestPipelineMips.sv}

vsim -t 1ps +transport_int_delays +transport_path_delays -L altera_mf_ver -L altera_ver -L lpm_ver -L sgate_ver -L cycloneiv_hssi_ver -L cycloneiv_pcie_hip_ver -L cycloneiv_ver -L gate_work -L work -voptargs="+acc"  TestPipelineMips

add wave *
view structure
view signals
run -all
