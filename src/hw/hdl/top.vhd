
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

library desyrdl;
use desyrdl.common.all;
use desyrdl.pkg_pl_regs.all;

library xil_defaultlib;
use xil_defaultlib.acmi_package.ALL;


entity top is
generic(
    FPGA_VERSION			: integer := 9;
    SIM_MODE				: integer := 0
    );
  port (  
    -- adc ltc2107
    adc_spi_cs              : out std_logic;
    adc_spi_sck             : out std_logic;
    adc_spi_sdi             : out std_logic;
    adc_spi_sdo             : in std_logic;
    adc_clk_p               : in std_logic;
    adc_clk_n               : in std_logic;
    adc_data_p              : in std_logic_vector(7 downto 0);
    adc_data_n              : in std_logic_vector(7 downto 0);  
    adc_of_p                : in std_logic;
    adc_of_n                : in std_logic;  

    --test pulse signals       
    tp_pos_pulse            : out std_logic_vector(4 downto 0);
    tp_neg_pulse            : out std_logic_vector(4 downto 0);
    
    --eeprom
    eeprom_csn              : out std_logic;
    eeprom_sck              : out std_logic;
    eeprom_sdi              : out std_logic;
    eeprom_holdn            : out std_logic;
    eeprom_sdo              : in std_logic;    

    --fault leds 
    fault_led               : out std_logic_vector(15 downto 0);
    
    --relay board interface
    faultn                  : out std_logic;
    faultn_rdbk             : in std_logic;
    fault_rst               : out std_logic;
    force_trig              : out std_logic;
    keylock                 : in std_logic;
    spare                   : in std_logic_vector(4 downto 0);
    
	-- afe power management
	afe_pwrenb              : out std_logic;

    --evr transceiver
    gth_evr_refclk_p        : in std_logic;
    gth_evr_refclk_n        : in std_logic;
    gth_evr_tx_p            : out std_logic;
    gth_evr_tx_n            : out std_logic;
    gth_evr_rx_p            : in std_logic;
    gth_evr_rx_n            : in std_logic;   
    
    -- dfe i/o
    sfp_led                 : out std_logic_vector(11 downto 0);
    sfp_rxlos               : in std_logic_vector(5 downto 0);
    fp_in                   : in std_logic_vector(3 downto 0);
    fp_out                  : out std_logic_vector(3 downto 0);
    fp_led                  : out std_logic_vector(7 downto 0);
    dbg                     : out std_logic_vector(19 downto 0) 

  );
end top;
 

architecture behv of top is

  
  signal pl_clk0            : std_logic;
  signal pl_clk1            : std_logic;
  signal adc_clk            : std_logic;
  signal pl_resetn          : std_logic;
  signal pl_reset           : std_logic;
  signal ps_leds            : std_logic_vector(7 downto 0);
  
  signal m_axi4_m2s         : t_pl_regs_m2s;
  signal m_axi4_s2m         : t_pl_regs_s2m;
  
  signal adc_data           : std_logic_vector(15 downto 0); 

  signal reg_o_adcfifo      : t_reg_o_adc_fifo_rdout;
  signal reg_i_adcfifo      : t_reg_i_adc_fifo_rdout;
  signal reg_o_adc          : t_reg_o_adc_cntrl;
  signal reg_i_adc          : t_reg_i_adc_status; 
  signal reg_i_trig         : t_reg_i_trig;
  signal reg_o_evr          : t_reg_o_evr;
  signal reg_i_evr          : t_reg_i_evr;
  signal reg_o_eeprom       : t_reg_o_eeprom;
  signal reg_i_pulsestats   : t_reg_i_pulse_stats_array;

  signal adc_samplenum      : std_logic_vector(31 downto 0);
  signal beam_detect_window : std_logic;
  signal beam_cycle_window  : std_logic;
  signal fault_startup      : std_logic;
  signal live_time          : std_logic_vector(31 downto 0);
  signal startup_cnt        : std_logic_vector(31 downto 0);


  signal evr_gps_trig       : std_logic;
  signal evr_trig           : std_logic;  
  signal evr_ts             : std_logic_vector(63 downto 0); 
  signal evr_rcvd_clk       : std_logic;
  signal evr_ref_clk        : std_logic;

  
  signal ioc_access_led  : std_logic;
  
  signal count           : integer;    
  signal toggle_reg      : std_logic;




  attribute mark_debug     : string;
  --attribute mark_debug of reg_o: signal is "true";
  attribute mark_debug of adc_data: signal is "true";

 

