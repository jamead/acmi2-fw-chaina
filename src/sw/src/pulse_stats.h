#ifndef PULSE_STATS_H
#define PULSE_STATS_H

#include <stdint.h>



#define NUM_PULSES  5U

typedef struct {
    int32_t baseline;
    uint32_t peak;
    uint32_t integral;
    uint32_t fwhm;
    uint32_t peak_index;
} pulse_info_t;


typedef struct {
    uint32_t header;                   // offset 0
    uint32_t fpgaver;                  // offset 4

    pulse_info_t pulse[NUM_PULSES];    // offsets 8 - 104
                                      // pulse[0] = BEAM
                                      // pulse[1] = TP1
                                      // pulse[2] = TP2
                                      // pulse[3] = TP3
                                      // pulse[4] = COW

    uint32_t faults_live_raw;          // offset 108
    uint32_t faults_lat;               // offset 112
    uint32_t trig_cnt;                 // offset 116
    uint32_t accum;                    // offset 120
    uint32_t acis;                     // offset 124
    uint32_t crc_artix;                // offset 128
    uint32_t faults_tp;                // offset 132
    uint32_t startup_cnt;              // offset 136
    uint32_t beamaccum_limit_calc;     // offset 140

} pulse_stats_msg_t;


#endif
