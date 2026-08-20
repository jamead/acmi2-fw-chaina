
library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


  
package acmi_package is

type t_adc_raw is array(0 to 3) of std_logic_vector(15 downto 0);

type sfp_i2c_data_type is array(0 to 5) of std_logic_vector(15 downto 0);

  

type t_reg_o_adc_cntrl is record
   spi_we     : std_logic;
   spi_wdata  : std_logic_vector(31 downto 0);
   idly_wval  : std_logic_vector(8 downto 0);
   idly_wstr  : std_logic_vector(15 downto 0);
   fco_dlystr : std_logic_vector(1 downto 0);
end record t_reg_o_adc_cntrl;

type t_reg_i_adc_status is record
   spi_rdata     : std_logic_vector(31 downto 0);
   idlycha_rval  : std_logic_vector(8 downto 0);
   idlychb_rval  : std_logic_vector(8 downto 0);
   idlychc_rval  : std_logic_vector(8 downto 0);
   idlychd_rval  : std_logic_vector(8 downto 0);      
end record t_reg_i_adc_status;




type t_reg_i_adc_fifo_rdout is record
   dout     : std_logic_vector(31 downto 0);
   rdcnt    : std_logic_vector(31 downto 0); 
end record t_reg_i_adc_fifo_rdout;

type t_reg_o_adc_fifo_rdout is record
   enb      : std_logic;
   rst      : std_logic;
   rdstr    : std_logic;
end record t_reg_o_adc_fifo_rdout;


type t_reg_i_tbt_fifo_rdout is record
   dout     : std_logic_vector(31 downto 0);
   rdcnt    : std_logic_vector(31 downto 0); 
end record t_reg_i_tbt_fifo_rdout;

type t_reg_o_tbt_fifo_rdout is record
   enb      : std_logic;
   rst      : std_logic;
   rdstr    : std_logic;
end record t_reg_o_tbt_fifo_rdout;


type t_reg_o_dsa is record
   str      : std_logic;
   data     : std_logic_vector(7 downto 0);
end record t_reg_o_dsa;

type t_reg_o_evr is record
   reset         : std_logic;
   dma_trigno    : std_logic_vector(7 downto 0);
   event_src_sel : std_logic;
end record t_reg_o_evr;

type t_reg_i_evr is record
   ts_ns      : std_logic_vector(31 downto 0);
   ts_s       : std_logic_vector(31 downto 0);
end record t_reg_i_evr;


type t_reg_o_pll is record
   str      : std_logic;
   data     : std_logic_vector(31 downto 0);
end record t_reg_o_pll;

type t_reg_i_pll is record
   locked      : std_logic;
end record t_reg_i_pll;


type t_reg_o_therm is record
   spi_we     : std_logic;
   spi_wdata  : std_logic_vector(31 downto 0);
   sel        : std_logic_vector(1 downto 0);
end record t_reg_o_therm;

type t_reg_i_therm is record
   spi_rdata    : std_logic_vector(7 downto 0);
end record t_reg_i_therm;





type sdi_cntrl_type is record
   reset       : std_logic_vector(15 downto 0);
   my_addr     : std_logic_vector(15 downto 0);
   stop_addr   : std_logic_vector(15 downto 0);
   fa_trig_dly : std_logic_vector(11 downto 0);
   
end record sdi_cntrl_type;

type sdi_status_type is record
   cw_crcerrcnt          : std_logic_vector(31 downto 0);
   ccw_crcerrcnt         : std_logic_vector(31 downto 0);
   fa_trig_cnt           : std_logic_vector(31 downto 0);
   fa_trig_sync_cnt      : std_logic_vector(31 downto 0);
   cw_timeout_cnt_fault  : std_logic_vector(15 downto 0);
   ccw_timeout_cnt_fault : std_logic_vector(15 downto 0);
end record sdi_status_type;

type brd_temps_type is record
   temp0 : std_logic_vector(15 downto 0);
   temp1 : std_logic_vector(15 downto 0);
   temp2 : std_logic_vector(15 downto 0);
   temp3 : std_logic_vector(15 downto 0);
end record brd_temps_type;


type afe_regs_type is record
   temp0 : std_logic_vector(15 downto 0);
   temp1 : std_logic_vector(15 downto 0);
   temp2 : std_logic_vector(15 downto 0);
   temp3 : std_logic_vector(15 downto 0);
   Vreg0 : std_logic_vector(15 downto 0);
   Vreg1 : std_logic_vector(15 downto 0);
   Vreg2 : std_logic_vector(15 downto 0);
   Vreg3 : std_logic_vector(15 downto 0);
   Vreg4 : std_logic_vector(15 downto 0);
   Vreg5 : std_logic_vector(15 downto 0);
   Vreg6 : std_logic_vector(15 downto 0);
   Vreg7 : std_logic_vector(15 downto 0);
   Ireg0 : std_logic_vector(15 downto 0);
   Ireg1 : std_logic_vector(15 downto 0);
   Ireg2 : std_logic_vector(15 downto 0);
   Ireg3 : std_logic_vector(15 downto 0);
   Ireg4 : std_logic_vector(15 downto 0);
   Ireg5 : std_logic_vector(15 downto 0);
   Ireg6 : std_logic_vector(15 downto 0);
   Ireg7 : std_logic_vector(15 downto 0);
end record afe_regs_type;




