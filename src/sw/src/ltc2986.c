/********************************************************************
*  LTC2986 Temperature Readout Chip 
*  8-3-2020
*  
*  This program reads the thermistor temperatures from the LTC2986
********************************************************************/
#include "xil_printf.h"
#include "pl_regs.h"
#include "FreeRTOS.h"
#include "task.h"
#include "zubpm.h"

#include <xil_io.h>


void setup_thermistors(u8 chipnum)
{
    //Setup which of the 3 chips to setup
	Xil_Out32(XPAR_M_AXI_BASEADDR + THERM_SEL_REG, chipnum);
	//vTaskDelay(pdMS_TO_TICKS(1));
    usleep(1000);

	// Set up the 10KOhm sense resistor on Channel 2....
	Xil_Out32(XPAR_M_AXI_BASEADDR + THERM_SPI_REG, 0x020204e8);
	//vTaskDelay(pdMS_TO_TICKS(1));
    usleep(1000);
	Xil_Out32(XPAR_M_AXI_BASEADDR + THERM_SPI_REG, 0x0202059c);
	//vTaskDelay(pdMS_TO_TICKS(1));
    usleep(1000);
	Xil_Out32(XPAR_M_AXI_BASEADDR + THERM_SPI_REG, 0x02020640);
	//vTaskDelay(pdMS_TO_TICKS(1));
    usleep(1000);
	Xil_Out32(XPAR_M_AXI_BASEADDR + THERM_SPI_REG, 0x02020700);
	//vTaskDelay(pdMS_TO_TICKS(1));
    usleep(1000);

	// Set up the first thermistor on channel 4...
	Xil_Out32(XPAR_M_AXI_BASEADDR + THERM_SPI_REG, 0x02020cb0);
	//vTaskDelay(pdMS_TO_TICKS(1));
    usleep(1000);
	Xil_Out32(XPAR_M_AXI_BASEADDR + THERM_SPI_REG, 0x02020d8c);
	//vTaskDelay(pdMS_TO_TICKS(1));
    usleep(1000);
	Xil_Out32(XPAR_M_AXI_BASEADDR + THERM_SPI_REG, 0x02020e00);
	//vTaskDelay(pdMS_TO_TICKS(1));
    usleep(1000);
	Xil_Out32(XPAR_M_AXI_BASEADDR + THERM_SPI_REG, 0x02020f00);
	//vTaskDelay(pdMS_TO_TICKS(1));
    usleep(1000);

	// Set up the second thermistor on channel 6...
	Xil_Out32(XPAR_M_AXI_BASEADDR + THERM_SPI_REG, 0x020214b0);
	//vTaskDelay(pdMS_TO_TICKS(1));
    usleep(1000);
	Xil_Out32(XPAR_M_AXI_BASEADDR + THERM_SPI_REG, 0x0202158c);
	//vTaskDelay(pdMS_TO_TICKS(1));
    usleep(1000);
	Xil_Out32(XPAR_M_AXI_BASEADDR + THERM_SPI_REG, 0x02021600);
	//vTaskDelay(pdMS_TO_TICKS(1));
    usleep(1000);
	Xil_Out32(XPAR_M_AXI_BASEADDR + THERM_SPI_REG, 0x02021700);
	//vTaskDelay(pdMS_TO_TICKS(1));
    usleep(1000);

}

/*
void trig_thermistors(u8 chipnum)
{

	//Setup which of the 3 chips to setup
	Xil_Out32(XPAR_M_AXI_BASEADDR + THERM_SEL_REG, chipnum);
	vTaskDelay(pdMS_TO_TICKS(1));

	//Multiple Conversion Mask Register (doesn't seem to work
	//Xil_Out32(XPAR_M_AXI_BASEADDR + THERM_SPI_REG, 0x0200F7FF);
	//usleep(1000);
	//Initiate conversion on all channels
	//Xil_Out32(XPAR_M_AXI_BASEADDR + THERM_SPI_REG, 0x02000080);
    //usleep(1000);
	//Initiate conversion on channel 6
	//Xil_Out32(XPAR_M_AXI_BASEADDR + THERM_SPI_REG, 0x02000084);
	//usleep(1000);


}
*/


void read_thermistors(uint8_t chipnum, float *temp1, float *temp2)
{
    int dat1, dat2, dat3;

    // Select which of the 3 chips to setup
    Xil_Out32(XPAR_M_AXI_BASEADDR + THERM_SEL_REG, chipnum);
    //vTaskDelay(pdMS_TO_TICKS(1));   // ~1 ms delay
    usleep(1000);

    // --- Read the first thermistor on CH4 ---
    // Initiate conversion
    Xil_Out32(XPAR_M_AXI_BASEADDR + THERM_SPI_REG, 0x02000084);
    vTaskDelay(pdMS_TO_TICKS(170)); // conversion time ~170 ms
    //usleep(170000);

    // Read out 3 bytes
    Xil_Out32(XPAR_M_AXI_BASEADDR + THERM_SPI_REG, 0x03001f00);
    //vTaskDelay(pdMS_TO_TICKS(1));
    usleep(1000);
    dat1 = Xil_In32(XPAR_M_AXI_BASEADDR + THERM_SPI_REG);

    Xil_Out32(XPAR_M_AXI_BASEADDR + THERM_SPI_REG, 0x03001e00);
    //vTaskDelay(pdMS_TO_TICKS(1));
    usleep(1000);
    dat2 = Xil_In32(XPAR_M_AXI_BASEADDR + THERM_SPI_REG);

    Xil_Out32(XPAR_M_AXI_BASEADDR + THERM_SPI_REG, 0x03001d00);
    //vTaskDelay(pdMS_TO_TICKS(1));
    usleep(1000);
    dat3 = Xil_In32(XPAR_M_AXI_BASEADDR + THERM_SPI_REG);

    *temp1 = (float)(dat1 + dat2 * 256 + dat3 * 65536) / 1024.0f;


    // --- Read the second thermistor on CH6 ---
    Xil_Out32(XPAR_M_AXI_BASEADDR + THERM_SPI_REG, 0x02000086);
    vTaskDelay(pdMS_TO_TICKS(170)); // conversion time ~170 ms
    //usleep(170000);

    // Read out 3 bytes
    Xil_Out32(XPAR_M_AXI_BASEADDR + THERM_SPI_REG, 0x03002700);
    //vTaskDelay(pdMS_TO_TICKS(1));
    usleep(1000);
    dat1 = Xil_In32(XPAR_M_AXI_BASEADDR + THERM_SPI_REG);

    Xil_Out32(XPAR_M_AXI_BASEADDR + THERM_SPI_REG, 0x03002600);
    //vTaskDelay(pdMS_TO_TICKS(1));
    usleep(1000);
    dat2 = Xil_In32(XPAR_M_AXI_BASEADDR + THERM_SPI_REG);

    Xil_Out32(XPAR_M_AXI_BASEADDR + THERM_SPI_REG, 0x03002500);
    //vTaskDelay(pdMS_TO_TICKS(1));
    usleep(1000);
    dat3 = Xil_In32(XPAR_M_AXI_BASEADDR + THERM_SPI_REG);


    *temp2 = (float)(dat1 + dat2 * 256 + dat3 * 65536) / 1024.0f;
}









