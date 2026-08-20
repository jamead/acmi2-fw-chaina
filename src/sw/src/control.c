
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
#include "zubpm.h"
#include "pl_regs.h"
#include "psc_msg.h"








void set_fpleds(u32 msgVal)  {
	Xil_Out32(XPAR_M_AXI_BASEADDR + FP_LEDS_REG, msgVal);
}


void soft_trig(u32 msgVal) {
	if (msgVal == 1) {
      xil_printf("Soft Trigger...\r\n");
	  Xil_Out32(XPAR_M_AXI_BASEADDR + DMA_SOFTTRIG_REG, 1);
	  Xil_Out32(XPAR_M_AXI_BASEADDR + DMA_SOFTTRIG_REG, 0);
	}
}

void set_atten(u32 msgVal) {
    xil_printf("Setting RF attenuator to %d dB\r\n",msgVal);
    Xil_Out32(XPAR_M_AXI_BASEADDR + RF_DSA_REG, msgVal*4);
}

void set_geo_dly(u32 msgVal) {
    // the Geo delay is the same as tbt_gate delay, set them both for now
	Xil_Out32(XPAR_M_AXI_BASEADDR + FINE_TRIG_DLY_REG, msgVal);
	Xil_Out32(XPAR_M_AXI_BASEADDR + TBT_GATEDLY_REG, msgVal);
}


void set_coarse_dly(u32 msgVal) {
	Xil_Out32(XPAR_M_AXI_BASEADDR + COARSE_TRIG_DLY_REG, msgVal);
}



void set_trigtobeam_thresh(int msgVal) {
	Xil_Out32(XPAR_M_AXI_BASEADDR + TRIGTOBEAM_THRESH_REG, msgVal);
}


void set_eventno(u32 msgVal) {
	Xil_Out32(XPAR_M_AXI_BASEADDR + EVR_DMA_TRIGNUM_REG, msgVal);
}

void set_trigsrc(u32 msgVal) {
    if (msgVal == 0) {
        xil_printf("Setting Trigger Source to EVR\r\n");
        Xil_Out32(XPAR_M_AXI_BASEADDR + DMA_TRIGSRC_REG, msgVal);
    }
    else if (msgVal == 1) {
	    xil_printf("Setting Trigger Source to INT (soft)\r\n");
        Xil_Out32(XPAR_M_AXI_BASEADDR + DMA_TRIGSRC_REG, msgVal);
    }
    else
        xil_printf("Invalid Trigger Source\r\n");

}



void set_kxky(u32 axis, u32 msgVal) {

    if (axis == HOR)	{
       xil_printf("Setting Kx to %d nm\r\n",msgVal);
       Xil_Out32(XPAR_M_AXI_BASEADDR + KX_REG, msgVal);
    }
    else {
       xil_printf("Setting Ky to %d nm\r\n",msgVal);
       Xil_Out32(XPAR_M_AXI_BASEADDR + KY_REG, msgVal);

    }
}


void set_bbaoffset(u32 axis, u32 msgVal) {

    if (axis == HOR)	{
       xil_printf("Setting BBA X to %d nm\r\n",msgVal);
       Xil_Out32(XPAR_M_AXI_BASEADDR + BBA_XOFF_REG, msgVal);

    }
    else {
       xil_printf("Setting BBA Y to %d nm\r\n",msgVal);
       Xil_Out32(XPAR_M_AXI_BASEADDR + BBA_YOFF_REG, msgVal);
    }
}


static inline int clamp(int val, int min, int max) {
    if (val < min) return min;
    if (val > max) return max;
    return val;
}


void set_dmalen(u32 channel, u32 msgVal) {

   u32 dmalen;

   xil_printf("Disable DMA\r\n");
   Xil_Out32(XPAR_M_AXI_BASEADDR + DMA_ADCENABLE_REG, 0);
   Xil_Out32(XPAR_M_AXI_BASEADDR + DMA_TBTENABLE_REG, 0);
   Xil_Out32(XPAR_M_AXI_BASEADDR + DMA_FAENABLE_REG, 0);


  switch(channel) {
    case ADC:
    	dmalen = clamp(msgVal, 1000, 1000000);
    	Xil_Out32(XPAR_M_AXI_BASEADDR + DMA_ADCBURSTLEN_REG, dmalen);
    	xil_printf("Setting ADC DMA length to %d\r\n", dmalen);
	    break;

	case TBT:
    	dmalen = clamp(msgVal, 1000, 1000000);
    	Xil_Out32(XPAR_M_AXI_BASEADDR + DMA_TBTBURSTLEN_REG, dmalen);
        xil_printf("Setting TBT DMA length to %d\r\n",dmalen);
	    break;

    case FA:
    	dmalen = clamp(msgVal, 1000, 100000);
    	Xil_Out32(XPAR_M_AXI_BASEADDR + DMA_FABURSTLEN_REG, dmalen);
        xil_printf("Setting FA DMA length to %d\r\n",dmalen);
	    break;

    default:
        xil_printf("Invalid channel number\r\n");
	    break;
    }

  //now need to re-arm the DMA engine with the new length
  dma_arm();

}





