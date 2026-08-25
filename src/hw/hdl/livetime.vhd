------------------------------------------------------------------------------
-- Title         : Generate 1Hz timestamp
-------------------------------------------------------------------------------

-- 08/19/2015: created.
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
  
entity live_time is
  port (
    clk          	: in  std_logic;  
    reset               : in std_logic;
    accum_update        : out std_logic;
    timestamp           : out std_logic_vector(31 downto 0);
    watchdog_clock      : out std_logic   
  );    
end live_time;

architecture behv of live_time is

signal clk_cnt        : std_logic_vector(31 downto 0);



begin  


  
--1Hz timestamp and watchdog clock
process(clk)
  begin
    if (rising_edge(clk)) then
      if (reset = '1') then
        timestamp <= 32d"0";
        clk_cnt <= 32d"0"; 
        watchdog_clock <= '0';
      --elsif (clk_cnt > 32d"200") then
      elsif (clk_cnt >= 32d"200000000") then     
        timestamp <= timestamp + 1;
        clk_cnt <= 32d"0";
        watchdog_clock <= not watchdog_clock;
      else
        clk_cnt <= clk_cnt + 1;
      end if;
    end if;
  end process;  
  
  
end behv;
