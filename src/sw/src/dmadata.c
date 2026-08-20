
// Trigger and Send DMA Data: ADC, TbT, FA

#include <stdio.h>

#include <xparameters.h>

#include <FreeRTOS.h>
#include <lwip/sys.h>
#include <lwip/stats.h>
#include "xil_cache.h"

#include "local.h"
#include "zubpm.h"
#include "pl_regs.h"
#include "dmadata.h"

#include "xtime_l.h"





void dma_arm() {

	//u32 *adc_ptr, *tbt_ptr, *fa_ptr;
	u32 adclen, tbtlen, falen;

	xil_printf("Arming DMA...\r\n");
	//Disable the ADC,TbT,FA DMA logic (trig_logic.vhd)
	//xil_printf("   Disable DMA\r\n");
	//Xil_Out32(XPAR_M_AXI_BASEADDR + DMA_ADCENABLE_REG, 0);
	//Xil_Out32(XPAR_M_AXI_BASEADDR + DMA_TBTENABLE_REG, 0);
	//Xil_Out32(XPAR_M_AXI_BASEADDR + DMA_FAENABLE_REG, 0);


	//Read the DMA length registers, just so we can print them
	adclen = Xil_In32(XPAR_M_AXI_BASEADDR + DMA_ADCBURSTLEN_REG);
	tbtlen = Xil_In32(XPAR_M_AXI_BASEADDR + DMA_TBTBURSTLEN_REG);
	falen = Xil_In32(XPAR_M_AXI_BASEADDR + DMA_FABURSTLEN_REG);

	xil_printf("   DMA ADC Length = %d\r\n",adclen);
	xil_printf("   DMA TbT Length = %d\r\n",tbtlen);
	xil_printf("   DMA FA Length = %d\r\n",falen);

	//clear the DMA memory, not necessary, already Invalidated it.
	//adc_ptr = (u32 *) ADC_DMA_DATA;
	//tbt_ptr = (u32 *) TBT_DMA_DATA;
	//fa_ptr  = (u32 *) FA_DMA_DATA;
	//for (i=0;i<10000000;i++)  adc_ptr[i] = 0;
	//for (i=0;i<10000000;i++)  tbt_ptr[i] = 0;
	//for (i=0;i<10000000;i++)  fa_ptr[i]  = 0;


	//reset the PL DMA FIFO
	Xil_Out32(XPAR_M_AXI_BASEADDR + DMA_FIFORST_REG, 1);
	Xil_Out32(XPAR_M_AXI_BASEADDR + DMA_FIFORST_REG, 0);

	//reset the AXI DMA Core
	Xil_Out32(XPAR_AXI_DMA_ADC_BASEADDR + S2MM_DMACR, 4);
	Xil_Out32(XPAR_AXI_DMA_TBT_BASEADDR + S2MM_DMACR, 4);
	Xil_Out32(XPAR_AXI_DMA_FA_BASEADDR + S2MM_DMACR, 4);

	//Start the S2MM channel with all interrupts masked
	Xil_Out32(XPAR_AXI_DMA_ADC_BASEADDR + S2MM_DMACR, 0xF001);
	Xil_Out32(XPAR_AXI_DMA_TBT_BASEADDR + S2MM_DMACR, 0xF001);
	Xil_Out32(XPAR_AXI_DMA_FA_BASEADDR + S2MM_DMACR, 0xF001);

	//Write the Destination Address for the ADC data
	Xil_Out32(XPAR_AXI_DMA_ADC_BASEADDR + S2MM_DA, ADC_DMA_DATA);
	Xil_Out32(XPAR_AXI_DMA_TBT_BASEADDR + S2MM_DA, TBT_DMA_DATA);
	Xil_Out32(XPAR_AXI_DMA_FA_BASEADDR + S2MM_DA, FA_DMA_DATA);


	//Write the S2MM transfer length (must be written last (PG021 p72)
    //length is in bytes, for adc: 4 adc channels * 2bytes/sample
	Xil_Out32(XPAR_AXI_DMA_ADC_BASEADDR + S2MM_LEN, (adclen+16) * 4 * 2);

	//length is in bytes, for TbT: 16 - 4 byte values
	Xil_Out32(XPAR_AXI_DMA_TBT_BASEADDR + S2MM_LEN, (tbtlen) * 16 * 4);

	//length is in bytes, for FA: 10 - 4 byte values
	Xil_Out32(XPAR_AXI_DMA_FA_BASEADDR + S2MM_LEN, (falen) * 10 * 4);


	//Enable the ADC,TbT,FA DMA logic (trig_logic.vhd)
	//DMA triggers are disabled until rising edge of ADC_ENABLE_REG
	//xil_printf("   Enabling DMA Triggers\r\n");
	//Xil_Out32(XPAR_M_AXI_BASEADDR + DMA_TBTENABLE_REG, 1);
	//Xil_Out32(XPAR_M_AXI_BASEADDR + DMA_FAENABLE_REG, 1);
	//Xil_Out32(XPAR_M_AXI_BASEADDR + DMA_ADCENABLE_REG, 1);


}

