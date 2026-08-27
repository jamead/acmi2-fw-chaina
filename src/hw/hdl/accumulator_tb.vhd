----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/06/2015 07:14:02 PM
-- Design Name: 
-- Module Name: besocm_artix_tb - Behavioral
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
use IEEE.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--library work;
--use work.xbpm_package.ALL;


entity accumulator_tb is
end accumulator_tb;

architecture behv of accumulator_tb is


component accumulator is
  port (
    clk                : in std_logic;
    rst                : in std_logic;
    faultn             : in std_logic;
    accum_len          : in std_logic_vector(12 downto 0);
    beam_detect_window : in std_logic;
    accum_update       : in std_logic;
    q_min              : in std_logic_vector(31 downto 0);
    sample             : in std_logic_vector(31 downto 0);
    accum              : out std_logic_vector(31 downto 0)
);
end component;     


  signal clk                : std_logic;
  signal rst                : std_logic;
  signal faultn             : std_logic;
  signal beam_detect_window : std_logic;
  signal accum_update       : std_logic;
  signal sample             : std_logic_vector(31 downto 0);
  signal accum              : std_logic_vector(31 downto 0);
  signal accum_len          : std_logic_vector(12 downto 0);
  signal q_min              : std_logic_vector(31 downto 0);

begin


dut:  accumulator
  port map (
    clk => clk, 
    rst => rst, 
    faultn => faultn,
    accum_len => accum_len,
    beam_detect_window => beam_detect_window, 
    accum_update => accum_update,
    q_min => q_min, 
    sample => sample, 
    accum => accum
);
     


process
  begin 
    clk <= '0';
    wait for 2.5 ns;
    clk <= '1'; 
    wait for 2.5 ns;
end process;


--accumulator update
process
  begin 
    accum_update <= '0';
    wait for 500 ns;
    accum_update <= '1';
    wait for 5 ns; 
end process;


--beam detect window
process
  begin 
    beam_detect_window <= '0';
    wait for 800 ns;
    beam_detect_window <= '1';
    wait for 100 ns;
    beam_detect_window <= '0';
    wait for 100 ns; 
end process;




process
  begin 
    rst <= '1';
    faultn <= '1';
    q_min <= 32d"5";
    sample <= 32d"10";
    accum_len <= 13d"250";

    wait for 100 ns;
    rst <= '0';

    wait for 10000 ns;
    sample <= 32d"0";
    wait for 1000 ns;
    sample <= 32d"1";
    
 
    wait for 10000 us;     
    
    
end process;


end behv;