library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

 

library UNISIM;
use UNISIM.VComponents.all;

entity calc_baseline is
  port (
   clk          : in  std_logic;
   trig         : in std_logic;
   start_calc   : in std_logic;                  
   adc_data     : in signed(15 downto 0);
   baseline     : out signed(15 downto 0);
   baseline_val : out std_logic              
  );    
end calc_baseline;


architecture behv of calc_baseline is

  type state_type is (IDLE,START_ACCUM);
  signal state           : state_type := idle;


  constant ACCUMLEN      : INTEGER := 31;
  signal accum_cnt       : std_logic_vector(5 downto 0) := 6d"0";
  signal accum           : signed(15 downto 0) := 16d"0";
  signal accum_lat       : signed(15 downto 0) := 16d"0";
  signal accum_val       : std_logic := '0';
  signal start_calc_last : std_logic;
        
  
  
begin  


process (clk)
begin
  if (rising_edge(clk)) then
    baseline <= accum_lat;
    baseline_val <= accum_val;
  end if;
end process;


-- do the accumulation (block average)
find_baseline: process (clk)
  begin
    if (rising_edge(clk)) then
      if (trig = '1') then
        --reset baseline at beginning of each besocm cycle
        accum <= 16d"0";
        accum_lat <= 16d"0";  
      else
        case state is 
          when IDLE =>  
            accum_val <= '0';
            start_calc_last <= start_calc;
            if (start_calc = '1') and (start_calc_last = '0') then
              accum_cnt <= 6d"0";
              state <= start_accum;
            end if;
          
          when START_ACCUM =>           
            if (accum_cnt = ACCUMLEN) then
              accum <= 16d"0"; 
              accum_lat <= shift_right((accum),5); --divide by 32
              accum_cnt <= 6d"0";
              accum_val <= '1';
              state <= idle;
            else
              accum_val <= '0';
              accum_cnt <= accum_cnt + 1;
              accum <= accum + adc_data;
            end if;
        end case;
      end if;
    end if;
end process;


  
end behv;
