
#include <sleep.h>
#include "netif/xadapter.h"
//#include "platform_config.h"
#include "xil_printf.h"
#include "lwip/init.h"
#include "lwip/inet.h"
#include "FreeRTOS.h"


#include "xparameters.h"
#include "xsysmonpsu.h"
#include "xiicps.h"

#include "xstatus.h"       // For XStatus
#include "pm_defs.h"
#include "pm_common.h"       // PM API functions
#include "pm_api_sys.h"

#include "local.h"
#include "pl_regs.h"
#include "zubpm.h"





#define PLATFORM_EMAC_BASEADDR XPAR_XEMACPS_0_BASEADDR
#define SYSMON_DEVICE_ID XPAR_XSYSMONPSU_0_DEVICE_ID

XIicPs IicPsInstance;	    // Instance of the IIC Device
XSysMonPsu SysMonInstance;  // Instance of the Sysmon Device


#define PLATFORM_ZYNQMP


psc_key* the_server;

//static sys_thread_t main_thread_handle;



uint32_t git_hash;

//ip_t ip_settings;



XIicPs IicPsInstance;	    // Instance of the IIC Device
XSysMonPsu SysMonInstance;  // Instance of the Sysmon Device


//TimerHandle_t xUptimeTimer;  // Timer handle
//u32 UptimeCounter = 0;  // Uptime counter



// Timer callback function
//void vUptimeTimerCallback(TimerHandle_t xTimer) {
//    UptimeCounter++;  // Increment uptime counter
//}



void print_firmware_version()
{

  time_t epoch_time;
  struct tm *human_time;
  char timebuf[80];

  xil_printf("Module ID Number: %x\r\n", Xil_In32(XPAR_M_AXI_BASEADDR + MOD_ID_NUM));
  xil_printf("Module Version Number: %x\r\n", Xil_In32(XPAR_M_AXI_BASEADDR + MOD_ID_VER));
  xil_printf("Project ID Number: %x\r\n", Xil_In32(XPAR_M_AXI_BASEADDR + PROJ_ID_NUM));
  xil_printf("Project Version Number: %x\r\n", Xil_In32(XPAR_M_AXI_BASEADDR + PROJ_ID_VER));
  //compare to git commit with command: git rev-parse --short HEAD
  xil_printf("Git Checksum: %x\r\n", Xil_In32(XPAR_M_AXI_BASEADDR + GIT_SHASUM));
  epoch_time = Xil_In32(XPAR_M_AXI_BASEADDR + COMPILE_TIMESTAMP);
  human_time = localtime(&epoch_time);
  strftime(timebuf, sizeof(timebuf), "%Y-%m-%d %H:%M:%S", human_time);
  xil_printf("Project Compilation Timestamp: %s\r\n", timebuf);
}






s32 init_sysmon() {

	s32 Status;
    XSysMonPsu_Config *SysMonConfig;

	// Initialize the SYSMON driver
	SysMonConfig = XSysMonPsu_LookupConfig(SYSMON_DEVICE_ID);
	if (SysMonConfig == NULL) {
		return XST_FAILURE;
	}

	Status = XSysMonPsu_CfgInitialize(&SysMonInstance, SysMonConfig, SysMonConfig->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	// Self-Test the System Monitor/ADC device
	Status = XSysMonPsu_SelfTest(&SysMonInstance);
	if (Status != XST_SUCCESS) {
		xil_printf("SysMonPsu self-test failed.\n");
		return XST_FAILURE;
	}

    return XST_SUCCESS;
}


static void client_event(void *pvt, psc_event evt, psc_client *ckey)
{
    if(evt!=PSC_CONN)
        return;
    // send some "static" information once when a new client connects.
    struct {
        uint32_t git_hash;
        uint32_t serial;
    } msg = {
        .git_hash = htonl(git_hash),
        .serial = 0, // TODO: read from EEPROM
    };
    (void)pvt;

    psc_send_one(ckey, 0x100, sizeof(msg), &msg);
}




static void client_msg(void *pvt, psc_client *ckey, uint16_t msgid, uint32_t msglen, void *msg)
{
    (void)pvt;

	//xil_printf("In Client_Msg:  MsgID=%d   MsgLen=%d\r\n",msgid,msglen);


    //blink front panel LED
    Xil_Out32(XPAR_M_AXI_BASEADDR + IOC_ACCESS_REG, 1);
    Xil_Out32(XPAR_M_AXI_BASEADDR + IOC_ACCESS_REG, 0);

    switch(msgid) {
        case 1: //register settings
        	reg_settings(msg);
        	break;
        case 2: //eeprom settings
        	eeprom_settings(msg);
        case 3: //tail cancellation table
        	write_adc_table(msg,msglen);
        case 5: //ping event
            break;
    }



}




static void on_startup(void *pvt, psc_key *key)
{
    (void)pvt;
    (void)key;
    lstats_setup();
    brdstats_setup();
    wvfmdata_setup();
    console_setup();
}



static void realmain(void *arg)
{
    (void)arg;

    printf("Main thread running\n");

    {
        net_config conf = {};
        sdcard_handle(&conf);
        //InitSettingsfromQspi();
        net_setup(&conf);

    }

    //discover_setup();
    //tftp_setup();

    const psc_config conf = {
        .port = 3000,
        .start = on_startup,
        .conn = client_event,
        .recv = client_msg,
    };

    psc_run(&the_server, &conf);
    while(1) {
        fprintf(stderr, "ERROR: PSC server loop returns!\n");
        sys_msleep(1000);
    }
}




int main()
{

    u32 ts_s, ts_ns;
    float temp1, temp2;
    u32 i;

	xil_printf("ACMI-2 ChainA ...\r\n");
    print_firmware_version();


	xil_printf("Init I2c...\r\n");
	init_i2c();
	xil_printf("Init Sysmon...\r\n");
	init_sysmon();

    // oscillator for EVR reference clock
	xil_printf("Init lmk1e2...\r\n");
    write_lmk61e2();


	//EVR reset
	Xil_Out32(XPAR_M_AXI_BASEADDR + EVR_RST_REG, 0xFF);
	usleep(10);
	Xil_Out32(XPAR_M_AXI_BASEADDR + EVR_RST_REG, 0);
    usleep(1000);

    //read Timestamp
    for (i=0;i<5;i++) {
       ts_s = Xil_In32(XPAR_M_AXI_BASEADDR + EVR_TS_S_REG);
       ts_ns = Xil_In32(XPAR_M_AXI_BASEADDR + EVR_TS_NS_REG);
       xil_printf("ts= %d    %d\r\n",ts_s,ts_ns);
       sleep(1);
    }


    sys_thread_new("main", realmain, NULL, THREAD_STACKSIZE, DEFAULT_THREAD_PRIO);


	vTaskStartScheduler();

    //never reached
	return 0;
}
