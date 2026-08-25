library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


library UNISIM;
use UNISIM.VComponents.all;

entity calc_fwhm is
  port (
   clk          : in  std_logic;
   trig         : in std_logic;
   start_calc   : in std_logic;  
   baseline     : in signed(15 downto 0); 
   peak         : in signed(16 downto 0);               
   adc_data     : in signed(15 downto 0);
   fwhm         : out unsigned(15 downto 0);
   fwhm_val     : out std_logic              
  );    
end calc_fwhm;


architecture behv of calc_fwhm is

  type state_type is (IDLE,START_FWHM,FOUND_PULSE);
  signal state         : state_type := idle;


  signal adc_data_bs      : signed(16 downto 0);
  signal adc_data_bs_nzs  : signed(16 downto 0);
  signal fwhm_level       : signed(15 downto 0);   
 
   
--  attribute mark_debug                  : string;
--  attribute mark_debug of trig: signal is "true";
--  attribute mark_debug of start_calc : signal is "true";
--  attribute mark_debug of baseline: signal is "true";
--  attribute mark_debug of peak: signal is "true";  
--  attribute mark_debug of adc_data: signal is "true";
--  attribute mark_debug of adc_data_bs: signal is "true";
--  attribute mark_debug of fwhm: signal is "true"; 
--  attribute mark_debug of fwhm_val: signal is "true";
--  attribute mark_debug of state: signal is "true";
  
  
begin  


--fwhm level is 1/2 the peak.
fwhm_level <= peak(16 downto 1);  

--add a 17th bit, result could grow beyond 16 bits.
sub_baseline: process (clk)
  begin
     if (rising_edge(clk)) then
      adc_data_bs_nzs <= resize(adc_data,17) - resize(baseline,17);
      --if charge is negative, set to 0.
      adc_data_bs <= adc_data_bs_nzs;
--      if (adc_data_bs_nzs < 17d"0") then
--        adc_data_bs <= 17d"0";
--      else
--        adc_data_bs <= adc_data_bs_nzs;
--      end if;
--    end if; 
    end if;
end process;


find_fwhm: process (clk)
  begin
    if (rising_edge(clk)) then
      if (trig = '1') then
        --reset fwhm count at beginning of each besocm cycle
        fwhm <= 16d"0";  
        fwhm_val <= '0';
      else
        case state is 
          when IDLE =>  
            fwhm_val <= '0';
            if (start_calc = '1') then
              fwhm <= 16d"0";
              state <= start_fwhm;
            end if;
          
          when START_FWHM =>           
            if (adc_data_bs >= fwhm_level) then
              fwhm <= fwhm + 1;
              state <= found_pulse;
            end if;
            
          when FOUND_PULSE =>
            if (adc_data_bs <= fwhm_level) then
               state <= idle;
               fwhm_val <= '1';
            else
               fwhm <= fwhm + 1;
            end if;
        end case;
      end if;
    end if;
end process;


  
end behv;
