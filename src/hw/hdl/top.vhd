
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

  
  signal pl_clk0         : std_logic;
  signal pl_clk1         : std_logic;
  signal adc_clk         : std_logic;
  signal pl_resetn       : std_logic;
  signal pl_reset        : std_logic;
  signal ps_leds         : std_logic_vector(7 downto 0);
  
  signal m_axi4_m2s      : t_pl_regs_m2s;
  signal m_axi4_s2m      : t_pl_regs_s2m;
  
  signal adc_clk_in      : std_logic;
  signal adc_data        : std_logic_vector(15 downto 0); 
  signal adc_data_dma    : t_adc_raw;
  signal adc_data_sw     : t_adc_raw;
  signal adc_dbg         : std_logic_vector(3 downto 0);
  
  signal adc_spi_we      : std_logic;
  signal adc_spi_wdata   : std_logic_vector(31 downto 0);
  signal adc_spi_rdata   : std_logic_vector(31 downto 0);
  signal adc_idly_wrval  : std_logic_vector(8 downto 0);
  signal adc_idly_wrstr  : std_logic_vector(15 downto 0);
  signal adc_idly_rdval  : std_logic_vector(8 downto 0);       
  signal adc_fco_dlystr  : std_logic_vector(1 downto 0);  
  
  signal reg_o_adcfifo   : t_reg_o_adc_fifo_rdout;
  signal reg_i_adcfifo   : t_reg_i_adc_fifo_rdout;
  signal reg_o_tbtfifo   : t_reg_o_tbt_fifo_rdout;
  signal reg_i_tbtfifo   : t_reg_i_tbt_fifo_rdout;

  
  signal reg_o_dsa       : t_reg_o_dsa;  
  signal reg_o_pll       : t_reg_o_pll;
  signal reg_i_pll       : t_reg_i_pll;
  signal reg_o_adc       : t_reg_o_adc_cntrl;
  signal reg_i_adc       : t_reg_i_adc_status; 
  signal reg_o_tbt       : t_reg_o_tbt;
  signal reg_o_dma       : t_reg_o_dma;
  signal reg_i_dma       : t_reg_i_dma;
  signal reg_o_evr       : t_reg_o_evr;
  signal reg_i_evr       : t_reg_i_evr;
  signal reg_o_therm     : t_reg_o_therm;
  signal reg_i_therm     : t_reg_i_therm;
  signal reg_o_swrffe    : t_reg_o_swrffe;
  
  signal tbt_data        : t_tbt_data;    
  signal sa_data         : t_sa_data;
  signal fa_data         : t_fa_data;
  
  signal sw_rffe_demux   : std_logic;
  signal sw_rffe_time    : std_logic;
  
  signal dma_adc_active  : std_logic;
  signal dma_adc_tdata   : std_logic_vector(63 downto 0);
  signal dma_adc_tkeep   : std_logic_vector(7 downto 0);
  signal dma_adc_tlast   : std_logic;
  signal dma_adc_tready  : std_logic;
  signal dma_adc_tvalid  : std_logic;
    
  signal dma_tbt_active  : std_logic;
  signal dma_tbt_tdata   : std_logic_vector(63 downto 0);
  signal dma_tbt_tkeep   : std_logic_vector(7 downto 0);
  signal dma_tbt_tlast   : std_logic;
  signal dma_tbt_tready  : std_logic;
  signal dma_tbt_tvalid  : std_logic;  
    
  signal dma_fa_active   : std_logic;
  signal dma_fa_tdata    : std_logic_vector(63 downto 0);
  signal dma_fa_tkeep    : std_logic_vector(7 downto 0);
  signal dma_fa_tlast    : std_logic;
  signal dma_fa_tready   : std_logic;
  signal dma_fa_tvalid   : std_logic;    
  
  signal evr_tbt_trig    : std_logic;
  signal evr_fa_trig     : std_logic;
  signal evr_sa_trig     : std_logic;
  signal evr_gps_trig    : std_logic;
  signal evr_dma_trig    : std_logic;  
  signal evr_ts          : std_logic_vector(63 downto 0); 
  signal evr_rcvd_clk    : std_logic;
  signal evr_ref_clk     : std_logic;
   
  signal tbt_extclk      : std_logic;  
  
  signal tbt_gate        : std_logic;
  signal tbt_trig        : std_logic;
  signal pt_trig         : std_logic;
  signal fa_trig         : std_logic;
  signal sa_trig         : std_logic;
  signal sa_trig_stretch : std_logic;
  signal ps_fpled_stretch: std_logic;
  signal dma_trig        : std_logic;
  signal dma_busy        : std_logic;
  
  signal ioc_access_led  : std_logic;
  
  signal count           : integer;    
  signal toggle_reg      : std_logic;




  attribute mark_debug     : string;
  --attribute mark_debug of reg_o: signal is "true";
  attribute mark_debug of adc_data: signal is "true";
  attribute mark_debug of adc_data_sw: signal is "true";
 

