# ------------------------------------------------------------------------------
# ADC LTC2107 interface - Bank 65 (1.8 V)
# ------------------------------------------------------------------------------

# SPI / control
set_property PACKAGE_PIN AE2 [get_ports adc_spi_cs]
set_property PACKAGE_PIN AD2 [get_ports adc_spi_sck]
set_property PACKAGE_PIN AE3 [get_ports adc_spi_sdi]
set_property PACKAGE_PIN AH1 [get_ports adc_spi_sdo]

set_property IOSTANDARD LVCMOS18 [get_ports adc_spi_cs]
set_property IOSTANDARD LVCMOS18 [get_ports adc_spi_sck]
set_property IOSTANDARD LVCMOS18 [get_ports adc_spi_sdi]
set_property IOSTANDARD LVCMOS18 [get_ports adc_spi_sdo]

# ADC differential clock
set_property PACKAGE_PIN AE5 [get_ports adc_clk_p]
set_property PACKAGE_PIN AF5 [get_ports adc_clk_n]

# ADC differential data lanes
set_property PACKAGE_PIN AE10 [get_ports {adc_data_p[0]}]
set_property PACKAGE_PIN AF10 [get_ports {adc_data_n[0]}]
set_property PACKAGE_PIN AE8 [get_ports {adc_data_p[1]}]
set_property PACKAGE_PIN AF8 [get_ports {adc_data_n[1]}]
set_property PACKAGE_PIN AF6 [get_ports {adc_data_p[2]}]
set_property PACKAGE_PIN AG6 [get_ports {adc_data_n[2]}]
set_property PACKAGE_PIN AG5 [get_ports {adc_data_p[3]}]
set_property PACKAGE_PIN AG4 [get_ports {adc_data_n[3]}]
set_property PACKAGE_PIN AE7 [get_ports {adc_data_p[4]}]
set_property PACKAGE_PIN AF7 [get_ports {adc_data_n[4]}]
set_property PACKAGE_PIN AF2 [get_ports {adc_data_p[5]}]
set_property PACKAGE_PIN AF1 [get_ports {adc_data_n[5]}]
set_property PACKAGE_PIN AD10 [get_ports {adc_data_p[6]}]
set_property PACKAGE_PIN AE9 [get_ports {adc_data_n[6]}]
set_property PACKAGE_PIN AD7 [get_ports {adc_data_p[7]}]
set_property PACKAGE_PIN AD6 [get_ports {adc_data_n[7]}]

# ADC overflow differential pair
set_property PACKAGE_PIN AD4 [get_ports adc_of_p]
set_property PACKAGE_PIN AE4 [get_ports adc_of_n]

set_property IOSTANDARD LVDS [get_ports {adc_clk_p adc_clk_n {adc_data_p[*]} {adc_data_n[*]} adc_of_p adc_of_n}]

