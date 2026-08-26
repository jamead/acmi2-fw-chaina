
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
#include "pulse_stats.h"


static uint32_t trigger_count = 0;


void PulseStatsGatherData(pulse_stats_msg_t *data)
{
    uint32_t addr;

    if (data == NULL)
        return;

    data->header  = 0x8000; //REG_READ(HEADER_REG);
    data->fpgaver = 123; //REG_READ(FPGAVER_REG);

    for (uint32_t i = 0; i < NUM_PULSES; i++) {

        addr = PULSE_STATS_BASE_REG + (i * PULSE_STATS_STRIDE);

        data->pulse[i].baseline   = (int32_t)(int16_t)REG_READ(addr + PULSE_STATS_BASELINE_OFFSET);
        xil_printf("%d: baseline: %d\r\n",i,data->pulse[i].baseline);
        data->pulse[i].peak       = REG_READ(addr + PULSE_STATS_PEAK_OFFSET);
        data->pulse[i].integral   = REG_READ(addr + PULSE_STATS_INTEGRAL_OFFSET);
        data->pulse[i].fwhm       = REG_READ(addr + PULSE_STATS_FWHM_OFFSET);
        data->pulse[i].peak_index = REG_READ(addr + PULSE_STATS_PEAK_INDEX_OFFSET);
    }

    data->faults_live_raw      = 0; //REG_READ(FAULTS_LIVE_RAW_REG);
    data->faults_lat           = 0; //REG_READ(FAULTS_LAT_REG);
    data->trig_cnt             = trigger_count; //REG_READ(TRIG_CNT_REG);
    data->accum                = 0; //REG_READ(ACCUM_REG);
    data->acis                 = 0; //REG_READ(ACIS_REG);
    data->crc_artix            = 0; //REG_READ(CRC_ARTIX_REG);
    data->faults_tp            = 0; //REG_READ(FAULTS_TP_REG);
    data->startup_cnt          = 0; //REG_READ(STARTUP_CNT_REG);
    data->beamaccum_limit_calc = 0; //REG_READ(BEAMACCUM_LIMIT_CALC_REG);
}



static void send_adc_waveform(void)
{
    static int16_t wvfm_adc[WVFM_NUM_SAMPLES];

    for (uint32_t i = 0; i < WVFM_NUM_SAMPLES; i++) {
        int16_t sample = (int16_t)REG_READ(ADCFIFO_DATA_REG);
        //if (i<100)
		//  xil_printf("%d:  %d\r\n",i,sample);
        wvfm_adc[i] = (int16_t)htons((int16_t)sample);
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

    xil_printf("Got Trigger!\r\n");

    trigger_count++;

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
            send_adc_waveform();
        	send_pulse_stats();
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

