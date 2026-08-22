
// get waveform data from Artix and send to IOC

#include <stdio.h>


#include <xparameters.h>

#include <FreeRTOS.h>
#include <lwip/sys.h>
#include <lwip/stats.h>

#include "local.h"

#include "pl_regs.h"








static void wvfmdata_push(void *unused)
{
    (void)unused;

    u32 wvfm_debug = 1;
    u32 wordcnt, pollcnt;
    u32 i;
    s32 rdbk;


    static s32 pulse_stats[64];
    static s32 eeprom[64];
    static s16 boow_adc[128];
    static s16 wvfm_adc[16000];
    static u32 timestamp[2];





    while(1) {

        //vTaskDelay(pdMS_TO_TICKS(100));
        //xil_printf("Triggering Artix...\r\n");
        //soft_trig_artix();


        vTaskDelay(pdMS_TO_TICKS(100));
        pollcnt = 0;
        do {
        	wordcnt = Xil_In32(XPAR_M_AXI_BASEADDR + ADCFIFO_RDCNT_REG);
        	vTaskDelay(pdMS_TO_TICKS(100));
           if (wvfm_debug) xil_printf("PollCnt: %d    Num FIFO Words: %d\r\n", pollcnt, wordcnt);
        	pollcnt++;
        } while (wordcnt < 8000); // && (pollcnt < 5000));

        xil_printf("Got Trig!   PollCnt: %d     Num FIFO Words: %d\r\n", pollcnt, wordcnt);

        if (wordcnt > 8000) {

          // First 64 words are Pulse Statistics
          //if (wvfm_debug)  xil_printf("Pulse Stats...\r\n");
          //for (i=0;i<64;i++) {
          // 	  rdbk = Xil_In32(XPAR_M_AXI_BASEADDR + ADCFIFO_DATA_REG);
       // 	  if (wvfm_debug)  xil_printf("%d:  %x\r\n", i,rdbk);
       // 	  pulse_stats[i] = htonl(rdbk);
        //  }

         // if (wvfm_debug) xil_printf("EEPROM Settings...\r\n");
          // Words 64-127 are EEPROM settings
         // for (i=0;i<64;i++) {
       // 	  rdbk = Xil_In32(XPAR_M_AXI_BASEADDR + ADCFIFO_DATA_REG);
       // 	  if (wvfm_debug)  xil_printf("%d:  %d\r\n", i,rdbk);
        //	  eeprom[i] = htonl(rdbk);
          //}


          // Words 192-255 are BOOW adc data
          //for (i=0;i<128;i=i+2) {
        //	  //2 ADC samples are packed in a 32 bit word
        //	  rdbk = Xil_In32(XPAR_M_AXI_BASEADDR + ADCFIFO_DATA_REG);
        //	  boow_adc[i]   = htons((s16) ((rdbk & 0xFFFF0000) >> 16));
        //	  boow_adc[i+1] = htons((s16) (rdbk & 0xFFFF));
         // }


          //  16k are the ADC samples after the trigger
          for (i=0;i<16000;i++) {
        	  rdbk = Xil_In32(XPAR_M_AXI_BASEADDR + ADCFIFO_DATA_REG);
        	  wvfm_adc[i] = htonl(rdbk);

          }

          timestamp[0] = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + EVR_TS_NS_LAT_REG));
          timestamp[1] = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + EVR_TS_S_LAT_REG));
          //xil_printf("Timestamp ns: %d\r\n",timestamp[0]);
          //xil_printf("Timestamp s : %d\r\n",timestamp[1]);

          /*
          for (i=0;i<16258;i++) {
           //read FIFO
        	wvfm[i] = Xil_In32(XPAR_M_AXI_BASEADDR + FIFO_DATA_REG);
        	if ((i<128) && (wvfm_debug))
        	  xil_printf("%d:  %x\r\n", i,wvfm[i]);
        	if (i==37)  //over write word #37 from Artix with EVR Timestamp sec
        	   wvfm[i] = 0; //ts_s;
        	if (i==38) //overwrite word #38 from Artix with EVR Timestamp ns
        	   wvfm[i] = 0; //ts_ns;

          }
          */




        }


        if (wvfm_debug) xil_printf("Resetting FIFO...\r\n");
        Xil_Out32(XPAR_M_AXI_BASEADDR + ADCFIFO_RST_REG, 1);
        vTaskDelay(pdMS_TO_TICKS(1));
        Xil_Out32(XPAR_M_AXI_BASEADDR + ADCFIFO_RST_REG, 0);
        vTaskDelay(pdMS_TO_TICKS(1));

        wordcnt = Xil_In32(XPAR_M_AXI_BASEADDR + ADCFIFO_RDCNT_REG);
        if (wvfm_debug) xil_printf("Num FIFO Words: %d\r\n", wordcnt);

        //xil_printf("\r\n\r\n");




        //psc_send(the_server, 52, sizeof(eeprom), eeprom);
        //psc_send(the_server, 53, sizeof(boow_adc), boow_adc);
        psc_send(the_server, 54, sizeof(wvfm_adc), wvfm_adc);
        //psc_send(the_server, 51, sizeof(pulse_stats), pulse_stats);
        psc_send(the_server, 55, sizeof(timestamp), timestamp);


    }
}

void wvfmdata_setup(void)
{
    printf("INFO: Starting Wvfm Data daemon\n");
    sys_thread_new("wvfmdata", wvfmdata_push, NULL, THREAD_STACKSIZE, DEFAULT_THREAD_PRIO);
}

