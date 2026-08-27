-------------------------------------------------------------------------------
-- Title         : Faults
-------------------------------------------------------------------------------

-- 10/15/2021: created.
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
  
library work;
use work.acmi_package.ALL;

  
entity faults is
  port (
    clk          	    : in std_logic;  
    reset               : in std_logic;
    beam_cycle_window   : in std_logic;
    trig                : in std_logic;
    fault_startup       : in std_logic;
    fault_bad_power     : in std_logic;
    fault_no_clock      : in std_logic;
    fault_no_pulse      : in std_logic;
    fault_no_trigger    : in std_logic;
    acis_faultn         : in std_logic; 
    acis_fault_rdbk     : in std_logic; 
    acis_reset          : in std_logic;  
    acis_force_trip     : in std_logic; 
    acis_keylock        : in std_logic;        
    acis_readbacks      : out std_logic_vector(7 downto 0);    
    adc_sat             : in std_logic;
    params              : in t_reg_o_eeprom;
    pulse_stats         : in t_reg_i_pulse_stats_array;
    accum               : in std_logic_vector(31 downto 0);
    fault               : out std_logic;
    faults_rdbk         : out std_logic_vector(15 downto 0)
  );    
end faults;

architecture behv of faults is


    signal fault_beam_high           : std_logic;       -- P19   fault_rsvd1
    signal fault_bunch_limit         : std_logic;       -- U21   fault_rsvd2
    signal fault_pulse_integrity     : std_logic;       -- V19   fault_pulse_integrity
    signal fault_base_integrity      : std_logic;       -- AA19  fault_base_integrity
    signal fault_tp1                 : std_logic;       -- AA18  fault_test_pulse_high
    signal fault_tp2                 : std_logic;       -- V18   fault_test_pulse_mid 
    signal fault_tp3                 : std_logic;       -- R18   fault_test_pulse_base
    signal fault_bad_limit           : std_logic;       -- V20   fault_bad_limit
    signal fault_adc_sat             : std_logic;       -- V22   fault_adc_overrange  
    signal fault_beam_out_window     : std_logic;       -- W21   fault_rsvd3
    signal fault_rsvd                : std_logic;       -- AA21  fault_rsvd4
    
    signal prev_beam_cycle_window    : std_logic;
    signal adc_sat_lat               : std_logic;
    signal beamoow_peak_found_lat    : std_logic;


--    attribute mark_debug                  : string;
--    attribute mark_debug of fault_beam_high : signal is "true";
--    attribute mark_debug of fault_bunch_limit : signal is "true";
--    attribute mark_debug of fault_bad_limit: signal is "true";
--    attribute mark_debug of fault_tp1 : signal is "true";   
--    attribute mark_debug of fault_tp2 : signal is "true";
--    attribute mark_debug of fault_tp3 : signal is "true";

--    attribute mark_debug of faults_rdbk: signal is "true";
--    attribute mark_debug of beamoow_peak_found_lat: signal is "true";
--    attribute mark_debug of adc_sat_lat: signal is "true";
--    attribute mark_debug of fault_beam_out_window: signal is "true";


begin  

acis_readbacks <= "000" & acis_faultn & acis_fault_rdbk & acis_reset & acis_force_trip & acis_keylock;


fault <= or faults_rdbk(15 downto 0);


-- go to picoZed readbacks
faults_rdbk(0) <= fault_beam_high;
faults_rdbk(1) <= fault_bunch_limit;
faults_rdbk(2) <= fault_base_integrity; 
faults_rdbk(3) <= fault_tp1; 
faults_rdbk(4) <= fault_tp2; 
faults_rdbk(5) <= fault_tp3; 
faults_rdbk(6) <= fault_bad_limit; 
faults_rdbk(7) <= fault_beam_out_window; 
faults_rdbk(8) <= not fault_bad_power; 
faults_rdbk(9) <= fault_adc_sat;  
faults_rdbk(10) <= not acis_keylock; 
faults_rdbk(11) <= not acis_force_trip; 
faults_rdbk(12) <= fault_startup; 
faults_rdbk(13) <= not fault_no_clock; 
faults_rdbk(14) <= '0';
faults_rdbk(15) <= not fault_no_trigger; 



