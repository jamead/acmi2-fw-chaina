library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library work;
use work.acmi_package.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity find_peak is
  port (
   clk          : in std_logic;   
   trig         : in std_logic;            
   adc_data     : in signed(15 downto 0);
   gate         : in std_logic;
   baseline     : in signed(15 downto 0);
   sampnum      : in std_logic_vector(31 downto 0);
   peak         : out signed(16 downto 0);
   peak_sampnum : out std_logic_vector(31 downto 0);
   peak_val     : out std_logic             
  );    
end find_peak;


architecture behv of find_peak is

  type state_type is (IDLE,GATE_ACTIVE);
  signal state         : state_type;

  signal max_adc        : signed(15 downto 0);

  
--  attribute mark_debug                 : string;
--  attribute mark_debug of state: signal is "true";
--  attribute mark_debug of max_adc: signal is "true";


  
  
  
begin  

peak <= resize(max_adc,17) - resize(baseline,17);

find_peak: process(clk)
begin
  if (rising_edge(clk)) then
    if (trig = '1') then
      state <= idle;
      max_adc <= to_signed(-32000,16);  
      --peak <= 17d"0";
      peak_sampnum <= 32d"0";
    else
  
      case state is
        when IDLE =>
          peak_val <= '0';  
          if (gate = '1') then
            state <= gate_active;
          end if;
          
        when GATE_ACTIVE =>
          if (gate = '0') then
            peak_val <= '1';
            state <= idle;
          end if;
          if (adc_data > max_adc) then
            max_adc <= adc_data;
            peak_sampnum <= sampnum;
          end if;
       end case;
     end if;
  end if;
end process;



  
end behv;
