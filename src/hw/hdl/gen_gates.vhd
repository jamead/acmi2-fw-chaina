library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;



library UNISIM;
use UNISIM.VComponents.all;

entity gen_gates is
  port (
   clk            : in std_logic;
   trig           : in std_logic;
   adc_samplenum  : in std_logic_vector(31 downto 0); 
   gate_start     : in std_logic_vector(31 downto 0);              
   baseline_gate  : out std_logic;
   integral_gate  : out std_logic             
  );    
end gen_gates;


architecture behv of gen_gates is
  
  constant BASELINE_LEN     : std_logic_vector(7 downto 0) := 8d"32";
  constant INTEGRAL_LEN     : std_logic_vector(7 downto 0) := 8d"60";
    
  type     state_type is (IDLE, TRIGGERED, BASELINE_ACTIVE, INTEGRAL_ACTIVE); 
  signal   state            : state_type  := idle;
  
  
  signal baseline_cnt       : std_logic_vector(7 downto 0);
  signal integral_cnt       : std_logic_vector(7 downto 0); 

  
begin  


 
 -- generate the pulse
process (clk)
  begin  
    if (rising_edge(clk)) then
      case state is
         when IDLE =>   
           if (trig = '1') then
              baseline_gate <= '0';
              integral_gate <= '0';
              baseline_cnt <= 8d"0";
              integral_cnt <= 8d"0";
              state <= triggered;
           end if;

         when TRIGGERED =>  
	       if (adc_samplenum >= gate_start) then 
	         baseline_gate <= '1';
	         baseline_cnt <= BASELINE_LEN;
	         integral_cnt <= INTEGRAL_LEN;
             state <= baseline_active;
		   end if;
			   
         when BASELINE_ACTIVE =>  
		   if (baseline_cnt = 0) then 
			 baseline_gate <= '0';
             state <= INTEGRAL_ACTIVE;
		   else
		     baseline_gate <= '1';
		     baseline_cnt <= baseline_cnt-1;
		   end if;			   		   
			   		
        when INTEGRAL_ACTIVE =>  
		   if (integral_cnt = 0) then 
			 integral_gate <= '0';
             state <= idle;
		   else
		     integral_gate <= '1';
		     integral_cnt <= integral_cnt-1;
		   end if;			   		   			   		
	   		
			   			   
         when others =>
           state <= IDLE;
       end case;
     end if; 
  end process;


  
end behv;
