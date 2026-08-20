
// remote reporting of select LwIP statistics

#include <stdio.h>

//#include <xsysmon.h>
#include <xparameters.h>
//#include "xadcps.h"

#include <FreeRTOS.h>
#include <lwip/sys.h>
#include <lwip/stats.h>

#include "local.h"

#include "xtime_l.h"

#include "zubpm.h"

#define MAX_TASKS 16

//static XSysMon xmon;

void test_delay() {
    XTime tStart, tEnd;
    XTime_GetTime(&tStart);

    vTaskDelay(pdMS_TO_TICKS(1000));

    XTime_GetTime(&tEnd);
    double elapsed_sec = (double)(tEnd - tStart) / COUNTS_PER_SECOND;

    printf("Elapsed time: %.3f seconds\n", elapsed_sec);
}


static void lstats_push(void *unused)
{
    (void)unused;

    char ip_addr[16];

    struct {
        uint32_t uptime;  // 0
        uint32_t nthread; // 4
        // 8 - LINK_STATS
        struct {
            uint32_t xmit; // 8
            uint32_t recv; // 12
            uint32_t drop; // 16
            uint32_t chkerr; // 20
            uint32_t memerr; // 24
            uint32_t proterr; // 28
            uint32_t err; // 32
        } link;
        // MEM_STATS
        struct {
            uint32_t err; // 36
            uint32_t avail; // 40
            uint32_t used; // 44
            uint32_t max; // 48
            uint32_t illegal; // 52
        } mem;
        struct {
            uint32_t avail; // 56
            uint32_t avail_largest_block; // 60
            uint32_t avail_lowest; // 64
            uint32_t nactive; // 68
        } os_mem;
        // for backwards compatibility, must only append new values.
    } msg;


    while(1) {

    	//xil_printf("Lstats Push...\r\n");
        vTaskDelay(pdMS_TO_TICKS(1000));

        // uptime as float32
        msg.uptime = htonf((xTaskGetTickCount() * 1.0f) / configTICK_RATE_HZ);
        msg.nthread = htonl(uxTaskGetNumberOfTasks());

        msg.link.xmit = htonl(lwip_stats.link.xmit);

        msg.link.recv = htonl(lwip_stats.link.recv);
        msg.link.drop = htonl(lwip_stats.link.drop);

        msg.link.chkerr = htonl(lwip_stats.link.chkerr);
        msg.link.memerr = htonl(lwip_stats.link.memerr);
        msg.link.proterr = htonl(lwip_stats.link.proterr);
        msg.link.err = htonl(lwip_stats.link.err);

        msg.mem.err = htonl(lwip_stats.mem.err);
        msg.mem.avail = htonl(lwip_stats.mem.avail);
        msg.mem.used = htonl(lwip_stats.mem.used);
        msg.mem.max = htonl(lwip_stats.mem.max);
        msg.mem.illegal = htonl(lwip_stats.mem.illegal);


        HeapStats_t stats;
        vPortGetHeapStats(&stats);
        msg.os_mem.avail = htonl(stats.xAvailableHeapSpaceInBytes);
        msg.os_mem.avail_lowest = htonl(stats.xMinimumEverFreeBytesRemaining);
        msg.os_mem.avail_largest_block = htonl(stats.xSizeOfLargestFreeBlockInBytes);
        msg.os_mem.nactive = htonl(stats.xNumberOfSuccessfulAllocations - stats.xNumberOfSuccessfulFrees);


        // LwIP inet_ntoa() uses a static char[] , so one call at a time
        //printf("%s\n", inet_ntoa(server_netif.ip_addr.addr));

        strncpy(ip_addr, inet_ntoa(server_netif.ip_addr.addr), sizeof(ip_addr));
        //printf("/%s", inet_ntoa(server_netif.netmask.addr));
        //printf(" gw: %s\n", inet_ntoa(server_netif.gw.addr));



        psc_send(the_server, 103, sizeof(ip_addr), &ip_addr);
        psc_send(the_server, 101, sizeof(msg), &msg);
    }
}

void lstats_setup(void)
{
    printf("INFO: Starting stats daemon\n");
    sys_thread_new("lstats", lstats_push, NULL, THREAD_STACKSIZE, DEFAULT_THREAD_PRIO);
}

