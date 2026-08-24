

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
set_property port_width 16 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {wvfm_fifo/adc_data[0]} {wvfm_fifo/adc_data[1]} {wvfm_fifo/adc_data[2]} {wvfm_fifo/adc_data[3]} {wvfm_fifo/adc_data[4]} {wvfm_fifo/adc_data[5]} {wvfm_fifo/adc_data[6]} {wvfm_fifo/adc_data[7]} {wvfm_fifo/adc_data[8]} {wvfm_fifo/adc_data[9]} {wvfm_fifo/adc_data[10]} {wvfm_fifo/adc_data[11]} {wvfm_fifo/adc_data[12]} {wvfm_fifo/adc_data[13]} {wvfm_fifo/adc_data[14]} {wvfm_fifo/adc_data[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 16 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {wvfm_fifo/fifo_dout[0]} {wvfm_fifo/fifo_dout[1]} {wvfm_fifo/fifo_dout[2]} {wvfm_fifo/fifo_dout[3]} {wvfm_fifo/fifo_dout[4]} {wvfm_fifo/fifo_dout[5]} {wvfm_fifo/fifo_dout[6]} {wvfm_fifo/fifo_dout[7]} {wvfm_fifo/fifo_dout[8]} {wvfm_fifo/fifo_dout[9]} {wvfm_fifo/fifo_dout[10]} {wvfm_fifo/fifo_dout[11]} {wvfm_fifo/fifo_dout[12]} {wvfm_fifo/fifo_dout[13]} {wvfm_fifo/fifo_dout[14]} {wvfm_fifo/fifo_dout[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 32 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {wvfm_fifo/reg_i[fifo_dout][0]} {wvfm_fifo/reg_i[fifo_dout][1]} {wvfm_fifo/reg_i[fifo_dout][2]} {wvfm_fifo/reg_i[fifo_dout][3]} {wvfm_fifo/reg_i[fifo_dout][4]} {wvfm_fifo/reg_i[fifo_dout][5]} {wvfm_fifo/reg_i[fifo_dout][6]} {wvfm_fifo/reg_i[fifo_dout][7]} {wvfm_fifo/reg_i[fifo_dout][8]} {wvfm_fifo/reg_i[fifo_dout][9]} {wvfm_fifo/reg_i[fifo_dout][10]} {wvfm_fifo/reg_i[fifo_dout][11]} {wvfm_fifo/reg_i[fifo_dout][12]} {wvfm_fifo/reg_i[fifo_dout][13]} {wvfm_fifo/reg_i[fifo_dout][14]} {wvfm_fifo/reg_i[fifo_dout][15]} {wvfm_fifo/reg_i[fifo_dout][16]} {wvfm_fifo/reg_i[fifo_dout][17]} {wvfm_fifo/reg_i[fifo_dout][18]} {wvfm_fifo/reg_i[fifo_dout][19]} {wvfm_fifo/reg_i[fifo_dout][20]} {wvfm_fifo/reg_i[fifo_dout][21]} {wvfm_fifo/reg_i[fifo_dout][22]} {wvfm_fifo/reg_i[fifo_dout][23]} {wvfm_fifo/reg_i[fifo_dout][24]} {wvfm_fifo/reg_i[fifo_dout][25]} {wvfm_fifo/reg_i[fifo_dout][26]} {wvfm_fifo/reg_i[fifo_dout][27]} {wvfm_fifo/reg_i[fifo_dout][28]} {wvfm_fifo/reg_i[fifo_dout][29]} {wvfm_fifo/reg_i[fifo_dout][30]} {wvfm_fifo/reg_i[fifo_dout][31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 32 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {wvfm_fifo/reg_i[fifo_rdcnt][0]} {wvfm_fifo/reg_i[fifo_rdcnt][1]} {wvfm_fifo/reg_i[fifo_rdcnt][2]} {wvfm_fifo/reg_i[fifo_rdcnt][3]} {wvfm_fifo/reg_i[fifo_rdcnt][4]} {wvfm_fifo/reg_i[fifo_rdcnt][5]} {wvfm_fifo/reg_i[fifo_rdcnt][6]} {wvfm_fifo/reg_i[fifo_rdcnt][7]} {wvfm_fifo/reg_i[fifo_rdcnt][8]} {wvfm_fifo/reg_i[fifo_rdcnt][9]} {wvfm_fifo/reg_i[fifo_rdcnt][10]} {wvfm_fifo/reg_i[fifo_rdcnt][11]} {wvfm_fifo/reg_i[fifo_rdcnt][12]} {wvfm_fifo/reg_i[fifo_rdcnt][13]} {wvfm_fifo/reg_i[fifo_rdcnt][14]} {wvfm_fifo/reg_i[fifo_rdcnt][15]} {wvfm_fifo/reg_i[fifo_rdcnt][16]} {wvfm_fifo/reg_i[fifo_rdcnt][17]} {wvfm_fifo/reg_i[fifo_rdcnt][18]} {wvfm_fifo/reg_i[fifo_rdcnt][19]} {wvfm_fifo/reg_i[fifo_rdcnt][20]} {wvfm_fifo/reg_i[fifo_rdcnt][21]} {wvfm_fifo/reg_i[fifo_rdcnt][22]} {wvfm_fifo/reg_i[fifo_rdcnt][23]} {wvfm_fifo/reg_i[fifo_rdcnt][24]} {wvfm_fifo/reg_i[fifo_rdcnt][25]} {wvfm_fifo/reg_i[fifo_rdcnt][26]} {wvfm_fifo/reg_i[fifo_rdcnt][27]} {wvfm_fifo/reg_i[fifo_rdcnt][28]} {wvfm_fifo/reg_i[fifo_rdcnt][29]} {wvfm_fifo/reg_i[fifo_rdcnt][30]} {wvfm_fifo/reg_i[fifo_rdcnt][31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 16 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {adc/adc_data_2s[0]} {adc/adc_data_2s[1]} {adc/adc_data_2s[2]} {adc/adc_data_2s[3]} {adc/adc_data_2s[4]} {adc/adc_data_2s[5]} {adc/adc_data_2s[6]} {adc/adc_data_2s[7]} {adc/adc_data_2s[8]} {adc/adc_data_2s[9]} {adc/adc_data_2s[10]} {adc/adc_data_2s[11]} {adc/adc_data_2s[12]} {adc/adc_data_2s[13]} {adc/adc_data_2s[14]} {adc/adc_data_2s[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 16 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {adc/adc_data_corr[0]} {adc/adc_data_corr[1]} {adc/adc_data_corr[2]} {adc/adc_data_corr[3]} {adc/adc_data_corr[4]} {adc/adc_data_corr[5]} {adc/adc_data_corr[6]} {adc/adc_data_corr[7]} {adc/adc_data_corr[8]} {adc/adc_data_corr[9]} {adc/adc_data_corr[10]} {adc/adc_data_corr[11]} {adc/adc_data_corr[12]} {adc/adc_data_corr[13]} {adc/adc_data_corr[14]} {adc/adc_data_corr[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 16 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {adc/adc_data_ob[0]} {adc/adc_data_ob[1]} {adc/adc_data_ob[2]} {adc/adc_data_ob[3]} {adc/adc_data_ob[4]} {adc/adc_data_ob[5]} {adc/adc_data_ob[6]} {adc/adc_data_ob[7]} {adc/adc_data_ob[8]} {adc/adc_data_ob[9]} {adc/adc_data_ob[10]} {adc/adc_data_ob[11]} {adc/adc_data_ob[12]} {adc/adc_data_ob[13]} {adc/adc_data_ob[14]} {adc/adc_data_ob[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 16 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {adc_data[0]} {adc_data[1]} {adc_data[2]} {adc_data[3]} {adc_data[4]} {adc_data[5]} {adc_data[6]} {adc_data[7]} {adc_data[8]} {adc_data[9]} {adc_data[10]} {adc_data[11]} {adc_data[12]} {adc_data[13]} {adc_data[14]} {adc_data[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list wvfm_fifo/fifo_wren]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {wvfm_fifo/reg_o[fifo_enb]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {wvfm_fifo/reg_o[fifo_rdstr]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {wvfm_fifo/reg_o[fifo_rst]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list wvfm_fifo/trig_s]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets adc_clk]
