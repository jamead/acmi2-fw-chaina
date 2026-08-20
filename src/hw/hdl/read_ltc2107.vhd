library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use ieee.std_logic_textio.all;
use std.textio.all;

library UNISIM;
use UNISIM.VComponents.all;

entity read_ltc2107 is
 generic (
    SIM_MODE            : integer := 0
  );
  port (
   adc_clk_p   : in  std_logic;                  
   adc_clk_n   : in  std_logic;
   reset       : in std_logic;  
   trig        : in std_logic;                   
   adc_data_p  : in std_logic_vector(7 downto 0);
   adc_data_n  : in std_logic_vector(7 downto 0); 
   adc_of_p    : in std_logic;
   adc_of_n    : in std_logic;
   adc_clk     : out std_logic;
   adc_data    : out std_logic_vector(15 downto 0);
   adc_sat     : out std_logic              
  );    
end read_ltc2107;


architecture behv of read_ltc2107 is

     signal adc_data_in  : std_logic_vector(7 downto 0);
     signal adc_data_i   : std_logic_vector(15 downto 0);
     signal adc_clk_i    : std_logic;
     signal adc_clk_dlyd : std_logic;
     signal adc_clk_o    : std_logic;
     signal adc_of       : std_logic;
     signal sample_cnt   : integer := 0;
     signal idly_rdy     : std_logic;
  
   attribute mark_debug                 : string;
   attribute mark_debug of adc_data      : signal is "true";

  
  
begin  

adc_sat <= adc_of;

adc_clk_inst  : IBUFDS  port map (O => adc_clk_i, I => adc_clk_p, IB => adc_clk_n); 


adc_clk_bufg  : BUFG    port map (O => adc_clk, I => adc_clk_dlyd);

gen_adcdata: for i in 0 to 7 generate
begin
  adc_data_inst  : IBUFDS  port map (O => adc_data_in(i), I => adc_data_p(i), IB => adc_data_n(i)); 
end generate;

adc_of_inst  : IBUFDS  port map (O => adc_of, I => adc_of_p, IB => adc_of_n); 


adcdata_syn: if (SIM_MODE = 0) generate 
lat_data: process(adc_clk)
begin
   if (rising_edge(adc_clk)) then
     adc_data <= adc_data_i;
   end if;
end process;
end generate;


--ltc2107 adc clock and data come out aligned, need to delay the adc clock a bit (10*78ps = 780ps)
IDELAYCTRL_inst : IDELAYCTRL
   port map (
      RDY => idly_rdy,       -- 1-bit output: Ready output
      REFCLK => adc_clk_i, -- 1-bit input: Reference clock input
      RST => reset        -- 1-bit input: Active high reset input
   );


dly_clk : IDELAYE2
   generic map (
      CINVCTRL_SEL => "FALSE",          -- Enable dynamic clock inversion (FALSE, TRUE)
      DELAY_SRC => "DATAIN",           -- Delay input (IDATAIN, DATAIN)
      HIGH_PERFORMANCE_MODE => "FALSE", -- Reduced jitter ("TRUE"), Reduced power ("FALSE")
      IDELAY_TYPE => "FIXED",           -- FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
      IDELAY_VALUE => 15,                -- Input delay tap setting (0-31)
      PIPE_SEL => "FALSE",              -- Select pipelined mode, FALSE, TRUE
      REFCLK_FREQUENCY => 200.0,        -- IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
      SIGNAL_PATTERN => "CLOCK"          -- DATA, CLOCK input signal
   )
   port map (
      CNTVALUEOUT => open, -- 5-bit output: Counter value output
      DATAOUT => adc_clk_dlyd,         -- 1-bit output: Delayed data output
      C => adc_clk,                     -- 1-bit input: Clock input
      CE => '0',                   -- 1-bit input: Active high enable increment/decrement input
      CINVCTRL => '0',       -- 1-bit input: Dynamic clock inversion input
      CNTVALUEIN => "00000",   -- 5-bit input: Counter value input
      DATAIN => adc_clk_i, --'0',           -- 1-bit input: Internal delay data input
      IDATAIN => '0', --adc_clk_i,         -- 1-bit input: Data input from the I/O
      INC => '0',                 -- 1-bit input: Increment / Decrement tap delay input
      LD => '0',                   -- 1-bit input: Load IDELAY_VALUE input
      LDPIPEEN => '0',       -- 1-bit input: Enable PIPELINE register to load data input
      REGRST => not idly_rdy            -- 1-bit input: Active-high reset tap-delay input
   );





gen_iddrs: for i in 0 to 7 generate
begin
da0_1 : IDDR 
   generic map (
      DDR_CLK_EDGE => "SAME_EDGE_PIPELINED", -- "OPPOSITE_EDGE", "SAME_EDGE" 
                                       -- or "SAME_EDGE_PIPELINED" 
      INIT_Q1 => '0', -- Initial value of Q1: '0' or '1'
      INIT_Q2 => '0', -- Initial value of Q2: '0' or '1'
      SRTYPE => "SYNC") -- Set/Reset type: "SYNC" or "ASYNC" 
   port map (
      Q1 => adc_data_i(i*2), -- 1-bit output for positive edge of clock 
      Q2 => adc_data_i(i*2+1),  -- 1-bit output for negative edge of clock
      C => adc_clk_dlyd,   -- 1-bit clock input
      CE => '1',  -- 1-bit clock enable input
      D => adc_data_in(i),   -- 1-bit DDR data input
      R => '0',   -- 1-bit reset
      S => '0'    -- 1-bit set
      );
end generate;



adcdata_sim: if (SIM_MODE = 1) generate read_adc_data: 
  process(adc_clk)
    constant ADC_DATA_FILE : string := "/home/mead/acmi/fwk/acmi-chaina/src/hw/sim/acmi_adc_data.txt";
    file adc_vector   : text open read_mode is ADC_DATA_FILE; --"/home/mead/acmi/fwk/acmi-chaina/src/hw/sim/acmi_adc_data.txt";   
    variable row       : line;
    variable adc_raw  : integer;

    --variable sampnum   : integer;
  
    begin
      if rising_edge(adc_clk)  then
        sample_cnt <= sample_cnt + 1;
        if (trig = '1') then
          file_close(adc_vector);
          file_open(adc_vector,ADC_DATA_FILE,read_mode);
          sample_cnt <= 0;
        end if;
        if (sample_cnt < 16000) then
           readline(adc_vector,row);
           --read(row,sampnum);
           read(row,adc_raw);
           adc_data <= x"8000" xor std_logic_vector(to_signed(adc_raw,16)); 
        else
           adc_data <= x"8000";
        end if;
      end if;
end process;
end generate;



  
end behv;
