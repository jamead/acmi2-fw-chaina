library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;



library UNISIM;
use UNISIM.VComponents.all;

entity adc_samplenum is
  port (
   clk          : in  std_logic;
   trig         : in std_logic; 
   samplenum    : out std_logic_vector(31 downto 0) := 32d"000" 
  );    
end adc_samplenum;


architecture behv of adc_samplenum is
    
    signal prev_trig     : std_logic := '0';
  
begin  



 -- generate the pulse
process (clk)
  begin  
    if (rising_edge(clk)) then
      prev_trig <= trig;
      if (trig = '1') then
        samplenum <= 32d"0"; 
      else
        samplenum <= samplenum + 1;
      end if;
    end if; 
  end process;


  
end behv;
