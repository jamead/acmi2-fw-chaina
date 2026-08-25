

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
  
entity startup_dly is
  port (
    clk          	    : in std_logic;  
    reset               : in std_logic;
    trig                : in std_logic;
    keylock             : in std_logic;
    startup_delay       : in std_logic_vector(31 downto 0);
    startup_dly_cnt     : out std_logic_vector(31 downto 0);
    startup_fault       : out std_logic  
  );    
end startup_dly;

architecture behv of startup_dly is


  signal eeprom_rdy_last       : std_logic;
  signal startup_enb           : std_logic;
  signal keylock_last          : std_logic;
 
 
--  attribute mark_debug                 : string;
--  attribute mark_debug of eeprom_rdy      : signal is "true";
--  attribute mark_debug of eeprom_rdy_last : signal is "true";
--  attribute mark_debug of startup_enb     : signal is "true";
--  attribute mark_debug of startup_fault   : signal is "true";
--  attribute mark_debug of startup_dly_cnt : signal is "true";
--  attribute mark_debug of startup_delay   : signal is "true";
 
 
 
begin  

 


-- startup delay counter.   Fault acmi until this counter goes to zero 
process(clk)
  begin
    if (rising_edge(clk)) then
      if (reset = '1') then
        startup_dly_cnt <= 32d"0"; 
        startup_fault <= '1'; 
        startup_enb <= '0';    
      else
        --trig startup delay when key goes to run mode
        --acis_keylock = 1 is run mode, 0 is edit mode
        keylock_last <= keylock;
        if (keylock = '1' and keylock_last = '0') then
           startup_enb <= '1';
           startup_fault <= '1';
           startup_dly_cnt <= startup_delay;
        end if;
           
        if (trig = '1' and startup_enb = '1') then
           if (startup_dly_cnt = 32d"0") then
             startup_fault <= '0';
             startup_enb <= '0';
           else
             startup_dly_cnt <= startup_dly_cnt - 1; 
           end if;
        end if;
      end if;
    end if;
  end process;
  
  
end behv;
