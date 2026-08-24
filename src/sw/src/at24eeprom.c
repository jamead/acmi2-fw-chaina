#include "xparameters.h"
#include "xiicps.h"
#include <sleep.h>
#include "xil_printf.h"
#include <stdio.h>
#include "FreeRTOS.h"
#include "task.h"

#include "pl_regs.h"
#include "local.h"
#include "at24eeprom.h"
#include "zudfe.h"





/**
 * @brief Write 1 byte to AT24CM02
 */
int EepromWriteByte(u16 addr, u8 data)
{
    u8 buf[3];

	i2c_set_port_expander(I2C_PORTEXP0_ADDR,0x80);
	i2c_set_port_expander(I2C_PORTEXP1_ADDR,0x0);

    buf[0] = (u8)(addr >> 8);      // mem addr high
    buf[1] = (u8)(addr & 0xFF);    // mem addr low
    buf[2] = data;                 // data byte

    i2c_write(buf,3,EEPROM_ADDR);
    //int sent = XIicPs_MasterSendPolled(&Iic, buf, 3, EEPROM_ADDR_7B);
    //if (sent != 3) return XST_FAILURE;

    //while (XIicPs_BusIsBusy(&Iic)) { }  // ok for now

    usleep(10000);              // wait for internal write
    return;
}

/**
 * @brief Read 1 byte from AT24CM02
 */
uint8_t EepromReadByte(uint32_t addr) {
    uint8_t addr_buf[2];
    uint8_t data = 0;

	i2c_set_port_expander(I2C_PORTEXP0_ADDR,0x80);
	i2c_set_port_expander(I2C_PORTEXP1_ADDR,0x0);

    addr_buf[0] = (uint8_t)(addr >> 8);
    addr_buf[1] = (uint8_t)(addr & 0xFF);


    // 1. Send the 3-byte address pointer
    i2c_write(addr_buf,2,EEPROM_ADDR);
    //XIicPs_MasterSendPolled(&I2cInstance, addr_buf, 3, EEPROM_ADDR);

    // 2. Receive the data byte
    i2c_read(&data,1,EEPROM_ADDR);
    //XIicPs_MasterRecvPolled(&I2cInstance, &data, 1, EEPROM_ADDR);

    return data;
}



/* Writes exactly 256 bytes. mem_addr must be 0x..00 (page aligned). */
int EepromWrite256(u16 mem_addr, const u8 *src)
{
    u8 buf[2 + EEPROM_PAGE_SIZE];

	i2c_set_port_expander(I2C_PORTEXP0_ADDR,0x80);
	i2c_set_port_expander(I2C_PORTEXP1_ADDR,0x0);

    if (src == NULL) return XST_INVALID_PARAM;

    /* Must not cross page boundary */
    if ((mem_addr & (EEPROM_PAGE_SIZE - 1)) != 0) {
        return XST_INVALID_PARAM;   // not aligned
    }

    buf[0] = (u8)(mem_addr >> 8);
    buf[1] = (u8)(mem_addr & 0xFF);

    memcpy(&buf[2], src, EEPROM_PAGE_SIZE);

    /* Send 2-byte address + 256 bytes data */
    s32 st = i2c_write(buf, 2 + EEPROM_PAGE_SIZE, EEPROM_ADDR);
    if (st != XST_SUCCESS) return XST_FAILURE;

    /* wait internal write cycle */
    usleep(10000);

    return XST_SUCCESS;
}



int EepromRead256(u16 mem_addr, u8 *dst)
{
    u8 a[2];

	i2c_set_port_expander(I2C_PORTEXP0_ADDR,0x80);
	i2c_set_port_expander(I2C_PORTEXP1_ADDR,0x0);

    if (dst == NULL) return XST_INVALID_PARAM;

    a[0] = (u8)(mem_addr >> 8);
    a[1] = (u8)(mem_addr & 0xFF);

    if (i2c_write(a, 2, EEPROM_ADDR) != XST_SUCCESS) return XST_FAILURE;
    if (i2c_read(dst, EEPROM_PAGE_SIZE, EEPROM_ADDR) != XST_SUCCESS) return XST_FAILURE;

    return XST_SUCCESS;
}


void InitSettingsfromEeprom()
{
   u32 chan;
   u8 eeprombuf[EEPROM_PAGE_SIZE];

   xil_printf("Reading AT24CM02 EEPROM...\r\n");

   EepromRead256(0, eeprombuf);
   xil_printf("DisperseData...\r\n");
   EepromDisperseData(eeprombuf);
   EepromPrintData(eeprombuf);

}