begin

afe_pwrenb <= '1';
reg_i_pll.locked <= '0'; 


dbg(0) <= pl_clk0;
dbg(1) <= dma_busy; --'0'; --adc_fco_dlystr(0); --'0';
dbg(2) <= adc_dbg(1);  --psdone 
dbg(3) <= '0';
dbg(4) <= adc_dbg(2); -- adc_fco_bufg 
dbg(5) <= adc_dbg(3); --adc_fco_mmcm 
dbg(6) <= '0'; --gth_refclk_buf; --'0';
dbg(7) <= '0'; --gth_txusr_clk;
dbg(8) <= '0'; --gth_rxusr_clk;
dbg(9) <= evr_tbt_trig;
dbg(10) <= evr_fa_trig;
dbg(11) <= evr_sa_trig;
dbg(12) <= tbt_trig; 
dbg(13) <= fa_trig;
dbg(14) <= sa_trig;
dbg(15) <= tbt_extclk;
dbg(16) <= sw_rffe_demux; --fp_in(0);
dbg(17) <= sw_rffe_time; --fp_in(1);
dbg(18) <= fp_in(2);
dbg(19) <= fp_in(3);


fp_out(0) <= evr_tbt_trig; --fa_trig; --pl_clk0;
fp_out(1) <= tbt_extclk; --afe_sw_rffe_p; --evr_rcvd_clk; 
fp_out(2) <= tbt_trig; --adc_clk_in; --adc_clk; 
fp_out(3) <= evr_rcvd_clk; --sw_rffe_time; --evr_rcvd_clk; --tbt_extclk; --tbt_trig; 

fp_led(7) <= dma_adc_active;
fp_led(6) <= dma_tbt_active; 
fp_led(5) <= dma_fa_active; 
fp_led(4) <= dma_busy; 
fp_led(3) <= '0'; --not ad9510_status;
fp_led(2) <= ioc_access_led; 
fp_led(1) <= '0';
fp_led(0) <= sa_trig_stretch;

sfp_led(0) <= evr_gps_trig;
sfp_led(11 downto 1) <= (others => '0');


--adc_clk_inst  : IBUFDS  port map (O => adc_clk_in, I => adc_clk_p, IB => adc_clk_n); 
--tbt_clk_inst  : IBUFDS  port map (O => tbt_extclk, I => tbt_clk_p, IB => tbt_clk_n); 

--evr_clk_inst : OBUFDS  generic map (IOSTANDARD => "LVDS", SLEW => "FAST") port map (O => evr_rcvd_clk_p,  OB => evr_rcvd_clk_n, I => evr_rcvd_clk);
--evr_clk_inst : OBUFDS  generic map (IOSTANDARD => "LVDS", SLEW => "FAST") port map (O => evr_rcvd_clk_p,  OB => evr_rcvd_clk_n, I => evr_tbt_trig);



pl_reset <= not pl_resetn;


fault_led <= (others => toggle_reg);

process(pl_clk0)
  begin
    if rising_edge(pl_clk0) then
       if pl_reset = '1' then
          count      <= 0;
          toggle_reg <= '0';
       elsif count = 100000000 then
          count      <= 0;
          toggle_reg <= not toggle_reg;
       else
          count <= count + 1;
       end if;
     end if;
 end process;



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
    adc_data_ob => open, --dac_data,
    adc_clk => adc_clk,
    adc_sat => open --adc_sat
  );









