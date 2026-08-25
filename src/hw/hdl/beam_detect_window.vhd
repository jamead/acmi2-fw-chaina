library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;



library UNISIM;
use UNISIM.VComponents.all;

entity beam_detect_window is
  port (
   clk          : in  std_logic;
   trig         : in std_logic;                  
   gate         : out std_logic              
  );    
end beam_detect_window;


architecture behv of beam_detect_window is
    
  type     state_type is (IDLE, TRIGGERED, PULSE_HI); 
  signal   state            : state_type  := idle;
  
  signal pulse_dlycnt       : std_logic_vector(15 downto 0) := 16d"0";
  signal pulse_hicnt        : std_logic_vector(15 downto 0) := 16d"0";  
  signal pulse              : std_logic := '0';
  
  
begin  

gate <= pulse;

 
 -- generate the pulse
process (clk)
  begin  
    if (rising_edge(clk)) then
      case state is
         when IDLE =>   
           pulse <= '0';
           if (trig = '1') then
              pulse_dlycnt <= 16d"1";
              pulse_hicnt <= 16d"2000";
              state <= triggered;
           end if;

         when TRIGGERED =>  
	       if (pulse_dlycnt = 0) then 
             state <= PULSE_HI;
		   else
			 pulse_dlycnt <= pulse_dlycnt-1;
		   end if;
			   
         when PULSE_HI =>  
		   if (pulse_hicnt = 0) then 
			 pulse <= '0';
             state <= idle;
		   else
		     pulse <= '1';
		     pulse_hicnt <= pulse_hicnt-1;
		   end if;			   		   
			   			   
         when others =>
           state <= IDLE;
       end case;
     end if; 
  end process;


  
end behv;