void EepromPrintData(Eeprom_params_msg_t *data)
{
    xil_printf("EEPROM Parameter Contents:\r\n");

    xil_printf("header                  = 0x%08lX\r\n", (unsigned long)data->header);

    xil_printf("tp1_pulse_delay         = %lu\r\n", (unsigned long)data->tp1_pulse_delay);
    xil_printf("tp1_pulse_width         = %lu\r\n", (unsigned long)data->tp1_pulse_width);
    xil_printf("tp1_adc_delay           = %lu\r\n", (unsigned long)data->tp1_adc_delay);

    xil_printf("tp2_pulse_delay         = %lu\r\n", (unsigned long)data->tp2_pulse_delay);
    xil_printf("tp2_pulse_width         = %lu\r\n", (unsigned long)data->tp2_pulse_width);
    xil_printf("tp2_adc_delay           = %lu\r\n", (unsigned long)data->tp2_adc_delay);

    xil_printf("tp3_pulse_delay         = %lu\r\n", (unsigned long)data->tp3_pulse_delay);
    xil_printf("tp3_pulse_width         = %lu\r\n", (unsigned long)data->tp3_pulse_width);
    xil_printf("tp3_adc_delay           = %lu\r\n", (unsigned long)data->tp3_adc_delay);

    xil_printf("beam_adc_delay          = %lu\r\n", (unsigned long)data->beam_adc_delay);
    xil_printf("beam_oow_threshold      = %lu\r\n", (unsigned long)data->beam_oow_threshold);

    xil_printf("tp1_int_low_limit       = %lu\r\n", (unsigned long)data->tp1_int_low_limit);
    xil_printf("tp1_int_high_limit      = %lu\r\n", (unsigned long)data->tp1_int_high_limit);
    xil_printf("tp2_int_low_limit       = %lu\r\n", (unsigned long)data->tp2_int_low_limit);
    xil_printf("tp2_int_high_limit      = %lu\r\n", (unsigned long)data->tp2_int_high_limit);
    xil_printf("tp3_int_low_limit       = %lu\r\n", (unsigned long)data->tp3_int_low_limit);
    xil_printf("tp3_int_high_limit      = %lu\r\n", (unsigned long)data->tp3_int_high_limit);

    xil_printf("tp1_peak_low_limit      = %lu\r\n", (unsigned long)data->tp1_peak_low_limit);
    xil_printf("tp1_peak_high_limit     = %lu\r\n", (unsigned long)data->tp1_peak_high_limit);
    xil_printf("tp2_peak_low_limit      = %lu\r\n", (unsigned long)data->tp2_peak_low_limit);
    xil_printf("tp2_peak_high_limit     = %lu\r\n", (unsigned long)data->tp2_peak_high_limit);
    xil_printf("tp3_peak_low_limit      = %lu\r\n", (unsigned long)data->tp3_peak_low_limit);
    xil_printf("tp3_peak_high_limit     = %lu\r\n", (unsigned long)data->tp3_peak_high_limit);

    xil_printf("tp1_fwhm_low_limit      = %lu\r\n", (unsigned long)data->tp1_fwhm_low_limit);
    xil_printf("tp1_fwhm_high_limit     = %lu\r\n", (unsigned long)data->tp1_fwhm_high_limit);
    xil_printf("tp2_fwhm_low_limit      = %lu\r\n", (unsigned long)data->tp2_fwhm_low_limit);
    xil_printf("tp2_fwhm_high_limit     = %lu\r\n", (unsigned long)data->tp2_fwhm_high_limit);
    xil_printf("tp3_fwhm_low_limit      = %lu\r\n", (unsigned long)data->tp3_fwhm_low_limit);
    xil_printf("tp3_fwhm_high_limit     = %lu\r\n", (unsigned long)data->tp3_fwhm_high_limit);

    xil_printf("tp1_base_low_limit      = %lu\r\n", (unsigned long)data->tp1_base_low_limit);
    xil_printf("tp1_base_high_limit     = %lu\r\n", (unsigned long)data->tp1_base_high_limit);
    xil_printf("tp2_base_low_limit      = %lu\r\n", (unsigned long)data->tp2_base_low_limit);
    xil_printf("tp2_base_high_limit     = %lu\r\n", (unsigned long)data->tp2_base_high_limit);
    xil_printf("tp3_base_low_limit      = %lu\r\n", (unsigned long)data->tp3_base_low_limit);
    xil_printf("tp3_base_high_limit     = %lu\r\n", (unsigned long)data->tp3_base_high_limit);

    xil_printf("tp1_pos_level           = %lu\r\n", (unsigned long)data->tp1_pos_level);
    xil_printf("tp2_pos_level           = %lu\r\n", (unsigned long)data->tp2_pos_level);
    xil_printf("tp3_pos_level           = %lu\r\n", (unsigned long)data->tp3_pos_level);

    xil_printf("tp1_neg_level           = %lu\r\n", (unsigned long)data->tp1_neg_level);
    xil_printf("tp2_neg_level           = %lu\r\n", (unsigned long)data->tp2_neg_level);
    xil_printf("tp3_neg_level           = %lu\r\n", (unsigned long)data->tp3_neg_level);

    xil_printf("accum_HL                = %lu\r\n", (unsigned long)data->accum_HL);
    xil_printf("beam_HL                 = %lu\r\n", (unsigned long)data->beam_HL);

    xil_printf("baseline_low_limit      = %lu\r\n", (unsigned long)data->baseline_low_limit);
    xil_printf("baseline_high_limit     = %lu\r\n", (unsigned long)data->baseline_high_limit);

    xil_printf("charge_cal              = %lu\r\n", (unsigned long)data->charge_cal);
    xil_printf("accum_q_min             = %lu\r\n", (unsigned long)data->accum_q_min);
    xil_printf("accum_len               = %lu\r\n", (unsigned long)data->accum_len);

    xil_printf("crc_eeprom              = 0x%08lX\r\n", (unsigned long)data->crc_eeprom);
}



