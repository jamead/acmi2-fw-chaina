
create_clock -period 5.000 -name adc_clk_in [get_ports adc_clk_p]


# 3 independent clock domains
#PL domain          ADC domain          EVR domain
#---------          ----------          ----------
#clk_pl_0           adc_clk_in          rxoutclk_out[0]
#                       |               txoutclk_out[0]
#                       v
#                   mmcm_clk



set_clock_groups -name async_clock_domains -asynchronous -group [get_clocks -include_generated_clocks clk_pl_0] -group [get_clocks -include_generated_clocks adc_clk_in] -group [get_clocks {{rxoutclk_out[0]} {txoutclk_out[0]}}]














