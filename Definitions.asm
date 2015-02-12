;***********************************************************************************
;*****************[ Основные константы ]********************************************
;***********************************************************************************

;Дата и время компиляции проэкта, тип устройства
#define PROJECT_DATE __CENTURY__*1000000 + __YEAR__*10000 + __MONTH__*100 + __DAY__
#define PROJECT_TIME __HOUR__*10000 + __MINUTE__*100 + __SECOND__
#define DEVICESTRING "ATmega48"

;Версия
.EQU  IP_VERSION        = $0100
.EQU  IP_PROJECT_DATE   = PROJECT_DATE
.EQU  IP_PROJECT_TIME   = PROJECT_TIME

;***********************************************************************************
;*****************[ Константы протокола EAST2 ]*************************************
;***********************************************************************************

.EQU  EAST2_START                    = $85
.EQU  EAST2_STOP                     = $21
.EQU  EAST2_DEVICE_ADDRESS           = $13

.EQU  CMD_CONNECT                    = $00
.EQU  CMD_IRIVER_ON                  = $11;
.EQU  CMD_IRIVER_MUTE                = $12;
.EQU  CMD_IRIVER_OFF                 = $13;
.EQU  CMD_IRIVER_VOLM                = $14;
.EQU  CMD_IRIVER_VOLP                = $15;
.EQU  CMD_IRIVER_BACK                = $16;
.EQU  CMD_IRIVER_NEXT                = $17;
.EQU  CMD_PANASONIC_EXTERNAL         = $21;
.EQU  CMD_PANASONIC_INTERNAL         = $22;
.EQU  CMD_PANASONIC_LIGHT            = $23;
.EQU  CMD_PANASONIC_SLEEP_ON         = $24;
.EQU  CMD_PANASONIC_SLEEP_OFF        = $25;
.EQU  CMD_PANASONIC_MOTOR_ON         = $26;
.EQU  CMD_PANASONIC_MOTOR_OFF        = $27;
.EQU  CMD_BOOT_ENTER                 = $F0
.EQU  CMD_DISCONNECT                 = $FF

.EQU  STATUS_SUCCESS                 = $00
.EQU  STATUS_ERROR                   = $02

;***********************************************************************************
;*****************[ Режимы работы ]*************************************************
;***********************************************************************************

.EQU  EAST2_WAIT_START               = 0
.EQU  EAST2_WAIT_SIZEL               = 1
.EQU  EAST2_WAIT_SIZEH               = 2
.EQU  EAST2_WAIT_DATA                = 3
.EQU  EAST2_WAIT_STOP                = 4
.EQU  EAST2_WAIT_CSL                 = 5
.EQU  EAST2_WAIT_CSH                 = 6

;***********************************************************************************
;*****************[ Порты, назначение выводов ]*************************************
;***********************************************************************************

; PB0  - In  - Panasonic ICP1 IR Rx
.EQU pIRRX  = PB0
; PB1  - In  - Panasonic Sleep Status In
.EQU pSLPIN = PB1
; PB2  - In  - Panasonic Motor Status In
.EQU pMSIN  = PB2
; PB3  - Out - iRiver Next
.EQU iNEXT  = PB3
; PB4  - Out - iRiver Start
.EQU iSTART = PB4
; PB5  - Out - iRiver Back
.EQU iBACK  = PB5
; PB6  -  x  - XTAL
; PB7  -  x  - XTAL

; PD0  - In  - RxD
; PD1  - Out - TxD
; PD2  - In  - INT0 Out from Idle Mode
; PD3  - Out - Panasonic Face Light LED
.EQU pLIGHT = PD3
; PD4  - In  - Boot Button
.EQU BOOT   = PD4
; PD5  - Out - Status LED, iRiver Hold
.EQU STATUS = PD5
.EQU iHOLD  = PD5 
; PD6  - Out - S1 Audio Mux Controll
; PD7  - Out - S2 Audio Mux Controll
.EQU S1     = PD6
.EQU S2     = PD7

; PC0  - In  - Panasonic Cassete Present Sensor
.EQU pCASS  = PC0
; PC1  - In  - ADC Photo Diode In
; PC2  - Out - iRiver Volume Minus
.EQU iVOLM  = PC2
; PC3  - Out - iRiver Volume Plus
.EQU iVOLP  = PC3
; PC4  - Out - Panasonic Motor Controll
.EQU pMOTOR = PC4
; PC5  - Out - Panasonic Sleep Controll
.EQU pSLEEP = PC5
; ADC6 - In  - iRiver ADC Reference Voltage
; ADC7 - In  - ADC Vcc Status

;***********************************************************************************
;*****************[ Переменные в ОЗУ ]**********************************************
;***********************************************************************************

.DSEG
  rUMode:    .BYTE 1
  rUSize:    .BYTE 2
  rUBuffer:  .BYTE 60
  rUCnt:     .BYTE 2
  rUPtr:     .BYTE 2
  rUCS:      .BYTE 2
.CSEG

;***********************************************************************************
;*****************[ Регистровые переменные ]****************************************
;***********************************************************************************

;*****************[ Main ]**********************************************************
.DEF Light  = r2

.DEF Temp   = r16
.DEF Delay  = r17
.DEF Count  = r18
.DEF Port   = r19
.DEF Flags  = r20
.EQU  UF    = 0
.EQU  MF    = 1
.EQU  TF    = 2

;*****************[ UART ]**********************************************************

.DEF USREG   = r13
;DEF Temp    = r16
.DEF Mode    = r16
.DEF U_Data  = r21
.DEF U_Addr  = r22
.DEF U_Cmd   = r23
.DEF U_Param = r24

.DEF U_Cnt   = r26
.DEF U_CntL  = r26
.DEF U_CntH  = r27
.DEF U_Reg   = r28
.DEF U_RegL  = r28
.DEF U_RegH  = r29
.DEF U_Ptr   = r28
.DEF U_PtrL  = r28
.DEF U_PtrH  = r29
.DEF U_CS    = r30
.DEF U_CSL   = r30
.DEF U_CSH   = r31
