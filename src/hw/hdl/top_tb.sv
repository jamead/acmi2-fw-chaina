`timescale 1ns / 1ps
`define ZYNQ_VIP top_tb.dut.system_i.zynq_ultra_ps_e_0.inst

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2024 08:26:29 AM
// Design Name: 
// Module Name: top_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_tb; 

    reg tb_ACLK; 
    reg tb_ARESETn; 
    wire temp_clk; 
    wire temp_rstn;  
    reg [31:0] read_data; 
    wire [7:0] leds; 
    reg resp; 
    //reg [1:0] adc_fco_p;
    //reg [1:0] adc_fco_n;

    wire [1:0] adc_csb;
    wire [1:0] adc_sdi;
    reg [1:0] adc_sdo;
    wire [1:0] adc_sclk;   
    reg [1:0] adc_fco_p;
    reg [1:0] adc_fco_n; 
    reg [1:0] adc_dco_p;
    reg [1:0] adc_dco_n;   
    reg [15:0] adc_sdata_p;
    reg [15:0] adc_sdata_n;    

    reg adc_clk_p;
    reg adc_clk_n;

    reg tbt_clk_p;
    reg tbt_clk_n;

    wire ad9510_sclk;
    wire ad9510_sdata;
    wire ad9510_lat;
    wire ad9510_func;
    reg ad9510_status;
    reg ad9510_sdo;

    wire dsa_clk;
    wire dsa_sdata;
    wire dsa_latch;

    wire therm_sclk;
    reg therm_sdo;
    wire therm_sdi;
    wire [2:0] therm_csn;
    wire therm_rstn;

    wire [1:0] heatdac_syncn;
    wire [1:0] heatdac_sclk;  
    wire [1:0] heatdac_sdin;
    reg [1:0] heatdac_sdo; 
    wire [1:0] heatdac_ldacn;

    wire heatdac_clrn;  
    wire heatdac_bin2s;             

    wire afe_pwrenb;
    reg afe_pwrflt;

    reg gth_evr_refclk_p;
    reg gth_evr_refclk_n;
    wire gth_evr_tx_p;
    wire gth_evr_tx_n;
    reg gth_evr_rx_p;
    reg gth_evr_rx_n;   

    wire afe_sw_rffe_p;
    wire afe_sw_rffe_n; 
    
    wire [11:0] sfp_led;
    reg [5:0] sfp_rxlos;

    reg [3:0] fp_in;
    wire [3:0] fp_out;
    wire [7:0] fp_led;
    wire [19:0] dbg;







    initial  
    begin        
        tb_ACLK = 1'b0; 
        adc_fco_p = 2'b0;
        adc_fco_n = 2'b11;
    end 

     

    //------------------------------------------------------------------------ 
    // Simple Clock Generator 
    //------------------------------------------------------------------------ 
    always #10 tb_ACLK = !tb_ACLK; 
    
    // ADC clock
    always #8 adc_fco_p = !adc_fco_p;
    always #8 adc_fco_n = !adc_fco_n;

        

    initial 
    begin 

        $display ("running the tb"); 
        tb_ARESETn = 1'b0; 
        repeat(20)@(posedge tb_ACLK);         
        tb_ARESETn = 1'b1; 
        @(posedge tb_ACLK); 
        repeat(5) @(posedge tb_ACLK); 

           
  	    `ZYNQ_VIP.por_srstb_reset(1'b1); 
        #200; 
        `ZYNQ_VIP.por_srstb_reset(1'b0); 
        `ZYNQ_VIP.fpga_soft_reset(32'h1); 
        #2000 ;  // This delay depends on your clock frequency. It should be at least 16 clock cycles.  
        `ZYNQ_VIP.por_srstb_reset(1'b1); 
        `ZYNQ_VIP.fpga_soft_reset(32'h0); 
        #2000 ; 


        //Write the adc dly value
        `ZYNQ_VIP.write_data(32'hA0000020,4, 32'h1, resp);      
        #2000
        `ZYNQ_VIP.write_data(32'hA0000020,4, 32'h2, resp);    
        #2000
        `ZYNQ_VIP.write_data(32'hA0000020,4, 32'h3, resp);             
        #2000

        //Write the adc dly strobe
        `ZYNQ_VIP.write_data(32'hA0000024,4, 32'h0, resp);      
        #2000
        `ZYNQ_VIP.write_data(32'hA0000024,4, 32'h1, resp);    
        #2000
        `ZYNQ_VIP.write_data(32'hA0000024,4, 32'h0, resp);             
 
        //This drives the LEDs on the GPIO output 
       `ZYNQ_VIP.write_data(32'hA0000140,4, 32'h55, resp); 
        `ZYNQ_VIP.read_data(32'hA0000140,4, read_data, resp); 
        $display ("LEDs are toggled, observe the waveform"); 

        //Write into the BRAM through GP0 and read back 
        //`ZYNQ_VIP.write_data(32'hA0010000,4, 32'hDEADBEEF, resp); 
        //`ZYNQ_VIP.read_data(32'hA0010000,4,read_data,resp); 
        //$display ("%t, running the testbench, data read from BRAM was 32'h%x",$time, read_data); 

    if(read_data == 32'hDEADBEEF) begin 
           $display ("AXI VIP Test PASSED"); 
        end 
        else begin 
           $display ("AXI VIP Test FAILED"); 
        end 
        $display ("Simulation completed"); 
        $stop; 
    end 

  

    assign temp_clk = tb_ACLK; 
    assign temp_rstn = tb_ARESETn; 

 
//top dut (); 

// Set generics using defparam
defparam dut.FPGA_VERSION = 10;
defparam dut.SIM_MODE = 1;


top #(
    .FPGA_VERSION(10),  // Set FPGA_VERSION generic
    .SIM_MODE(1)        // Set SIM_MODE generic
)
dut (
    .adc_csb(adc_csb),
    .adc_sdi(adc_sdi),
    .adc_sdo(adc_sdo),
    .adc_sclk(adc_sclk),   
    .adc_fco_p(adc_fco_p),
    .adc_fco_n(adc_fco_n), 
    .adc_dco_p(adc_dco_p),
    .adc_dco_n(adc_dco_n),   
    .adc_sdata_p(adc_sdata_p),
    .adc_sdata_n(adc_sdata_n),    

    .adc_clk_p(adc_clk_p),
    .adc_clk_n(adc_clk_n),

    .tbt_clk_p(tbt_clk_p),
    .tbt_clk_n(tbt_clk_n),

    .ad9510_sclk(ad9510_sclk),
    .ad9510_sdata(ad9510_sdata),
    .ad9510_lat(ad9510_lat),
    .ad9510_func(ad9510_func),
    .ad9510_status(ad9510_status),
    .ad9510_sdo(ad9510_sdo),

    .dsa_clk(dsa_clk),
    .dsa_sdata(dsa_sdata),
    .dsa_latch(dsa_latch),

    .therm_sclk(therm_sclk),
    .therm_sdo(therm_sdo),
    .therm_sdi(therm_sdi),
    .therm_csn(therm_csn),
    .therm_rstn(therm_rstn),

    .heatdac_syncn(heatdac_syncn),
    .heatdac_sclk(heatdac_sclk),  
    .heatdac_sdin(heatdac_sdin),
    .heatdac_sdo(heatdac_sdo), 
    .heatdac_ldacn(heatdac_ldacn),

    .heatdac_clrn(heatdac_clrn),  
    .heatdac_bin2s(heatdac_bin2s),             

    .afe_pwrenb(afe_pwrenb),
    .afe_pwrflt(afe_pwrflt),

    .gth_evr_refclk_p(gth_evr_refclk_p),
    .gth_evr_refclk_n(gth_evr_refclk_n),
    .gth_evr_tx_p(gth_evr_tx_p),
    .gth_evr_tx_n(gth_evr_tx_n),
    .gth_evr_rx_p(gth_evr_rx_p),
    .gth_evr_rx_n(gth_evr_rx_n),   

    .afe_sw_rffe_p(afe_sw_rffe_p),
    .afe_sw_rffe_n(afe_sw_rffe_n), 
    
    .sfp_led(sfp_led),
    .sfp_rxlos(sfp_rxlos),

    .fp_in(fp_in),
    .fp_out(fp_out),
    .fp_led(fp_led),
    .dbg(dbg)
);


   

  

  

endmodule 