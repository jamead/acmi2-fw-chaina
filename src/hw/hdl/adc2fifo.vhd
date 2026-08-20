-------------------------------------------------------------------------------
-- Title         : AXI Data Generator
-------------------------------------------------------------------------------
-- File          : axi_data_gen.vhd
-- Author        : Joseph Mead  mead@bnl.gov
-- Created       : 01/11/2013
-------------------------------------------------------------------------------
-- Description:
-- Provides logic to send adc or test data to FIFO interface.
-- A testdata_en input permits test counters to be sent for verification 
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Modification history:
-- 01/11/2013: created.
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.ALL;
  
library work;
use work.acmi_package.ALL;  
  
entity adc2fifo is
  port (
    sys_clk          	: in  std_logic;
    adc_clk             : in  std_logic;
    reset     			: in  std_logic;   
	reg_o               : in  t_reg_o_adc_fifo_rdout;
	reg_i               : out t_reg_i_adc_fifo_rdout;  
    tbt_trig            : in std_logic;                    	
	adc_data            : in t_adc_raw
);    
end adc2fifo;

architecture behv of adc2fifo is
  
  
 component adcbuf_fifo IS
  port (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    rd_data_count : OUT STD_LOGIC_VECTOR(14 DOWNTO 0)
  );
END component; 




  
  type     state_type is (IDLE, ARM, WR_FIFO);                   
  signal   state   : state_type;  
 
  
  signal fifo_din          : std_logic_vector(63 downto 0);
  signal fifo_full         : std_logic;
  signal fifo_empty        : std_logic;
  signal fifo_rd_data_cnt  : std_logic_vector(14 downto 0);
 
  signal fifo_wren         : std_logic;
  
  signal fifo_rdstr_prev   : std_logic;
  signal fifo_rdstr_fe     : std_logic;
  
  signal adc_stream_enb_sr : std_logic_vector(2 downto 0);
  signal adc_stream_enb_s  : std_logic;

  signal sample_num        : std_logic_vector(31 downto 0);
  
 
--  attribute mark_debug     : string;
--  attribute mark_debug of reg_o: signal is "true";
--  attribute mark_debug of reg_i: signal is "true";
  
  
--  attribute mark_debug              : string;

--  attribute mark_debug of state: signal is "true";
  
--  attribute mark_debug of fifo_din: signal is "true";
--  attribute mark_debug of fifo_wren: signal is "true";
--  attribute mark_debug of adc_fifo_rst: signal is "true";
--  attribute mark_debug of adc_stream_enb_sr: signal is "true";
--  attribute mark_debug of adc_stream_enb_s: signal is "true";
--  attribute mark_debug of adc_stream_enb: signal is "true";
--  attribute mark_debug of adc_fifo_dout: signal is "true";
--  attribute mark_debug of fifo_rdstr_fe: signal is "true";
--  attribute mark_debug of fifo_rd_data_cnt: signal is "true";


begin  



reg_i.rdcnt  <= 17d"0" & fifo_rd_data_cnt;


--since fifo is fall-through mode, want the rdstr
--to happen after the current word is read.
process (reset,sys_clk)
   begin
       if (reset = '1') then
          fifo_rdstr_prev <= '0';
          fifo_rdstr_fe <= '0';
       elsif (sys_clk'event and sys_clk = '1') then
          fifo_rdstr_prev <= reg_o.rdstr;
          if (reg_o.rdstr = '0' and fifo_rdstr_prev = '1') then
              fifo_rdstr_fe <= '1'; --falling edge
          else
              fifo_rdstr_fe <= '0';
          end if;
       end if;
end process;




-- sync tbt_stream_enb to adc clock domain
process (adc_clk)
begin
  if (rising_edge(adc_clk)) then
	if (reset = '1') then
	  adc_stream_enb_sr <= "000";
    else
      adc_stream_enb_sr(0) <= reg_o.enb;
      adc_stream_enb_sr(1) <= adc_stream_enb_sr(0);
      adc_stream_enb_sr(2) <= adc_stream_enb_sr(1);
    end if;
    if (adc_stream_enb_sr(2) = '0' and adc_stream_enb_sr(1) = '1') then
      adc_stream_enb_s <= '1';
    else
      adc_stream_enb_s <= '0';
    end if;
  end if;
end process;








adcfifo : adcbuf_fifo
  PORT MAP (
    rst => reg_o.rst,
    wr_clk => adc_clk,
    wr_en => fifo_wren,  
    din => fifo_din,    
    rd_clk => sys_clk,
    rd_en => fifo_rdstr_fe,
    dout => reg_i.dout,
    full => fifo_full,
    empty => fifo_empty,
    rd_data_count => fifo_rd_data_cnt
  );




--write samples to fifo
process(adc_clk)
  begin
     if (rising_edge(adc_clk)) then
       if (reset = '1') then
          fifo_wren <= '0';
          sample_num <= (others => '0');
          state <= idle;
          fifo_din <= (others => '0');
       else
         case state is
           when IDLE =>  
             fifo_wren <= '0'; 
             sample_num <= (others => '0');    
             if (adc_stream_enb_s = '1') then
                state <= arm;
             end if;
             
           when ARM =>  
             if (tbt_trig = '1') then
                state <= wr_fifo;
             end if;
             
           when WR_FIFO =>
              fifo_wren <= '1';
              fifo_din <= adc_data(1) & adc_data(0) & adc_data(3) & adc_data(2); 
              sample_num <= sample_num + 1;
              if (sample_num = 32d"8010") then
                state <= idle;
              else
                sample_num <= sample_num + 1;
              end if;
              
          when OTHERS => 
              state <= idle;    
              
         end case;
       end if;
     end if;
end process; 



  
end behv;
