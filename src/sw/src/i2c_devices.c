#include "xparameters.h"
#include "xiicps.h"
#include <sleep.h>
#include "xil_printf.h"
#include <stdio.h>
#include "FreeRTOS.h"
#include "task.h"
#include "zubpm.h"


extern XIicPs IicPsInstance;			/* Instance of the IIC Device */


static const u32 lmk61e2_values [] = {
		0x0010, 0x010B, 0x0233, 0x08B0, 0x0901, 0x1000, 0x1180, 0x1502,
		0x1600, 0x170F, 0x1900, 0x1A2E, 0x1B00, 0x1C00, 0x1DA9, 0x1E00,
		0x1F00, 0x20C8, 0x2103, 0x2224, 0x2327, 0x2422, 0x2502, 0x2600,
		0x2707, 0x2F00, 0x3000, 0x3110, 0x3200, 0x3300, 0x3400, 0x3500,
		0x3800, 0x4802,
};


// Registers to program si571 to 25MHz.
/*static const uint8_t si571_values[][2] = {
	{137, 0x10}, //Freeze DCO
	{7, 0x66},
    {8, 0xC2},
    {9, 0xAE},
    {10, 0x01},
    {11, 0x18},
    {12, 0xFC},
    {137, 0x0},  //Unfreeze DCO
	{135, 0x40}  //Enable New Frequency
};*/

// Registers to program si571 to 117.3491MHz.
/*
static const uint8_t si571_values[][2] = {
	{137, 0x10}, //Freeze DCO
	{7, 0x61},
    {8, 0x42},
    {9, 0xB2},
    {10, 0x04},
    {11, 0x5B},
    {12, 0x76},
    {137, 0x0},  //Unfreeze DCO
	{135, 0x40}  //Enable New Frequency
};
*/

static const uint8_t si571_values[][2] = {
	{137, 0x10}, //Freeze DCO
	{7, 0xA0},
    {8, 0xC2},
    {9, 0xD3},
    {10, 0x69},
    {11, 0xB0},
    {12, 0x13},
    {137, 0x0},  //Unfreeze DCO
	{135, 0x40}  //Enable New Frequency
};


static const uint8_t si569_values[][2] = {
	{255, 0x10}, //Freeze DCO
	{69, 0x00},
    {17, 0x00},
	{23, 0x5E},
	{24, 0x00},
	{26, 0x66},
	{27, 0x2F},
	{28, 0x2B},
	{29, 0x49},
	{30, 0x48},
	{31, 0x00},
	{32, 0x08},
	{35, 0x86},
	{7,  0x08},
	{17, 0x01}
};




void read_si569() {
   u8 i, buf[2], stat;

   xil_printf("Read si569 registers\r\n");
   for (i=0;i<9;i++) {
       buf[0] = i+23;
       i2c_write(buf,1,0x56);
       stat = i2c_read(buf, 1, 0x56);
       xil_printf("Stat: %d:   val0:%x  \r\n",stat, buf[0]);
	}
	xil_printf("\r\n");
}


void prog_si569() {
	u8 buf[2], stat;

	//xil_printf("Si571 Registers before re-programming...\r\n");
	//read_si571();
	xil_printf("Programming si569\r\n");


	//Program New Registers
	for (size_t i = 0; i < sizeof(si569_values) / sizeof(si569_values[0]); i++) {
	    buf[0] = si569_values[i][0];
	    buf[1] = si569_values[i][1];
	    stat = i2c_write(buf, 2, 0x56);
	    xil_printf("Stat: %d:   val0:%x  \r\n",stat, buf[0]);
	    usleep(50000);
	}
	//xil_printf("Si571 Registers after re-programming...\r\n");
    //read_si571();
}









void read_si571() {
   u8 i, buf[2], stat;

   xil_printf("Read si571 registers\r\n");
   for (i=0;i<6;i++) {
       buf[0] = i+7;
       i2c_write(buf,1,0x56);
       stat = i2c_read(buf, 1, 0x56);
       xil_printf("Stat: %d:   val0:%x  \r\n",stat, buf[0]);
	}
	xil_printf("\r\n");
}


