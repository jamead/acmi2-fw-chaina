library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ts_gen is
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        start    : in  std_logic; 
        din      : in  std_logic_vector(31 downto 0);
        dout     : out std_logic_vector(7 downto 0);
        dout_val : out std_logic
    );
end entity;


architecture behv of ts_gen is

    type byte_array is array (0 to 31) of std_logic_vector(7 downto 0);
    signal temp   : byte_array;
    type state_type is (IDLE, SEND_1HZ, PREPAUSE, ACTIVE, PAUSE, CHECK_IF_LAST, UPDATE);
    signal state  : state_type := IDLE;
    signal start_d : std_logic := '0';  -- for rising edge detection
    signal idx: integer range 0 to 31;
    
    signal start_prev : std_Logic;
    signal dlycnt : unsigned(7 downto 0);
    

begin

process(clk, rst)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        state <= IDLE;
        start_prev <= '0';
        dout <= 8d"0";
        dout_val <= '0';
        start_prev <= start;
      else
        case state is
          when IDLE =>      
            dout_val <= '0';
            dlycnt <= 8d"0";
            if start = '1'  then
              state <= send_1hz;
              idx <= 31;
            end if;
          
          when SEND_1HZ =>
             dout <= 8d"32";
             dout_val <= '1';
             state <= prepause;
             
          when PREPAUSE => 
            dout_val <= '0';
            dlycnt <= dlycnt + 1;
            if (dlycnt = 8d"10") then
              dlycnt <= 8d"0";
              state <= active;
            end if;
       
          when ACTIVE =>
            if din(idx) = '0' then
              dout <= x"70";
            else
              dout <= x"71";
            end if;
            dout_val <= '1';
            state <= pause;
          
          when PAUSE => 
            dout_val <= '0';
            dlycnt <= dlycnt + 1;
            if (dlycnt = 8d"10") then
              dlycnt <= 8d"0";
              state <= check_if_last;
            end if;
            
            
          when CHECK_IF_LAST =>
            dout_val <= '0';
            if idx = 0 then
              state <= UPDATE;  
            else
              idx <= idx - 1;
              state <= active;
            end if;

                
          when UPDATE =>
            dout <= x"7D"; 
            dout_val <= '1';
            state <= idle;
                   
          when OTHERS =>
            state <= idle;

      end case;
    end if;
  end if;  
end process;


end architecture;

