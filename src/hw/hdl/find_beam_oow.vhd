library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.acmi_package.ALL;


entity find_beam_oow is
  port ( 
   clk              : in std_logic;
   trig             : in std_logic;
   adc_data         : in signed(15 downto 0);
   adc_data_dly     : in signed(15 downto 0);     
   params           : in t_reg_o_eeprom;
   adc_samplenum    : in std_logic_vector(31 downto 0);
   pulse_stats      : out t_reg_i_pulse_stats
  );    
end find_beam_oow;


architecture behv of find_beam_oow is


 
  signal pulse_found       : std_logic;

  signal peakfind_gate     : std_logic;
  signal peak              : signed(16 downto 0);
  signal peak_val          : std_logic; 
  signal peak_samplenum    : std_logic_vector(31 downto 0);      
  signal gate              : std_logic_vector(3 downto 0);
  signal gate_or           : std_logic;
  signal boow_adc_data     : signed(15 downto 0);
  signal boow_adc_data_dly : std_logic_vector(15 downto 0);

  signal baseline_gate     : std_logic;
  signal baseline         : signed(15 downto 0);
  signal baseline_val     : std_logic;
  signal integral_gate    : std_logic;
  signal integral         : signed(31 downto 0);
  signal integral_val     : std_logic;
  signal fwhm             : unsigned(15 downto 0);
  signal fwhm_val         : std_logic;


  attribute mark_debug                 : string;


  attribute mark_debug of gate: signal is "true";
  attribute mark_debug of gate_or: signal is "true";
  attribute mark_debug of boow_adc_data: signal is "true";
  attribute mark_debug of pulse_found: signal is "true";
  attribute mark_debug of peakfind_gate: signal is "true";
  attribute mark_debug of peak: signal is "true";
  attribute mark_debug of peak_val: signal is "true";
  attribute mark_debug of peak_samplenum: signal is "true";        
  attribute mark_debug of baseline_gate: signal is "true";
  attribute mark_debug of baseline: signal is "true";
  attribute mark_debug of baseline_val: signal is "true";
  attribute mark_debug of integral_gate: signal is "true";
  attribute mark_debug of integral: signal is "true";
  attribute mark_debug of integral_val: signal is "true";      
  attribute mark_debug of fwhm: signal is "true";
  attribute mark_debug of fwhm_val: signal is "true";

 
  

  
begin  


pulse_stats.baseline <= std_logic_vector(baseline); 
pulse_stats.integral <= std_logic_vector(integral); 
pulse_stats.peak <= std_logic_vector(peak); 
pulse_stats.peak_index <= peak_samplenum;
pulse_stats.threshold <= std_logic_vector(params.beam_oow_threshold(15 downto 0));
pulse_stats.fwhm <= std_logic_vector(fwhm); 
pulse_stats.peak_found <= peak_val;




gate_or <= gate(0) or gate(1) or gate(2) or gate(3);
boow_adc_data <= 16d"0" when (gate_or = '1') else adc_data;



gen_window_beam: entity work.gen_gate
  port map (
   clk => clk, 
   trig => trig, 
   adc_samplenum => adc_samplenum,  
   gate_start => params.beam_adc_delay, 
   width => 32d"92",
   gate => gate(0)                           
  );    


gen_window_tp1: entity work.gen_gate
  port map (
   clk => clk, 
   trig => trig, 
   adc_samplenum => adc_samplenum,  
   gate_start => params.tp1_adc_delay, 
   width => 32d"92",
   gate => gate(1)                           
  );    


gen_window_tp2: entity work.gen_gate
  port map (
   clk => clk, 
   trig => trig, 
   adc_samplenum => adc_samplenum,  
   gate_start => params.tp2_adc_delay, 
   width => 32d"92",
   gate => gate(2)                           
  );    

gen_window_tp3: entity work.gen_gate
  port map (
   clk => clk, 
   trig => trig, 
   adc_samplenum => adc_samplenum,  
   gate_start => params.tp3_adc_delay, 
   width => 32d"92",
   gate => gate(3)                           
  );    

gen_window_peakfind: entity work.gen_gate
  port map (
   clk => clk, 
   trig => pulse_found, 
   adc_samplenum => adc_samplenum,  
   gate_start => 32d"0", 
   width => 32d"10",
   gate => peakfind_gate                           
  );    


gen_windows: entity work.gen_gates
  port map (
   clk => clk, 
   trig => pulse_found, 
   adc_samplenum => adc_samplenum,  
   gate_start => 32d"0", 
   baseline_gate => baseline_gate,
   integral_gate => integral_gate                           
  );  



boow_pulse: entity work.find_boow_pulse 
  port map (
   clk => clk,    
   trig => trig,   
   threshold => params.beam_oow_threshold(15 downto 0),           
   boow_adc_data => boow_adc_data,
   boow_adc_data_dly => boow_adc_data_dly,
   pulse_found => pulse_found           
  );    



find_peak: entity work.find_peak
  port map (
   clk => clk,    
   trig => trig,             
   adc_data => boow_adc_data, --signed(boow_adc_data_dly), --boow_adc_data,
   gate =>  peakfind_gate,
   baseline => baseline, 
   sampnum => adc_samplenum,
   peak => peak,
   peak_sampnum => peak_samplenum,
   peak_val => peak_val                
  );    


adc_baseline: entity work.calc_baseline
  port map (
   clk => clk, 
   trig => trig,
   start_calc => baseline_gate,                   
   adc_data => adc_data_dly,
   baseline => baseline, 
   baseline_val => baseline_val              
  );    



pulse_integral: entity work.calc_integral
  port map (
   clk => clk, 
   trig => trig,
   start_calc => integral_gate, 
   baseline => baseline,                  
   adc_data => adc_data_dly,
   integral => integral, 
   integral_val => integral_val              
  );    


pulse_fwhm: entity work.calc_fwhm
  port map (
   clk => clk, 
   trig => trig, 
   start_calc => baseline_val,   
   baseline => baseline, 
   peak => peak,                
   adc_data => adc_data_dly, 
   fwhm => fwhm,
   fwhm_val => fwhm_val              
  );    




end behv;
