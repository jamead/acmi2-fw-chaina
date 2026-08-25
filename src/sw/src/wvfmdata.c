
// get waveform data from Artix and send to IOC

#include <stdio.h>


#include <xparameters.h>

#include <FreeRTOS.h>
#include <lwip/sys.h>
#include <lwip/stats.h>

#include "local.h"
#include "at24eeprom.h"

#include "pl_regs.h"
#include "wvfmdata.h"


void PulseStatsGatherData(pulse_stats_msg_t *stats)
{
    uint32_t addr;

    for (unsigned i = 0; i < 5; i++) {

        addr = XPAR_M_AXI_BASEADDR +
               PULSE_STATS_BASE_REG +
               (i * PULSE_STATS_STRIDE);

        stats->pulse[i].baseline =
            Xil_In32(addr + PULSE_STATS_BASELINE_OFFSET);

        stats->pulse[i].integral =
            Xil_In32(addr + PULSE_STATS_INTEGRAL_OFFSET);

        stats->pulse[i].peak =
            Xil_In32(addr + PULSE_STATS_PEAK_OFFSET);

        stats->pulse[i].peak_index =
            Xil_In32(addr + PULSE_STATS_PEAK_INDEX_OFFSET);

        stats->pulse[i].peak_found =
            Xil_In32(addr + PULSE_STATS_PEAK_FOUND_OFFSET);

        stats->pulse[i].threshold =
            Xil_In32(addr + PULSE_STATS_THRESHOLD_OFFSET);

        stats->pulse[i].fwhm =
            Xil_In32(addr + PULSE_STATS_FWHM_OFFSET);
    }
}


static void send_adc_waveform(void)
{
    static int16_t wvfm_adc[WVFM_NUM_SAMPLES];

    for (uint32_t i = 0; i < WVFM_NUM_SAMPLES; i++) {
        int16_t sample = (int16_t)REG_READ(ADCFIFO_DATA_REG);
        wvfm_adc[i] = (int16_t)htons((uint16_t)sample);
    }

    psc_send(the_server,
             MSGID_WVFM,
             sizeof(wvfm_adc),
             wvfm_adc);
}

static void htonl_words(void *data, uint32_t num_words)
{
    uint32_t *p = (uint32_t *)data;

    for (uint32_t i = 0; i < num_words; i++) {
        p[i] = htonl(p[i]);
    }
}


static uint32_t wait_for_adc_fifo(uint32_t debug)
{
    uint32_t wordcnt;
    uint32_t pollcnt = 0;

    do {
        wordcnt = REG_READ(ADCFIFO_RDCNT_REG);

        if (debug) {
            xil_printf("PollCnt: %lu    Num FIFO Words: %lu\r\n",
                       pollcnt, wordcnt);
        }

        pollcnt++;
        vTaskDelay(pdMS_TO_TICKS(100));

    } while (wordcnt < 8000);

    return wordcnt;
}


static void reset_adc_fifo(uint32_t debug)
{
    if (debug)
        xil_printf("Resetting FIFO...\r\n");

    REG_WRITE(ADCFIFO_RST_REG, 1);
    vTaskDelay(pdMS_TO_TICKS(1));

    REG_WRITE(ADCFIFO_RST_REG, 0);
    vTaskDelay(pdMS_TO_TICKS(1));

    if (debug) {
        uint32_t wordcnt = REG_READ(ADCFIFO_RDCNT_REG);

        xil_printf("Num FIFO Words: %lu\r\n", wordcnt);
    }
}

static void send_timestamp(void)
{
    uint32_t timestamp[2];

    timestamp[0] = htonl(REG_READ(EVR_TS_NS_REG));
    timestamp[1] = htonl(REG_READ(EVR_TS_S_REG));

    psc_send(the_server,
             MSGID_TIMESTAMP,
             sizeof(timestamp),
             timestamp);
}


static void send_eeprom_data(void)
{
    Eeprom_params_msg_t data;

    EepromGatherData(&data);

    htonl_words(&data, EEPROM_PARAMS_NUM_REGS);

    psc_send(the_server,
             MSGID_EEPROM,
             sizeof(data),
             &data);
}


static void send_pulse_stats(void)
{
    pulse_stats_msg_t data;

    PulseStatsGatherData(&data);

    htonl_words(&data, sizeof(data) / sizeof(uint32_t));

    psc_send(the_server,
             MSGID_PULSE_STATS,
             sizeof(data),
             &data);
}





static void wvfmdata_push(void *unused)
{
    (void)unused;

    const uint32_t debug = 0;

    while (1) {

        uint32_t wordcnt = wait_for_adc_fifo(debug);

        if (wordcnt > WVFM_FIFO_MIN_WORDS) {
            send_pulse_stats();
            send_adc_waveform();
            send_timestamp();
        }

        reset_adc_fifo(debug);
        send_eeprom_data();
    }
}



void wvfmdata_setup(void)
{
    printf("INFO: Starting Wvfm Data daemon\n");
    sys_thread_new("wvfmdata", wvfmdata_push, NULL, THREAD_STACKSIZE, DEFAULT_THREAD_PRIO);
}