void process_FA_dma(famsg_t *famsg, u32 nsamples)
{
    u32 i;

    u32 *fa_data = (u32 *)FA_DMA_DATA;

    // Read samples from DMA buffer
    for (i = 0; i < nsamples; i++) {
        famsg[i].hdr = htonl(*fa_data++);
        famsg[i].cnt = htonl(*fa_data++);
        famsg[i].cha_mag = htonl(*fa_data++);
        famsg[i].chb_mag = htonl(*fa_data++);
        famsg[i].chc_mag = htonl(*fa_data++);
        famsg[i].chd_mag = htonl(*fa_data++);
        famsg[i].rsvd = htonl(*fa_data++);
        famsg[i].sum = htonl(*fa_data++);
        famsg[i].xpos_nm = htonl(*fa_data++);
        famsg[i].ypos_nm = htonl(*fa_data++);

    }

    // Debug print first 10
    /*
    for (i = 0; i < 10 && i < nsamples; i++) {
        xil_printf("FA Sample %lu: %8d  %8d  %8d  %8d\r\n",
                   (unsigned long)i,
                   ntohs(famsg[i].cha_mag),
                   ntohs(famsg[i].chb_mag),
                   ntohs(famsg[i].chc_mag),
                   ntohs(famsg[i].chd_mag));
    }
    */

    psc_send(the_server, 55, nsamples * sizeof(famsg_t), famsg);
}







void process_TbT_dma(tbtmsg_t *tbtmsg, u32 nsamples)
{
    u32 i;

    u32 *tbt_data = (u32 *)TBT_DMA_DATA;

    // Read samples from DMA buffer
    for (i = 0; i < nsamples; i++) {
        tbtmsg[i].hdr = htonl(*tbt_data++);
        tbtmsg[i].cnt = htonl(*tbt_data++);
        tbtmsg[i].cha_mag = htonl(*tbt_data++);
        tbtmsg[i].cha_phs = htonl(*tbt_data++);
        tbtmsg[i].chb_mag = htonl(*tbt_data++);
        tbtmsg[i].chb_phs = htonl(*tbt_data++);
        tbtmsg[i].chc_mag = htonl(*tbt_data++);
        tbtmsg[i].chc_phs = htonl(*tbt_data++);
        tbtmsg[i].chd_mag = htonl(*tbt_data++);
        tbtmsg[i].chd_phs = htonl(*tbt_data++);
        tbtmsg[i].xpos_raw = htonl(*tbt_data++);
        tbtmsg[i].ypos_raw = htonl(*tbt_data++);
        tbtmsg[i].rsvd = htonl(*tbt_data++);
        tbtmsg[i].sum = htonl(*tbt_data++);
        tbtmsg[i].xpos_nm = htonl(*tbt_data++);
        tbtmsg[i].ypos_nm = htonl(*tbt_data++);

    }

    // Debug print first 10
    /*
    for (i = 0; i < 10 && i < nsamples; i++) {
        xil_printf("Sample %lu: %8d  %8d  %8d  %8d\r\n",
                   (unsigned long)i,
                   ntohs(tbtmsg[i].cha_mag),
                   ntohs(tbtmsg[i].chb_mag),
                   ntohs(tbtmsg[i].chc_mag),
                   ntohs(tbtmsg[i].chd_mag));
    }
    */

    // Send buffer (size = nsamples * sizeof(adcmsg_t))
    psc_send(the_server, 54, nsamples * sizeof(tbtmsg_t), tbtmsg);
}




