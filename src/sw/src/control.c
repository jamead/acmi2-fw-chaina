
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
#include "pl_regs.h"
#include "psc_msg.h"
#include "at24eeprom.h"
#include "zudfe.h"










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



void eeprom_settings(void *msg)
{
    uint32_t *msgptr = (uint32_t *)msg;
    uint32_t eeprom_addr;
    uint32_t msg_data;
    uint32_t pl_addr;
    int status;

    Eeprom_params_msg_t eeprom_data;
    u8 eeprom_page[EEPROM_PAGE_SIZE];

    /*
     * Message from IOC:
     *   msgptr[0] = EEPROM parameter byte offset
     *   msgptr[1] = new value
     */
    eeprom_addr = ntohl(msgptr[0]);
    msg_data = ntohl(msgptr[1]);

    xil_printf("EEPROM Addr: %lu  Data: %lu\r\n",
               (unsigned long)eeprom_addr,
               (unsigned long)msg_data);

    /*
     * Check that the requested address is within the
     * 200-byte EEPROM parameter block and is 32-bit aligned.
     */
    if ((eeprom_addr >= EEPROM_PARAMS_SIZE_BYTES) ||
        ((eeprom_addr & 0x3U) != 0U)) {

        xil_printf("ERROR: Invalid EEPROM address: %lu\r\n",
                   (unsigned long)eeprom_addr);

        return;
    }

    /*
     * Update the corresponding PL register.
     */
    pl_addr = XPAR_M_AXI_BASEADDR +
              EEPROM_PARAMS_BASE_OFFSET +
              eeprom_addr;

    Xil_Out32(pl_addr, msg_data);

    /*
     * Read all 50 current PL registers into the EEPROM structure.
     */
    EepromGatherData(&eeprom_data);

    /*
     * EEPROM writes are one complete 256-byte page.
     * Fill unused bytes with erased EEPROM value (0xFF).
     */
    memset(eeprom_page, 0xFF, sizeof(eeprom_page));

    memcpy(eeprom_page,
           &eeprom_data,
           sizeof(eeprom_data));

    /*
     * Write the entire EEPROM page.
     */
    status = EepromWrite256(0x0000, eeprom_page);

    if (status != XST_SUCCESS) {
        xil_printf("ERROR: EEPROM write failed\r\n");
    }
    else {
        xil_printf("EEPROM parameters updated successfully\r\n");
    }
}



/*
void eeprom_settings(void *msg) {

	u32 *msgptr = (u32 *)msg;
	u32 spi_addr, spi_data;
	u32 eeprom_addr;
	s32 msg_data, eeprom_data;



    eeprom_addr = htonl(msgptr[0]);
    msg_data = htonl(msgptr[1]);

    xil_printf("EEPROM Addr: %d    Data: %d\r\n",eeprom_addr, msg_data);

}
*/



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



