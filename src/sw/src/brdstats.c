
// remote reporting of select LwIP statistics

#include <stdio.h>


#include <xparameters.h>
//#include "xadcps.h"

#include <FreeRTOS.h>
#include <lwip/sys.h>
#include <lwip/stats.h>

#include "local.h"
#include "zubpm.h"
#include "pl_regs.h"

#include "xsysmonpsu.h"


#include "xtime_l.h"

#define MAX_TASKS 16

//static XSysMon xmon;

extern XSysMonPsu SysMonInstance;



float sysmon_read_stats() {

	s32 temprawdata;
	float val;

    // Read the temperature data
    temprawdata = XSysMonPsu_GetAdcData(&SysMonInstance, XSM_CH_TEMP, XSYSMON_PS);

    // Convert raw temperature data to degrees Celsius
    val = XSysMonPsu_RawToTemperature_OnChip(temprawdata);
    //printf("Die Temp in func: %f\n",val);
    return(val);

}



static void brdstats_push(void *unused)
{
    (void)unused;
    u32 i;
    float sfpregs[5];

    static struct {
        uint32_t githash;  // 0
        struct {
            uint32_t dfe_brd[4]; // 4,8,12,16
            uint32_t afe_brd[2]; //20,24
            uint32_t die_ps; // 28
            uint32_t die_pl; //32
            uint32_t rsvd; // 36
        } brd_temps;
        struct {
        	uint32_t vin_v;   //40
        	uint32_t vin_i;   //44
            uint32_t v3_3_v; // 48
            uint32_t v3_3_i; // 52
            uint32_t v2_5_v; // 56
            uint32_t v2_5_i; // 60
            uint32_t v1_8_v; // 64
            uint32_t v1_8_i; // 68
            uint32_t v1_2ddr_v; // 72
            uint32_t v1_2ddr_i; // 76
            uint32_t v0_85_v; // 80
            uint32_t v0_85_i; // 84
            uint32_t v2_5mgt_v; // 88
            uint32_t v2_5mgt_i; // 92
            uint32_t v1_2mgt_v; // 96
            uint32_t v1_2mgt_i; // 100
            uint32_t v0_9mgt_v; // 104
            uint32_t v0_9mgt_i; // 108
        } dfe_pwr;
        struct {
        	uint32_t reg[3];  //112,116,120
        	uint32_t pwrmgmt; //124
        	uint32_t rsvd;    //128
        } reg_temps;
        struct {
        	uint32_t vin;  //132
        	uint32_t iin;  //136
        } afe_pwr;
        struct {
        	uint32_t temp[6];   //140,144,148,152,156,160
        	uint32_t vcc[6];    //164,168,172,176,180,184
        	uint32_t txbias[6]; //188,192,196,200,204,208
        	uint32_t txpwr[6];  //212,216,220,224,228,232
        	uint32_t rxpwr[6];  //236,240,244,248,252,256
        }sfp;
        // for backwards compatibility, must only append new values.
    } msg;




    while(1) {

        vTaskDelay(pdMS_TO_TICKS(1000));


        //read FPGA version (git checksum) from PL register
        msg.githash = Xil_In32(XPAR_M_AXI_BASEADDR + GIT_SHASUM);

        //read DFE temperature from i2c bus
        i2c_set_port_expander(I2C_PORTEXP1_ADDR,1);

        msg.brd_temps.dfe_brd[0] = htonf(read_i2c_temp(BRDTEMP0_ADDR));
        msg.brd_temps.dfe_brd[1] = htonf(read_i2c_temp(BRDTEMP1_ADDR));
        msg.brd_temps.dfe_brd[2] = htonf(read_i2c_temp(BRDTEMP2_ADDR));
        msg.brd_temps.dfe_brd[3] = htonf(read_i2c_temp(BRDTEMP3_ADDR));

        //read AFE temperature from i2c bus
        i2c_set_port_expander(I2C_PORTEXP1_ADDR,0x40);
        msg.brd_temps.afe_brd[0] = htonf(read_i2c_temp(BRDTEMP0_ADDR));
        msg.brd_temps.afe_brd[1] = htonf(read_i2c_temp(BRDTEMP2_ADDR));
        msg.afe_pwr.vin = htonf(ina226_read_bus_voltage());
        msg.afe_pwr.iin = htonf(ina226_read_current());
        //printf("Vin: %f\n",ina226_read_bus_voltage());
        //printf("Iin: %f\n",ina226_read_current());

        //read die temps
    	//printf("FPGA Temp: %f\r\n",sysmon_read_stats());
        msg.brd_temps.die_ps = htonf(sysmon_read_stats());
        //msg.brd_temps.die_ps = htonf(sysmon_ps_getTemp());

        //read temps from LTC2991 chips
    	i2c_set_port_expander(I2C_PORTEXP1_ADDR,4);
    	i2c_configure_ltc2991();

        msg.reg_temps.reg[0] = htonf(i2c_ltc2991_reg1_temp());
        msg.reg_temps.reg[1] = htonf(i2c_ltc2991_reg2_temp());
        msg.reg_temps.reg[2] = htonf(i2c_ltc2991_reg3_temp());

        //read voltage & currents from LTC2991 chips
        msg.dfe_pwr.vin_v = htonf(i2c_ltc2991_vcc_vin());
        msg.dfe_pwr.vin_i = htonf(i2c_ltc2991_vcc_vin_current());
        msg.dfe_pwr.v3_3_v = htonf(i2c_ltc2991_vcc_3v3());
        msg.dfe_pwr.v3_3_i = htonf(i2c_ltc2991_vcc_3v3_current());
        msg.dfe_pwr.v2_5_v = htonf(i2c_ltc2991_vcc_2v5());
        msg.dfe_pwr.v2_5_i = htonf(i2c_ltc2991_vcc_2v5_current());
        msg.dfe_pwr.v1_8_v = htonf(i2c_ltc2991_vcc_1v8());
        msg.dfe_pwr.v1_8_i = htonf(i2c_ltc2991_vcc_1v8_current());
        msg.dfe_pwr.v1_2ddr_v = htonf(i2c_ltc2991_vcc_1v2_ddr());
        msg.dfe_pwr.v1_2ddr_i = htonf(i2c_ltc2991_vcc_1v2_ddr_current());
        msg.dfe_pwr.v0_85_v = htonf(i2c_ltc2991_vcc_0v85());
        msg.dfe_pwr.v0_85_i = htonf(i2c_ltc2991_vcc_0v85_current());
        msg.dfe_pwr.v2_5mgt_v = htonf(i2c_ltc2991_vcc_mgt_2v5());
        msg.dfe_pwr.v2_5mgt_i = htonf(i2c_ltc2991_vcc_mgt_2v5_current());
        msg.dfe_pwr.v1_2mgt_v = htonf(i2c_ltc2991_vcc_mgt_1v2());
        msg.dfe_pwr.v1_2mgt_i = htonf(i2c_ltc2991_vcc_mgt_1v2_current());
        msg.dfe_pwr.v0_9mgt_v = htonf(i2c_ltc2991_vcc_mgt_0v9());
        msg.dfe_pwr.v0_9mgt_i =  htonf(i2c_ltc2991_vcc_mgt_0v9_current());


        // read SFP status information from i2c bus
        for (i=0;i<=5;i++) {
           i2c_sfp_get_stats(&sfpregs, i);
           msg.sfp.temp[i] = htonf(sfpregs[0]);
           msg.sfp.vcc[i] = htonf(sfpregs[1]);
           msg.sfp.txbias[i] = htonf(sfpregs[2]);
           msg.sfp.txpwr[i] = htonf(sfpregs[3]);
           msg.sfp.rxpwr[i] = htonf(sfpregs[4]);
        }

        // Read power management info from i2c bus
    	i2c_set_port_expander(I2C_PORTEXP1_ADDR,8);
        msg.reg_temps.pwrmgmt = htonf(i2c_ltc2977_stats());

        //printf("\r\nDB0 Link Status: %d",gpio_read(EMIO_DB0_LINK_STAT));
        //printf("\r\nDB1 Link Status: %d",gpio_read(EMIO_DB1_LINK_STAT));
        //xil_printf("DB Present = %d   %d\r\n",msg.db.present[0], msg.db.present[1]);

        psc_send(the_server, 32, sizeof(msg), &msg);
    }
}

void brdstats_setup(void)
{
    printf("INFO: Starting board stats daemon\n");
    sys_thread_new("brdstats", brdstats_push, NULL, THREAD_STACKSIZE, DEFAULT_THREAD_PRIO);
}

