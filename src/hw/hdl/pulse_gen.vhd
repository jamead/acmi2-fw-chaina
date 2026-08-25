library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VComponents.all;

entity pulse_gen is
  port (
   clk         : in std_logic;                    
   reset  	   : in std_logic;  
   trig        : in std_logic;
   pulsedly    : in std_logic_vector(31 downto 0);
   pulsehi     : in std_logic_vector(31 downto 0);
   pulse       : out std_logic                  
  );    
end pulse_gen;

architecture behv of pulse_gen is

  type     state_type is (IDLE, TRIGGERED, PULSE_HI); 
  signal   state            : state_type;
  
  signal pulse_dlycnt       : std_logic_vector(31 downto 0);
  signal pulse_hicnt        : std_logic_vector(31 downto 0);

 
--   attribute mark_debug     : string;
--   attribute mark_debug of pulse_dlycnt: signal is "true";  
--   attribute mark_debug of pulse_hicnt: signal is "true"; 
--   attribute mark_debug of state: signal is "true";
--   attribute mark_debug of pulse: signal is "true";


  
begin  



-- generate the pulses
process (clk, reset)
  begin  
    if (rising_edge(clk)) then
      if (reset = '1') then  
        state <= IDLE;
        pulse_dlycnt <= (others => '0');
        pulse_hicnt <= (others => '0');
        pulse <= '0';
        
      else
        case state is
           when IDLE =>   
             pulse <= '0';
             if (trig = '1') then
                pulse_dlycnt <= pulsedly;
                pulse_hicnt <= pulsehi;
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
    end if;  
  end process;


end behv;