# Internal 100-ohm differential termination on the FPGA receiver.
# Apply the termination property to the P side of each differential input pair.
set_property DIFF_TERM_ADV TERM_100 [get_ports adc_clk_p]
set_property DIFF_TERM_ADV TERM_100 [get_ports {adc_data_p[*]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports adc_of_p]

# Add the ADC clock timing constraint when its actual frequency is known, e.g.:
# create_clock -name adc_clk -period <period_ns> [get_ports adc_clk_p]

# ------------------------------------------------------------------------------
# Fault LEDs - Bank 66 (1.8 V)
# ------------------------------------------------------------------------------
set_property PACKAGE_PIN AA12 [get_ports {fault_led[0]}]
set_property PACKAGE_PIN Y12 [get_ports {fault_led[1]}]
set_property PACKAGE_PIN Y1 [get_ports {fault_led[2]}]
set_property PACKAGE_PIN Y2 [get_ports {fault_led[3]}]
set_property PACKAGE_PIN W4 [get_ports {fault_led[4]}]
set_property PACKAGE_PIN W5 [get_ports {fault_led[5]}]
set_property PACKAGE_PIN AC11 [get_ports {fault_led[6]}]
set_property PACKAGE_PIN AC12 [get_ports {fault_led[7]}]
set_property PACKAGE_PIN Y7 [get_ports {fault_led[8]}]
set_property PACKAGE_PIN Y8 [get_ports {fault_led[9]}]
set_property PACKAGE_PIN AA6 [get_ports {fault_led[10]}]
set_property PACKAGE_PIN AA7 [get_ports {fault_led[11]}]
set_property PACKAGE_PIN AA10 [get_ports {fault_led[12]}]
set_property PACKAGE_PIN AA11 [get_ports {fault_led[13]}]
set_property PACKAGE_PIN Y9 [get_ports {fault_led[14]}]
set_property PACKAGE_PIN Y10 [get_ports {fault_led[15]}]

set_property IOSTANDARD LVCMOS18 [get_ports {fault_led[*]}]

# ------------------------------------------------------------------------------
# Test pulser interface - HD Banks 49/50 (3.3 V)
# ------------------------------------------------------------------------------
set_property PACKAGE_PIN E15 [get_ports {tp_neg_pulse[0]}]
set_property PACKAGE_PIN A16 [get_ports {tp_neg_pulse[1]}]
set_property PACKAGE_PIN A15 [get_ports {tp_neg_pulse[2]}]
set_property PACKAGE_PIN B15 [get_ports {tp_neg_pulse[3]}]
set_property PACKAGE_PIN A13 [get_ports {tp_neg_pulse[4]}]

set_property PACKAGE_PIN C13 [get_ports {tp_pos_pulse[0]}]
set_property PACKAGE_PIN G16 [get_ports {tp_pos_pulse[1]}]
set_property PACKAGE_PIN B16 [get_ports {tp_pos_pulse[2]}]
set_property PACKAGE_PIN A12 [get_ports {tp_pos_pulse[3]}]
set_property PACKAGE_PIN B13 [get_ports {tp_pos_pulse[4]}]

set_property IOSTANDARD LVCMOS33 [get_ports {{tp_neg_pulse[*]} {tp_pos_pulse[*]}}]

# ------------------------------------------------------------------------------
# EEPROM interface - HD Banks 49/50 (3.3 V)
# ------------------------------------------------------------------------------
set_property PACKAGE_PIN F13 [get_ports eeprom_csn]
set_property PACKAGE_PIN D12 [get_ports eeprom_sck]
set_property PACKAGE_PIN E14 [get_ports eeprom_sdi]
set_property PACKAGE_PIN B12 [get_ports eeprom_holdn]
set_property PACKAGE_PIN D10 [get_ports eeprom_sdo]

set_property IOSTANDARD LVCMOS33 [get_ports eeprom_csn]
set_property IOSTANDARD LVCMOS33 [get_ports eeprom_sck]
set_property IOSTANDARD LVCMOS33 [get_ports eeprom_sdi]
set_property IOSTANDARD LVCMOS33 [get_ports eeprom_holdn]
set_property IOSTANDARD LVCMOS33 [get_ports eeprom_sdo]

# Spreadsheet net 'wpn' is on U9 D11, but no corresponding port was present in
# the supplied VHDL entity declaration, so it is intentionally not constrained.

# ------------------------------------------------------------------------------
# Relay board interface - HD Bank 50 (3.3 V)
# ------------------------------------------------------------------------------
set_property PACKAGE_PIN J12 [get_ports faultn]
set_property PACKAGE_PIN H14 [get_ports faultn_rdbk]
set_property PACKAGE_PIN E10 [get_ports fault_rst]
set_property PACKAGE_PIN G11 [get_ports force_trig]
set_property PACKAGE_PIN H12 [get_ports keylock]

set_property PACKAGE_PIN G14 [get_ports {spare[0]}]
set_property PACKAGE_PIN F12 [get_ports {spare[1]}]
set_property PACKAGE_PIN F11 [get_ports {spare[2]}]
set_property PACKAGE_PIN J14 [get_ports {spare[3]}]
set_property PACKAGE_PIN J16 [get_ports {spare[4]}]

set_property IOSTANDARD LVCMOS33 [get_ports {faultn faultn_rdbk fault_rst force_trig keylock {spare[*]}}]

# ------------------------------------------------------------------------------
# AFE power management - HD Bank 50 (3.3 V)
# ------------------------------------------------------------------------------
set_property PACKAGE_PIN H11 [get_ports afe_pwrenb]
set_property IOSTANDARD LVCMOS33 [get_ports afe_pwrenb]