void set_gain(u32 channel, u32 msgVal) {

switch(channel) {
    case CHA:
       Xil_Out32(XPAR_M_AXI_BASEADDR + CHA_GAIN_REG, msgVal);
       xil_printf("Setting ChA gain to %d \r\n",msgVal);
	   break;
	case CHB:
	   Xil_Out32(XPAR_M_AXI_BASEADDR + CHB_GAIN_REG, msgVal);
       xil_printf("Setting ChB gain to %d\r\n",msgVal);
	   break;
    case CHC:
       Xil_Out32(XPAR_M_AXI_BASEADDR + CHC_GAIN_REG, msgVal);
       xil_printf("Setting ChC gain to %d\r\n",msgVal);
	   break;
	case CHD:
	   Xil_Out32(XPAR_M_AXI_BASEADDR + CHD_GAIN_REG, msgVal);
       xil_printf("Setting ChD gain to %d\r\n",msgVal);
	   break;
    default:
       xil_printf("Invalid gain channel number\r\n");
	   break;
    }
}


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
        case SOFT_TRIG_MSG:
            soft_trig(data.u);
            break;

		case DMA_TRIG_SRC_MSG:
			xil_printf("Set Trigger Source Message:   Value=%d\r\n",data.u);
            set_trigsrc(data.u);
            break;

		case RF_ATTEN_MSG:
			xil_printf("RF Attenuator Message:   Value=%d\r\n",data.u);
            set_atten(data.u);
            break;

		case KX_MSG:
			xil_printf("Kx Message:   Value=%d\r\n",data.u);
            set_kxky(HOR,data.u);
            break;

		case KY_MSG:
		    xil_printf("Ky Message:   Value=%d\r\n",data.u);
            set_kxky(VERT,data.u);
            break;

        case BBA_XOFF_MSG:
           	xil_printf("BBA X Offset:   Value=%d\r\n",data.u);
           	set_bbaoffset(HOR,data.u);
            break;

        case BBA_YOFF_MSG:
           	xil_printf("BBA Y Offset:   Value=%d\r\n",data.u);
           	set_bbaoffset(VERT,data.u);
            break;

        case CHA_GAIN_MSG:
           	xil_printf("ChA Gain Message:   Value=%d\r\n",data.u);
            set_gain(CHA,data.u);
            break;

        case CHB_GAIN_MSG:
          	xil_printf("ChB Gain Message:   Value=%d\r\n",data.u);
            set_gain(CHB,data.u);
            break;

        case CHC_GAIN_MSG:
          	xil_printf("ChC Gain Message:   Value=%d\r\n",data.u);
            set_gain(CHC,data.u);
            break;

        case CHD_GAIN_MSG:
          	xil_printf("ChD Gain Message:   Value=%d\r\n",data.u);
            set_gain(CHD,data.u);
            break;

        case FINE_TRIG_DLY_MSG:
          	xil_printf("Fine Trig Delay Message:   Value=%d\r\n",data.u);
            //set_geo_dly(data.u);
            break;

        case COARSE_TRIG_DLY_MSG:
          	xil_printf("Coarse Trig Delay Message:   Value=%d\r\n",data.u);
          	//set_coarse_dly(data.u);
           	break;

        case TRIGTOBEAM_THRESH_MSG:
           	xil_printf("Trigger to Beam Threshold Message:   Value=%d\r\n",data.u);
          	//set_trigtobeam_thresh(data.u);
           	break;

        case DDC_LPFILT_SEL_MSG:
           	xil_printf("DDC LP Filter Select:   Value=%d\r\n",data.u);
        	Xil_Out32(XPAR_M_AXI_BASEADDR + DDC_LPFILT_SEL_REG, data.u);
           	break;

        case EVENT_NO_MSG:
           	xil_printf("DMA Event Number Message:   Value=%d\r\n",data.u);
            set_eventno(data.u);
            break;


        case FP_LED_MSG:
          	xil_printf("Setting FP LED:   Value=%d\r\n",data.u);
          	//set_fpleds(data.u);
          	break;

        case DMA_ADCLEN_MSG:
          	xil_printf("Setting DMA ADC Length:   Value=%d\r\n",data.u);
          	set_dmalen(ADC,data.u);
          	break;

        case DMA_TBTLEN_MSG:
           	xil_printf("Setting DMA TBT Length:   Value=%d\r\n",data.u);
           	set_dmalen(TBT,data.u);
           	break;

        case DMA_FALEN_MSG:
          	xil_printf("Setting DMA FA Length:   Value=%d\r\n",data.u);
           	set_dmalen(FA,data.u);
          	break;

        case EVENT_SRC_SEL_MSG:
           	xil_printf("Setting Event Source:   Value=%d\r\n",data.u);
           	Xil_Out32(XPAR_M_AXI_BASEADDR + EVENT_SRC_SEL_REG, data.u);
           	break;

        case RFFESW_ENB_MSG:
          	xil_printf("Setting RF Switching Enable   Value=%d\r\n",data.u);
          	Xil_Out32(XPAR_M_AXI_BASEADDR + SWRFFE_ENB_REG, data.u);
          	break;

        case RFFESW_TRIGDLY_MSG:
          	xil_printf("Setting RF Switching Trigger Delay   Value=%d\r\n",data.u);
          	Xil_Out32(XPAR_M_AXI_BASEADDR + SWRFFE_TRIGDLY_REG, data.u);
          	break;

        case RFFESW_DEMUXDLY_MSG:
          	xil_printf("Setting RF Switching Demux Delay   Value=%d\r\n",data.u);
          	Xil_Out32(XPAR_M_AXI_BASEADDR + SWRFFE_DEMUXDLY_REG, data.u);
          	break;

        case RFFESW_ADCDMASEL_MSG:
		    xil_printf("Setting ADC DMA Source Value=%d\r\n",data.u);
            Xil_Out32(XPAR_M_AXI_BASEADDR + SWRFFE_ADCDMASEL_REG, data.u);
            break;



        case ADC_IDLY_MSG:
           	xil_printf("Setting ADC IDLY:  Value=%d\r\n",data.u);
           	Xil_Out32(XPAR_M_AXI_BASEADDR + ADC_IDLYWVAL_REG, data.u);
           	//strobe the idly value into all 16 idly registers
           	Xil_Out32(XPAR_M_AXI_BASEADDR + ADC_IDLYSTR_REG, 0xFFFF);
           	Xil_Out32(XPAR_M_AXI_BASEADDR + ADC_IDLYSTR_REG, 0);
           	usleep(10);
           	rdval = Xil_In32(XPAR_M_AXI_BASEADDR + ADC_IDLYCHARVAL_REG);
           	xil_printf("ChA IDLY rval=%d\r\n",rdval);
           	rdval = Xil_In32(XPAR_M_AXI_BASEADDR + ADC_IDLYCHBRVAL_REG);
           	xil_printf("ChB IDLY rval=%d\r\n",rdval);
           	rdval = Xil_In32(XPAR_M_AXI_BASEADDR + ADC_IDLYCHCRVAL_REG);
           	xil_printf("ChC IDLY rval=%d\r\n",rdval);
           	rdval = Xil_In32(XPAR_M_AXI_BASEADDR + ADC_IDLYCHDRVAL_REG);
           	xil_printf("ChD IDLY rval=%d\r\n",rdval);
            break;


        case ADC_MMCM0_MSG:
           	if (data.u == 1) {
           		xil_printf("Setting ADC0 MMCM FCO Delay\r\n");
           	    Xil_Out32(XPAR_M_AXI_BASEADDR + ADC_FCOMMCM_REG, 1);
           	    Xil_Out32(XPAR_M_AXI_BASEADDR + ADC_FCOMMCM_REG, 0);
           	}
            break;

        case ADC_MMCM1_MSG:
           	if (data.u == 1) {
          		xil_printf("Setting ADC1 MMCM FCO Delay\r\n");
           	    Xil_Out32(XPAR_M_AXI_BASEADDR + ADC_FCOMMCM_REG, 2);
           	    Xil_Out32(XPAR_M_AXI_BASEADDR + ADC_FCOMMCM_REG, 0);
           	}
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