--check fault conditions at end of beam_cycle
check_faults: process (clk)
begin
  if (rising_edge(clk)) then
    if (reset = '1') then
      fault_beam_high <= '0';
      fault_bunch_limit <= '0';
      fault_tp1 <= '0';
      fault_tp2 <= '0';
      fault_tp3 <= '0';
      fault_adc_sat <= '0';
      fault_bad_limit <= '0';
      fault_beam_out_window <= '0';
      beamoow_peak_found_lat <= '0';
      adc_sat_lat <= '0';
      
    else
      prev_beam_cycle_window <= beam_cycle_window;
      -- found a beam out of window pulse
      if (pulse_stats(4).peak_found = '1') then
        beamoow_peak_found_lat <= '1';
      end if;
      
      --if adc is saturated
      if (adc_sat = '1') then
        adc_sat_lat <= '1';
      end if;
      
      --check rest of faults at end of beam cycle window
      if (prev_beam_cycle_window = '1' and beam_cycle_window = '0') then
        
        -- beam accum limit check
        --if (accum > params.beamaccum_limit_calc) then
        if (accum > params.beamaccum_limit_hr) then 
          fault_bunch_limit <= '1';
        else
          fault_bunch_limit <= '0';
        end if;

        -- beam too high check
        if (pulse_stats(0).integral > params.beamhigh_limit) then
          fault_beam_high <= '1';
        else 
          fault_beam_high <= '0';
        end if;
        
        -- baseline integrity checks if baseline for beam pulse is within limits
        if (signed(pulse_stats(0).baseline) > signed(params.baseline_high_limit)) or 
           (signed(pulse_stats(0).baseline) < signed(params.baseline_low_limit)) then
          fault_base_integrity <= '1';
        else
          fault_base_integrity <= '0';
        end if;
        
  
         --tp1 problem +2nC
        if ((pulse_stats(1).integral > params.tp1_int_high_limit) or
            (pulse_stats(1).integral < params.tp1_int_low_limit) or
            (pulse_stats(1).peak > params.tp1_peak_high_limit) or
            (pulse_stats(1).peak < params.tp1_peak_low_limit) or
            (signed(pulse_stats(1).baseline) > signed(params.tp1_base_high_limit)) or
            (signed(pulse_stats(1).baseline) < signed(params.tp1_base_low_limit)) or            
            (pulse_stats(1).fwhm > params.tp1_fwhm_high_limit) or
            (pulse_stats(1).fwhm < params.tp1_fwhm_low_limit)) then                    
          fault_tp1 <= '1';
        else
          fault_tp1 <= '0';
        end if; 
  

        --tp2 problem -2nC
        if ((pulse_stats(2).integral > params.tp2_int_high_limit) or
            (pulse_stats(2).integral < params.tp2_int_low_limit) or
            (pulse_stats(2).peak > params.tp2_peak_high_limit) or
            (pulse_stats(2).peak < params.tp2_peak_low_limit) or
            (signed(pulse_stats(2).baseline) > signed(params.tp2_base_high_limit)) or
            (signed(pulse_stats(2).baseline) < signed(params.tp2_base_low_limit)) or            
            (pulse_stats(2).fwhm > params.tp2_fwhm_high_limit) or
            (pulse_stats(2).fwhm < params.tp2_fwhm_low_limit)) then                    
          fault_tp2 <= '1';
        else
          fault_tp2 <= '0';
        end if;

        --tp3 problem -18nC
        if ((pulse_stats(3).integral > params.tp3_int_high_limit) or
            (pulse_stats(3).integral < params.tp3_int_low_limit) or
            (pulse_stats(3).peak > params.tp3_peak_high_limit) or
            (pulse_stats(3).peak < params.tp3_peak_low_limit) or
            (signed(pulse_stats(3).baseline) > signed(params.tp3_base_high_limit)) or
            (signed(pulse_stats(3).baseline) < signed(params.tp3_base_low_limit)) or            
            (pulse_stats(3).fwhm > params.tp3_fwhm_high_limit) or
            (pulse_stats(3).fwhm < params.tp3_fwhm_low_limit)) then                   
          fault_tp3 <= '1';
        else
          fault_tp3 <= '0';
        end if;



        -- adc saturation
        if (adc_sat_lat = '1') then
          fault_adc_sat <= '1';
          adc_sat_lat <= '0';
        else
          fault_adc_sat <= '0';
        end if;
   
        if (beamoow_peak_found_lat = '1') then
          fault_beam_out_window <= '1';
          beamoow_peak_found_lat <= '0';
        else
          fault_beam_out_window <= '0';
        end if; 
   
        
        -- bad limit, compares crc calculated in fpga vs what is in eeprom
        if ((params.crc32_eeprom /= params.crc32_calc) and acis_keylock = '1') then
          fault_bad_limit <= '1';
        else 
          fault_bad_limit <= '0';
        end if;
        

        
        
      end if;
    end if;
  end if;
end process;
   
end behv;
