
#include <stdio.h>
#include <string.h>
#include <sleep.h>
#include "xil_cache.h"

#include "lwip/sockets.h"
#include "netif/xadapter.h"
#include "lwipopts.h"
#include "xil_printf.h"
#include "FreeRTOS.h"
#include "task.h"

/* Hardware support includes */
#include "zubpm.h"
#include "pl_regs.h"
#include "psc_msg.h"










void set_eventno(u32 msgVal) {
	Xil_Out32(XPAR_M_AXI_BASEADDR + TRIG_EVENTNO_REG, msgVal);
}

void write_adc_table(void *msg, u32 msglen)
{

	u32 spi_addr, spi_data;
	u32 *msgptr = (u32 *)msg;
	u32 i,table_len;

	table_len = msglen / 4;
    xil_printf("Writing ADC Table: %d words\r\n",msglen);
	if (table_len > 16000) {
		xil_printf("Max Table is 16,000 samples\r\n");
		return;
	}

	//for (i=0;i<table_len;i++) {
    /*
	for (i=0;i<100;i++) {
      spi_data = htonl(*msgptr++);
      spi_addr = i<<16 | ADC_TABLE;
      xil_printf("ADC Table: spi_addr=%8x  spi_data=%8x\r\n",spi_addr, spi_data);
	  Xil_Out32(XPAR_M_AXI_BASEADDR + ARTIX_SPI_DATA, spi_data);
	  Xil_Out32(XPAR_M_AXI_BASEADDR + ARTIX_SPI_ADDR, spi_addr);
	  Xil_Out32(XPAR_M_AXI_BASEADDR + ARTIX_SPI_WE, 0x1);
	  Xil_Out32(XPAR_M_AXI_BASEADDR + ARTIX_SPI_WE, 0x0);
	  vTaskDelay(pdMS_TO_TICKS(1));
	}
    */

}





void eeprom_settings(void *msg) {

	u32 *msgptr = (u32 *)msg;
	u32 spi_addr, spi_data;
	u32 eeprom_addr;
	s32 msg_data, eeprom_data;



    eeprom_addr = htonl(msgptr[0]);
    msg_data = htonl(msgptr[1]);

    xil_printf("EEPROM Addr: %d    Data: %d\r\n",eeprom_addr, msg_data);

}




void reg_settings(void *msg) {

	u32 *msgptr = (u32 *)msg;
	u32 addr;
    u32 rdval, regAddr, regVal;

	typedef union {
	    u32 u;
	    float f;
	    s32 i;
	} MsgUnion;

	MsgUnion data;


    addr = htonl(msgptr[0]);
    data.u = htonl(msgptr[1]);

    xil_printf("Addr: %d    Data: %d\r\n",addr,data.u);


    switch(addr) {


        case ADC_IDLY_MSG:
           	xil_printf("Setting ADC IDLY:  Value=%d\r\n",data.u);
           	Xil_Out32(XPAR_M_AXI_BASEADDR + ADC_IDLYWVAL_REG, data.u);
           	//strobe the idly value into all 16 idly registers
           	Xil_Out32(XPAR_M_AXI_BASEADDR + ADC_IDLYSTR_REG, 0xFFFF);
           	Xil_Out32(XPAR_M_AXI_BASEADDR + ADC_IDLYSTR_REG, 0);
           	usleep(10);
           	rdval = Xil_In32(XPAR_M_AXI_BASEADDR + ADC_IDLYRVAL_REG);
           	xil_printf(" IDLY rval=%d\r\n",rdval);

            break;



        case ADC_SPI_MSG:
           	regAddr = (data.u & 0xFF00) >> 8;
           	regVal = (data.u & 0xFF);
           	xil_printf("Programming ADC SPI Register  Addr: %x   Data: %x \r\n", regAddr, regVal);
           	Xil_Out32(XPAR_M_AXI_BASEADDR + ADC_SPI_REG, regAddr<<8 | regVal);
           	usleep(1000);
           	//read back
           	Xil_Out32(XPAR_M_AXI_BASEADDR + ADC_SPI_REG, 0x8000 | regAddr<<8 | regVal);
           	usleep(1000);
           	rdval = Xil_In32(XPAR_M_AXI_BASEADDR + ADC_SPI_REG);
           	xil_printf("SPI Read Back ADC0 Reg: %d = %x\r\n",regAddr,rdval);
           	usleep(1000);
           	Xil_Out32(XPAR_M_AXI_BASEADDR + ADC_SPI_REG, 0x10000 | 0x8000 | regAddr<<8 | regVal);
           	usleep(1000);
           	rdval = Xil_In32(XPAR_M_AXI_BASEADDR + ADC_SPI_REG);
           	xil_printf("SPI Read Back ADC1 Reg: %d = %x\r\n",regAddr,rdval);
            break;

        default:
          	xil_printf("Msg not supported yet...\r\n");
           	break;
        }

}



