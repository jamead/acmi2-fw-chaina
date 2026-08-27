----------------------------------------------------------------------------------
-- Company:  Brookhaven National Lab
-- Engineer: Joseph Mead
-- 
-- Create Date: 09/19/2019 10:25:22 AM
-- Design Name: 
-- Module Name: accum.vhd
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description:   
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VComponents.all;


entity accumulator is
  port (
    clk                : in std_logic;
    rst                : in std_logic;
    accum_len          : in std_logic_vector(12 downto 0);
    beam_detect_window : in std_logic;
    q_min              : in std_logic_vector(31 downto 0);
    sample             : in std_logic_vector(31 downto 0);
    --charge_oow         : in std_logic_vector(31 downto 0);
    accum              : out std_logic_vector(31 downto 0)
);
end accumulator;      


    
    
architecture behv of accumulator is

component accum_dpram IS
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    clkb : IN STD_LOGIC;
    rstb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    rsta_busy : OUT STD_LOGIC;
    rstb_busy : OUT STD_LOGIC
  );
END component;

  type state_type is (IDLE,WAIT1,CALC_ACCUM,UPDATE_DPRAM,UPDATE_PTRS);
  signal state         : state_type := idle;

  signal trig                    : std_logic;
  signal end_sample              : std_logic_vector(31 downto 0);
  signal wraddr                  : std_logic_vector(12 downto 0);
  signal rdaddr                  : std_logic_vector(12 downto 0);
  signal wren                    : std_logic_vector(0 downto 0);
  signal buffull                 : std_logic;
  signal bufcnt                  : std_logic_vector(12 downto 0); 
  signal prev_beam_detect_window : std_logic := '0'; 
  signal beam_valid              : std_logic;
  signal new_sample              : std_logic_vector(31 downto 0);
  --signal rsta_busy               : std_logic;
  --signal rstb_busy               : std_logic;
 
 
   --debug signals (connect to ila)
--   attribute mark_debug                 : string;
--   attribute mark_debug of sample: signal is "true";
--   attribute mark_debug of new_sample: signal is "true";
--   attribute mark_debug of accum: signal is "true";
--   attribute mark_debug of accum_len: signal is "true";
--   attribute mark_debug of trig: signal is "true";
--   attribute mark_debug of buffull: signal is "true";
--   attribute mark_debug of bufcnt : signal is "true";
--   attribute mark_debug of end_sample: signal is "true";
--   attribute mark_debug of wraddr: signal is "true";
--   attribute mark_debug of rdaddr: signal is "true";
--   attribute mark_debug of beam_detect_window: signal is "true";
--   attribute mark_debug of beam_valid: signal is "true";
--   attribute mark_debug of q_min: signal is "true";
--   attribute mark_debug of faultn: signal is "true";
--   attribute mark_debug of charge_oow: signal is "true";
 
 
begin  

--generate a trigger at the end of of beam detect window to do a accumulator update
process(clk, rst)
  begin
    if (rising_edge(clk)) then
      prev_beam_detect_window <= beam_detect_window;
      if (prev_beam_detect_window = '1' and beam_detect_window = '0') then
        trig <= '1';
      else 
        trig <= '0';
      end if;
    end if;
end process;


--accumulator update state machine
process (clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then
        state <= idle;
        new_sample <= 32d"0";
        buffull <= '0';
        bufcnt <= 13d"0";
        wraddr <= 13d"0";
        rdaddr <= 13d"1";  
        wren <= "0"; 
        accum <= 32d"0";
                          
      else
        case state is 
          when IDLE =>  
            if (trig = '1') then
              state <= calc_accum;
              if (sample > q_min) then
                new_sample <= sample;
              else
                new_sample <= q_min;
              end if; 
              if (bufcnt >= accum_len) then
                buffull <= '1';
              else
                bufcnt <= bufcnt + 1;  
              end if; 
            end if;         
 
          when CALC_ACCUM =>
            state <= wait1;  --give 2 clock cycles for addition
            if (buffull = '0') then
              accum <= accum + new_sample;
            else
              accum <= accum + new_sample - end_sample;
            end if;                    

          when WAIT1 =>            
            state <= update_dpram;
            
          when UPDATE_DPRAM =>
              state <= update_ptrs;
              wren(0) <= '1';
              
              
          when UPDATE_PTRS =>
              state <= idle;
              wren(0) <= '0';     
              wraddr <= rdaddr;
              if (rdaddr = accum_len) then
                rdaddr <= 13d"0";
              else 
                rdaddr <= rdaddr + 1;        
              end if;
        end case;
      end if;
    end if;
end process;



-- calculate the new sample charge
--process(clk)
--  begin
--    if (rising_edge(clk)) then
--      if (trig = '1') then
--        -- if calculated charge is < q_min, then store q_min
--        if (sample > q_min) or (faultn = '0') then
--          validated_sample <= sample + charge_oow;
--        else
--          validated_sample <= q_min + charge_oow;
--        end if;
--      end if;

--    end if;
-- end process;      




-- don't allow outputs until sample buffer is full
--process (clk, rst)
--  begin
--    if (rst = '1') then
--      buffull <= '0';
--      bufcnt <= 13d"0";
--    elsif (clk'event and clk = '1') then
--      if (trig = '1') then   
--        if (bufcnt >= accum_len) then
--          buffull <= '1';
--        else
--          bufcnt <= bufcnt + 1;
--        end if;
--      end if;
--    end if;
--end process;



-- do the accumulation
--process (clk, rst)
--  begin
--    if (rst = '1') then
--      accum <= (others => '0');
--    elsif (clk'event and clk = '1') then
--      if (trig = '1') then
--        if (buffull = '0') then
--          accum <= accum + new_sample;
--        else
--          accum <=  accum + new_sample - end_sample;
--        end if;
--      end if;
--    end if;
--end process;





-- write into / read from dpram
--process (clk, rst)
--  begin
--    if (rising_edge(clk)) then
--      if (rst = '1') then
--        wraddr <= 13d"0";
--        rdaddr <= 13d"1";  
--        wren <= "0";  
--      else
--        if (trig = '1') then
--          wren(0) <= '1';
--          wraddr <= rdaddr;
--          if (rdaddr = accum_len) then
--            rdaddr <= 13d"0";
--          else 
--            rdaddr <= rdaddr + 1;        
--          end if;
----          if (wraddr = accum_len) then
----            wraddr <= 13d"0";
----          else 
----            wraddr <= wraddr + 1;        
----          end if;
--        else
--          wren(0) <= '0';  
--        end if;
--      end if;
--    end if;
--end process;
          






-- need ram to keep track of the end sample that must be subtracted from the accumulator
dpram: accum_dpram 
  port map (
    clka => clk, 
    wea => wren, 
    addra => wraddr, 
    dina => new_sample, 
    clkb => clk, 
    rstb => rst, 
    addrb => rdaddr, 
    doutb => end_sample, 
    rsta_busy => open, --rsta_busy, 
    rstb_busy => open --rstb_busy
 );






  
end behv;
