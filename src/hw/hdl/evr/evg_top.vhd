

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VComponents.all;

library xil_defaultlib;
use xil_defaultlib.acmi_package.ALL;



entity evg_top is
  port (
  sys_clk        : in std_logic;
  evg_clk        : in std_logic;
  sys_rst        : in std_logic;
  gth_txdata     : out std_logic_vector(15 downto 0);
  gth_txcharisk  : out std_logic_vector(7 downto 0)
);  
end evg_top;

architecture behv of evg_top is




  signal cnt_1hz      : unsigned(31 downto 0) := (others => '0');
  signal sig_1hz      : std_logic := '0';
  signal sig_1hz_sync : std_logic;
  signal epoch_time   : unsigned(31 downto 0);
  signal txcnt        : unsigned(15 downto 0);
  
  signal ts_code      : std_logic_vector(7 downto 0);
  signal ts_code_val  : std_logic;

  

  attribute mark_debug     : string;
  attribute mark_debug of gth_txdata: signal is "true";  
  attribute mark_debug of gth_txcharisk: signal is "true";
  attribute mark_debug of ts_code: signal is "true";
  attribute mark_debug of ts_code_val: signal is "true"; 
  attribute mark_debug of cnt_1hz: signal is "true";
  attribute mark_debug of epoch_time: signal is "true";
  attribute mark_debug of sig_1hz: signal is "true";
  attribute mark_debug of sig_1hz_sync: signal is "true";





begin 



             
-- tx event codes (1Hz + timestamp)
process (evg_clk)
begin
  if (rising_edge(evg_clk)) then
    if (sys_rst = '1') then
      gth_txdata <= x"50BC";
      gth_txcharisk <= x"01";
    else
      if (ts_code_val = '1') then
        gth_txdata <= x"00" & ts_code;
        gth_txcharisk <= x"00";
      else
        gth_txdata <= x"50BC";
        gth_txcharisk <= x"01";
      end if;
    end if;
  end if;
end process;




--generate process to output a 0x70 code when epoch-time bit is 1 and 0x71 when epoch time is 0
timestamp: entity work.ts_gen
  port map (
    clk => evg_clk, 
    rst => sys_rst, 
    start => sig_1hz_sync,  
    din => std_logic_vector(epoch_time), 
    dout => ts_code,     
    dout_val => ts_code_val
    );



evr_sync_inst: entity work.sync_cdc
  port map (
    clk   => evg_clk,
    reset => sys_rst,
    din   => sig_1hz,
    dout  => open,        
    rise  => sig_1hz_sync   
  );





-- generate 1 Hz signal for updating timestamp
process(sys_clk)
  begin
    if rising_edge(sys_clk) then
      if sys_rst = '1' then
        cnt_1hz <= (others => '0');
        sig_1hz  <= '0';
        epoch_time <= to_unsigned(1761037205,32);
      else
        if cnt_1hz = to_unsigned(50000000 - 1, 32) then
          if sig_1hz = '0' then
             epoch_time <= epoch_time + 1;
          end if;
          cnt_1hz <= (others => '0');
          sig_1hz  <= not sig_1hz;  -- toggle every 0.5 s
        else
          cnt_1hz <= cnt_1hz + 1;
        end if;
      end if;
    end if;
end process;




end behv;
