-- CDC Synchronizer 
--
--125 MHz domain                         200 MHz domain
--
-- din
--  |
--  v
--+-----+    +-----+    +-----+    +-----+
--| FF0 |--->| FF1 |--->| FF2 |--->| DLY |
--+-----+    +-----+    +-----+    +-----+
--   ^                    |
--   |                    +-----------> dout
-- possible
-- metastability
--
--                         FF2 & ~DLY
--                              |
--                              v
--                             rise
--                         1 clk wide






library ieee;
use ieee.std_logic_1164.all;

entity sync_cdc is
  port (
    clk   : in  std_logic;
    reset : in  std_logic;
    din   : in  std_logic;
    dout  : out std_logic;
    rise  : out std_logic
  );
end entity;

architecture behv of sync_cdc is

  signal sr        : std_logic_vector(2 downto 0);
  signal sync_dly  : std_logic;

  attribute ASYNC_REG : string;
  attribute ASYNC_REG of sr : signal is "TRUE";

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        sr       <= (others => '0');
        sync_dly <= '0';
      else

        -- 3-stage metastability synchronizer
        sr(0) <= din;
        sr(1) <= sr(0);
        sr(2) <= sr(1);

        -- Previous value of fully synchronized signal
        sync_dly <= sr(2);

      end if;
    end if;
  end process;

  dout <= sr(2);

  -- One 200 MHz clock pulse on rising edge
  rise <= sr(2) and not sync_dly;

end architecture;