void EepromGatherData(Eeprom_params_msg_t *data)
{
    u32 base;

    base = XPAR_M_AXI_BASEADDR;

    data->header = Xil_In32(base + HEADER_REG);

    data->tp1_pulse_delay = Xil_In32(base + TP1_PULSE_DELAY_REG);
    data->tp1_pulse_width = Xil_In32(base + TP1_PULSE_WIDTH_REG);
    data->tp1_adc_delay = Xil_In32(base + TP1_ADC_DELAY_REG);

    data->tp2_pulse_delay = Xil_In32(base + TP2_PULSE_DELAY_REG);
    data->tp2_pulse_width = Xil_In32(base + TP2_PULSE_WIDTH_REG);
    data->tp2_adc_delay = Xil_In32(base + TP2_ADC_DELAY_REG);

    data->tp3_pulse_delay = Xil_In32(base + TP3_PULSE_DELAY_REG);
    data->tp3_pulse_width = Xil_In32(base + TP3_PULSE_WIDTH_REG);
    data->tp3_adc_delay = Xil_In32(base + TP3_ADC_DELAY_REG);

    data->beam_adc_delay = Xil_In32(base + BEAM_ADC_DELAY_REG);
    data->beam_oow_threshold = Xil_In32(base + BEAM_OOW_THRESHOLD_REG);

    data->tp1_int_low_limit = Xil_In32(base + TP1_INT_LOW_LIMIT_REG);
    data->tp1_int_high_limit = Xil_In32(base + TP1_INT_HIGH_LIMIT_REG);
    data->tp2_int_low_limit = Xil_In32(base + TP2_INT_LOW_LIMIT_REG);
    data->tp2_int_high_limit = Xil_In32(base + TP2_INT_HIGH_LIMIT_REG);
    data->tp3_int_low_limit = Xil_In32(base + TP3_INT_LOW_LIMIT_REG);
    data->tp3_int_high_limit = Xil_In32(base + TP3_INT_HIGH_LIMIT_REG);

    data->tp1_peak_low_limit = Xil_In32(base + TP1_PEAK_LOW_LIMIT_REG);
    data->tp1_peak_high_limit = Xil_In32(base + TP1_PEAK_HIGH_LIMIT_REG);
    data->tp2_peak_low_limit = Xil_In32(base + TP2_PEAK_LOW_LIMIT_REG);
    data->tp2_peak_high_limit = Xil_In32(base + TP2_PEAK_HIGH_LIMIT_REG);
    data->tp3_peak_low_limit = Xil_In32(base + TP3_PEAK_LOW_LIMIT_REG);
    data->tp3_peak_high_limit = Xil_In32(base + TP3_PEAK_HIGH_LIMIT_REG);

    data->tp1_fwhm_low_limit = Xil_In32(base + TP1_FWHM_LOW_LIMIT_REG);
    data->tp1_fwhm_high_limit = Xil_In32(base + TP1_FWHM_HIGH_LIMIT_REG);
    data->tp2_fwhm_low_limit = Xil_In32(base + TP2_FWHM_LOW_LIMIT_REG);
    data->tp2_fwhm_high_limit = Xil_In32(base + TP2_FWHM_HIGH_LIMIT_REG);
    data->tp3_fwhm_low_limit = Xil_In32(base + TP3_FWHM_LOW_LIMIT_REG);
    data->tp3_fwhm_high_limit = Xil_In32(base + TP3_FWHM_HIGH_LIMIT_REG);

    data->tp1_base_low_limit = Xil_In32(base + TP1_BASE_LOW_LIMIT_REG);
    data->tp1_base_high_limit = Xil_In32(base + TP1_BASE_HIGH_LIMIT_REG);
    data->tp2_base_low_limit = Xil_In32(base + TP2_BASE_LOW_LIMIT_REG);
    data->tp2_base_high_limit = Xil_In32(base + TP2_BASE_HIGH_LIMIT_REG);
    data->tp3_base_low_limit = Xil_In32(base + TP3_BASE_LOW_LIMIT_REG);
    data->tp3_base_high_limit = Xil_In32(base + TP3_BASE_HIGH_LIMIT_REG);

    data->tp1_pos_level = Xil_In32(base + TP1_POS_LEVEL_REG);
    data->tp2_pos_level = Xil_In32(base + TP2_POS_LEVEL_REG);
    data->tp3_pos_level = Xil_In32(base + TP3_POS_LEVEL_REG);

    data->tp1_neg_level = Xil_In32(base + TP1_NEG_LEVEL_REG);
    data->tp2_neg_level = Xil_In32(base + TP2_NEG_LEVEL_REG);
    data->tp3_neg_level = Xil_In32(base + TP3_NEG_LEVEL_REG);

    data->accum_HL = Xil_In32(base + ACCUM_HL_REG);
    data->beam_HL = Xil_In32(base + BEAM_HL_REG);

    data->baseline_low_limit = Xil_In32(base + BASELINE_LOW_LIMIT_REG);
    data->baseline_high_limit = Xil_In32(base + BASELINE_HIGH_LIMIT_REG);

    data->charge_cal = Xil_In32(base + CHARGE_CAL_REG);
    data->accum_q_min = Xil_In32(base + ACCUM_Q_MIN_REG);
    data->accum_len = Xil_In32(base + ACCUM_LEN_REG);

    data->crc_eeprom = Xil_In32(base + CRC_EEPROM_REG);
}





