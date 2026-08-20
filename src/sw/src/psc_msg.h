//The PSC interface defines many different MsgID's
//The PSC Header is always 8 bytes
#define MSGHDRLEN 8

//This message is for System Health
#define MSGID30 30
#define MSGID30LEN 1024 //748   //in bytes

//This message is for 10Hz data
#define MSGID31 31
#define MSGID31LEN 1024  //316   //in bytes

//This message is for system info
#define MSGID32 32
#define MSGID32LEN 1024  //400  //in bytes



//This message is for ADC Live waveform
//10000 pts * 4vals * 2bytes/val
#define MSGID51 51 
#define MSGID51LEN 80000   //in bytes

//This message is for TbT waveform
//1024 pts * 7vals * 4bytes/val (a,b,c,d,x,y,sum)
#define MSGID52 52 
#define MSGID52LEN 230000  //in bytes

//This message is for ADC DMA
//1e6 pts * 4vals * 2bytes/val
#define MSGID53 53
#define MSGID53LEN 8000000  //in bytes

//This message is for TBT DMA
//100e3 pts * 16vals * 4bytes/val
#define MSGID54 54
#define MSGID54LEN 6400000  //in bytes

//This message is for FA DMA
//20e3 pts * 10vals * 4bytes/val
#define MSGID55 55
#define MSGID55LEN 800000  //in bytes





// Control Message Offsets
#define SOFT_TRIG_MSG 0
#define FP_LED_MSG 4
#define PILOT_TONE_ENB_MSG 8
#define ADC_IDLY_MSG 12
#define ADC_MMCM0_MSG 16
#define ADC_MMCM1_MSG 20
#define ADC_SPI_MSG 24
#define EVENT_SRC_SEL_MSG 36
#define DMA_TRIG_SRC_MSG 52
#define DMA_ADCLEN_MSG 56
#define DMA_TBTLEN_MSG 60
#define DMA_FALEN_MSG 64
#define DDC_LPFILT_SEL_MSG 68
#define MACHINE_SEL_MSG 76
#define PILOT_TONE_SPI_MSG 104
#define RF_ATTEN_MSG 132
#define PT_ATTEN_MSG 136
#define KX_MSG 144
#define KY_MSG 148
#define BBA_XOFF_MSG 152
#define BBA_YOFF_MSG 156
#define CHA_GAIN_MSG 160
#define CHB_GAIN_MSG 164
#define CHC_GAIN_MSG 168
#define CHD_GAIN_MSG 172
#define FINE_TRIG_DLY_MSG 192  //Geo Delay
#define TBT_GATE_WIDTH_MSG 196
#define COARSE_TRIG_DLY_MSG 272
#define TRIGTOBEAM_THRESH_MSG 276
#define EVENT_NO_MSG 320
#define RFFESW_ENB_MSG 400
#define RFFESW_TRIGDLY_MSG 404
#define RFFESW_DEMUXDLY_MSG 408
#define RFFESW_ADCDMASEL_MSG 412




