#ifndef PL_REGS_H
#define PL_REGS_H

#include <stdint.h>

/*
 * Register offsets generated from pl_regs.rdl
 *
 * All values are byte offsets from the base address of the
 * AXI/PL register block.
 *
 * Example:
 *     value = Xil_In32(PL_REG_BASE + DMA_TRIGCNT_OFFSET);
 */

#define PL_REG_NUM_REGISTERS                109U

/* ------------------------------------------------------------------------- */
/* Module / ADC / Control Registers                                        */
/* ------------------------------------------------------------------------- */

#define MOD_ID_NUM                             0x000U
#define MOD_ID_VER                             0x004U
#define PROJ_ID_NUM                            0x010U
#define PROJ_ID_VER                            0x014U
#define GIT_SHASUM                             0x018U
#define COMPILE_TIMESTAMP                      0x01CU


/* ------------------------------------------------------------------------- */
/* / ADC Control Registers                                        */
/* ------------------------------------------------------------------------- */

#define ADC_IDLYWVAL_REG                        0x020U
#define ADC_IDLYSTR_REG                         0x024U
#define ADC_IDLYRVAL_REG                        0x028U
#define ADC_SPI_REG                             0x048U

/* ------------------------------------------------------------------------- */
/* / MISC Register                                       */
/* ------------------------------------------------------------------------- */

#define IOC_ACCESS_REG                          0x070U


/* ------------------------------------------------------------------------- */
/* EVR Registers                                                           */
/* ------------------------------------------------------------------------- */

#define EVR_RST_REG                             0x0BCU
#define EVR_TS_NS_REG                           0x150U
#define EVR_TS_S_REG                            0x154U
#define EVR_TS_NS_LAT_REG                       0x158U
#define EVR_TS_S_LAT_REG                        0x15CU
#define TRIG_EVENTNO_REG                        0x160U
#define TRIG_DELAY_REG                          0x164U

/* ------------------------------------------------------------------------- */
/* ADC FIFO Registers                                                      */
/* ------------------------------------------------------------------------- */

#define ADCFIFO_STREAMENB_REG                   0x200U
#define ADCFIFO_RST_REG                         0x204U
#define ADCFIFO_DATA_REG                        0x208U
#define ADCFIFO_RDCNT_REG                       0x20CU


/* ------------------------------------------------------------------------- */
/* EEPROM Parameter Registers                                              */
/* ------------------------------------------------------------------------- */

#define HEADER_REG                              0x300U
#define TP1_PULSE_DELAY_REG                     0x304U
#define TP1_PULSE_WIDTH_REG                     0x308U
#define TP1_ADC_DELAY_REG                       0x30CU
#define TP2_PULSE_DELAY_REG                     0x310U
#define TP2_PULSE_WIDTH_REG                     0x314U
#define TP2_ADC_DELAY_REG                       0x318U
#define TP3_PULSE_DELAY_REG                     0x31CU
#define TP3_PULSE_WIDTH_REG                     0x320U
#define TP3_ADC_DELAY_REG                       0x324U
#define BEAM_ADC_DELAY_REG                      0x328U
#define BEAM_OOW_THRESHOLD_REG                  0x32CU
#define TP1_INT_LOW_LIMIT_REG                   0x330U
#define TP1_INT_HIGH_LIMIT_REG                  0x334U
#define TP2_INT_LOW_LIMIT_REG                   0x338U
#define TP2_INT_HIGH_LIMIT_REG                  0x33CU
#define TP3_INT_LOW_LIMIT_REG                   0x340U
#define TP3_INT_HIGH_LIMIT_REG                  0x344U
#define TP1_PEAK_LOW_LIMIT_REG                  0x348U
#define TP1_PEAK_HIGH_LIMIT_REG                 0x34CU
#define TP2_PEAK_LOW_LIMIT_REG                  0x350U
#define TP2_PEAK_HIGH_LIMIT_REG                 0x354U
#define TP3_PEAK_LOW_LIMIT_REG                  0x358U
#define TP3_PEAK_HIGH_LIMIT_REG                 0x35CU
#define TP1_FWHM_LOW_LIMIT_REG                  0x360U
#define TP1_FWHM_HIGH_LIMIT_REG                 0x364U
#define TP2_FWHM_LOW_LIMIT_REG                  0x368U
#define TP2_FWHM_HIGH_LIMIT_REG                 0x36CU
#define TP3_FWHM_LOW_LIMIT_REG                  0x370U
#define TP3_FWHM_HIGH_LIMIT_REG                 0x374U
#define TP1_BASE_LOW_LIMIT_REG                  0x378U
#define TP1_BASE_HIGH_LIMIT_REG                 0x37CU
#define TP2_BASE_LOW_LIMIT_REG                  0x380U
#define TP2_BASE_HIGH_LIMIT_REG                 0x384U
#define TP3_BASE_LOW_LIMIT_REG                  0x388U
#define TP3_BASE_HIGH_LIMIT_REG                 0x38CU
#define TP1_POS_LEVEL_REG                       0x390U
#define TP2_POS_LEVEL_REG                       0x394U
#define TP3_POS_LEVEL_REG                       0x398U
#define TP1_NEG_LEVEL_REG                       0x39CU
#define TP2_NEG_LEVEL_REG                       0x3A0U
#define TP3_NEG_LEVEL_REG                       0x3A4U
#define ACCUM_HL_REG                            0x3A8U
#define BEAM_HL_REG                             0x3ACU
#define BASELINE_LOW_LIMIT_REG                  0x3B0U
#define BASELINE_HIGH_LIMIT_REG                 0x3B4U
#define CHARGE_CAL_REG                          0x3B8U
#define ACCUM_Q_MIN_REG                         0x3BCU
#define ACCUM_LEN_REG                           0x3C0U
#define CRC_EEPROM_REG                          0x3C4U