void prog_si571() {
	u8 buf[2];

	xil_printf("Si571 Registers before re-programming...\r\n");
	read_si571();
	//Program New Registers
	for (size_t i = 0; i < sizeof(si571_values) / sizeof(si571_values[0]); i++) {
	    buf[0] = si571_values[i][0];
	    buf[1] = si571_values[i][1];
	    i2c_write(buf, 2, 0x56);
	}
	xil_printf("Si571 Registers after re-programming...\r\n");
    read_si571();
}





void init_i2c() {
    //s32 Status;
    XIicPs_Config *ConfigPtr;


    // Look up the configuration in the config table
    ConfigPtr = XIicPs_LookupConfig(0);
    //if(ConfigPtr == NULL) return XST_FAILURE;

    // Initialize the II2 driver configuration
    XIicPs_CfgInitialize(&IicPsInstance, ConfigPtr, ConfigPtr->BaseAddress);
    //if(Status != XST_SUCCESS) return XST_FAILURE;

    //set i2c clock rate to 100KHz
    XIicPs_SetSClk(&IicPsInstance, 100000);
}


s32 i2c_write(u8 *buf, u8 len, u8 addr) {

	s32 status;

	//xil_printf("start i2c write\r\n");
	while (XIicPs_BusIsBusy(&IicPsInstance));
	status = XIicPs_MasterSendPolled(&IicPsInstance, buf, len, addr);
	//xil_printf("done i2c write\r\n");
	return status;
}

s32 i2c_read(u8 *buf, u8 len, u8 addr) {

	s32 status;

	while (XIicPs_BusIsBusy(&IicPsInstance));
    status = XIicPs_MasterRecvPolled(&IicPsInstance, buf, len, addr);
    return status;

}



// 24AA025E48 EEPROM  --------------------------------------
#define IIC_EEPROM_ADDR 0x50
#define IIC_MAC_REG 0xFA

