

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 2048 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list adc/read_adc/adc_clk]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 8 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {adc/adc_spi/rreg[0]} {adc/adc_spi/rreg[1]} {adc/adc_spi/rreg[2]} {adc/adc_spi/rreg[3]} {adc/adc_spi/rreg[4]} {adc/adc_spi/rreg[5]} {adc/adc_spi/rreg[6]} {adc/adc_spi/rreg[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 2 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {adc/adc_spi/state[0]} {adc/adc_spi/state[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 8 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {adc/adc_spi/spi_addr[0]} {adc/adc_spi/spi_addr[1]} {adc/adc_spi/spi_addr[2]} {adc/adc_spi/spi_addr[3]} {adc/adc_spi/spi_addr[4]} {adc/adc_spi/spi_addr[5]} {adc/adc_spi/spi_addr[6]} {adc/adc_spi/spi_addr[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 8 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {adc/adc_spi/spi_data[0]} {adc/adc_spi/spi_data[1]} {adc/adc_spi/spi_data[2]} {adc/adc_spi/spi_data[3]} {adc/adc_spi/spi_data[4]} {adc/adc_spi/spi_data[5]} {adc/adc_spi/spi_data[6]} {adc/adc_spi/spi_data[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 16 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {adc/read_adc/adc_data[0]} {adc/read_adc/adc_data[1]} {adc/read_adc/adc_data[2]} {adc/read_adc/adc_data[3]} {adc/read_adc/adc_data[4]} {adc/read_adc/adc_data[5]} {adc/read_adc/adc_data[6]} {adc/read_adc/adc_data[7]} {adc/read_adc/adc_data[8]} {adc/read_adc/adc_data[9]} {adc/read_adc/adc_data[10]} {adc/read_adc/adc_data[11]} {adc/read_adc/adc_data[12]} {adc/read_adc/adc_data[13]} {adc/read_adc/adc_data[14]} {adc/read_adc/adc_data[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 16 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {adc/adc_data_2s[0]} {adc/adc_data_2s[1]} {adc/adc_data_2s[2]} {adc/adc_data_2s[3]} {adc/adc_data_2s[4]} {adc/adc_data_2s[5]} {adc/adc_data_2s[6]} {adc/adc_data_2s[7]} {adc/adc_data_2s[8]} {adc/adc_data_2s[9]} {adc/adc_data_2s[10]} {adc/adc_data_2s[11]} {adc/adc_data_2s[12]} {adc/adc_data_2s[13]} {adc/adc_data_2s[14]} {adc/adc_data_2s[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 16 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {adc/adc_data_corr[0]} {adc/adc_data_corr[1]} {adc/adc_data_corr[2]} {adc/adc_data_corr[3]} {adc/adc_data_corr[4]} {adc/adc_data_corr[5]} {adc/adc_data_corr[6]} {adc/adc_data_corr[7]} {adc/adc_data_corr[8]} {adc/adc_data_corr[9]} {adc/adc_data_corr[10]} {adc/adc_data_corr[11]} {adc/adc_data_corr[12]} {adc/adc_data_corr[13]} {adc/adc_data_corr[14]} {adc/adc_data_corr[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 16 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {adc/adc_data_ob[0]} {adc/adc_data_ob[1]} {adc/adc_data_ob[2]} {adc/adc_data_ob[3]} {adc/adc_data_ob[4]} {adc/adc_data_ob[5]} {adc/adc_data_ob[6]} {adc/adc_data_ob[7]} {adc/adc_data_ob[8]} {adc/adc_data_ob[9]} {adc/adc_data_ob[10]} {adc/adc_data_ob[11]} {adc/adc_data_ob[12]} {adc/adc_data_ob[13]} {adc/adc_data_ob[14]} {adc/adc_data_ob[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list adc/adc_spi/din]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list adc/adc_spi/dout]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list adc/adc_spi/prev_spi_trig]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list adc/adc_spi/sclk]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list adc/adc_spi/spi_trig]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 1 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list adc/adc_spi/sync]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets u_ila_0_adc_clk]