/* ------------------------------------------------------------------------- */
/* Pulse Statistics Registers                                              */
/* ------------------------------------------------------------------------- */

#define PULSE0_BASELINE_REG                     0x400U
#define PULSE0_INTEGRAL_REG                     0x404U
#define PULSE0_PEAK_REG                         0x408U
#define PULSE0_PEAK_INDEX_REG                   0x40CU
#define PULSE0_PEAK_FOUND_REG                   0x410U
#define PULSE0_THRESHOLD_REG                    0x414U
#define PULSE0_FWHM_REG                         0x418U
#define PULSE1_BASELINE_REG                     0x41CU
#define PULSE1_INTEGRAL_REG                     0x420U
#define PULSE1_PEAK_REG                         0x424U
#define PULSE1_PEAK_INDEX_REG                   0x428U
#define PULSE1_PEAK_FOUND_REG                   0x42CU
#define PULSE1_THRESHOLD_REG                    0x430U
#define PULSE1_FWHM_REG                         0x434U
#define PULSE2_BASELINE_REG                     0x438U
#define PULSE2_INTEGRAL_REG                     0x43CU
#define PULSE2_PEAK_REG                         0x440U
#define PULSE2_PEAK_INDEX_REG                   0x444U
#define PULSE2_PEAK_FOUND_REG                   0x448U
#define PULSE2_THRESHOLD_REG                    0x44CU
#define PULSE2_FWHM_REG                         0x450U
#define PULSE3_BASELINE_REG                     0x454U
#define PULSE3_INTEGRAL_REG                     0x458U
#define PULSE3_PEAK_REG                         0x45CU
#define PULSE3_PEAK_INDEX_REG                   0x460U
#define PULSE3_PEAK_FOUND_REG                   0x464U
#define PULSE3_THRESHOLD_REG                    0x468U
#define PULSE3_FWHM_REG                         0x46CU
#define PULSE4_BASELINE_REG                     0x470U
#define PULSE4_INTEGRAL_REG                     0x474U
#define PULSE4_PEAK_REG                         0x478U
#define PULSE4_PEAK_INDEX_REG                   0x47CU
#define PULSE4_PEAK_FOUND_REG                   0x480U
#define PULSE4_THRESHOLD_REG                    0x484U
#define PULSE4_FWHM_REG                         0x488U

/* ------------------------------------------------------------------------- */
/* EEPROM block convenience definitions                                      */
/* ------------------------------------------------------------------------- */

#define EEPROM_PARAMS_BASE_OFFSET              0x300U
#define EEPROM_PARAMS_NUM_REGS                 50U
#define EEPROM_PARAMS_SIZE_BYTES               200U

/* ------------------------------------------------------------------------- */
/* Pulse statistics convenience definitions                                  */
/* ------------------------------------------------------------------------- */

#define PULSE_STATS_BASE_REG                   0x400U
#define PULSE_STATS_STRIDE                     0x01CU


#define PULSE_STATS_BASELINE_OFFSET            0x00U
#define PULSE_STATS_INTEGRAL_OFFSET            0x04U
#define PULSE_STATS_PEAK_OFFSET                0x08U
#define PULSE_STATS_PEAK_INDEX_OFFSET          0x0CU
#define PULSE_STATS_PEAK_FOUND_OFFSET          0x10U
#define PULSE_STATS_THRESHOLD_OFFSET           0x14U
#define PULSE_STATS_FWHM_OFFSET                0x18U

#define PULSE_STATS_BASELINE_MASK              0x0000FFFFU
#define PULSE_STATS_INTEGRAL_MASK              0xFFFFFFFFU
#define PULSE_STATS_PEAK_MASK                  0x0001FFFFU
#define PULSE_STATS_PEAK_INDEX_MASK            0xFFFFFFFFU
#define PULSE_STATS_PEAK_FOUND_MASK            0x00000001U
#define PULSE_STATS_THRESHOLD_MASK             0x0000FFFFU
#define PULSE_STATS_FWHM_MASK                  0x0000FFFFU

#define PULSE_STATS_PULSE_BASE_OFFSET(n) \
    (PULSE_STATS_BASE_OFFSET + ((uint32_t)(n) * PULSE_STATS_STRIDE))

#endif /* PL_REGS_H */









