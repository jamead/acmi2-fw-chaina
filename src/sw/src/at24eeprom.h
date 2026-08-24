
#define EEPROM_ADDR      0x50    // 7-bit Address
#define EEPROM_PAGE_SIZE 252



#ifndef PSC_MESSAGES_H
#define PSC_MESSAGES_H

#include <stdint.h>

typedef struct {
    uint32_t header;

    uint32_t tp1_pulse_delay;
    uint32_t tp1_pulse_width;
    uint32_t tp1_adc_delay;

    uint32_t tp2_pulse_delay;
    uint32_t tp2_pulse_width;
    uint32_t tp2_adc_delay;

    uint32_t tp3_pulse_delay;
    uint32_t tp3_pulse_width;
    uint32_t tp3_adc_delay;

    uint32_t beam_adc_delay;
    uint32_t beam_oow_threshold;

    uint32_t tp1_int_low_limit;
    uint32_t tp1_int_high_limit;
    uint32_t tp2_int_low_limit;
    uint32_t tp2_int_high_limit;
    uint32_t tp3_int_low_limit;
    uint32_t tp3_int_high_limit;

    uint32_t tp1_peak_low_limit;
    uint32_t tp1_peak_high_limit;
    uint32_t tp2_peak_low_limit;
    uint32_t tp2_peak_high_limit;
    uint32_t tp3_peak_low_limit;
    uint32_t tp3_peak_high_limit;

    uint32_t tp1_fwhm_low_limit;
    uint32_t tp1_fwhm_high_limit;
    uint32_t tp2_fwhm_low_limit;
    uint32_t tp2_fwhm_high_limit;
    uint32_t tp3_fwhm_low_limit;
    uint32_t tp3_fwhm_high_limit;

    uint32_t tp1_base_low_limit;
    uint32_t tp1_base_high_limit;
    uint32_t tp2_base_low_limit;
    uint32_t tp2_base_high_limit;
    uint32_t tp3_base_low_limit;
    uint32_t tp3_base_high_limit;

    uint32_t tp1_pos_level;
    uint32_t tp2_pos_level;
    uint32_t tp3_pos_level;

    uint32_t tp1_neg_level;
    uint32_t tp2_neg_level;
    uint32_t tp3_neg_level;

    uint32_t accum_HL;
    uint32_t beam_HL;

    uint32_t baseline_low_limit;
    uint32_t baseline_high_limit;

    uint32_t charge_cal;
    uint32_t accum_q_min;
    uint32_t accum_len;

    uint32_t crc_eeprom;

} Eeprom_params_msg_t;




typedef struct {
    uint32_t baseline;
    uint32_t integral;
    uint32_t peak;
    uint32_t peak_index;
    uint32_t peak_found;
    uint32_t threshold;
    uint32_t fwhm;
} pulse_stats_t;

typedef struct {
    pulse_stats_t pulse[5];
} pulse_stats_msg_t;



#endif /* PSC_MESSAGES_H */




int EepromFlashInit();

void EepromGatherData(Eeprom_params_msg_t *data);
void EepromDisperseData(u8 *readbuf);
void EepromPrintData(Eeprom_params_msg_t *data);
void GetEepromSettings(u32 chan);





