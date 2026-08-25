#ifndef WVFMDATA_H
#define WVFMDATA_H


/* ============================================================
 * PSC Message IDs
 * ============================================================ */

#define MSGID_PULSE_STATS           51U
#define MSGID_EEPROM                52U
#define MSGID_WVFM                  54U
#define MSGID_TIMESTAMP             55U


/* ============================================================
 * ADC Waveform
 * ============================================================ */

#define WVFM_NUM_SAMPLES            16000U
#define WVFM_FIFO_WAIT_WORDS        8000U
#define WVFM_FIFO_MIN_WORDS         15900U


/* ============================================================
 * Pulse Statistics
 * ============================================================ */

#define NUM_PULSES                  5U
#define PULSE_STATS_WORDS_PER_PULSE 7U
#define PULSE_STATS_NUM_WORDS       (NUM_PULSES * PULSE_STATS_WORDS_PER_PULSE)



/* ============================================================
 * Convenience Register Access
 * ============================================================ */

#define REG_READ(reg) \
    Xil_In32(XPAR_M_AXI_BASEADDR + (reg))

#define REG_WRITE(reg, value) \
    Xil_Out32(XPAR_M_AXI_BASEADDR + (reg), (value))


#endif /* WVFMDATA_H */



