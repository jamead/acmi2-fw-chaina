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
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.ALL;
  
library work;
use work.acmi_package.ALL;  
  
entity adc2dma is
  port (
    sys_clk          	: in  std_logic;
    adc_clk             : in  std_logic;
    reset     			: in  std_logic;                       
    trig		 		: in  std_logic;
    reg_o               : in t_reg_o_dma;	 	 
	adc_data            : in t_adc_raw; 	 
	dma_active          : out std_logic; 
    m_axis_tdata        : out std_logic_vector(63 downto 0);
    m_axis_tkeep        : out std_logic_vector(7 downto 0);
    m_axis_tlast        : out std_logic;
    m_axis_tready       : in std_logic;
    m_axis_tvalid       : out std_logic     
  );    
end adc2dma;

architecture rtl of adc2dma is
 
  
component adcdata_fifo
  port (
    s_axis_aresetn : IN STD_LOGIC;
    s_axis_aclk : IN STD_LOGIC;
    s_axis_tvalid : IN STD_LOGIC;
    s_axis_tready : OUT STD_LOGIC;
    s_axis_tdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    s_axis_tlast : IN STD_LOGIC;
    m_axis_aclk : IN STD_LOGIC;
    m_axis_tvalid : OUT STD_LOGIC;
    m_axis_tready : IN STD_LOGIC;
    m_axis_tdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    m_axis_tlast : OUT STD_LOGIC;
    axis_wr_data_count : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    axis_rd_data_count : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
end component;

  
  type     wr_state_type is (IDLE, ACTIVE, HOLD);                    
  signal   wr_state      : wr_state_type;  
  

  signal len			   : std_logic_vector(31 downto 0);
  signal testdata		   : std_logic_vector(63 downto 0); 
  
  signal fifo_wrlen        : std_logic_vector(31 downto 0); 
  
  signal data_wren_i	   : std_logic;   

  signal strobe_lat		   : std_logic;
  signal tx_active		   : std_logic;
  signal dlycnt            : INTEGER;
  
  signal trig_s            : std_logic_vector(2 downto 0);
  signal trig_fifo         : std_logic;
  
  
  signal fifo_din          : std_logic_vector(127 downto 0);
  signal fifo_full         : std_logic;
  signal fifo_rdcnt        : std_logic_vector(31 downto 0);
  signal fifo_wrcnt        : std_logic_vector(31 downto 0);
 
  signal fifo_rden         : std_logic;
  signal fifo_wren         : std_logic;
  signal fifo_testdata     : std_logic_vector(63 downto 0);
  
  signal s_axis_aresetn   : std_logic;
  signal s_axis_tready    : std_logic;
  signal s_axis_tdata     : std_logic_vector(63 downto 0);
  signal s_axis_testdata  : std_logic_vector(63 downto 0);
  signal s_axis_tvalid    : std_logic;
  signal s_axis_tlast     : std_logic;
  
  signal burst_len         : std_logic_vector(31 downto 0);

  
  
  attribute mark_debug              : string;

  attribute mark_debug of burst_len : signal is "true";
  attribute mark_debug of wr_state: signal is "true";
  attribute mark_debug of trig: signal is "true";
  attribute mark_debug of trig_s: signal is "true";
  attribute mark_debug of trig_fifo: signal is "true";
  attribute mark_debug of fifo_wrcnt: signal is "true";
  attribute mark_debug of fifo_rdcnt: signal is "true";
  attribute mark_debug of fifo_wrlen: signal is "true";
  attribute mark_debug of s_axis_testdata : signal is "true";
  attribute mark_debug of s_axis_tvalid : signal is "true";
  attribute mark_debug of s_axis_tlast : signal is "true";
  attribute mark_debug of s_axis_tready : signal is "true";     
  attribute mark_debug of reg_o: signal is "true";
  
  attribute mark_debug of m_axis_tdata : signal is "true";
  attribute mark_debug of m_axis_tkeep : signal is "true";
  attribute mark_debug of m_axis_tvalid : signal is "true";
  attribute mark_debug of m_axis_tlast : signal is "true";
  attribute mark_debug of m_axis_tready : signal is "true";   
 


begin  


m_axis_tkeep <= x"FF";
s_axis_aresetn <= not reg_o.fifo_rst;


s_axis_tdata <= adc_data(2) & adc_data(3) & adc_data(0) & adc_data(1) when reg_o.testdata_enb = '0' else
                s_axis_testdata;

burst_len <= reg_o.adc_len;

dma_active <= '0' when (fifo_wrlen = 32d"0") else '1';


u1fifo: adcdata_fifo
  port map (
    s_axis_aresetn => s_axis_aresetn, 
    s_axis_aclk => adc_clk, 
    s_axis_tvalid => s_axis_tvalid, 
    s_axis_tready => s_axis_tready, 
    s_axis_tdata => s_axis_tdata, 
    s_axis_tlast => s_axis_tlast, 
    m_axis_aclk => sys_clk, 
    m_axis_tvalid => m_axis_tvalid, 
    m_axis_tready => m_axis_tready, 
    m_axis_tdata => m_axis_tdata, 
    m_axis_tlast => m_axis_tlast, 
    axis_wr_data_count => fifo_wrcnt, 
    axis_rd_data_count => fifo_rdcnt
  );



--keep fifo wren high for burstlen clocks
process (adc_clk)
begin 
  if (rising_edge(adc_clk)) then
    if (reset = '1') then
      s_axis_tlast <= '0';
      s_axis_tvalid <= '0';
      fifo_wrlen <= 32d"0";
      s_axis_testdata <= (others => '0');
      wr_state <= IDLE;
                
    else
      case wr_state is 
        when IDLE =>
          s_axis_tlast <= '0';
          s_axis_tvalid <= '0';
          if (trig = '1') then
            wr_state <= active;
            fifo_wrlen <= burst_len;
            fifo_testdata <= (others => '0');
            s_axis_tvalid <= '1';
          end if;
          
        when ACTIVE =>
           s_axis_testdata <= s_axis_testdata + 1;
           fifo_wrlen <= fifo_wrlen - 1;
           if (fifo_wrlen = 1) then
              s_axis_tlast <= '1';
              wr_state <= idle;
           end if;
           
        when OTHERS =>
           wr_state <= idle;
      end case;
    end if;
  end if;
end process;  







  
end rtl;