begin

afe_pwrenb <= '1';


dbg(0) <= pl_clk0;
dbg(1) <= '0'; 
dbg(2) <= '0';  
dbg(3) <= '0';
dbg(4) <= '0';  
dbg(5) <= '0'; 
dbg(6) <= '0'; 
dbg(7) <= '0'; 
dbg(8) <= '0'; 
dbg(9) <= '0';
dbg(10) <= '0';
dbg(11) <= '0';
dbg(12) <= '0'; 
dbg(13) <= '0';
dbg(14) <= '0';
dbg(15) <= '0';
dbg(16) <= '0';
dbg(17) <= '0';
dbg(18) <= '0';
dbg(19) <= '0';


fp_out(0) <= '0';
fp_out(1) <= '0'; 
fp_out(2) <= '0'; 
fp_out(3) <= '0'; 

fp_led(7) <= '0';
fp_led(6) <= '0'; 
fp_led(5) <= '0'; 
fp_led(4) <= '0'; 
fp_led(3) <= '0'; 
fp_led(2) <= ioc_access_led; 
fp_led(1) <= '0';
fp_led(0) <= '0';

sfp_led(0) <= evr_gps_trig;
sfp_led(11 downto 1) <= (others => '0');

fault_led <= (others => '0');


pl_reset <= not pl_resetn;








timing: entity work.timing_events
  port map(
    clk => adc_clk,
    reset => pl_reset,
    trig => evr_trig, 
    eeprom_params => reg_o_eeprom, 
    keylock => keylock,    
    beam_detect_window => beam_detect_window,
    beam_cycle_window => beam_cycle_window,
    adc_samplenum => adc_samplenum,
    tp_pos_pulse => tp_pos_pulse,
    tp_neg_pulse => tp_neg_pulse,
    live_time => live_time, 
    startup_cnt => startup_cnt, 
    fault_startup => fault_startup
 );





--configures and reads ADC
adc : entity work.adc_interface
  generic map (
    SIM_MODE => SIM_MODE
  )
  port map (
    reset => pl_reset,
    trig => '0', --trig,
    sclk => adc_spi_sck,                    
    din => adc_spi_sdi, 
    dout => adc_spi_sdo, 
    sync => adc_spi_cs,     
    adc_clk_p => adc_clk_p,
    adc_clk_n => adc_clk_n,
    adc_data_p => adc_data_p,
    adc_data_n => adc_data_n,
    adc_of_p => adc_of_p,
    adc_of_n => adc_of_n,
    adc_data_lut => 16d"0",  --adc_data_lut,
    adc_data_corr => adc_data,
    adc_data_ob => open, 
    adc_clk => adc_clk,
    adc_sat => open  --adc_sat
  );


-- calculates all metrics on beam and test pulses
calc_q: entity work.calc_charge
  port map (
   clk => adc_clk,
   trig => evr_trig,
   adc_samplenum => adc_samplenum,
   params => reg_o_eeprom,              
   adc_data_raw => adc_data, 
   adc_data_inv_dly => open, --adc_data_dly, 
   pulse_stats => reg_i_pulsestats  
  );    




















-- push 16k samples to FIFO on trigger
wvfm_fifo: entity work.adc_data_rdout
  port map (
    sys_clk => pl_clk0,
    adc_clk => adc_clk,
    sys_rst => pl_reset,
    trig => evr_trig,
    reg_o => reg_o_adcfifo,
    reg_i => reg_i_adcfifo,
    adc_data => adc_data
 );



