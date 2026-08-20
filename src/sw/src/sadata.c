
// Gather and Send 10Hz position data

#include <stdio.h>


#include <xparameters.h>

#include <FreeRTOS.h>
#include <lwip/sys.h>
#include <lwip/stats.h>

#include "local.h"
#include "zubpm.h"
#include "pl_regs.h"

#include "xsysmonpsu.h"
#include "xtime_l.h"




static void sadata_push(void *unused)
{
    (void)unused;
    u32 sa_trigwait, sa_cnt=0, sa_cnt_prev=0;

    static struct {
       	u32 count;        // PSC Offset 0
        u32 evr_ts_ns;    // PSC Offset 4
       	u32 evr_ts_s;     // PSC Offset 8
       	u32 cha_mag;      // PSC Offset 12
       	u32 chb_mag;      // PSC Offset 16
       	u32 chc_mag;      // PSC Offset 20
       	u32 chd_mag;      // PSC Offset 24
       	u32 sum;          // PSC Offset 28
       	s32 xpos_nm;      // PSC Offset 32
       	s32 ypos_nm;      // PSC Offset 36
    } msg;


    while(1) {

        //vTaskDelay(pdMS_TO_TICKS(1000));
		//loop here until next 10Hz event
		do {
		   sa_trigwait++;
		   sa_cnt = Xil_In32(XPAR_M_AXI_BASEADDR + SA_TRIGNUM_REG);
		   //xil_printf("SA CNT: %d    %d\r\n",sa_cnt, sa_cnt_prev);
		   vTaskDelay(pdMS_TO_TICKS(10));
		}
	    while (sa_cnt_prev == sa_cnt);
		sa_cnt_prev = sa_cnt;



        msg.count = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + SA_TRIGNUM_REG));
        msg.evr_ts_ns = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + EVR_TS_NS_REG));
        msg.evr_ts_s = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + EVR_TS_S_REG));

        msg.cha_mag = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + SA_CHA_REG));
        msg.chb_mag = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + SA_CHB_REG));
        msg.chc_mag = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + SA_CHC_REG));
        msg.chd_mag = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + SA_CHD_REG));

        msg.sum = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + SA_SUM_REG));

        msg.xpos_nm = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + SA_XPOS_REG));
        msg.ypos_nm = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + SA_YPOS_REG));


        psc_send(the_server, 31, sizeof(msg), &msg);
    }
}

void sadata_setup(void)
{
    printf("INFO: Starting SA Data daemon\n");
    sys_thread_new("sadata", sadata_push, NULL, THREAD_STACKSIZE, DEFAULT_THREAD_PRIO);
}

