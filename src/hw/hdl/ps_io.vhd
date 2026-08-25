
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

library desyrdl;
use desyrdl.common.all;
use desyrdl.pkg_pl_regs.all;

library xil_defaultlib;
use xil_defaultlib.acmi_package.ALL;

library work;
use work.acmi_package.ALL;


entity ps_io is
  port (  
     pl_clock         : in std_logic;
     pl_reset         : in std_logic;
   
     m_axi4_m2s       : in t_pl_regs_m2s;
     m_axi4_s2m       : out t_pl_regs_s2m;  
      
     fp_leds          : out std_logic_vector(7 downto 0);
        
	 reg_o_adc        : out t_reg_o_adc_cntrl;
	 reg_i_adc        : in  t_reg_i_adc_status; 
	 reg_o_adcfifo    : out t_reg_o_adc_fifo_rdout;
	 reg_i_adcfifo    : in  t_reg_i_adc_fifo_rdout; 
	 reg_o_eeprom     : out t_reg_o_eeprom;
	 reg_i_pulsestats : in t_reg_i_pulse_stats_array;
	 
	 reg_i_trig      : in t_reg_i_trig;

	 reg_o_evr       : out t_reg_o_evr;
	 reg_i_evr       : in  t_reg_i_evr;

     ioc_access_led  : out std_logic

  );
end ps_io;


architecture behv of ps_io is

  

  
  signal reg_i        : t_addrmap_pl_regs_in;
  signal reg_o        : t_addrmap_pl_regs_out;
  signal ioc_access   : std_logic;





begin

fp_leds <= reg_o.FP_LEDS.val.data;
ioc_access <= reg_o.ioc_access.data.data(0);


reg_o_adc.spi_we <= reg_o.adc_spi.data.swmod; 
reg_o_adc.spi_wdata <= reg_o.adc_spi.data.data; 
reg_i.adc_spi.data.data <= reg_i_adc.spi_rdata;    
reg_o_adc.idly_wval <= reg_o.adc_idlyval.data.data;  
reg_o_adc.idly_wstr <= reg_o.adc_idlystr.data.data; 

reg_i.adc_idlyrdval.data.data <= reg_i_adc.idly_rval;   


reg_o_adcfifo.fifo_enb <= reg_o.adcfifo_streamenb.data.swmod;
reg_o_adcfifo.fifo_rst <= reg_o.adcfifo_reset.data.data(0);
reg_o_adcfifo.fifo_rdstr <= reg_o.adcfifo_data.data.swacc;
reg_i.adcfifo_rdcnt.data.data <= reg_i_adcfifo.fifo_rdcnt;
reg_i.adcfifo_data.data.data <= reg_i_adcfifo.fifo_dout;


reg_i.ts_ns.val.data <= reg_i_evr.ts_ns; 
reg_i.ts_s.val.data <= reg_i_evr.ts_s; 
reg_i.trig_ts_ns.val.data <= reg_i_trig.ts_ns; 
reg_i.trig_ts_s.val.data <= reg_i_trig.ts_s; 

reg_o_evr.reset <= reg_o.evr_reset.data.data(0);
reg_o_evr.dma_trigno <= reg_o.trig_eventno.val.data;