reg_i_evr.ts_s <= evr_ts(63 downto 32);
reg_i_evr.ts_ns <= evr_ts(31 downto 0);



----embedded event receiver
evr: entity work.evr_top 
  generic map (
    SIM_MODE => SIM_MODE
  )
  port map(
    sys_clk => pl_clk0,
    sys_rst => pl_reset,
    reg_o => reg_o_evr,
    --gth_reset => gth_reset,

    gth_refclk_p => gth_evr_refclk_p,  -- 312.5 MHz reference clock
    gth_refclk_n => gth_evr_refclk_n,
    gth_tx_p => gth_evr_tx_p,
    gth_tx_n => gth_evr_tx_n,
    gth_rx_p => gth_evr_rx_p,
    gth_rx_n => gth_evr_rx_n,
      
    --trignum => evr_dma_trignum, 
    trigdly => (x"00000001"), 
    tbt_trig => open,  
    fa_trig => open,  
    sa_trig => open,  
    usr_trig => evr_trig, 
    gps_trig => evr_gps_trig, 
    timestamp => evr_ts,  
    evr_rcvd_clk => evr_rcvd_clk
);	




ps_pl: entity work.ps_io
  port map (
    pl_clock => pl_clk0, 
    pl_reset => not pl_resetn, 
    m_axi4_m2s => m_axi4_m2s, 
    m_axi4_s2m => m_axi4_s2m, 
    fp_leds => ps_leds,
    reg_o_adc => reg_o_adc,
    reg_i_adc => reg_i_adc,   
    reg_o_adcfifo => reg_o_adcfifo, 
	reg_i_adcfifo => reg_i_adcfifo,
	reg_o_eeprom => reg_o_eeprom,
	reg_i_pulsestats => reg_i_pulsestats,
	reg_o_evr => reg_o_evr, 
	reg_i_evr => reg_i_evr,
	reg_i_trig => reg_i_trig,
	ioc_access_led => ioc_access_led
          
  );



system_i: component system
  port map (
    pl_clk0 => pl_clk0,
    pl_clk1 => pl_clk1,
    pl_resetn => pl_resetn,
     
    m_axi_araddr => m_axi4_m2s.araddr, 
    m_axi_arprot => m_axi4_m2s.arprot,
    m_axi_arready => m_axi4_s2m.arready,
    m_axi_arvalid => m_axi4_m2s.arvalid,
    m_axi_awaddr => m_axi4_m2s.awaddr,
    m_axi_awprot => m_axi4_m2s.awprot,
    m_axi_awready => m_axi4_s2m.awready,
    m_axi_awvalid => m_axi4_m2s.awvalid,
    m_axi_bready => m_axi4_m2s.bready,
    m_axi_bresp => m_axi4_s2m.bresp,
    m_axi_bvalid => m_axi4_s2m.bvalid,
    m_axi_rdata => m_axi4_s2m.rdata,
    m_axi_rready => m_axi4_m2s.rready,
    m_axi_rresp => m_axi4_s2m.rresp,
    m_axi_rvalid => m_axi4_s2m.rvalid,
    m_axi_wdata => m_axi4_m2s.wdata,
    m_axi_wready => m_axi4_s2m.wready,
    m_axi_wstrb => m_axi4_m2s.wstrb,
    m_axi_wvalid => m_axi4_m2s.wvalid
    );




--stretch the sa_trig signal so can be seen on LED
--sa_led : entity work.stretch
--  port map (
--	clk => adc_clk,
--	reset => pl_reset, 
--	sig_in => sa_trig, 
--	len => 3000000, -- ~25ms;
--	sig_out => sa_trig_stretch
--);	  	

--stretch the sa_trig signal so can be seen on LED
--pscmsg_led : entity work.stretch
--  port map (
--	clk => pl_clk0,
--	reset => pl_reset, 
--	sig_in => ps_leds(0), 
--	len => 3000000, -- ~25ms;
--	sig_out => ps_fpled_stretch
--);	  	



end behv;
