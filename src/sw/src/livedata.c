
// remote reporting of select LwIP statistics

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










static void livedata_push(void *unused)
{
    (void)unused;

    static struct {
    	s32 xpos;
    	s32 ypos;
    } tbtmsg[8000];

    static struct {
        s16 cha; // 0
        s16 chb; // 2
        s16 chc; // 4
        s16 chd; // 6
    } adcmsg[8000];

    s16 cha, chb, chc, chd;
    u32 i,regval;



    while(1) {

        vTaskDelay(pdMS_TO_TICKS(1000));
        //xil_printf("In LiveData...\r\n");

        //Start ADC FIFO write
        Xil_Out32(XPAR_M_AXI_BASEADDR + ADCFIFO_STREAMENB_REG, 1);
        //Xil_Out32(XPAR_M_AXI_BASEADDR + ADCFIFO_STREAMENB_REG, 0);

        //Start TbT FIFO write
        Xil_Out32(XPAR_M_AXI_BASEADDR + TBTFIFO_STREAMENB_REG, 1);

        vTaskDelay(pdMS_TO_TICKS(10));
        //xil_printf("Words in FIFO: %d\r\n",Xil_In32(XPAR_M_AXI_BASEADDR + ADCFIFO_CNT_REG));

        // read out live adc data buffer from FIFO
        for (i=0;i<8000;i++) {
            //chC and chD are in a single 32 bit word
        	//chB and chA are in a single 32 bit word
        	regval = Xil_In32(XPAR_M_AXI_BASEADDR + ADCFIFO_DATA_REG);
         	chd = (s16) ((regval & 0xFFFF0000) >> 16);
         	chc = (s16) (regval & 0xFFFF);
            regval = Xil_In32(XPAR_M_AXI_BASEADDR + ADCFIFO_DATA_REG);
         	chb = (s16) ((regval & 0xFFFF0000) >> 16);
         	cha = (s16) (regval & 0xFFFF);

            adcmsg[i].cha = htons(cha);
            adcmsg[i].chb = htons(chb);
            adcmsg[i].chc = htons(chc);
            adcmsg[i].chd = htons(chd);

         }

        //printf("Resetting FIFO...\n");
        Xil_Out32(XPAR_M_AXI_BASEADDR + ADCFIFO_RST_REG, 1);
        vTaskDelay(pdMS_TO_TICKS(1));
        Xil_Out32(XPAR_M_AXI_BASEADDR + ADCFIFO_RST_REG, 0);

        psc_send(the_server, 51, sizeof(adcmsg), adcmsg);


        // Read and send live TbT data
        for (i=0;i<8000;i++) {
        	tbtmsg[i].xpos = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + TBTFIFO_DATA_REG));
        	tbtmsg[i].ypos = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + TBTFIFO_DATA_REG));
        }

        Xil_Out32(XPAR_M_AXI_BASEADDR + TBTFIFO_RST_REG, 1);
        vTaskDelay(pdMS_TO_TICKS(1));
        Xil_Out32(XPAR_M_AXI_BASEADDR + TBTFIFO_RST_REG, 0);

        /*
        for (i = 0; i < 10; i++) {
            xil_printf("Sample %lu: A=%d  B=%d  C=%d  D=%d\r\n",
                       (unsigned long)i,
                       adcmsg[i].cha,
                       adcmsg[i].chb,
                       adcmsg[i].chc,
                       adcmsg[i].chd);
        }
        */

        psc_send(the_server, 52, sizeof(tbtmsg), tbtmsg);


    }
}

void livedata_setup(void)
{
    printf("INFO: Starting Live Data daemon\n");
    sys_thread_new("livedata", livedata_push, NULL, THREAD_STACKSIZE, DEFAULT_THREAD_PRIO);
}