-- EEPROM
reg_o_eeprom.header <= reg_o.header.val.data;
reg_o_eeprom.tp1_pulse_delay <= reg_o.tp1_pulse_delay.val.data;
reg_o_eeprom.tp1_pulse_width <= reg_o.tp1_pulse_width.val.data;
reg_o_eeprom.tp1_adc_delay <= reg_o.tp1_adc_delay.val.data;
reg_o_eeprom.tp2_pulse_delay <= reg_o.tp2_pulse_delay.val.data;
reg_o_eeprom.tp2_pulse_width <= reg_o.tp2_pulse_width.val.data;
reg_o_eeprom.tp2_adc_delay <= reg_o.tp2_adc_delay.val.data;
reg_o_eeprom.tp3_pulse_delay <= reg_o.tp3_pulse_delay.val.data;
reg_o_eeprom.tp3_pulse_width <= reg_o.tp3_pulse_width.val.data;
reg_o_eeprom.tp3_adc_delay <= reg_o.tp3_adc_delay.val.data;
reg_o_eeprom.beam_adc_delay <= reg_o.beam_adc_delay.val.data;
reg_o_eeprom.beam_oow_threshold <= reg_o.beam_oow_threshold.val.data;
reg_o_eeprom.tp1_int_low_limit <= reg_o.tp1_int_low_limit.val.data;
reg_o_eeprom.tp1_int_high_limit <= reg_o.tp1_int_high_limit.val.data;
reg_o_eeprom.tp2_int_low_limit <= reg_o.tp2_int_low_limit.val.data;
reg_o_eeprom.tp2_int_high_limit <= reg_o.tp2_int_high_limit.val.data;
reg_o_eeprom.tp3_int_low_limit <= reg_o.tp3_int_low_limit.val.data;
reg_o_eeprom.tp3_int_high_limit <= reg_o.tp3_int_high_limit.val.data;
reg_o_eeprom.tp1_peak_low_limit <= reg_o.tp1_peak_low_limit.val.data;
reg_o_eeprom.tp1_peak_high_limit <= reg_o.tp1_peak_high_limit.val.data;
reg_o_eeprom.tp2_peak_low_limit <= reg_o.tp2_peak_low_limit.val.data;
reg_o_eeprom.tp2_peak_high_limit <= reg_o.tp2_peak_high_limit.val.data;
reg_o_eeprom.tp3_peak_low_limit <= reg_o.tp3_peak_low_limit.val.data;
reg_o_eeprom.tp3_peak_high_limit <= reg_o.tp3_peak_high_limit.val.data;
reg_o_eeprom.tp1_fwhm_low_limit <= reg_o.tp1_fwhm_low_limit.val.data;
reg_o_eeprom.tp1_fwhm_high_limit <= reg_o.tp1_fwhm_high_limit.val.data;
reg_o_eeprom.tp2_fwhm_low_limit <= reg_o.tp2_fwhm_low_limit.val.data;
reg_o_eeprom.tp2_fwhm_high_limit <= reg_o.tp2_fwhm_high_limit.val.data;
reg_o_eeprom.tp3_fwhm_low_limit <= reg_o.tp3_fwhm_low_limit.val.data;
reg_o_eeprom.tp3_fwhm_high_limit <= reg_o.tp3_fwhm_high_limit.val.data;
reg_o_eeprom.tp1_base_low_limit <= reg_o.tp1_base_low_limit.val.data;
reg_o_eeprom.tp1_base_high_limit <= reg_o.tp1_base_high_limit.val.data;
reg_o_eeprom.tp2_base_low_limit <= reg_o.tp2_base_low_limit.val.data;
reg_o_eeprom.tp2_base_high_limit <= reg_o.tp2_base_high_limit.val.data;
reg_o_eeprom.tp3_base_low_limit <= reg_o.tp3_base_low_limit.val.data;
reg_o_eeprom.tp3_base_high_limit <= reg_o.tp3_base_high_limit.val.data;
reg_o_eeprom.tp1_pos_level <= reg_o.tp1_pos_level.val.data;
reg_o_eeprom.tp2_pos_level <= reg_o.tp2_pos_level.val.data;
reg_o_eeprom.tp3_pos_level <= reg_o.tp3_pos_level.val.data;
reg_o_eeprom.tp1_neg_level <= reg_o.tp1_neg_level.val.data;
reg_o_eeprom.tp2_neg_level <= reg_o.tp2_neg_level.val.data;
reg_o_eeprom.tp3_neg_level <= reg_o.tp3_neg_level.val.data;
reg_o_eeprom.beamaccum_limit_hr <= reg_o.accum_HL.val.data;
reg_o_eeprom.beamhigh_limit <= reg_o.beam_HL.val.data;
reg_o_eeprom.baseline_low_limit <= reg_o.baseline_low_limit.val.data;
reg_o_eeprom.baseline_high_limit <= reg_o.baseline_high_limit.val.data;
reg_o_eeprom.charge_calibration <= reg_o.charge_cal.val.data;
reg_o_eeprom.accum_q_min <= reg_o.accum_q_min.val.data;
reg_o_eeprom.accum_length <= reg_o.accum_len.val.data;
reg_o_eeprom.crc32_eeprom <= reg_o.crc_eeprom.val.data;



