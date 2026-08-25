library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;



library UNISIM;
use UNISIM.VComponents.all;

entity calc_integral is
  port (
   clk          : in  std_logic;
   trig         : in std_logic;
   start_calc   : in std_logic;  
   baseline     : in signed(15 downto 0);                
   adc_data     : in signed(15 downto 0);
   integral     : out signed(31 downto 0);
   integral_val : out std_logic              
  );    
end calc_integral;


architecture behv of calc_integral is

  type state_type is (IDLE,START_ACCUM);
  signal state         : state_type := idle;


  constant ACCUMLEN      : INTEGER := 59;
  signal accum_cnt       : std_logic_vector(5 downto 0) := 6d"0";
  signal accum           : signed(31 downto 0) := 32d"0";
  signal accum_lat       : signed(31 downto 0) := 32d"0";  
  signal accum_val       : std_logic := '0';
  signal adc_data_bs     : signed(16 downto 0);
  signal adc_data_bs_nzs : signed(16 downto 0);
  signal start_calc_last : std_logic;
        
  
  
begin  

integral <= accum_lat;
integral_val <= accum_val;

--add a 17th bit, result could grow beyond 16 bits.
sub_baseline: process (clk)
  begin
    if (rising_edge(clk)) then
      adc_data_bs_nzs <= resize(adc_data,17) - resize(baseline,17);
      --if charge is negative, set to 0.
      if (adc_data_bs_nzs < 17d"0") then
        adc_data_bs <= 17d"0";
      else
        adc_data_bs <= adc_data_bs_nzs;
      end if;
    end if;
end process;

-- do the integral (trapezoid rule)
find_integral: process (clk)
  begin
    if (rising_edge(clk)) then
      if (trig = '1') then
        --reset accum at beginning of each besocm cycle
        accum_lat <= 32d"0";  
      else
        case state is 
          when IDLE =>  
            accum_val <= '0';
            start_calc_last <= start_calc;
            if (start_calc = '1' and start_calc_last = '0') then
              accum_cnt <= 6d"0";
              state <= start_accum;
            end if;
          
          when START_ACCUM =>           
            if (accum_cnt = ACCUMLEN) then
              accum_lat <= accum;
              accum <= 32d"0"; 
              accum_cnt <= 6d"0";
              accum_val <= '1';
              state <= idle;
            else
              accum_val <= '0';
              accum_cnt <= accum_cnt + 1;
              accum <= signed(accum) + adc_data_bs;
            end if;
        end case;
      end if;
    end if;
end process;


  
end behv;
