
// remote reporting thermistors on AFE

#include <stdio.h>


#include <xparameters.h>
//#include "xadcps.h"

#include <FreeRTOS.h>
#include <lwip/sys.h>
#include <lwip/stats.h>

#include "local.h"
#include "zubpm.h"







static void thermistors_push(void *unused)
{
    (void)unused;
    float temp1, temp2;


    static struct {
        u32 fe_a;
        u32 fe_b;
        u32 fe_c;
        u32 fe_d;
        u32 adc_ab;
        u32 adc_cd;

    } msg;


    setup_thermistors(0);
    setup_thermistors(1);
    setup_thermistors(2);


    while(1) {

        vTaskDelay(pdMS_TO_TICKS(1));
        //read temperatures from Thermistors on AFE
      	read_thermistors(0,&temp1,&temp2);
      	//printf("Therm1:  %8f  %8f\r\n",temp1,temp2);
        msg.fe_a = htonf(temp1);
        msg.fe_b = htonf(temp2);
      	read_thermistors(1,&temp1,&temp2);
      	//printf("Therm1:  %8f  %8f\r\n",temp1,temp2);
        msg.fe_c = htonf(temp1);
        msg.fe_d = htonf(temp2);
      	read_thermistors(2,&temp1,&temp2);
      	//printf("Therm1:  %8f  %8f\r\n",temp1,temp2);
        msg.adc_ab = htonf(temp1);
        msg.adc_cd = htonf(temp2);



        psc_send(the_server, 33, sizeof(msg), &msg);
    }
}



void thermistor_setup(void)
{
    printf("INFO: Starting Thermistors daemon\n");

    sys_thread_new("thermistor", thermistors_push, NULL, THREAD_STACKSIZE, DEFAULT_THREAD_PRIO);
}