-- Pulse Statistics
reg_i.pulse0_baseline.val.data <= reg_i_pulsestats(0).baseline;
reg_i.pulse0_integral.val.data <= reg_i_pulsestats(0).integral;
reg_i.pulse0_peak.val.data <= reg_i_pulsestats(0).peak;
reg_i.pulse0_peak_index.val.data <= reg_i_pulsestats(0).peak_index;
reg_i.pulse0_peak_found.val.data(0) <= reg_i_pulsestats(0).peak_found;
reg_i.pulse0_threshold.val.data <= reg_i_pulsestats(0).threshold;
reg_i.pulse0_fwhm.val.data <= reg_i_pulsestats(0).fwhm;

reg_i.pulse1_baseline.val.data <= reg_i_pulsestats(1).baseline;
reg_i.pulse1_integral.val.data <= reg_i_pulsestats(1).integral;
reg_i.pulse1_peak.val.data <= reg_i_pulsestats(1).peak;
reg_i.pulse1_peak_index.val.data <= reg_i_pulsestats(1).peak_index;
reg_i.pulse1_peak_found.val.data(0) <= reg_i_pulsestats(1).peak_found;
reg_i.pulse1_threshold.val.data <= reg_i_pulsestats(1).threshold;
reg_i.pulse1_fwhm.val.data <= reg_i_pulsestats(1).fwhm;

reg_i.pulse2_baseline.val.data <= reg_i_pulsestats(2).baseline;
reg_i.pulse2_integral.val.data <= reg_i_pulsestats(2).integral;
reg_i.pulse2_peak.val.data <= reg_i_pulsestats(2).peak;
reg_i.pulse2_peak_index.val.data <= reg_i_pulsestats(2).peak_index;
reg_i.pulse2_peak_found.val.data(0) <= reg_i_pulsestats(2).peak_found;
reg_i.pulse2_threshold.val.data <= reg_i_pulsestats(2).threshold;
reg_i.pulse2_fwhm.val.data <= reg_i_pulsestats(2).fwhm;

reg_i.pulse3_baseline.val.data <= reg_i_pulsestats(3).baseline;
reg_i.pulse3_integral.val.data <= reg_i_pulsestats(3).integral;
reg_i.pulse3_peak.val.data <= reg_i_pulsestats(3).peak;
reg_i.pulse3_peak_index.val.data <= reg_i_pulsestats(3).peak_index;
reg_i.pulse3_peak_found.val.data(0) <= reg_i_pulsestats(3).peak_found;
reg_i.pulse3_threshold.val.data <= reg_i_pulsestats(3).threshold;
reg_i.pulse3_fwhm.val.data <= reg_i_pulsestats(3).fwhm;

reg_i.pulse4_baseline.val.data <= reg_i_pulsestats(4).baseline;
reg_i.pulse4_integral.val.data <= reg_i_pulsestats(4).integral;
reg_i.pulse4_peak.val.data <= reg_i_pulsestats(4).peak;
reg_i.pulse4_peak_index.val.data <= reg_i_pulsestats(4).peak_index;
reg_i.pulse4_peak_found.val.data(0) <= reg_i_pulsestats(4).peak_found;
reg_i.pulse4_threshold.val.data <= reg_i_pulsestats(4).threshold;
reg_i.pulse4_fwhm.val.data <= reg_i_pulsestats(4).fwhm;





regs: pl_regs
  port map (
    pi_clock => pl_clock, 
    pi_reset => pl_reset, 

    pi_s_top => m_axi4_m2s, 
    po_s_top => m_axi4_s2m, 
    -- to logic interface
    pi_addrmap => reg_i,  
    po_addrmap => reg_o
  );


--stretch the signal so can be seen on LED
iocaccess_stretch : entity work.stretch
  port map (
	clk => pl_clock,
	reset => pl_reset, 
	sig_in => ioc_access, 
	len => 3000000, -- ~25ms;
	sig_out => ioc_access_led
);	 



end behv;
