
// Gather and Send General Register Readbacks

#include <stdio.h>


#include <xparameters.h>

#include <FreeRTOS.h>
#include <lwip/sys.h>
#include <lwip/stats.h>

#include "local.h"
#include "zubpm.h"
#include "pl_regs.h"

#include "xtime_l.h"




static void gendata_push(void *unused)
{
    (void)unused;
    u32 dmastatus;

    static struct {
    	u32 pll_locked;         //PSC Offset 0
    	u32 cha_gain;           //PSC Offset 4
        u32 chb_gain;  		    //PSC Offset 8
        u32 chc_gain;           //PSC Offset 12
        u32 chd_gain;           //PSC Offset 16
        u32 rf_atten;           //PSC Offset 20
        u32 kx;				    //PSC Offset 24
        u32 ky; 			    //PSC Offset 28
        u32 bba_xoff;           //PSC Offset 32
        u32 bba_yoff;           //PSC Offset 36
        u32 evr_ts_s_triglat;   //PSC Offset 40
    	u32 evr_ts_ns_triglat;  //PSC Offset 44
        u32 trig_eventno;       //PSC Offset 48
        u32 trig_dmacnt;        //PSC Offset 52
        u32 fine_trig_dly;      //PSC Offset 56
        u32 coarse_trig_dly;    //PSC Offset 60
        u32 trigtobeam_thresh;  //PSC Offset 64
    	u32 trigtobeam_dly;     //PSC Offset 68
    	u32 dma_adclen;         //PSC Offset 72
    	u32 dma_tbtlen;         //PSC Offset 76
    	u32 dma_falen;          //PSC Offset 80
    	u32 dma_adc_active;     //PSC Offset 84
    	u32 dma_tbt_active;     //PSC Offset 88
    	u32 dma_fa_active;      //PSC Offset 92
    	u32 dma_tx_active;      //PSC Offset 96
    } msg;




    while(1) {



        //update at 5Hz
        vTaskDelay(pdMS_TO_TICKS(100));

        msg.cha_gain = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + CHA_GAIN_REG));
        msg.chb_gain = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + CHB_GAIN_REG));
        msg.chc_gain = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + CHC_GAIN_REG));
        msg.chd_gain = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + CHD_GAIN_REG));
        msg.pll_locked = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + PLL_LOCKED_REG));
        msg.kx = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + KX_REG));
        msg.ky = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + KY_REG));
        msg.bba_xoff = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + BBA_XOFF_REG));
        msg.bba_yoff = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + BBA_YOFF_REG));
        msg.rf_atten = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + RF_DSA_REG) / 4);
        msg.coarse_trig_dly = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + COARSE_TRIG_DLY_REG));
        //msg.fine_trig_dly = Xil_In32(XPAR_M_AXI_BASEADDR + FINE_TRIG_DLY_REG);

        msg.trig_dmacnt = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + DMA_TRIGCNT_REG));
        msg.dma_adclen = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + DMA_ADCBURSTLEN_REG));
        msg.dma_tbtlen = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + DMA_TBTBURSTLEN_REG));
        msg.dma_falen = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + DMA_FABURSTLEN_REG));

        msg.trig_eventno = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + EVR_DMA_TRIGNUM_REG));
        msg.evr_ts_s_triglat = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + EVR_TS_S_LAT_REG));
        msg.evr_ts_ns_triglat = htonl(Xil_In32(XPAR_M_AXI_BASEADDR + EVR_TS_NS_LAT_REG));
        //msg.trigtobeam_thresh = Xil_In32(XPAR_M_AXI_BASEADDR + TRIGTOBEAM_THRESH_REG);
        //msg.trigtobeam_dly = Xil_In32(XPAR_M_AXI_BASEADDR + TRIGTOBEAM_DLY_REG);

        dmastatus = Xil_In32(XPAR_M_AXI_BASEADDR + DMA_STATUS_REG);
        msg.dma_adc_active = htonl((dmastatus & 0x10) >> 4);
        msg.dma_tbt_active = htonl((dmastatus & 0x8) >> 3);
        msg.dma_fa_active = htonl((dmastatus & 0x4) >> 2);
        //tx_active is really dma_permit signal in trigcntrl.vhd
        msg.dma_tx_active = htonl((dmastatus & 0x2) >> 1);

        //xil_printf("Sending GenRegs...\r\n");
        psc_send(the_server, 30, sizeof(msg), &msg);
    }
}

void gendata_setup(void)
{
    printf("INFO: Starting General Data daemon\n");
    sys_thread_new("gendata", gendata_push, NULL, THREAD_STACKSIZE, DEFAULT_THREAD_PRIO);
}

