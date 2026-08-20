library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VComponents.all;

entity ltc2107_spi is
  port (
   clk         : in  std_logic;                  
   reset  	   : in  std_logic;                     
   sclk        : out std_logic;                   
   din 	       : out std_logic;
   dout        : in  std_logic;
   sync        : out std_logic                 
  );    
end ltc2107_spi;

architecture behv of ltc2107_spi is

--read adc data
--component vio_spi
--  port  (
--    clk        : in std_logic;
--    probe_out0 : out std_logic_vector(7 downto 0); 
--    probe_out1 : out std_logic_vector(7 downto 0);
--    probe_out2 : out std_logic_vector(0 downto 0)
--);
--end component;





  type   state_type is (IDLE, CLKP1, CLKP2, SETSYNC); 
  signal state            : state_type  := idle;                                                                             
  signal treg             : std_logic_vector(15 downto 0)  := 16d"0";                                                                                                                                    
  signal bcnt             : integer range 0 to 24 := 0;     
  signal rddata           : std_logic_vector(7 downto 0);     
                   
  signal clk_cnt            : std_logic_vector(7 downto 0) := 8d"0";    
  signal clk_enb            : std_logic  := '1';
  
  signal rreg               : std_logic_vector(7 downto 0) := 8d"0";
  
  signal prev_reset         : std_logic;
  
  signal spi_addr           : std_logic_vector(7 downto 0);
  signal spi_data           : std_logic_vector(7 downto 0);
  signal spi_trig           : std_logic_vector(0 downto 0);
  signal prev_spi_trig      : std_logic;
  
  
  attribute mark_debug                 : string;
  attribute mark_debug of spi_addr     : signal is "true";
  attribute mark_debug of spi_data     : signal is "true";  
  attribute mark_debug of spi_trig     : signal is "true";
  attribute mark_debug of prev_spi_trig: signal is "true";
  attribute mark_debug of state        : signal is "true";  
  attribute mark_debug of sclk         : signal is "true";   
  attribute mark_debug of din          : signal is "true"; 
  attribute mark_debug of dout         : signal is "true";
  attribute mark_debug of sync         : signal is "true"; 
  attribute mark_debug of rreg         : signal is "true"; 

 
  
begin  




--read adc data
--vio: vio_spi
--  port map (
--    clk => clk,
--    probe_out0 => spi_addr,
--    probe_out1 => spi_data,
--    probe_out2 => spi_trig
--);



-- spi transfer
process (clk, reset)
  begin  
    if (clk'event and clk = '1') then  
      if (clk_enb = '1') then
        case state is
          when IDLE =>  
            din   <= '0';   
            sclk  <= '0';
            sync  <= '1';
            prev_reset <= reset;
            prev_spi_trig <= spi_trig(0);
            if (prev_reset = '1') and (reset = '0') then
            --if (reset = '0') then
                sync <= '0';
                treg <= x"0301"; --x"0303";  --reset adc, see datasheet  
                bcnt <= 15;  
                state <= CLKP1;
            end if;
            if (prev_spi_trig = '0') and (spi_trig(0) = '1') then
              sync <= '0';
              treg <= spi_addr & spi_data;
              bcnt <= 15;
              state <= CLKP1;
            end if;
            

          when CLKP1 =>     -- CLKP1 clock phase LOW
			sclk  <= '0';
            state <= CLKP2;
			treg <= treg(14 downto 0) & '0';
            din <= treg(15);

          when CLKP2 =>     -- CLKP1 clock phase 2
            sclk <= '1';
            rreg <= rreg(6 downto 0) & dout;
            if (bcnt = 0) then			
               state <= SETSYNC;
            else
               bcnt <= bcnt - 1;
               state <= CLKP1;
		    end if;
 
          when SETSYNC => 
            rddata <= rreg;
            sclk <= '0';
            sync <= '1';
            state <= idle;
            
    
          when others =>
            state <= IDLE;
      end case;
    end if;
  end if;
end process;



-- generate 2MHz clock enable from 200MHz system clock
clkdivide : process(clk, reset)
  begin
    if (rising_edge(clk)) then
       if clk_cnt = 8d"100" then
         clk_cnt <= 8d"0";
         clk_enb <= '1';
       else
         clk_cnt <= clk_cnt + 1;
         clk_enb <= '0';
       end if; 
    end if;
end process; 




  
end behv;
