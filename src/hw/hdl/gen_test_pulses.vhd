library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.acmi_package.ALL;


entity gen_test_pulses is
  port ( 
   clk              : in std_logic;
   reset            : in std_logic;
   trig             : in std_logic; 
   params           : in t_reg_o_eeprom;
   tp_pos_pulse     : out std_logic_vector(4 downto 0);
   tp_neg_pulse     : out std_logic_vector(4 downto 0) 
  );    
end gen_test_pulses;


architecture behv of gen_test_pulses is


  signal pulse      : std_logic_vector(3 downto 0);

 
  attribute mark_debug                 : string;
     
  attribute mark_debug of trig: signal is "true";   
  attribute mark_debug of pulse: signal is "true"; 
  attribute mark_debug of tp_pos_pulse: signal is "true";       
  attribute mark_debug of tp_neg_pulse: signal is "true";  
  attribute mark_debug of params: signal is "true";  
  
  
begin  

tp_pos_pulse <= params.tp1_pos_level(4 downto 0) when pulse(0) = '1' else
                params.tp2_pos_level(4 downto 0) when pulse(1) = '1' else
                params.tp3_pos_level(4 downto 0) when pulse(2) = '1' else  
                5d"0";
                
tp_neg_pulse <= params.tp1_neg_level(4 downto 0) when pulse(0) = '1' else
                params.tp2_neg_level(4 downto 0) when pulse(1) = '1' else
                params.tp3_neg_level(4 downto 0) when pulse(2) = '1' else  
                5d"0";
                
                                                   
 

tp1_pulse: entity work.pulse_gen
  port map (
   clk => clk,                    
   reset => reset,   
   trig => trig, 
   pulsedly => params.tp1_pulse_delay, 
   pulsehi => params.tp1_pulse_width, 
   pulse => pulse(0)                
  );    


tp2_pulse: entity work.pulse_gen
  port map (
   clk => clk,                    
   reset => reset,   
   trig => trig, 
   pulsedly => params.tp2_pulse_delay, 
   pulsehi => params.tp2_pulse_width, 
   pulse => pulse(1)                  
  );    


tp3_pulse: entity work.pulse_gen
  port map (
   clk => clk,                    
   reset => reset,   
   trig => trig, 
   pulsedly => params.tp3_pulse_delay, 
   pulsehi => params.tp3_pulse_width, 
   pulse => pulse(2)                  
  );    




end behv;