void EepromDisperseData(u8 *readbuf)
{
    Eeprom_params_msg_t eeprom_data;
    u32 base;

    memcpy(&eeprom_data, readbuf, sizeof(eeprom_data));

    base = XPAR_M_AXI_BASEADDR;

    Xil_Out32(base + HEADER_REG, eeprom_data.header);

    Xil_Out32(base + TP1_PULSE_DELAY_REG, eeprom_data.tp1_pulse_delay);
    Xil_Out32(base + TP1_PULSE_WIDTH_REG, eeprom_data.tp1_pulse_width);
    Xil_Out32(base + TP1_ADC_DELAY_REG, eeprom_data.tp1_adc_delay);

    Xil_Out32(base + TP2_PULSE_DELAY_REG, eeprom_data.tp2_pulse_delay);
    Xil_Out32(base + TP2_PULSE_WIDTH_REG, eeprom_data.tp2_pulse_width);
    Xil_Out32(base + TP2_ADC_DELAY_REG, eeprom_data.tp2_adc_delay);

    Xil_Out32(base + TP3_PULSE_DELAY_REG, eeprom_data.tp3_pulse_delay);
    Xil_Out32(base + TP3_PULSE_WIDTH_REG, eeprom_data.tp3_pulse_width);
    Xil_Out32(base + TP3_ADC_DELAY_REG, eeprom_data.tp3_adc_delay);

    Xil_Out32(base + BEAM_ADC_DELAY_REG, eeprom_data.beam_adc_delay);
    Xil_Out32(base + BEAM_OOW_THRESHOLD_REG, eeprom_data.beam_oow_threshold);

    Xil_Out32(base + TP1_INT_LOW_LIMIT_REG, eeprom_data.tp1_int_low_limit);
    Xil_Out32(base + TP1_INT_HIGH_LIMIT_REG, eeprom_data.tp1_int_high_limit);
    Xil_Out32(base + TP2_INT_LOW_LIMIT_REG, eeprom_data.tp2_int_low_limit);
    Xil_Out32(base + TP2_INT_HIGH_LIMIT_REG, eeprom_data.tp2_int_high_limit);
    Xil_Out32(base + TP3_INT_LOW_LIMIT_REG, eeprom_data.tp3_int_low_limit);
    Xil_Out32(base + TP3_INT_HIGH_LIMIT_REG, eeprom_data.tp3_int_high_limit);

    Xil_Out32(base + TP1_PEAK_LOW_LIMIT_REG, eeprom_data.tp1_peak_low_limit);
    Xil_Out32(base + TP1_PEAK_HIGH_LIMIT_REG, eeprom_data.tp1_peak_high_limit);
    Xil_Out32(base + TP2_PEAK_LOW_LIMIT_REG, eeprom_data.tp2_peak_low_limit);
    Xil_Out32(base + TP2_PEAK_HIGH_LIMIT_REG, eeprom_data.tp2_peak_high_limit);
    Xil_Out32(base + TP3_PEAK_LOW_LIMIT_REG, eeprom_data.tp3_peak_low_limit);
    Xil_Out32(base + TP3_PEAK_HIGH_LIMIT_REG, eeprom_data.tp3_peak_high_limit);

    Xil_Out32(base + TP1_FWHM_LOW_LIMIT_REG, eeprom_data.tp1_fwhm_low_limit);
    Xil_Out32(base + TP1_FWHM_HIGH_LIMIT_REG, eeprom_data.tp1_fwhm_high_limit);
    Xil_Out32(base + TP2_FWHM_LOW_LIMIT_REG, eeprom_data.tp2_fwhm_low_limit);
    Xil_Out32(base + TP2_FWHM_HIGH_LIMIT_REG, eeprom_data.tp2_fwhm_high_limit);
    Xil_Out32(base + TP3_FWHM_LOW_LIMIT_REG, eeprom_data.tp3_fwhm_low_limit);
    Xil_Out32(base + TP3_FWHM_HIGH_LIMIT_REG, eeprom_data.tp3_fwhm_high_limit);

    Xil_Out32(base + TP1_BASE_LOW_LIMIT_REG, eeprom_data.tp1_base_low_limit);
    Xil_Out32(base + TP1_BASE_HIGH_LIMIT_REG, eeprom_data.tp1_base_high_limit);
    Xil_Out32(base + TP2_BASE_LOW_LIMIT_REG, eeprom_data.tp2_base_low_limit);
    Xil_Out32(base + TP2_BASE_HIGH_LIMIT_REG, eeprom_data.tp2_base_high_limit);
    Xil_Out32(base + TP3_BASE_LOW_LIMIT_REG, eeprom_data.tp3_base_low_limit);
    Xil_Out32(base + TP3_BASE_HIGH_LIMIT_REG, eeprom_data.tp3_base_high_limit);

    Xil_Out32(base + TP1_POS_LEVEL_REG, eeprom_data.tp1_pos_level);
    Xil_Out32(base + TP2_POS_LEVEL_REG, eeprom_data.tp2_pos_level);
    Xil_Out32(base + TP3_POS_LEVEL_REG, eeprom_data.tp3_pos_level);

    Xil_Out32(base + TP1_NEG_LEVEL_REG, eeprom_data.tp1_neg_level);
    Xil_Out32(base + TP2_NEG_LEVEL_REG, eeprom_data.tp2_neg_level);
    Xil_Out32(base + TP3_NEG_LEVEL_REG, eeprom_data.tp3_neg_level);

    Xil_Out32(base + ACCUM_HL_REG, eeprom_data.accum_HL);
    Xil_Out32(base + BEAM_HL_REG, eeprom_data.beam_HL);

    Xil_Out32(base + BASELINE_LOW_LIMIT_REG, eeprom_data.baseline_low_limit);
    Xil_Out32(base + BASELINE_HIGH_LIMIT_REG, eeprom_data.baseline_high_limit);

    Xil_Out32(base + CHARGE_CAL_REG, eeprom_data.charge_cal);
    Xil_Out32(base + ACCUM_Q_MIN_REG, eeprom_data.accum_q_min);
    Xil_Out32(base + ACCUM_LEN_REG, eeprom_data.accum_len);

    Xil_Out32(base + CRC_EEPROM_REG, eeprom_data.crc_eeprom);
}

