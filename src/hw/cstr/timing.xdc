

create_clock -period 4.000 -name adc_dco0 -waveform {1.000 3.000} [get_ports {adc_dco_p[0]}]
create_clock -period 4.000 -name adc_dco1 -waveform {1.000 3.000} [get_ports {adc_dco_p[1]}]

create_clock -period 8.000 -name adc_fco0 -waveform {0.000 4.000} [get_ports {adc_fco_p[0]}]
create_clock -period 8.000 -name adc_fco1 -waveform {0.000 4.000} [get_ports {adc_fco_p[1]}]


set_clock_groups -name sysclk_adcclks -asynchronous -group [get_clocks clk_pl_0] -group [get_clocks [list adc_dco0 adc_dco1 adc_fco0 adc_fco1 clk_gth_refclk_0 clk_pl_0 [get_clocks -of_objects [get_pins adc_inst/adc0_fco_pll/inst/mmcme4_adv_inst/CLKOUT0]] [get_clocks -of_objects [get_pins adc_inst/adc1_fco_pll/inst/mmcme4_adv_inst/CLKOUT0]]]]

set_clock_groups -name sysclk_evrrxclk -asynchronous -group [get_clocks clk_pl_0] -group [get_clocks -of_objects [get_pins {evr/evr_syn.gth/inst/gen_gtwizard_gthe4_top.gth_wiz_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[1].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLK}]]
set_clock_groups -name sysclk_evrtxclk -asynchronous -group [get_clocks clk_pl_0] -group [get_clocks -of_objects [get_pins {evr/evr_syn.gth/inst/gen_gtwizard_gthe4_top.gth_wiz_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[1].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -name adcclk_evrrxclk -asynchronous -group [get_clocks -of_objects [get_pins adc_inst/adc1_fco_pll/inst/mmcme4_adv_inst/CLKOUT0]] -group [get_clocks -of_objects [get_pins {evr/evr_syn.gth/inst/gen_gtwizard_gthe4_top.gth_wiz_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[1].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLK}]]



#set_clock_groups -name sysclk_evrclk -asynchronous -group [get_clocks clk_pl_0] -group [get_clocks {evr/evr_syn.gth/inst/gen_gtwizard_gthe4_top.gth_wiz_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_cpll_cal_gthe4.gen_cpll_cal_inst[0].gen_inst_cpll_cal.gtwizard_ultrascale_v1_7_14_gthe4_cpll_cal_inst/gtwizard_ultrascale_v1_7_14_gthe4_cpll_cal_tx_i/bufg_gt_txoutclkmon_inst/O}]


#set_input_delay -clock [get_clocks adc_dco0] 1 [get_ports [list adc_sdata_p[0] adc_sdata_p[1] adc_sdata_p[2] adc_sdata_p[3] adc_sdata_p[4] adc_sdata_p[5] adc_sdata_p[6] adc_sdata_p[7]]]
#set_input_delay -clock [get_clocks adc_dco1] 1 [get_ports [list adc_sdata_p[8] adc_sdata_p[9] adc_sdata_p[10] adc_sdata_p[11] adc_sdata_p[12] adc_sdata_p[13] adc_sdata_p[14] adc_sdata_p[15]]]


#set_false_path -from [get_clocks adc_dco0] -to [get_clocks -of_objects [get_pins adc_inst/adc0_fco_pll/inst/mmcme4_adv_inst/CLKOUT0]]
#set_false_path -from [get_clocks adc_dco1] -to [get_clocks -of_objects [get_pins adc_inst/adc1_fco_pll/inst/mmcme4_adv_inst/CLKOUT0]]



















