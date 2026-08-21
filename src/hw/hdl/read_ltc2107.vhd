library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use ieee.std_logic_textio.all;
use std.textio.all;

library UNISIM;
use UNISIM.VComponents.all;


entity read_ltc2107 is
  generic (
    SIM_MODE : integer := 0
  );
  port (
    adc_clk_p   : in  std_logic;
    adc_clk_n   : in  std_logic;

    reset       : in  std_logic;
    trig        : in  std_logic;

    adc_data_p  : in  std_logic_vector(7 downto 0);
    adc_data_n  : in  std_logic_vector(7 downto 0);

    adc_of_p    : in  std_logic;
    adc_of_n    : in  std_logic;

    adc_clk     : out std_logic;
    adc_data    : out std_logic_vector(15 downto 0);
    adc_sat     : out std_logic
  );
end read_ltc2107;


architecture behv of read_ltc2107 is

  --------------------------------------------------------------------------
  -- ADC input signals
  --------------------------------------------------------------------------

  signal adc_data_in : std_logic_vector(7 downto 0);
  signal adc_data_i  : std_logic_vector(15 downto 0);

  signal adc_clk_raw : std_logic;
  signal adc_clk_int : std_logic;

  signal adc_of      : std_logic;


  --------------------------------------------------------------------------
  -- MMCM signals
  --------------------------------------------------------------------------

  signal mmcm_clk    : std_logic;
  signal mmcm_fb     : std_logic;
  signal mmcm_fb_buf : std_logic;
  signal mmcm_locked : std_logic;


  --------------------------------------------------------------------------
  -- Simulation
  --------------------------------------------------------------------------

  signal sample_cnt : integer := 0;


  --------------------------------------------------------------------------
  -- Debug
  --------------------------------------------------------------------------

  attribute mark_debug : string;
  attribute mark_debug of adc_data : signal is "true";


