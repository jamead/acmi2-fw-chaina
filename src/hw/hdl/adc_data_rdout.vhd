library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library work;
use work.acmi_package.ALL;

entity adc_data_rdout is
  port (
    sys_clk         : in std_logic; 
    adc_clk         : in std_logic;
    sys_rst         : in std_logic;
    trig            : in std_logic;
    reg_o           : in t_reg_o_adc_fifo_rdout;
    reg_i           : out t_reg_i_adc_fifo_rdout;
    adc_data       : in std_logic_vector(15 downto 0)
 );
end adc_data_rdout;

architecture behv of adc_data_rdout is


component wvfm_fifo
  port (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    rd_data_count : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
end component; 

  constant NUM_SAMPLES : natural := 16000;

  type     state_type is (IDLE,WR_FIFO);                   
  signal   state   : state_type;  


  signal fifo_wren        : std_logic := '0';  
  signal fifo_rdcnt       : std_logic_vector(15 downto 0);
  signal fifo_dout        : std_logic_vector(15 downto 0);
  
  signal trig_sr          : std_logic_vector(2 downto 0);
  signal trig_s           : std_logic;
  
  signal sample_num       : unsigned(15 downto 0);

  
  attribute ASYNC_REG : string;
  attribute ASYNC_REG of trig_sr : signal is "TRUE";


  attribute mark_debug                 : string;

  attribute mark_debug of fifo_wren: signal is "true";
  attribute mark_debug of adc_data: signal is "true";
  attribute mark_debug of reg_o: signal is "true";
  attribute mark_debug of reg_i: signal is "true";
  attribute mark_debug of trig_s: signal is "true";
  attribute mark_debug of fifo_dout: signal is "true";
  

begin


reg_i.fifo_rdcnt <= 16d"0" & fifo_rdcnt;


        

-- sync trig to adc clock domain
process (adc_clk)
begin
  if (rising_edge(adc_clk)) then
	if (sys_rst = '1') then
	  trig_sr <= "000";
	  trig_s  <= '0';
    else
      trig_sr(0) <= trig;
      trig_sr(1) <= trig_sr(0);
      trig_sr(2) <= trig_sr(1);

      if (trig_sr(2) = '0' and trig_sr(1) = '1') then
        trig_s <= '1';
      else
        trig_s <= '0';
      end if;
    end if;
  end if;
end process;



process(adc_clk)
begin
  if rising_edge(adc_clk) then
    if sys_rst = '1' then
      sample_num <= (others => '0');
      state      <= IDLE;
    else
      case state is

        when IDLE =>
          sample_num <= (others => '0');

          if trig_s = '1' then
            state <= WR_FIFO;
          end if;

        when WR_FIFO =>
          if sample_num = to_unsigned(NUM_SAMPLES-1, sample_num'length) then
            state <= IDLE;
          else
            sample_num <= sample_num + 1;
          end if;

        when others =>
          state <= IDLE;

      end case;
    end if;
  end if;
end process;




reg_i.fifo_dout <= std_logic_vector(resize(signed(fifo_dout), 32));


fifo_wren <= '1' when state = WR_FIFO else '0';


fifo_inst : wvfm_fifo
  PORT MAP (
    rst => reg_o.fifo_rst,
    wr_clk => adc_clk,
    rd_clk => sys_clk,
    din => adc_data,
    wr_en => fifo_wren,
    rd_en => reg_o.fifo_rdstr, 
    dout => fifo_dout, 
    full => open,
    empty => open,
    rd_data_count => fifo_rdcnt
  );



end behv;
