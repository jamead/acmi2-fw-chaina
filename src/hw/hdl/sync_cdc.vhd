-------------------------------------------------------------------------------
-- 3-stage synchronizer with rising-edge detection
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity sync_cdc is
  port (
    clk   : in  std_logic;
    reset : in  std_logic;
    din   : in  std_logic;   -- async input
    dout  : out std_logic;   -- synchronized signal
    rise  : out std_logic    -- single-cycle pulse on rising edge
  );
end entity;

architecture behv of sync_cdc is
  signal sr : std_logic_vector(2 downto 0);
begin
  process (clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        sr <= (others => '0');
      else
        sr(0) <= din;
        sr(1) <= sr(0);
        sr(2) <= sr(1);
      end if;
    end if;
  end process;

  -- outputs
  dout <= sr(2);
  rise <= '1' when (sr(2) = '0' and sr(1) = '1') else '0';

end architecture;

