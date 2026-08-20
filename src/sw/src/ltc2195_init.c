/********************************************************************
*  Mem-Map
*  8-17-2016
*  Tony Caracappa
*  This program reads the shared memory space
********************************************************************/
#include "xil_printf.h"
#include <sleep.h>
#include "pl_regs.h"
#include "xparameters.h"



void ltc2195_init()
{

   s32 i, regAddr, regVal, rdbk;
   s16 cha, chb, chc, chd;

   xil_printf("Programming LTC2195 (ADC)...    ");

   //Initialize SPI registers on LTC2195
   // SPI port on LTC2195 mapped to register ADC_SPI_REG
   //set 2's complement
   regAddr = 1;
   regVal = 0x20;
   xil_printf("Setting SPI Register\r\n");
   xil_printf("SPI Write Reg 1 to 0x20\r\n");
   Xil_Out32(XPAR_M_AXI_BASEADDR + ADC_SPI_REG, regAddr<<8 | regVal);
   usleep(1000);
   //read back from adc0
   Xil_Out32(XPAR_M_AXI_BASEADDR + ADC_SPI_REG, 0x8000 | regAddr<<8 | regVal);
   usleep(1000);
   rdbk = Xil_In32(XPAR_M_AXI_BASEADDR + ADC_SPI_REG);
   usleep(1000);
   xil_printf("SPI Read Back ADC0 Reg 1  = %x\r\n",rdbk);
   //read back from adc1
   Xil_Out32(XPAR_M_AXI_BASEADDR + ADC_SPI_REG, 0x10000 | 0x8000 | regAddr<<8 | regVal);
   usleep(1000);
   rdbk = Xil_In32(XPAR_M_AXI_BASEADDR + ADC_SPI_REG);
   xil_printf("SPI Read Back ADC1 Reg 1  = %x\r\n",rdbk);


   //set test pattern
   regAddr = 3;
   regVal = 0x01;
   Xil_Out32(XPAR_M_AXI_BASEADDR + ADC_SPI_REG, regAddr<<8 | regVal);
   usleep(1000);
   //read back
   Xil_Out32(XPAR_M_AXI_BASEADDR + ADC_SPI_REG, 0x8000 | regAddr<<8 | regVal);
   usleep(1000);
   rdbk = Xil_In32(XPAR_M_AXI_BASEADDR + ADC_SPI_REG);
   xil_printf("SPI Write Reg 3 to 0x55\r\n");
   xil_printf("SPI Read Back Reg 3  = %x\r\n",rdbk);

   //set test pattern
   regAddr = 4;
   regVal = 0x00;
   xil_printf("SPI Write Reg 4 to 0x55\r\n");
   Xil_Out32(XPAR_M_AXI_BASEADDR + ADC_SPI_REG, regAddr<<8 | regVal);
   usleep(1000);
   //read back
   Xil_Out32(XPAR_M_AXI_BASEADDR + ADC_SPI_REG, 0x8000 | regAddr<<8 | regVal);
   usleep(1000);
   rdbk = Xil_In32(XPAR_M_AXI_BASEADDR + ADC_SPI_REG);
   usleep(1000);
   xil_printf("SPI Read Back ADC0 Reg 4  = %x\r\n",rdbk);
   Xil_Out32(XPAR_M_AXI_BASEADDR + ADC_SPI_REG, 0x10000 | 0x8000 | regAddr<<8 | regVal);
   usleep(1000);
   rdbk = Xil_In32(XPAR_M_AXI_BASEADDR + ADC_SPI_REG);
   xil_printf("SPI Read Back ADC0 Reg 4  = %x\r\n",rdbk);





   //set 4 lane output
   regAddr = 2;
   regVal = 1;  //set to 1 for normal, set to 5 for test pattern
   Xil_Out32(XPAR_M_AXI_BASEADDR + ADC_SPI_REG, regAddr<<8 | regVal);
   //fpgabase[ADC_SPI_REG] = regAddr<<8 | regVal;
   usleep(1000);

   //set idly value for sdata bits
   Xil_Out32(XPAR_M_AXI_BASEADDR + ADC_IDLYWVAL_REG, 300);
   //strobe the idly value into all 16 idly registers
   Xil_Out32(XPAR_M_AXI_BASEADDR + ADC_IDLYSTR_REG, 0xFFFF);
   Xil_Out32(XPAR_M_AXI_BASEADDR + ADC_IDLYSTR_REG, 0);








   //read and print 20 ADC samples
   for (i=0;i<20;i++) {
	  cha = (s16) Xil_In16(XPAR_M_AXI_BASEADDR + ADC_RAWCHA_REG);
	  chb = (s16) Xil_In16(XPAR_M_AXI_BASEADDR + ADC_RAWCHB_REG);
	  chc = (s16) Xil_In16(XPAR_M_AXI_BASEADDR + ADC_RAWCHC_REG);
	  chd = (s16) Xil_In16(XPAR_M_AXI_BASEADDR + ADC_RAWCHD_REG);

      xil_printf("%d\t%d\t%d\t%d\r\n",cha,chb,chc,chd);
      usleep(100000);
   }

   //for (i=0;i<10;i++) {
   //   xil_printf("%d\t%d\t%d\t%d\r\n",fpgabase[SA_CHA_REG],fpgabase[SA_CHB_REG],
   // 		                          fpgabase[SA_CHC_REG],fpgabase[SA_CHD_REG]);
   //   usleep(100000);
   //}


   xil_printf("Programming Complete\r\n");

   return;

}
