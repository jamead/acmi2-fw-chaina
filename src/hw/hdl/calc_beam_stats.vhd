library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.acmi_package.ALL;


entity calc_beam_stats is
  port ( 
   clk              : in std_logic;
   trig             : in std_logic;
   adc_data         : in signed(15 downto 0);
   adc_data_dly     : in signed(15 downto 0);
   gate_start       : in std_logic_vector(31 downto 0);
   adc_samplenum    : in std_logic_vector(31 downto 0);
   pulse_stats      : out t_reg_i_pulse_stats
  );    
end calc_beam_stats;


architecture behv of calc_beam_stats is



  signal peak             : signed(16 downto 0);  
  signal peak_sampnum     : std_logic_vector(31 downto 0);
  signal peak_val         : std_logic;         
  signal baseline         : signed(15 downto 0);
  signal baseline_val     : std_logic;
  signal integral         : signed(31 downto 0);
  signal integral_val     : std_logic;
  signal fwhm             : unsigned(15 downto 0);
  signal fwhm_val         : std_logic;
  signal baseline_gate    : std_logic;
  signal integral_gate    : std_logic;


  attribute mark_debug                 : string;

--  attribute mark_debug of peak: signal is "true";   
--  attribute mark_debug of baseline: signal is "true";
--  attribute mark_debug of baseline_val: signal is "true";
--  attribute mark_debug of integral: signal is "true";
--  attribute mark_debug of integral_val: signal is "true";
--  attribute mark_debug of gate_start: signal is "true";
--  attribute mark_debug of baseline_gate: signal is "true";
--  attribute mark_debug of integral_gate: signal is "true";

  
  
  
  
begin  


pulse_stats.baseline <= std_logic_vector(baseline);
pulse_stats.integral <= std_logic_vector(integral);
pulse_stats.peak <= std_logic_vector(peak);
pulse_stats.peak_index <= peak_sampnum;
pulse_stats.threshold <= (others => '0');
pulse_stats.fwhm <= std_logic_vector(fwhm);
pulse_stats.peak_found <= '1';





gen_windows: entity work.gen_gates
  port map (
   clk => clk, 
   trig => trig, 
   adc_samplenum => adc_samplenum,  
   gate_start => gate_start, 
   baseline_gate => baseline_gate,
   integral_gate => integral_gate                           
  );    


find_peak: entity work.find_peak
  port map (
   clk => clk,    
   trig => trig,             
   adc_data => adc_data,
   gate =>  integral_gate,
   baseline => baseline,
   sampnum => adc_samplenum,
   peak => peak,
   peak_sampnum => peak_sampnum,
   peak_val => peak_val                
  );    



adc_baseline: entity work.calc_baseline
  port map (
   clk => clk, 
   trig => trig,
   start_calc => baseline_gate,                   
   adc_data => adc_data,
   baseline => baseline, 
   baseline_val => baseline_val              
  );    



pulse_integral: entity work.calc_integral
  port map (
   clk => clk, 
   trig => trig,
   start_calc => integral_gate, 
   baseline => baseline,                  
   adc_data => adc_data,
   integral => integral, 
   integral_val => integral_val              
  );    


pulse_fwhm: entity work.calc_fwhm
  port map (
   clk => clk, 
   trig => trig, 
   start_calc => peak_val,   
   baseline => baseline, 
   peak => peak,                
   adc_data => adc_data_dly, 
   fwhm => fwhm,
   fwhm_val => fwhm_val              
  );    



end behv;

