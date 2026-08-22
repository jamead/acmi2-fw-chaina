
library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


package acmi_package is


type sfp_i2c_data_type is array(0 to 5) of std_logic_vector(15 downto 0);

  

type t_reg_o_adc_cntrl is record
   spi_we     : std_logic;
   spi_wdata  : std_logic_vector(31 downto 0);
   idly_wval  : std_logic_vector(8 downto 0);
   idly_wstr  : std_logic_vector(15 downto 0);
   fco_dlystr : std_logic_vector(1 downto 0);
end record t_reg_o_adc_cntrl;

type t_reg_i_adc_status is record
   spi_rdata  : std_logic_vector(31 downto 0);
   idly_rval  : std_logic_vector(8 downto 0);
end record t_reg_i_adc_status;



type t_reg_i_adc_fifo_rdout is record
   fifo_dout     : std_logic_vector(31 downto 0);
   fifo_rdcnt    : std_logic_vector(31 downto 0); 
end record t_reg_i_adc_fifo_rdout;

type t_reg_o_adc_fifo_rdout is record
   fifo_enb      : std_logic;
   fifo_rst      : std_logic;
   fifo_rdstr    : std_logic;
end record t_reg_o_adc_fifo_rdout;



type t_reg_o_evr is record
   reset         : std_logic;
   dma_trigno    : std_logic_vector(7 downto 0);
   event_src_sel : std_logic;
end record t_reg_o_evr;

type t_reg_i_evr is record
   ts_ns      : std_logic_vector(31 downto 0);
   ts_s       : std_logic_vector(31 downto 0);
end record t_reg_i_evr;



type brd_temps_type is record
   temp0 : std_logic_vector(15 downto 0);
   temp1 : std_logic_vector(15 downto 0);
   temp2 : std_logic_vector(15 downto 0);
   temp3 : std_logic_vector(15 downto 0);
end record brd_temps_type;




type t_reg_i_trig is record
    trig_cnt     : std_logic_vector(31 downto 0); 
    status       : std_logic_vector(4 downto 0);
    ts_s         : std_logic_vector(31 downto 0);
    ts_ns        : std_logic_vector(31 downto 0);
end record t_reg_i_trig;



type t_reg_i_pulse_stats is record
    baseline     : std_logic_vector(15 downto 0);
    integral     : std_logic_vector(31 downto 0);
    peak         : std_logic_vector(16 downto 0);
    peak_index   : std_logic_vector(31 downto 0);
    peak_found   : std_logic;
    threshold    : std_logic_vector(15 downto 0);
    fwhm         : std_logic_vector(15 downto 0);
end record t_reg_i_pulse_stats;

type t_reg_i_pulse_stats_array is array(0 to 4) of t_reg_i_pulse_stats;




type t_reg_o_eeprom is record

    header                   : std_logic_vector(31 downto 0);

    tp1_pulse_delay          : std_logic_vector(31 downto 0);
    tp1_pulse_width          : std_logic_vector(31 downto 0);
    tp1_adc_delay            : std_logic_vector(31 downto 0);

    tp2_pulse_delay          : std_logic_vector(31 downto 0);
    tp2_pulse_width          : std_logic_vector(31 downto 0);
    tp2_adc_delay            : std_logic_vector(31 downto 0);

    tp3_pulse_delay          : std_logic_vector(31 downto 0);
    tp3_pulse_width          : std_logic_vector(31 downto 0);
    tp3_adc_delay            : std_logic_vector(31 downto 0);

    beam_adc_delay           : std_logic_vector(31 downto 0);
    beam_oow_threshold       : std_logic_vector(31 downto 0);

    tp1_int_low_limit        : std_logic_vector(31 downto 0);
    tp1_int_high_limit       : std_logic_vector(31 downto 0);
    tp2_int_low_limit        : std_logic_vector(31 downto 0);
    tp2_int_high_limit       : std_logic_vector(31 downto 0);
    tp3_int_low_limit        : std_logic_vector(31 downto 0);
    tp3_int_high_limit       : std_logic_vector(31 downto 0);

    tp1_peak_low_limit       : std_logic_vector(31 downto 0);
    tp1_peak_high_limit      : std_logic_vector(31 downto 0);
    tp2_peak_low_limit       : std_logic_vector(31 downto 0);
    tp2_peak_high_limit      : std_logic_vector(31 downto 0);
    tp3_peak_low_limit       : std_logic_vector(31 downto 0);
    tp3_peak_high_limit      : std_logic_vector(31 downto 0);

    tp1_fwhm_low_limit       : std_logic_vector(31 downto 0);
    tp1_fwhm_high_limit      : std_logic_vector(31 downto 0);
    tp2_fwhm_low_limit       : std_logic_vector(31 downto 0);
    tp2_fwhm_high_limit      : std_logic_vector(31 downto 0);
    tp3_fwhm_low_limit       : std_logic_vector(31 downto 0);
    tp3_fwhm_high_limit      : std_logic_vector(31 downto 0);

    tp1_base_low_limit       : std_logic_vector(31 downto 0);
    tp1_base_high_limit      : std_logic_vector(31 downto 0);
    tp2_base_low_limit       : std_logic_vector(31 downto 0);
    tp2_base_high_limit      : std_logic_vector(31 downto 0);
    tp3_base_low_limit       : std_logic_vector(31 downto 0);
    tp3_base_high_limit      : std_logic_vector(31 downto 0);

    tp1_pos_level            : std_logic_vector(31 downto 0);
    tp2_pos_level            : std_logic_vector(31 downto 0);
    tp3_pos_level            : std_logic_vector(31 downto 0);

    tp1_neg_level            : std_logic_vector(31 downto 0);
    tp2_neg_level            : std_logic_vector(31 downto 0);
    tp3_neg_level            : std_logic_vector(31 downto 0);

    beamaccum_limit_hr       : std_logic_vector(31 downto 0);
    beamhigh_limit           : std_logic_vector(31 downto 0);

    baseline_low_limit       : std_logic_vector(31 downto 0);
    baseline_high_limit      : std_logic_vector(31 downto 0);

    charge_calibration       : std_logic_vector(31 downto 0);
    accum_q_min              : std_logic_vector(31 downto 0);
    accum_length             : std_logic_vector(31 downto 0);

    crc32_eeprom             : std_logic_vector(31 downto 0);

    -- Internal calculated value, not stored in EEPROM
    crc32_calc               : std_logic_vector(31 downto 0);

end record t_reg_o_eeprom;









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
    m_axi_rready : out STD_LOGIC               
  );
  end component system;





	


end acmi_package;
  