begin


  --------------------------------------------------------------------------
  -- Outputs
  --------------------------------------------------------------------------

  adc_clk <= adc_clk_int;

  -- Preserve behavior of original design.
  adc_sat <= adc_of;


  --------------------------------------------------------------------------
  -- ADC differential clock input
  --------------------------------------------------------------------------

  adc_clk_inst : IBUFDS
    port map (
      O  => adc_clk_raw,
      I  => adc_clk_p,
      IB => adc_clk_n
    );


  --------------------------------------------------------------------------
  -- ADC differential data inputs
  --------------------------------------------------------------------------

  gen_adcdata : for i in 0 to 7 generate
  begin

    adc_data_inst : IBUFDS
      port map (
        O  => adc_data_in(i),
        I  => adc_data_p(i),
        IB => adc_data_n(i)
      );

  end generate;


  --------------------------------------------------------------------------
  -- ADC overflow input
  --------------------------------------------------------------------------

  adc_of_inst : IBUFDS
    port map (
      O  => adc_of,
      I  => adc_of_p,
      IB => adc_of_n
    );


  --==========================================================================
  -- HARDWARE
  --==========================================================================

  gen_hw : if SIM_MODE = 0 generate


    ------------------------------------------------------------------------
    -- MMCM
    --
    -- LTC2107 CLKOUT = 200 MHz
    --
    -- LTC2107 DDR data changes on both edges of CLKOUT.
    --
    -- Shift the capture clock by +90 degrees:
    --
    --      200 MHz period = 5.000 ns
    --
    --      5.000 ns / 4 = 1.250 ns
    --
    -- This places the capture edge approximately in the center
    -- of the DDR data eye.
    --
    -- MMCM:
    --
    --      Fvco = 200 MHz * 5 = 1000 MHz
    --
    --      Fout = 1000 MHz / 5 = 200 MHz
    --
    ------------------------------------------------------------------------

    adc_mmcm : MMCME4_BASE
      generic map (

        BANDWIDTH => "OPTIMIZED",

        CLKFBOUT_MULT_F => 5.0,
        CLKFBOUT_PHASE  => 0.0,

        CLKIN1_PERIOD => 5.000,

        CLKOUT0_DIVIDE_F   => 5.0,
        CLKOUT0_DUTY_CYCLE => 0.5,
        CLKOUT0_PHASE      => 270.0,

        CLKOUT1_DIVIDE     => 1,
        CLKOUT1_DUTY_CYCLE => 0.5,
        CLKOUT1_PHASE      => 0.0,

        CLKOUT2_DIVIDE     => 1,
        CLKOUT2_DUTY_CYCLE => 0.5,
        CLKOUT2_PHASE      => 0.0,

        CLKOUT3_DIVIDE     => 1,
        CLKOUT3_DUTY_CYCLE => 0.5,
        CLKOUT3_PHASE      => 0.0,

        CLKOUT4_CASCADE    => "FALSE",
        CLKOUT4_DIVIDE     => 1,
        CLKOUT4_DUTY_CYCLE => 0.5,
        CLKOUT4_PHASE      => 0.0,

        CLKOUT5_DIVIDE     => 1,
        CLKOUT5_DUTY_CYCLE => 0.5,
        CLKOUT5_PHASE      => 0.0,

        CLKOUT6_DIVIDE     => 1,
        CLKOUT6_DUTY_CYCLE => 0.5,
        CLKOUT6_PHASE      => 0.0,

        DIVCLK_DIVIDE => 1,

        IS_CLKFBIN_INVERTED => '0',
        IS_CLKIN1_INVERTED  => '0',
        IS_PWRDWN_INVERTED  => '0',
        IS_RST_INVERTED     => '0',

        REF_JITTER1 => 0.010,
        STARTUP_WAIT => "FALSE"

      )
      port map (

        CLKFBOUT  => mmcm_fb,
        CLKFBOUTB => open,

        CLKOUT0  => mmcm_clk,
        CLKOUT0B => open,

        CLKOUT1  => open,
        CLKOUT1B => open,

        CLKOUT2  => open,
        CLKOUT2B => open,

        CLKOUT3  => open,
        CLKOUT3B => open,

        CLKOUT4 => open,
        CLKOUT5 => open,
        CLKOUT6 => open,

        LOCKED => mmcm_locked,

        CLKFBIN => mmcm_fb_buf,
        CLKIN1  => adc_clk_raw,

        PWRDWN => '0',
        RST    => reset
      );


    ------------------------------------------------------------------------
    -- MMCM feedback clock buffer
    ------------------------------------------------------------------------

    mmcm_fb_bufg : BUFG
      port map (
        I => mmcm_fb,
        O => mmcm_fb_buf
      );


    ------------------------------------------------------------------------
    -- ADC capture clock global buffer
    --
    -- 200 MHz, +90 degrees from the LTC2107 CLKOUT
    ------------------------------------------------------------------------

    adc_clk_bufg : BUFG
      port map (
        I => mmcm_clk,
        O => adc_clk_int
      );


    ------------------------------------------------------------------------
    -- DDR input registers
    --
    -- LTC2107:
    --
    --   CLKOUT+ HIGH -> odd bits
    --   CLKOUT+ LOW  -> even bits
    --
    -- After delaying the clock +90 degrees:
    --
    --   delayed rising edge  -> center of CLKOUT HIGH
    --                           -> odd ADC bit
    --
    --   delayed falling edge -> center of CLKOUT LOW
    --                           -> even ADC bit
    --
    -- IDDRE1:
    --
    --   Q1 = rising-edge sample
    --   Q2 = falling-edge sample
    --
    ------------------------------------------------------------------------

    gen_iddrs : for i in 0 to 7 generate
    begin

      adc_iddr : IDDRE1
        generic map (
          DDR_CLK_EDGE   => "SAME_EDGE_PIPELINED",
          IS_C_INVERTED  => '0',
          IS_CB_INVERTED => '1'
        )
        port map (

          -- Odd ADC bit
          --Q1 => adc_data_i(i*2 + 1),
          Q1 => adc_data_i(i*2),
          -- Even ADC bit
          --Q2 => adc_data_i(i*2),
          Q2 => adc_data_i(i*2 + 1),
          C  => adc_clk_int,

          -- Connect same clock to CB and invert it inside IDDRE1
          CB => adc_clk_int,

          D  => adc_data_in(i),

          R  => reset
        );

    end generate;


    ------------------------------------------------------------------------
    -- Output pipeline register
    --
    -- Preserved from original design.
    ------------------------------------------------------------------------

    lat_data : process(adc_clk_int)
    begin

      if rising_edge(adc_clk_int) then

        if reset = '1' or mmcm_locked = '0' then
          adc_data <= (others => '0');

        else
          adc_data <= adc_data_i;

        end if;

      end if;

    end process;


  end generate;


--==========================================================================
-- SIMULATION
--==========================================================================
gen_sim : if SIM_MODE = 1 generate


    ------------------------------------------------------------------------
    -- For simulation use ADC clock directly.
    ------------------------------------------------------------------------

    adc_clk_int <= adc_clk_raw;


    ------------------------------------------------------------------------
    -- Read simulated ADC values from file
    ------------------------------------------------------------------------

    read_adc_data : process(adc_clk_int)

      constant ADC_DATA_FILE : string :=
        "/home/mead/acmi/fwk/acmi-chaina/src/hw/sim/acmi_adc_data.txt";

      file adc_vector : text open read_mode is ADC_DATA_FILE;

      variable row     : line;
      variable adc_raw : integer;

    begin

      if rising_edge(adc_clk_int) then

        sample_cnt <= sample_cnt + 1;


        --------------------------------------------------------------
        -- Rewind file on trigger
        --------------------------------------------------------------

        if trig = '1' then

          file_close(adc_vector);

          file_open(
            adc_vector,
            ADC_DATA_FILE,
            read_mode
          );

          sample_cnt <= 0;

        end if;


        --------------------------------------------------------------
        -- ADC samples
        --------------------------------------------------------------

        if sample_cnt < 16000 then

          readline(adc_vector, row);
          read(row, adc_raw);

          adc_data <=
            x"8000" xor
            std_logic_vector(to_signed(adc_raw, 16));

        else

          adc_data <= x"8000";

        end if;

      end if;

    end process;


  end generate;


end behv;