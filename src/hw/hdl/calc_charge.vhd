library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.acmi_package.ALL;


entity calc_charge is

  port ( 
   clk                : in std_logic;
   trig               : in std_logic;
   adc_samplenum      : in std_logic_vector(31 downto 0); 
   params             : in t_reg_o_eeprom;            
   adc_data_raw       : in std_logic_vector(15 downto 0);
   adc_data_inv_dly   : out std_logic_vector(15 downto 0);
   pulse_stats        : out t_reg_i_pulse_stats_array    
  );    
end calc_charge;


architecture behv of calc_charge is

component adc_shift_ram
  port (
    d : in std_logic_vector(15 downto 0); 
    clk : in std_logic; 
    q : out std_logic_vector(15 downto 0)
  );
end component; 

  
  signal negone              : signed(15 downto 0) := to_signed(-1,16);
  signal adc_data            : signed(15 downto 0);
  signal adc_data_inv        : signed(15 downto 0);
  signal adc_data_dly        : std_logic_vector(15 downto 0);
  signal boow_adc_data       : signed(15 downto 0);
 
  attribute mark_debug : string;
  attribute mark_debug of adc_data: signal is "true";
  attribute mark_debug of adc_data_dly: signal is "true"; 
  attribute mark_debug of adc_data_inv: signal is "true"; 
  attribute mark_debug of adc_data_inv_dly: signal is "true";
--  attribute mark_debug of test_pulse_gates: signal is "true";
--  attribute mark_debug of adc_samplenum: signal is "true";
  
  
  
  
begin  

--delay the adc data by 40 clocks, 
adc_dly : adc_shift_ram
  PORT MAP (
    D => std_logic_vector(adc_data),
    CLK => clk,
    Q => adc_data_dly
  );


--delay the adc data by 40 clocks, 
adc_dly_inv : adc_shift_ram
  PORT MAP (
    D => std_logic_vector(adc_data_inv),
    CLK => clk,
    Q => adc_data_inv_dly
  );



-- invert the adc data
process(clk)
begin
  if (rising_edge(clk)) then
    adc_data <= signed(adc_data_raw);
    if (adc_data_raw = x"8000") then 
       adc_data_inv <= x"7FFF";
    else
       adc_data_inv <= resize((signed(adc_data_raw) * negone),16);
    end if;
  end if;
end process;








-- beam 
beam:  entity work.calc_beam_stats
  port map ( 
   clk => clk, 
   trig => trig,
   adc_data => signed(adc_data_inv),
   adc_data_dly => signed(adc_data_inv_dly), 
   gate_start => params.beam_adc_delay,  
   adc_samplenum => adc_samplenum,
   pulse_stats => pulse_stats(0)
  );    


-- +2nC
tp1:  entity work.calc_beam_stats
  port map ( 
   clk => clk, 
   trig => trig,
   adc_data => signed(adc_data),
   adc_data_dly => signed(adc_data_dly), 
   gate_start => params.tp1_adc_delay, 
   adc_samplenum => adc_samplenum, 
   pulse_stats => pulse_stats(1)
  );    

-- -2nC
tp2:  entity work.calc_beam_stats
  port map ( 
   clk => clk, 
   trig => trig,
   adc_data => signed(adc_data_inv),
   adc_data_dly => signed(adc_data_inv_dly), 
   gate_start => params.tp2_adc_delay,
   adc_samplenum => adc_samplenum, 
   pulse_stats => pulse_stats(2)
  );    
 
-- -18nC
tp3:  entity work.calc_beam_stats
  port map ( 
   clk => clk, 
   trig => trig,
   adc_data => signed(adc_data_inv),
   adc_data_dly => signed(adc_data_inv_dly), 
   gate_start => params.tp3_adc_delay, 
   adc_samplenum => adc_samplenum,
   pulse_stats => pulse_stats(3)
  );    


--beam out of window
beam_oow:  entity work.find_beam_oow
  port map ( 
   clk => clk, 
   trig => trig,
   adc_data => signed(adc_data_inv),
   adc_data_dly => signed(adc_data_inv_dly),    
   params => params,
   adc_samplenum => adc_samplenum,
   pulse_stats => pulse_stats(4)   
  );    





end behv;