void process_ADC_dma(adcmsg_t *adcmsg, u32 nsamples)
{
    u32 i, regval;
    s16 cha, chb, chc, chd;
    u32 *adc_data = (u32 *)ADC_DMA_DATA;

    // Read samples from DMA buffer
    for (i = 0; i < nsamples; i++) {
        regval = *adc_data++;
        cha = (s16)((regval >> 16) & 0xFFFF);
        chb = (s16)(regval & 0xFFFF);

        regval = *adc_data++;
        chc = (s16)((regval >> 16) & 0xFFFF);
        chd = (s16)(regval & 0xFFFF);

        adcmsg[i].cha = htons(cha);
        adcmsg[i].chb = htons(chb);
        adcmsg[i].chc = htons(chc);
        adcmsg[i].chd = htons(chd);
    }

    // Debug print first 10
    /*
    for (i = 0; i < 10 && i < nsamples; i++) {
        xil_printf("Sample %lu: A=%d  B=%d  C=%d  D=%d\r\n",
                   (unsigned long)i,
                   ntohs(adcmsg[i].cha),
                   ntohs(adcmsg[i].chb),
                   ntohs(adcmsg[i].chc),
                   ntohs(adcmsg[i].chd));
    }
    */

    // Send buffer (size = nsamples * sizeof(adcmsg_t))
    psc_send(the_server, 53, nsamples * sizeof(adcmsg_t), adcmsg);
}






static void dmadata_push(void *unused)
{
    (void)unused;

    static adcmsg_t adcmsg[ADC_DMA_MAX_LEN];
    static tbtmsg_t tbtmsg[TBT_DMA_MAX_LEN];
    static famsg_t  famsg[FA_DMA_MAX_LEN];

    u32 adclen, tbtlen, falen;
    u32 trignum = 0, prevtrignum = 0;


    dma_arm();
	//Read the DMA length registers
	//adclen = Xil_In32(XPAR_M_AXI_BASEADDR + DMA_ADCBURSTLEN_REG);
	//tbtlen = Xil_In32(XPAR_M_AXI_BASEADDR + DMA_TBTBURSTLEN_REG);
	//falen = Xil_In32(XPAR_M_AXI_BASEADDR + DMA_FABURSTLEN_REG);


    while (1) {
        vTaskDelay(pdMS_TO_TICKS(10));

        //trignum is incremented after DMA data is pushed to DDR
        trignum = Xil_In32(XPAR_M_AXI_BASEADDR + DMA_TRIGCNT_REG);

        if (trignum != prevtrignum) {
            xil_printf("Received DMA Trigger Number: %d \r\n",trignum);
            //Xil_Out32(XPAR_M_AXI_BASEADDR + DMA_ADCENABLE_REG, 0);
            //Xil_Out32(XPAR_M_AXI_BASEADDR + DMA_TBTENABLE_REG, 0);
            //Xil_Out32(XPAR_M_AXI_BASEADDR + DMA_FAENABLE_REG, 0);

            //xil_printf("\nTrig Num: %d\r\n", trignum);
            prevtrignum = trignum;

            // Invalidate caches to see fresh DMA data
            Xil_DCacheInvalidateRange(ADC_DMA_DATA, ADC_DMA_MAX_LEN * sizeof(adcmsg_t));
            Xil_DCacheInvalidateRange(TBT_DMA_DATA, TBT_DMA_MAX_LEN * sizeof(tbtmsg_t));
            Xil_DCacheInvalidateRange(FA_DMA_DATA, FA_DMA_MAX_LEN * sizeof(famsg_t));

            // get the DMA lengths
           	adclen = Xil_In32(XPAR_M_AXI_BASEADDR + DMA_ADCBURSTLEN_REG);
        	tbtlen = Xil_In32(XPAR_M_AXI_BASEADDR + DMA_TBTBURSTLEN_REG);
        	falen = Xil_In32(XPAR_M_AXI_BASEADDR + DMA_FABURSTLEN_REG);

            // Process DMA data into adcmsg array
            process_ADC_dma(adcmsg, adclen);

            // Process DMA data into tbtmsg array
            process_TbT_dma(tbtmsg, tbtlen);

            // Process DMA data into tbtmsg array
            process_FA_dma(famsg, falen);

            // Clear DMA Trigger Latch, allows for next trigger
            Xil_Out32(XPAR_M_AXI_BASEADDR + DMA_TXTOIOC_DONE_REG, 1);
            Xil_Out32(XPAR_M_AXI_BASEADDR + DMA_TXTOIOC_DONE_REG, 0);




            // Re-arm DMA for next trigger
            dma_arm();

        }
    }
}

void dmadata_setup(void)
{
    printf("INFO: Starting DMA Data daemon\n");
    sys_thread_new("dmadata", dmadata_push, NULL, THREAD_STACKSIZE, DEFAULT_THREAD_PRIO);
}