void i2c_get_mac_address(u8 *mac){
	i2c_set_port_expander(I2C_PORTEXP0_ADDR,0x40);
	i2c_set_port_expander(I2C_PORTEXP1_ADDR,0x0);
    u8 buf[6] = {0};
    buf[0] = IIC_MAC_REG;
    i2c_write(buf,1,IIC_EEPROM_ADDR);
    i2c_read(mac,6,IIC_EEPROM_ADDR);
    xil_printf("EEPROM MAC ADDR = %2x %2x %2x %2x %2x %2x\r\n",mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
    //iic_chp_recv_repeated_start(buf, 1, mac, 6, IIC_EEPROM_ADDR);
}

/*
void i2c_eeprom_writeByte(u8 addr, u8 data){
	i2c_set_port_expander(I2C_PORTEXP1_ADDR,0x80);
    u8 buf[] = {addr, data};
    iic_chp_send(buf, 2, IIC_EEPROM_ADDR);
    iic_pe_disable(2, 0);
}


u8 i2c_eeprom_readByte(u8 addr){
	i2c_set_port_expander(I2C_PORTEXP1_ADDR,0x80);
    u8 buf[] = {addr};
    u8 recvBuf[1];
    iic_chp_recv_repeated_start(buf, 1, recvBuf, 1, IIC_EEPROM_ADDR);
    iic_pe_disable(2, 0);
    return recvBuf[0];
}

*/
void i2c_eeprom_writeBytes(u8 startAddr, u8 *data, u8 len){
	i2c_set_port_expander(I2C_PORTEXP1_ADDR,0x80);
    u8 buf[len + 1];
    buf[0] = startAddr;
    for(int i = 0; i < len; i++) buf[i+1] = data[i];
    i2c_write(buf, len + 1, IIC_EEPROM_ADDR);
}


void i2c_eeprom_readBytes(u8 startAddr, u8 *data, u8 len){
	u8 buf[] = {startAddr};
	i2c_set_port_expander(I2C_PORTEXP1_ADDR,0x80);
    i2c_write(buf,1,IIC_EEPROM_ADDR);
    i2c_read(data,len,IIC_EEPROM_ADDR);
    //u8 buf[] = {startAddr};
    //iic_chp_recv_repeated_start(buf, 1, data, len, IIC_EEPROM_ADDR);
    //iic_pe_disable(2, 0);
}



void eeprom_dump()
{
  u8 rdBuf[129];
  memset(rdBuf, 0xFF, sizeof(rdBuf));
  rdBuf[128] = 0;
  i2c_eeprom_readBytes(0, rdBuf, 128);

  printf("Read EEPROM:\r\n\r\n");
  printf("%s\r\n", rdBuf);

  for (int i = 0; i < 128; i++)
  {
    if ((i % 16) == 0)
      printf("\r\n0x%02x:  ", i);
    printf("%02x  ", rdBuf[i]);
  }
  printf("\r\n");
}









/*
void eeprom_write_ipaddr()
{
  u8 ip_addr[16], wrBuf[128];
  u8 octet1, octet2, octet3, octet4;

  memset(wrBuf, 0, 128);


  // Prompt the user to enter an IP address
  printf("Enter an IP address (format: x.x.x.x): ");

  // Read the IP address as four separate integers (octets)
  if (scanf("%u%u%u%u", &octet1, &octet2, &octet3, &octet4) == 4) {
        // Validate that each octet is within the range 0-255
        if (octet1 <= 255 && octet2 <= 255 && octet3 <= 255 && octet4 <= 255) {
            // Format and store the IP address as a string
            snprintf((char *)wrBuf, sizeof(wrBuf), "%u.%u.%u.%u", octet1, octet2, octet3, octet4);
            printf("IP Address Stored: %s\n", ip_addr);
        } else {
            printf("Error: One or more octets are out of range (0-255).\n");
        }
    } else
        printf("Error: Invalid input format. Please enter in x.x.x.x format.\n");


  printf("  Writing");
  for (size_t loc = 0; loc < 128; loc += 16)
  {
    i2c_eeprom_writeBytes(loc, &wrBuf[loc], 16);
    printf(".");
    usleep(10*1000);
  }
  printf("\r\n");
}
*/




void i2c_set_port_expander(u32 addr, u32 port)  {

    u8 buf[3];
    u32 len=1;

    buf[0] = port;
    buf[1] = 0;
    buf[2] = 0;

	while (XIicPs_BusIsBusy(&IicPsInstance));
    XIicPs_MasterSendPolled(&IicPsInstance, buf, len, addr);
}


void write_lmk61e2()
{
   u8 buf[4] = {0};
   u32 regval, i;

   u32 num_values = sizeof(lmk61e2_values) / sizeof(lmk61e2_values[0]);  // Get the number of elements in the array
   i2c_set_port_expander(I2C_PORTEXP1_ADDR,0x20);
   for (i=0; i<num_values; i++) {
	  regval = lmk61e2_values[i];
      buf[0] = (char) ((regval & 0x00FF00) >> 8);
      buf[1] = (char) (regval & 0xFF);
      //xil_printf("Writing I2c\r\n");
      i2c_write(buf,2,0x5A);
      xil_printf("LMK61e2 Write = 0x%x\t    B0 = %x    B1 = %x\r\n",regval, buf[0], buf[1]);
   };




}



float read_i2c_temp(u8 addr) {

    u8 buf[3];
    u32 temp;
    float tempflt;

	while (XIicPs_BusIsBusy(&IicPsInstance));
    XIicPs_MasterRecvPolled(&IicPsInstance, buf, 2, addr);
    temp = (buf[0] << 8) | (buf[1]);
    tempflt = (float)temp/128.0;
    return tempflt;

}



void i2c_sfp_get_stats(float *p, u8 sfp_slot) {

	const float TEMP_SCALE = 256;   //Temp is a 16bit signed 2's comp integer in increments of 1/256 degree C
	const float VCC_SCALE = 10000;  //VCC is a 16bit unsigned int in increments of 100uV
	const float TXBIAS_SCALE = 2000; //TxBias is a 16 bit unsigned integer in increments of 2uA
	const float PWR_SCALE = 10000;  //Tx and Rx Pwr is 16 bit unsigned integer in increments of 0.1uW

	s32 status;
    u8 addr = 0x51;  //SFP A2 address space
    u8 txBuf[3] = {96};
    u8 rxBuf[10] = {0,0,0,0,0,0,0,0,0,0};

	i2c_set_port_expander(I2C_PORTEXP0_ADDR,(1 << sfp_slot));
	i2c_set_port_expander(I2C_PORTEXP1_ADDR,0);
	//read 10 bytes starting at address 96 (see data sheet)
    i2c_write(txBuf,1,addr);
    status = i2c_read(rxBuf,10,addr);
    if (status != XST_SUCCESS) {
    	//No SFP module was found, read error, set all values to zero
    	p[0] = 0;
        p[1] = 0;
        p[2] = 0;
        p[3] = 0;
        p[4] = 0;
    }
    else {
    	p[0]   = (float) ((rxBuf[0] << 8) | (rxBuf[1])) / TEMP_SCALE;
    	p[1]    = (float) ((rxBuf[2] << 8) | (rxBuf[3])) / VCC_SCALE;
    	p[2] = (float) ((rxBuf[4] << 8) | (rxBuf[5])) / TXBIAS_SCALE;
    	p[3]  = (float) ((rxBuf[6] << 8) | (rxBuf[7])) / PWR_SCALE;
    	p[4]  = (float) ((rxBuf[8] << 8) | (rxBuf[9])) / PWR_SCALE;
    }
   /*
    xil_printf("SFP Slot : %d\r\n",sfp_slot);
    printf("SFP Temp = %f\r\n", p->sfp_temp[sfp_slot]);
    printf("SFP VCC = %f\r\n", p->sfp_vcc[sfp_slot]);
    printf("SFP txbias = %f\r\n", p->sfp_txbias[sfp_slot]);
    printf("SFP Tx Pwr = %f\r\n", p->sfp_txpwr[sfp_slot]);
    printf("SFP Rx Pwr = %f\r\n", p->sfp_rxpwr[sfp_slot]);
    xil_printf("\r\n");
    */

}





void i2c_get_ltc2991()
{
  printf("LTC2991 Voltage/Current/Temperature Monitoring\r\n");
  printf("----\r\n");
  printf("V 5.0:      %0.2f\r\n", i2c_ltc2991_vcc_vin());
  printf("I 5.0:      %0.2f\r\n", i2c_ltc2991_vcc_vin_current());
  printf("V 3.3:      %0.2f\r\n", i2c_ltc2991_vcc_3v3());
  printf("I 3.3:      %0.2f\r\n", i2c_ltc2991_vcc_3v3_current());
  printf("V 2.5:      %0.2f\r\n", i2c_ltc2991_vcc_2v5());
  printf("I 2.5:      %0.2f\r\n", i2c_ltc2991_vcc_2v5_current());
  printf("V 1.8:      %0.2f\r\n", i2c_ltc2991_vcc_1v8());
  printf("I 1.8:      %0.2f\r\n", i2c_ltc2991_vcc_1v8_current());
  printf("V 0.85:     %0.2f\r\n", i2c_ltc2991_vcc_0v85());
  printf("I 0.85:     %0.2f\r\n", i2c_ltc2991_vcc_0v85_current());
  printf("V 2.5 MGT:  %0.2f\r\n", i2c_ltc2991_vcc_mgt_2v5());
  printf("I 2.5 MGT:  %0.2f\r\n", i2c_ltc2991_vcc_mgt_2v5_current());
  printf("V 1.2 MGT:  %0.2f\r\n", i2c_ltc2991_vcc_mgt_1v2());
  printf("I 1.2 MGT:  %0.2f\r\n", i2c_ltc2991_vcc_mgt_1v2_current());
  printf("V 0.9 MGT:  %0.2f\r\n", i2c_ltc2991_vcc_mgt_0v9());
  printf("I 0.9 MGT:  %0.2f\r\n", i2c_ltc2991_vcc_mgt_0v9_current());
  printf("V 1.2 DDR:  %0.2f\r\n", i2c_ltc2991_vcc_1v2_ddr());
  printf("I 1.2 DDR:  %0.2f\r\n", i2c_ltc2991_vcc_1v2_ddr_current());

  printf("reg1_temp:  %0.2f\r\n", i2c_ltc2991_reg1_temp());
  printf("reg2_temp:  %0.2f\r\n", i2c_ltc2991_reg2_temp());
  printf("reg3_temp:  %0.2f\r\n", i2c_ltc2991_reg3_temp());
  printf("----\r\n");
}


float power(float base, int exponent) {
    float result = 1.0;
    int i;

    // Handle negative exponents by inverting the base and using positive exponent
    if (exponent < 0) {
        base = 1.0 / base;
        exponent = -exponent;
    }
    for (i = 0; i < exponent; i++) {
        result *= base;
    }
    return result;
}


float L11_to_float(int input_val)
{
    // extract exponent as MS 5 bits
    int exponent = input_val >> 11;
    // extract mantissa as LS 11 bits
    int mantissa = input_val & 0x7ff;
    // sign extend exponent from 5 to 8 bits
    if( exponent > 0x0F ) exponent = (exponent|0xE0)-256;
    // ints are 32 bits so using subtraction to adjust for negative numbers
    // sign extend mantissa from 11 to 16 bits
    if( mantissa > 0x03FF ) mantissa = (mantissa|0xF800)-65536;
    // compute value as mantissa * 2^(exponent)
    return mantissa * power(2,exponent);
}




float i2c_ltc2977_stats() {

	const u8 I2C_ADDR = 0x5C;
	const u8 TEMP_REG = 0x8D;
	const s32 TXLEN = 1;
	const s32 RXLEN = 2;

	u8 txBuf[] = {TEMP_REG};
	u8 rxBuf[] = {0,0};
	u32 res;


	i2c_set_port_expander(I2C_PORTEXP0_ADDR,0);
	i2c_set_port_expander(I2C_PORTEXP1_ADDR,8);

    // The LTC2977 requires a repeated start i2c transaction
    while (XIicPs_BusIsBusy(&IicPsInstance)); //Make sure bus is not busy
    XIicPs_SetOptions(&IicPsInstance, XIICPS_REP_START_OPTION);
    //write the command address

    XIicPs_MasterSendPolled(&IicPsInstance, txBuf, TXLEN, I2C_ADDR);
    XIicPs_ClearOptions(&IicPsInstance, XIICPS_REP_START_OPTION);
    //read the register
    XIicPs_MasterRecvPolled(&IicPsInstance, rxBuf, RXLEN, I2C_ADDR);

    res = (rxBuf[1] << 8) | (rxBuf[0]);
    return(L11_to_float(res));

    //printf("Pwr Temp: %f\r\n",p->pwrmgmt_temp);

}



// LTC2991  ------------------------------------------------
//static const u8 iic_ltc2991_addrs[] = {0x90>>1, 0x94>>1, 0x92>>1, 0x96>>1}; //Sorted by schematic order
/**
 * LTC2991[0] U42
 *   V1 - reg1 temp (T[deg C] = (650mV - V) / 2 mV/K)
 *   V2 - reg2 temp
 *   V3 - reg3 temp
 *   V4 - NC
 *   V5/V6 - NC
 *   V7/V8 - VIN / VCC5  (R sense = 0.01 ohms)
 * LTC2991[1] U14
 *   V1/V2 - LTM1_VOUT4/VCC_MGT_2.5V
 *   V3/V4 - LTM1_VOUT3/VCC_2.5V
 *   V5/V6 - LTM1_VOUT2/VCC_MGT_1.2V
 *   V7/V8 - LTM1_VOUT1/VCC_MGT_0.9V
 * LTC2991[2] U37
 *   V1/V2 - LTM2_VOUT4/VCC_1.2V_DDR
 *   V3/V4 - LTM2_VOUT3/VCC_1.8V
 *   V5/V6 - LTM2_VOUT1/VCC_3.3V
 *   V7/V8 - LTM3_VOUT1/VCC_0.85V
*/


void i2c_configure_ltc2991() {


    i2c_set_port_expander(I2C_PORTEXP1_ADDR,4);
    // reg 6 (ch 1-4) & 7 (ch 5-8) control measurement type
    //   0x00 - single ended voltage measurements
    //   0x11 - measure V{1,3,5,7} s.e. and V{1,3,5,7} - V{2,4,6,8} diff
    u8 txBuf[] = {0x06, 0x00, 0x11};
    // 1-4 s.e. and 5-8 diff+s.e.
    i2c_write(txBuf, 3, 0x48);
    // all ch diff+s.e.
    txBuf[1] = 0x11;
    i2c_write(txBuf, 3, 0x49);
    i2c_write(txBuf, 3, 0x4A);

    // reg 8 bit 4 controls one-shot or continuous measurement (1 = cont)
    txBuf[0] = 0x08;
    txBuf[1] = 0x10;
    i2c_write(txBuf,2,0x48);
    i2c_write(txBuf,2,0x49);
    i2c_write(txBuf,2,0x4A);

    // reg 1 is status/control, 0xF0 enables ch 1-8 measurements
    txBuf[0] = 0x01;
    txBuf[1] = 0xF0;
    i2c_write(txBuf,2,0x48);
    i2c_write(txBuf,2,0x49);
    i2c_write(txBuf,2,0x4A);

}





s16 i2c_ltc2991_voltage(u8 i2c_addr, u8 index){
    u8 txBuf[] = {(0x0A + (2*index))};
    u8 rxBuf[2];
    s16 result;

    //txBuf[0] = 0x0A;
    //txBuf[1] = 0x0;
    i2c_write(txBuf,1,i2c_addr);
    i2c_read(rxBuf,2,i2c_addr);
    //vTaskDelay(pdMS_TO_TICKS(1));
    // MS bit is status, next is sign bit, then 14 data bits
    // mask off the status, and do an extra shift to sign-extend the result
    result = (s16)((rxBuf[0] & 0x7F) << 9) | (rxBuf[1] << 1);
    return result >> 1;
}



/*
s16 iic_ltc2991_voltage(u8 chip, u8 index){
    u8 txBuf[] = {(0x0A + (2*index))};
    u8 rxBuf[2];
    s16 result;

    txBuf[0] = 0x0A;
    txBuf[1] =
    i2c_write(txBuf,1,0x48);
    i2c_read()
    iic_chp_recv_repeated_start(txBuf, 1, rxBuf, 2, iic_ltc2991_addrs[chip]);
    iic_pe_disable(1, 2);
    // MS bit is status, next is sign bit, then 14 data bits
    // mask off the status, and do an extra shift to sign-extend the result
    result = (s16)((rxBuf[0] & 0x7F) << 9) | (rxBuf[1] << 1);
    return result >> 1;
}
*/

static const double conv_volts_se = 305.18e-6;
static const double conv_volts_diff = 19.075e-6;
static const double conv_r_sense = 0.01;

float i2c_ltc2991_reg1_temp() {
    return (0.650 - (conv_volts_se * i2c_ltc2991_voltage(0x48, 0))) / 0.002;
}

float i2c_ltc2991_reg2_temp() {
    return (0.650 - (conv_volts_se * i2c_ltc2991_voltage(0x48, 1))) / 0.002;
}

float i2c_ltc2991_reg3_temp() {
    return (0.650 - (conv_volts_se * i2c_ltc2991_voltage(0x48, 2))) / 0.002;
}

float i2c_ltc2991_vcc_vin() {
	//scale by 2 because of voltage divider on schematic
    return 2 * conv_volts_se * i2c_ltc2991_voltage(0x48, 6);
}

float i2c_ltc2991_vcc_vin_current() {
	//scale by 2 because of voltage divider on schematic
    return 2 * (conv_volts_diff / conv_r_sense) * i2c_ltc2991_voltage(0x48, 7);
}

float i2c_ltc2991_vcc_mgt_2v5() {
    return conv_volts_se * i2c_ltc2991_voltage(0x4A, 0);
}

float i2c_ltc2991_vcc_mgt_2v5_current() {
    return (conv_volts_diff / conv_r_sense) * i2c_ltc2991_voltage(0x4A, 1);
}

float i2c_ltc2991_vcc_2v5() {
    return conv_volts_se * i2c_ltc2991_voltage(0x4A, 2);
}

float i2c_ltc2991_vcc_2v5_current() {
    return (conv_volts_diff / conv_r_sense) * i2c_ltc2991_voltage(0x4A, 3);
}

float i2c_ltc2991_vcc_mgt_1v2() {
    return conv_volts_se * i2c_ltc2991_voltage(0x4A, 4);
}

float i2c_ltc2991_vcc_mgt_1v2_current() {
    return (conv_volts_diff / conv_r_sense) * i2c_ltc2991_voltage(0x4A, 5);
}

float i2c_ltc2991_vcc_mgt_0v9() {
    return conv_volts_se * i2c_ltc2991_voltage(0x4A, 6);
}

float i2c_ltc2991_vcc_mgt_0v9_current() {
    return (conv_volts_diff / conv_r_sense) * i2c_ltc2991_voltage(0x4A, 7);
}

float i2c_ltc2991_vcc_1v2_ddr() {
    return conv_volts_se * i2c_ltc2991_voltage(0x49, 0);
}

float i2c_ltc2991_vcc_1v2_ddr_current() {
    return (conv_volts_diff / conv_r_sense) * i2c_ltc2991_voltage(0x49, 1);
}

float i2c_ltc2991_vcc_1v8() {
    return conv_volts_se * i2c_ltc2991_voltage(0x49, 2);
}

float i2c_ltc2991_vcc_1v8_current() {
    return (conv_volts_diff / conv_r_sense) * i2c_ltc2991_voltage(0x49, 3);
}

float i2c_ltc2991_vcc_3v3() {
    return conv_volts_se * i2c_ltc2991_voltage(0x49, 4);
}

float i2c_ltc2991_vcc_3v3_current() {
    return (conv_volts_diff / conv_r_sense) * i2c_ltc2991_voltage(0x49, 5);
}

float i2c_ltc2991_vcc_0v85() {
    return conv_volts_se * i2c_ltc2991_voltage(0x49, 6);
}

float i2c_ltc2991_vcc_0v85_current() {
    return (conv_volts_diff / conv_r_sense) * i2c_ltc2991_voltage(0x49, 6);
}

/*
u16 iic_ltc2991_read16(u8 index, u8 addr){
    iic_pe_enable(1,2);
    u8 txBuf[] = {addr};
    u8 rxBuf[2];
    iic_chp_recv_repeated_start(txBuf, 1, rxBuf, 2, iic_ltc2991_addrs[index]);
    u16 temp = (rxBuf[0] << 8) + rxBuf[1];
    iic_pe_disable(1,2);
    return temp;
}
u8 iic_ltc2991_read8(u8 index, u8 addr){
    iic_pe_enable(1,2);
    u8 txBuf[] = {addr};
    u8 rxBuf[1];
    iic_chp_recv_repeated_start(txBuf, 1, rxBuf, 1, iic_ltc2991_addrs[index]);
    iic_pe_disable(1,2);
    return rxBuf[0];
}
void iic_ltc2991_write16(u8 index, u8 addr, u16 data){
    iic_pe_enable(1, 2);
    u8 txBuf[] = {addr, (data >> 8), (data & 0xFF)};
    iic_chp_send(txBuf, 3, iic_ltc2991_addrs[index]);
    iic_pe_disable(1, 2);
}
void iic_ltc2991_write8(u8 index, u8 addr, u8 data){
    iic_pe_enable(1, 2);
    u8 txBuf[] = {addr, data};
    iic_chp_send(txBuf, 2, iic_ltc2991_addrs[index]);
    iic_pe_disable(1, 2);
}
*/

// INA226 on AFE board

#define INA226_ADDR          0x40  // A0=A1=0
#define INA226_REG_CONFIG    0x00
#define INA226_REG_SHUNTV    0x01
#define INA226_REG_BUSV      0x02
#define INA226_REG_POWER     0x03
#define INA226_REG_CURRENT   0x04
#define INA226_REG_CALIB     0x05

// Scaling for Rshunt = 0.02 Ω
#define INA226_CALIB_VALUE   0x0800                  // computed above
#define INA226_VOLTAGE_LSB   0.00125f                // 1.25 mV/LSB
#define INA226_CURRENT_LSB_A 0.000125f               // 125 µA/LSB
#define INA226_POWER_LSB_W   (25.0f * INA226_CURRENT_LSB_A) // 3.125 mW/LSB




// Write 16-bit word to INA226 register
s32 ina226_write_reg(u8 reg, u16 value) {
    u8 buf[3];
    buf[0] = reg;
    buf[1] = (u8)(value >> 8);   // MSB
    buf[2] = (u8)(value & 0xFF); // LSB
    return i2c_write(buf, 3, INA226_ADDR);
}


// Read 16-bit word from INA226 register
s32 ina226_read_reg(u8 reg, u16 *value) {
    u8 buf[2];
    s32 status;

    // Write register pointer first
    status = i2c_write(&reg, 1, INA226_ADDR);
    //xil_printf("status: %d\n",status);
    if (status != 0) return status;

    // Now read 2 bytes
    status = i2c_read(buf, 2, INA226_ADDR);
    if (status != 0) return status;

    *value = ((u16)buf[0] << 8) | buf[1];  // MSB first
    return 0;
}


// Optional: configure averaging and conversion times (example: defaults)
void ina226_init(void) {
    // Program calibration (must be set before reading CURRENT/POWER)
    ina226_write_reg(INA226_REG_CALIB, INA226_CALIB_VALUE);
    // (Optional) Set CONFIG if you want specific averaging/ct:
    // u16 cfg = 0x4127; // example: defaults; set as needed
    // ina226_write_reg(INA226_REG_CONFIG, cfg);
}

// Returns bus voltage in volts
float ina226_read_bus_voltage(void) {
    u16 raw;
    if (ina226_read_reg(INA226_REG_BUSV, &raw)) return -1.0f;
    // Bus voltage LSB = 1.25 mV
    float volts = (float)raw * INA226_VOLTAGE_LSB;
    return volts;

}

// Returns current in amps (uses calibration above)
float ina226_read_current(void) {
    u16 raw;
    if (ina226_read_reg(INA226_REG_CURRENT, &raw)) return -1.0f;
    int16_t s = (int16_t)raw;  // signed
    return (float)s * INA226_CURRENT_LSB_A;
}

// (Optional) Returns power in watts
float ina226_read_power(void) {
    u16 raw;
    if (ina226_read_reg(INA226_REG_POWER, &raw)) return -1.0f;
    return (float)raw * INA226_POWER_LSB_W;
}

