transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog  -work work +incdir+C:/Mac/Home/Documents/School/College\ -\ DU/Sophomore\ Year/Fall\ Quarter/ENCE_2101/Projects/Quartus/Clock_divider {C:/Mac/Home/Documents/School/College - DU/Sophomore Year/Fall Quarter/ENCE_2101/Projects/Quartus/Clock_divider/clock_divider.v}

