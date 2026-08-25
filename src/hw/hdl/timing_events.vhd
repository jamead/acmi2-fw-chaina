-------------------------------------------------------------------------------
-- Title         : generate timing events
-------------------------------------------------------------------------------

-- 08/19/2015: created.
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.acmi_package.ALL;


entity timing_events is 
  port (
    clk          	    : in std_logic;  
    reset               : in std_logic;
    trig                : in std_logic;
    eeprom_params       : in t_reg_o_eeprom;
    keylock             : in std_logic;
    beam_detect_window  : out std_logic;
    beam_cycle_window   : out std_logic;
    adc_samplenum       : out std_logic_vector(31 downto 0);
    tp_pos_pulse        : out std_logic_vector(4 downto 0);
    tp_neg_pulse        : out std_logic_vector(4 downto 0);
    live_time           : out std_logic_vector(31 downto 0);
    startup_cnt         : out std_logic_vector(31 downto 0);
    fault_startup       : out std_logic 
  );    
end timing_events;

architecture behv of timing_events is

  signal clk_cnt          : std_logic_vector(31 downto 0);
  signal ext_trig         : std_logic;
  signal fp_trig_out      : std_logic;

   --debug signals (connect to ila)
--   attribute mark_debug                 : string;
--   attribute mark_debug of beam_detect_window: signal is "true";       
--   attribute mark_debug of beam_cycle_window: signal is "true";
--   attribute mark_debug of fp_trig_out: signal is "true";
--   attribute mark_debug of pzed_params: signal is "true";
--   attribute mark_debug of trig_out: signal is "true";
--   attribute mark_debug of ext_trig: signal is "true";
--   attribute mark_debug of fiber_trig_fp: signal is "true";

begin  




  
startup_fault: entity work.startup_dly
  port map (
    clk => clk,   
    reset => reset, 
    trig => trig,
    keylock => keylock,
    startup_delay => eeprom_params.accum_length, 
    startup_dly_cnt => startup_cnt, 
    startup_fault => fault_startup  
  );    


  
-- generate 1Hz timestamp for watchdog clock
gen_rtc: entity work.live_time
  port map(
    clk => clk,
    reset => reset,
    timestamp => live_time, 
    watchdog_clock => open
);  



--generates test pulses
gen_tp: entity work.gen_test_pulses
  port map ( 
   clk => clk, 
   reset => reset, 
   trig => trig,  
   params => eeprom_params, 
   tp_pos_pulse => tp_pos_pulse,
   tp_neg_pulse => tp_neg_pulse 
  );    
  
  
-- used for accumulator.   Accumulator is updated
-- at the falling edge of beam_detect_window 
calc_active: entity work.beam_detect_window
  port map (
   clk => clk, 
   trig => trig,                  
   gate => beam_detect_window              
  );    
  
 
 
sampnum:  entity work.adc_samplenum
  port map (
   clk => clk, 
   trig => trig,   
   samplenum => adc_samplenum           
  );    
  
 

   
end behv;