reg_i_evr.ts_s <= evr_ts(63 downto 32);
reg_i_evr.ts_ns <= evr_ts(31 downto 0);



--adcstream:  entity work.adc2fifo
--  port map(
--    adc_clk => adc_clk,
--    sys_clk => pl_clk0, 
--    reset => pl_reset,   
--  	reg_o => reg_o_adcfifo,
--	reg_i => reg_i_adcfifo,  
--    tbt_trig => sw_rffe_time, --tbt_trig,                     
--	adc_data => adc_data
--);    



--adctoddr: entity work.adc2dma
--  port map(
--    sys_clk => pl_clk1, 
--    adc_clk => adc_clk, 
--    reset => pl_reset,                        
--    trig => dma_trig, --soft_trig, 
--    reg_o => reg_o_dma, 	 
--	adc_data => adc_data_dma, 
--	dma_active => dma_adc_active,
--    m_axis_tdata => dma_adc_tdata, 
--    m_axis_tkeep => dma_adc_tkeep,
--    m_axis_tlast => dma_adc_tlast, 
--    m_axis_tready => dma_adc_tready, 
--    m_axis_tvalid => dma_adc_tvalid   
--  );    




--embedded event receiver
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
    tbt_trig => evr_tbt_trig, 
    fa_trig => evr_fa_trig, 
    sa_trig => evr_sa_trig, 
    usr_trig => evr_dma_trig, 
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
    sa_data => sa_data,
    reg_o_tbt => reg_o_tbt,
    reg_o_adc => reg_o_adc,
    reg_i_adc => reg_i_adc,
    reg_o_therm => reg_o_therm,
    reg_i_therm => reg_i_therm,    
    reg_o_adcfifo => reg_o_adcfifo, 
	reg_i_adcfifo => reg_i_adcfifo,
	reg_o_tbtfifo => reg_o_tbtfifo, 
	reg_i_tbtfifo => reg_i_tbtfifo,
	reg_o_dma => reg_o_dma,
	reg_i_dma => reg_i_dma,
	reg_o_dsa => reg_o_dsa,
	reg_o_pll => reg_o_pll,
	reg_i_pll => reg_i_pll,
	reg_o_evr => reg_o_evr, 
	reg_i_evr => reg_i_evr,
	reg_o_swrffe => reg_o_swrffe,
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
    m_axi_wvalid => m_axi4_m2s.wvalid,
    
    s_axis_s2mm_adc_tdata => dma_adc_tdata,
    s_axis_s2mm_adc_tkeep => dma_adc_tkeep,
    s_axis_s2mm_adc_tlast => dma_adc_tlast, 
    s_axis_s2mm_adc_tready => dma_adc_tready,
    s_axis_s2mm_adc_tvalid => dma_adc_tvalid,
    s_axis_s2mm_tbt_tdata => dma_tbt_tdata,
    s_axis_s2mm_tbt_tkeep => dma_tbt_tkeep,
    s_axis_s2mm_tbt_tlast => dma_tbt_tlast, 
    s_axis_s2mm_tbt_tready => dma_tbt_tready,
    s_axis_s2mm_tbt_tvalid => dma_tbt_tvalid,
    s_axis_s2mm_fa_tdata => dma_fa_tdata,
    s_axis_s2mm_fa_tkeep => dma_fa_tkeep,
    s_axis_s2mm_fa_tlast => dma_fa_tlast, 
    s_axis_s2mm_fa_tready => dma_fa_tready,
    s_axis_s2mm_fa_tvalid => dma_fa_tvalid     
    );




--stretch the sa_trig signal so can be seen on LED
sa_led : entity work.stretch
  port map (
	clk => adc_clk,
	reset => pl_reset, 
	sig_in => sa_trig, 
	len => 3000000, -- ~25ms;
	sig_out => sa_trig_stretch
);	  	

--stretch the sa_trig signal so can be seen on LED
pscmsg_led : entity work.stretch
  port map (
	clk => pl_clk0,
	reset => pl_reset, 
	sig_in => ps_leds(0), 
	len => 3000000, -- ~25ms;
	sig_out => ps_fpled_stretch
);	  	



end behv;
