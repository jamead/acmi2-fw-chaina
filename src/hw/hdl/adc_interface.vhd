----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/15/2021 10:23:58 AM
-- Design Name: 
-- Module Name: adc_interface - behv
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
 
library work;
use work.acmi_package.ALL;



entity adc_interface is
generic (
    SIM_MODE            : integer := 0
  );
  port (
   reset  	    : in  std_logic; 
   trig         : in std_logic;                    
   sclk         : out std_logic;                   
   din 	        : out std_logic;
   dout         : in  std_logic;
   sync         : out std_logic;          
   adc_clk_p    : in  std_logic;                  
   adc_clk_n    : in  std_logic;                     
   adc_data_p   : in std_logic_vector(7 downto 0);
   adc_data_n   : in std_logic_vector(7 downto 0); 
   adc_of_p     : in std_logic;
   adc_of_n     : in std_logic;
   adc_clk      : out std_logic;
   adc_data_lut : in std_logic_vector(15 downto 0);
   adc_data_corr  : out std_logic_vector(15 downto 0);
   adc_data_ob  : out std_logic_vector(15 downto 0);
   adc_sat      : out std_logic              
  );    
end adc_interface;

architecture behv of adc_interface is

  signal adc_data_2s   : std_logic_vector(15 downto 0);
  
  --debug signals (connect to ila)
  attribute mark_debug                 : string;
  attribute mark_debug of adc_data_2s: signal is "true";        
  attribute mark_debug of adc_data_corr: signal is "true"; 

begin



-- by default, LTC2107 output is offset binary.   Convert to 2's complement by
-- inverting the MSB
process(adc_clk)
begin
  if (rising_edge(adc_clk)) then
    adc_data_2s <= x"8000" xor adc_data_ob;
    adc_data_corr <= adc_data_2s - adc_data_lut;
  end if;
end process;



--read adc data
--read_adc: entity work.readadc_ltc2107
--  generic map (
--    SIM_MODE => SIM_MODE
--  )
--  port map (
--    adc_clk_p => adc_clk_p,
--    adc_clk_n => adc_clk_n,
--    reset => reset,
--    adc_data_p => adc_data_p,
--    adc_data_n => adc_data_n,
--    adc_of_p => adc_of_p,
--    adc_of_n => adc_of_n,
--    adc_data => adc_data_ob,
--    adc_clk => adc_clk,
--    adc_sat => adc_sat
-- );


--read adc data
read_adc: entity work.read_ltc2107
  generic map (
    SIM_MODE => SIM_MODE
  )
  port map (
    adc_clk_p => adc_clk_p,
    adc_clk_n => adc_clk_n,
    reset => reset,
    trig => trig,
    adc_data_p => adc_data_p,
    adc_data_n => adc_data_n,
    adc_of_p => adc_of_p,
    adc_of_n => adc_of_n,
    adc_clk => adc_clk,    
    adc_data => adc_data_ob,
    adc_sat => adc_sat
 );




--din   <= '0';   
--sclk  <= '0';
--sync  <= '1';

-- adc spi configuration at power-on
adc_spi: entity work.ltc2107_spi
  port map (
    clk => adc_clk,                  
    reset => reset,                       
    sclk => sclk,                    
    din => din, 
    dout => dout, 
    sync => sync                 
);    





end behv;
