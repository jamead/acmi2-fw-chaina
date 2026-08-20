/********************************************************************
*  Mem-Map
*  8-17-2016
*  Tony Caracappa
*  This program reads the shared memory space
********************************************************************/
#include "xil_printf.h"
#include "sleep.h"
#include "pl_regs.h"



void prog_ad9510()
{



   xil_printf("Programming AD9510...\r\n");

   //Register 0x00: Serial Port Configuration, Data: 0x10 (Default)
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x0010);
   usleep(5000);

   //Register 0x58: Function Pin and Sync, Data: 0x00 (Default)
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x5800);
   usleep(5000);

   //Register 0x45: Clock Select and PD options, Data: 0x00 (Default=0x01)
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x4500);
   usleep(5000);

   //Register 0x3C: LVPECL OUT0, Data: 0x08 (Default=0x0A)
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x3c08);
   usleep(5000);

   //Register 0x4B: Divider 1, Data: 0x80 (Default=0x00)
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x4b80);
   usleep(5000);

   //Register 0x3D: LVPECL OUT1, Data: 0x08 (Default)
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x3d08);
   usleep(5000);

   //Register 0x49: Divider 0, Data: 0x80 (Default=0x00)
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x4980);
   usleep(5000);

   //Register 0x3E: LVPECL OUT2, Data: 0x08 (Default)
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x3e08);
   usleep(5000);

   //Register 0x4D: Divider 0, Data: 0x80 (Default=0x00)
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x4d80);
   usleep(5000);

   //Register 0x3F: LVPECL OUT3, Data: 0x08 (Default)
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x3f08);
   usleep(5000);

   //Register 0x4D: Divider 0, Data: 0x80 (Default=0x00)
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x4f80);
   usleep(5000);

   //Register 0x40: LVDS_CMOS OUT4, Data: 0x02 (Default)
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x4002);
   usleep(5000);

   //Register 0x51: Divider 4, Data: 0x80 (Default=0x00)
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x5180);
   usleep(5000);

   //Register 0x41: LVDS_CMOS OUT5, Data: 0x02 (Default)
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x4102);
   usleep(5000);

   //Register 0x53: Divider 5, Data: 0x80 (Default=0x00)
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x5380);
   usleep(5000);

   //Register 0x42: LVDS_CMOS OUT6, Data: 0x02 (Default=0x03)
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x4202);
   usleep(5000);

   //Register 0x55: Divider 6, Data: 0x80 (Default=0x00)
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x5580);
   usleep(5000);

   //Register 0x38: Delay Bypass 6, Data: 0x00 (Default=0x01)
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x3800);
   usleep(5000);

   //Register 0x39: Delay Full Scale 6, Data: 0x1b (Default=0x00)
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x391b);  //0x3900
   usleep(5000);

   //Register 0x3A: Delay Fine Adj 6, Data: 0x0A (Default=0x00)
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x3a0a);
   usleep(5000);

   //Register 0x43: LVDS_CMOS OUT7, Data: 0x02 (Default=0x03)
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x4302);
   usleep(5000);

   //Register 0x57: Divider 7, Data: 0x80 (Default=0x00)
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x5780);
   usleep(5000);

   //Register 0x04: A Counter, Data: 0x00 (Default)
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x0400);
   usleep(5000);

   //Register 0x05: B Counter (MSB), Data: 0x01 (Default=0x00)
   //N(B) = 310 (0x136)  -> for 378.545KHz Input
   //N(B) = 31    -> for 124.92MHz Input
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x0501);
   //Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x0500);
   usleep(5000);

   //Register 0x06: B Counter (LSB), Data: 0x36 (Default=0x00)
   //N(B) = 310 (0x136)   -> for 378.545KHz Input
   //N(B) = 31 (0x1F)  -> for 124.92MHz Input
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x0636);
   //Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x061F);
   usleep(5000);

   //Register 0x08: PLL 2, Data: 0x77 (Default=0x00)
   //CP Mode = 3, PLL mux Sel = 5, Polarity = 1
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x0877);
   usleep(5000);

   //Register 0x09: PLL 3, Data: 0x30 (Default=0x00)
   //CP Current = 3
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x0930);    //0x0900
   usleep(5000);

   //Register 0x0A: PLL 4, Data: 0x02 (Default=0x01)
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x0a02);
   usleep(5000);

   //Register 0x0B: R Divider (MSB), Data: 0x00 (Default)
   //R = 0   -> for 378.545KHz Input
   //R = 1 (0x21) -> for 124.92Mhz Input
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x0b00);
   //Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x0b01);
   usleep(5000);

   //Register 0x0C: R Divider (LSB), Data: 0x01 (Default=0x00)
   //R = 1   -> for 378.545KHz Input
   //R = 33 (0x4A) -> for 124.92Mhz Input
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x0c01);
   //Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x0c4A);

   usleep(5000);

   //Register 0x0D: PLL 5, Data: 0x00 (Default)
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x0d00);
   usleep(5000);

   //Register 0x5A: Update Registers, Data: 0x01 (Default=0x00)
   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x5a01);
   usleep(5000);
   xil_printf("Programming Complete\r\n");

   return;

}