type t_tbt_data is record
    cha_mag    : signed(31 downto 0);
    cha_phs    : signed(31 downto 0);
    cha_i      : signed(31 downto 0);
    cha_q      : signed(31 downto 0);
    chb_mag    : signed(31 downto 0);
    chb_phs    : signed(31 downto 0); 
    chb_i      : signed(31 downto 0);
    chb_q      : signed(31 downto 0);
    chc_mag    : signed(31 downto 0);
    chc_phs    : signed(31 downto 0); 
    chc_i      : signed(31 downto 0);
    chc_q      : signed(31 downto 0);
    chd_mag    : signed(31 downto 0);
    chd_phs    : signed(31 downto 0);     
    chd_i      : signed(31 downto 0);
    chd_q      : signed(31 downto 0);
    xpos       : signed(31 downto 0);
    ypos       : signed(31 downto 0);
    xpos_nm    : signed(31 downto 0);
    ypos_nm    : signed(31 downto 0);
    sum        : signed(31 downto 0);
end record t_tbt_data;


type t_sa_data is record
    cnt        : std_logic_vector(31 downto 0);
    cha_mag    : signed(31 downto 0);
    chb_mag    : signed(31 downto 0);
    chc_mag    : signed(31 downto 0);
    chd_mag    : signed(31 downto 0);     
    xpos       : signed(31 downto 0);
    ypos       : signed(31 downto 0);
    sum        : signed(31 downto 0);
end record t_sa_data;


type t_fa_data is record
    cha_mag    : signed(31 downto 0);
    chb_mag    : signed(31 downto 0);
    chc_mag    : signed(31 downto 0); 
    chd_mag    : signed(31 downto 0);     
    xpos       : signed(31 downto 0);
    ypos       : signed(31 downto 0);
    sum        : signed(31 downto 0);
end record t_fa_data;


type t_reg_o_swrffe is record
    adcdma_sel   : std_logic;
    enb          : std_logic_vector(1 downto 0);
    demuxdly     : std_logic_vector(8 downto 0);
    trigdly      : std_logic_vector(15 downto 0);
end record t_reg_o_swrffe;


type t_reg_o_tbt is record
    kx             : std_logic_vector(31 downto 0);
    ky             : std_logic_vector(31 downto 0);
    cha_gain       : std_logic_vector(15 downto 0);
    chb_gain       : std_logic_vector(15 downto 0);
    chc_gain       : std_logic_vector(15 downto 0);
    chd_gain       : std_logic_vector(15 downto 0);      
    xpos_offset    : std_logic_vector(31 downto 0);
    ypos_offset    : std_logic_vector(31 downto 0); 
    gate_delay     : std_logic_vector(8 downto 0); 
    gate_width     : std_logic_vector(8 downto 0);
    ddc_lpfilt_sel : std_logic; --0=4 tap FIR, 1=100 tap FIR
end record t_reg_o_tbt;


type t_reg_o_dma is record
    soft_trig    : std_logic;
    trigsrc      : std_logic;
    testdata_enb : std_logic;
    adc_len      : std_logic_vector(31 downto 0);
    tbt_len      : std_logic_vector(31 downto 0);
    fa_len       : std_logic_vector(31 downto 0);
    fifo_rst     : std_logic;
    adc_enb      : std_logic;
    tbt_enb      : std_logic;
    fa_enb       : std_logic;
    txtoioc_done : std_logic;
end record t_reg_o_dma;

type t_reg_i_dma is record
    trig_cnt     : std_logic_vector(31 downto 0); 
    status       : std_logic_vector(4 downto 0);
    ts_s         : std_logic_vector(31 downto 0);
    ts_ns        : std_logic_vector(31 downto 0);
end record t_reg_i_dma;



component system is
  port (
    pl_clk0 : out STD_LOGIC;
    pl_clk1 : out std_logic;
    pl_resetn : out STD_LOGIC;
    m_axi_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axi_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_awvalid : out STD_LOGIC;
    m_axi_awready : in STD_LOGIC;
    m_axi_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axi_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_wvalid : out STD_LOGIC;
    m_axi_wready : in STD_LOGIC;
    m_axi_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_bvalid : in STD_LOGIC;
    m_axi_bready : out STD_LOGIC;
    m_axi_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axi_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_arvalid : out STD_LOGIC;
    m_axi_arready : in STD_LOGIC;
    m_axi_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axi_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_rvalid : in STD_LOGIC;
    m_axi_rready : out STD_LOGIC;
    
    S_AXIS_S2MM_ADC_tdata : in std_logic_vector(63 downto 0); 
    S_AXIS_S2MM_ADC_tkeep : in std_logic_vector(7 downto 0); 
    S_AXIS_S2MM_ADC_tlast : in std_logic;  
    S_AXIS_S2MM_ADC_tready : out std_logic; 
    S_AXIS_S2MM_ADC_tvalid : in std_logic;   
    S_AXIS_S2MM_TBT_tdata : in std_logic_vector(63 downto 0); 
    S_AXIS_S2MM_TBT_tkeep : in std_logic_vector(7 downto 0); 
    S_AXIS_S2MM_TBT_tlast : in std_logic;  
    S_AXIS_S2MM_TBT_tready : out std_logic; 
    S_AXIS_S2MM_TBT_tvalid : in std_logic;
    S_AXIS_S2MM_FA_tdata : in std_logic_vector(63 downto 0); 
    S_AXIS_S2MM_FA_tkeep : in std_logic_vector(7 downto 0); 
    S_AXIS_S2MM_FA_tlast : in std_logic;  
    S_AXIS_S2MM_FA_tready : out std_logic; 
    S_AXIS_S2MM_FA_tvalid : in std_logic                   
  );
  end component system;





	


end acmi_package;
  
