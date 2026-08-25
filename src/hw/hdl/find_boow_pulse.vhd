library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library work;
use work.acmi_package.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity find_boow_pulse is
  port (
   clk               : in std_logic;   
   trig              : in std_logic; 
   threshold         : in std_logic_vector(15 downto 0);           
   boow_adc_data     : in signed(15 downto 0);
   boow_adc_data_dly : out std_logic_vector(15 downto 0);
   pulse_found       : out std_logic           
  );    
end find_boow_pulse;


architecture behv of find_boow_pulse is

component boow_shift_ram
  port (
    d : in std_logic_vector(15 downto 0); 
    clk : in std_logic; 
    q : out std_logic_vector(15 downto 0)
  );
end component; 

  type state_type is (SEARCHING, WAITFORNEXTTRIGGER);
  signal state         : state_type := searching;


  --signal boow_adc_data_dly : std_logic_vector(15 downto 0);

  
begin  




--delay the adc data by 8 clocks, used for floating baseline for pulse searching. 
boow_baseline_dly : boow_shift_ram
  PORT MAP (
    D => std_logic_vector(boow_adc_data),
    CLK => clk,
    Q => boow_adc_data_dly
  );



find_pulse: process(clk)
begin
  if (rising_edge(clk)) then
    case state is  
      when SEARCHING =>
        if (signed(boow_adc_data) > (signed(boow_adc_data_dly) + signed(threshold))) then 
          pulse_found <= '1';
          state <= WAITFORNEXTTRIGGER;
        else
          pulse_found <= '0';
        end if;
      
      when WAITFORNEXTTRIGGER =>   
        pulse_found <= '0';
        if (trig = '1') then
          state <= searching;
        end if;
      end case;
           
    end if;  

end process;


  
end behv;
