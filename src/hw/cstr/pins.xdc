set_property PACKAGE_PIN G21 [get_ports {fp_led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {fp_led[0]}]
set_property DRIVE 12 [get_ports {fp_led[0]}]
set_property SLEW SLOW [get_ports {fp_led[0]}]

set_property PACKAGE_PIN G20 [get_ports {fp_led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {fp_led[1]}]
set_property DRIVE 12 [get_ports {fp_led[1]}]
set_property SLEW SLOW [get_ports {fp_led[1]}]

set_property PACKAGE_PIN F21 [get_ports {fp_led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {fp_led[2]}]
set_property DRIVE 12 [get_ports {fp_led[2]}]
set_property SLEW SLOW [get_ports {fp_led[2]}]

set_property PACKAGE_PIN F20 [get_ports {fp_led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {fp_led[3]}]
set_property DRIVE 12 [get_ports {fp_led[3]}]
set_property SLEW SLOW [get_ports {fp_led[3]}]

set_property PACKAGE_PIN E22 [get_ports {fp_led[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {fp_led[4]}]
set_property DRIVE 12 [get_ports {fp_led[4]}]
set_property SLEW SLOW [get_ports {fp_led[4]}]

set_property PACKAGE_PIN E20 [get_ports {fp_led[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {fp_led[5]}]
set_property DRIVE 12 [get_ports {fp_led[5]}]
set_property SLEW SLOW [get_ports {fp_led[5]}]

set_property PACKAGE_PIN D22 [get_ports {fp_led[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {fp_led[6]}]
set_property DRIVE 12 [get_ports {fp_led[6]}]
set_property SLEW SLOW [get_ports {fp_led[6]}]

set_property PACKAGE_PIN D21 [get_ports {fp_led[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {fp_led[7]}]
set_property DRIVE 12 [get_ports {fp_led[7]}]
set_property SLEW SLOW [get_ports {fp_led[7]}]


set_property PACKAGE_PIN D20 [get_ports {fp_in[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {fp_in[0]}]

set_property PACKAGE_PIN C22 [get_ports {fp_in[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {fp_in[1]}]

set_property PACKAGE_PIN A20 [get_ports {fp_in[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {fp_in[2]}]

set_property PACKAGE_PIN C21 [get_ports {fp_in[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {fp_in[3]}]


set_property PACKAGE_PIN B21 [get_ports {fp_out[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {fp_out[0]}]
set_property DRIVE 12 [get_ports {fp_out[0]}]
set_property SLEW FAST [get_ports {fp_out[0]}]

set_property PACKAGE_PIN A21 [get_ports {fp_out[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {fp_out[1]}]
set_property DRIVE 12 [get_ports {fp_out[1]}]
set_property SLEW FAST [get_ports {fp_out[1]}]

set_property PACKAGE_PIN B20 [get_ports {fp_out[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {fp_out[2]}]
set_property DRIVE 12 [get_ports {fp_out[2]}]
set_property SLEW FAST [get_ports {fp_out[2]}]

set_property PACKAGE_PIN A22 [get_ports {fp_out[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {fp_out[3]}]
set_property DRIVE 12 [get_ports {fp_out[3]}]
set_property SLEW FAST [get_ports {fp_out[3]}]


#sfp RXLOS
set_property PACKAGE_PIN AP12 [get_ports {sfp_rxlos[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_rxlos[0]}]

set_property PACKAGE_PIN AK13 [get_ports {sfp_rxlos[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_rxlos[1]}]

set_property PACKAGE_PIN AK14 [get_ports {sfp_rxlos[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_rxlos[2]}]

set_property PACKAGE_PIN AG14 [get_ports {sfp_rxlos[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_rxlos[3]}]

set_property PACKAGE_PIN AG15 [get_ports {sfp_rxlos[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_rxlos[4]}]

set_property PACKAGE_PIN AF15 [get_ports {sfp_rxlos[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_rxlos[5]}]




#sfp_leds
#SFP0 LED0
set_property PACKAGE_PIN AL13 [get_ports {sfp_led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_led[0]}]
set_property DRIVE 8 [get_ports {sfp_led[0]}]
set_property SLEW SLOW [get_ports {sfp_led[0]}]

#SFP0 LED1
set_property PACKAGE_PIN AM14 [get_ports {sfp_led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_led[1]}]
set_property DRIVE 8 [get_ports {sfp_led[1]}]
set_property SLEW SLOW [get_ports {sfp_led[1]}]

#SFP1 LED0
set_property PACKAGE_PIN AL12 [get_ports {sfp_led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_led[2]}]
set_property DRIVE 8 [get_ports {sfp_led[2]}]
set_property SLEW SLOW [get_ports {sfp_led[2]}]

#SFP1 LED1
set_property PACKAGE_PIN AM13 [get_ports {sfp_led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_led[3]}]
set_property DRIVE 8 [get_ports {sfp_led[3]}]
set_property SLEW SLOW [get_ports {sfp_led[3]}]

#SFP2 LED0
set_property PACKAGE_PIN AN14 [get_ports {sfp_led[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_led[4]}]
set_property DRIVE 8 [get_ports {sfp_led[4]}]
set_property SLEW SLOW [get_ports {sfp_led[4]}]

#SFP2 LED1
set_property PACKAGE_PIN AN13 [get_ports {sfp_led[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_led[5]}]
set_property DRIVE 8 [get_ports {sfp_led[5]}]
set_property SLEW SLOW [get_ports {sfp_led[5]}]

#SFP3 LED0
set_property PACKAGE_PIN AP14 [get_ports {sfp_led[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_led[6]}]
set_property DRIVE 8 [get_ports {sfp_led[6]}]
set_property SLEW SLOW [get_ports {sfp_led[6]}]

#SFP3 LED1
set_property PACKAGE_PIN AN12 [get_ports {sfp_led[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_led[7]}]
set_property DRIVE 8 [get_ports {sfp_led[7]}]
set_property SLEW SLOW [get_ports {sfp_led[7]}]

#SFP4 LED0
set_property PACKAGE_PIN AH14 [get_ports {sfp_led[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_led[8]}]
set_property DRIVE 8 [get_ports {sfp_led[8]}]
set_property SLEW SLOW [get_ports {sfp_led[8]}]

#SFP4 LED1
set_property PACKAGE_PIN AJ15 [get_ports {sfp_led[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_led[9]}]
set_property DRIVE 8 [get_ports {sfp_led[9]}]
set_property SLEW SLOW [get_ports {sfp_led[9]}]

#SFP5 LED0
set_property PACKAGE_PIN AJ14 [get_ports {sfp_led[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_led[10]}]
set_property DRIVE 8 [get_ports {sfp_led[10]}]
set_property SLEW SLOW [get_ports {sfp_led[10]}]

#SFP5 LED1
set_property PACKAGE_PIN AK15 [get_ports {sfp_led[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_led[11]}]
set_property DRIVE 8 [get_ports {sfp_led[11]}]
set_property SLEW SLOW [get_ports {sfp_led[11]}]





set_property PACKAGE_PIN AK5 [get_ports {dbg[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dbg[0]}]
set_property DRIVE 12 [get_ports {dbg[0]}]
set_property SLEW FAST [get_ports {dbg[0]}]

set_property PACKAGE_PIN AL5 [get_ports {dbg[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dbg[1]}]
set_property DRIVE 12 [get_ports {dbg[1]}]
set_property SLEW FAST [get_ports {dbg[1]}]

set_property PACKAGE_PIN AM5 [get_ports {dbg[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dbg[2]}]
set_property DRIVE 12 [get_ports {dbg[2]}]
set_property SLEW FAST [get_ports {dbg[2]}]

set_property PACKAGE_PIN AK4 [get_ports {dbg[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dbg[3]}]
set_property DRIVE 12 [get_ports {dbg[3]}]
set_property SLEW FAST [get_ports {dbg[3]}]

set_property PACKAGE_PIN AM4 [get_ports {dbg[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dbg[4]}]
set_property DRIVE 12 [get_ports {dbg[4]}]
set_property SLEW FAST [get_ports {dbg[4]}]

set_property PACKAGE_PIN AN4 [get_ports {dbg[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dbg[5]}]
set_property DRIVE 12 [get_ports {dbg[5]}]
set_property SLEW FAST [get_ports {dbg[5]}]

set_property PACKAGE_PIN AK3 [get_ports {dbg[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dbg[6]}]
set_property DRIVE 12 [get_ports {dbg[6]}]
set_property SLEW FAST [get_ports {dbg[6]}]

set_property PACKAGE_PIN AP4 [get_ports {dbg[7]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dbg[7]}]
set_property DRIVE 12 [get_ports {dbg[7]}]
set_property SLEW FAST [get_ports {dbg[7]}]

set_property PACKAGE_PIN AL3 [get_ports {dbg[8]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dbg[8]}]
set_property DRIVE 12 [get_ports {dbg[8]}]
set_property SLEW FAST [get_ports {dbg[8]}]

set_property PACKAGE_PIN AM3 [get_ports {dbg[9]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dbg[9]}]
set_property DRIVE 12 [get_ports {dbg[9]}]
set_property SLEW FAST [get_ports {dbg[9]}]

set_property PACKAGE_PIN AN3 [get_ports {dbg[10]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dbg[10]}]
set_property DRIVE 12 [get_ports {dbg[10]}]
set_property SLEW FAST [get_ports {dbg[10]}]

set_property PACKAGE_PIN AP3 [get_ports {dbg[11]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dbg[11]}]
set_property DRIVE 12 [get_ports {dbg[11]}]
set_property SLEW FAST [get_ports {dbg[11]}]

set_property PACKAGE_PIN AL2 [get_ports {dbg[12]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dbg[12]}]
set_property DRIVE 12 [get_ports {dbg[12]}]
set_property SLEW FAST [get_ports {dbg[12]}]

set_property PACKAGE_PIN AK2 [get_ports {dbg[13]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dbg[13]}]
set_property DRIVE 12 [get_ports {dbg[13]}]
set_property SLEW FAST [get_ports {dbg[13]}]

set_property PACKAGE_PIN AN2 [get_ports {dbg[14]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dbg[14]}]
set_property DRIVE 12 [get_ports {dbg[14]}]
set_property SLEW FAST [get_ports {dbg[14]}]

set_property PACKAGE_PIN AP2 [get_ports {dbg[15]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dbg[15]}]
set_property DRIVE 12 [get_ports {dbg[15]}]
set_property SLEW FAST [get_ports {dbg[15]}]

set_property PACKAGE_PIN AP1 [get_ports {dbg[16]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dbg[16]}]
set_property DRIVE 12 [get_ports {dbg[16]}]
set_property SLEW FAST [get_ports {dbg[16]}]

set_property PACKAGE_PIN AN1 [get_ports {dbg[17]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dbg[17]}]
set_property DRIVE 12 [get_ports {dbg[17]}]
set_property SLEW FAST [get_ports {dbg[17]}]

set_property PACKAGE_PIN AM1 [get_ports {dbg[18]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dbg[18]}]
set_property DRIVE 12 [get_ports {dbg[18]}]
set_property SLEW FAST [get_ports {dbg[18]}]

set_property PACKAGE_PIN AL1 [get_ports {dbg[19]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dbg[19]}]
set_property DRIVE 12 [get_ports {dbg[19]}]
set_property SLEW FAST [get_ports {dbg[19]}]























