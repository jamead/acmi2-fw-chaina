library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_ts_gen is
end entity;

architecture sim of tb_ts_gen is

    -- DUT (Device Under Test) component declaration
    component ts_gen is
        port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            start    : in  std_logic; 
            din      : in  std_logic_vector(31 downto 0);
            dout     : out std_logic_vector(7 downto 0);
            dout_val : out std_logic
        );
    end component;

    -- Testbench signals
    signal clk_tb      : std_logic := '0';
    signal rst_tb      : std_logic := '0';
    signal start_tb    : std_logic := '0';
    signal din_tb      : std_logic_vector(31 downto 0) := (others => '0');
    signal dout_tb     : std_logic_vector(7 downto 0);
    signal dout_val_tb : std_logic;

    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate the DUT
    uut: ts_gen
        port map (
            clk      => clk_tb,
            rst      => rst_tb,
            start    => start_tb,
            din      => din_tb,
            dout     => dout_tb,
            dout_val => dout_val_tb
        );

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk_tb <= '0';
            wait for CLK_PERIOD / 2;
            clk_tb <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc : process
    begin
        -- Initialize
        rst_tb <= '1';
        wait for 50 ns;
        rst_tb <= '0';
        wait for 50 ns;

        -- Set input data pattern
        -- For example, 0xAAAAAAAA (alternating bits)
        din_tb <= x"00000001";  
        wait for 20 ns;

        -- Start pulse
        start_tb <= '1';
        wait for CLK_PERIOD;
        start_tb <= '0';

        -- Wait while state machine runs
        wait for 5000 ns;

        -- Change input pattern
        din_tb <= x"12345678";
        wait for 50 ns;

        -- Trigger again
        start_tb <= '1';
        wait for CLK_PERIOD;
        start_tb <= '0';

        wait for 5000 ns;

        -- Stop simulation
        wait;
    end process;

    -- Monitor output
    monitor : process(clk_tb)
    begin
        if rising_edge(clk_tb) then
            if dout_val_tb = '1' then
                report "Output valid: dout = " & to_hstring(dout_tb);
            end if;
        end if;
    end process;

end architecture;

