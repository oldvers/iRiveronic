.INCLUDE "m48def.inc"
.INCLUDE "Definitions.asm"
.INCLUDE "Interrupts.asm"
.INCLUDE "UART.asm"
.INCLUDE "WDT.asm"
.INCLUDE "iRiver.asm"
.INCLUDE "Panasonic.asm"

Reset:
   ldi   Temp,Byte1(RAMEND)
   out   SPL,Temp
   ldi   Temp,Byte2(RAMEND)
   out   SPH,Temp

   sbi   DDRD,STATUS
   sbi   PORTD,STATUS

   rcall iRiver_Init
   rcall Panasonic_Init

   ldi   Delay,6
   rcall Delay_x10ms ;60 ms

   clr   Flags

   rcall UART_Init

   ldi   Delay,200
   rcall Delay_x10ms
   cbi   PORTD,STATUS


   ;ldi   U_Data,133
   ;rcall UART_Tx
   ;ldi   U_Data,2
   ;rcall UART_Tx
   ;ldi   U_Data,13
   ;rcall UART_Tx
   ;ldi   U_Data,3
   ;rcall UART_Tx
   ;ldi   U_Data,33
   ;rcall UART_Tx
   ;ldi   U_Data,14
   ;rcall UART_Tx

   sei

;Forever:
   ;ldi   Delay,100
   ;rcall Delay_x10ms
   ;ldi   U_Data,133
   ;rcall UART_Tx
   ;ldi   U_Data,2
   ;rcall UART_Tx
   ;ldi   U_Data,13
   ;rcall UART_Tx
   ;ldi   U_Data,3
   ;rcall UART_Tx
   ;ldi   U_Data,33
   ;rcall UART_Tx
   ;ldi   U_Data,14
   ;rcall UART_Tx
   ;rjmp  Forever

WaitFor:
   rcall Panasonic_Status
   sbrs  Flags,UF
   rjmp  WaitFor
   rcall UART_CmdProc
   rjmp  WaitFor
   
   
   
   
   
;   sbic  PIND,BOOT
;   rjmp  PreLoad

;   inc   Count
;   cpi   Count,1
;   breq  iRiver_On
;   cpi   Count,2
;   breq  iRiver_Mute
;   cpi   Count,3
;   breq  iRiver_Mute
;   cpi   Count,4
;   breq  iRiver_Off
;   clr   Count
;   ldi   Delay,10   ;100 ms
;   rcall Delay_x10ms
;   rjmp  PreLoad
   
;iRiver_On:
;   sbi   PORTB,START
;   ldi   Delay,20   ;200 ms
;   rcall Delay_x10ms
;   cbi   PORTB,START
;   rjmp  PreLoad   

;iRiver_Mute:
;   sbi   PORTB,START
;   ldi   Delay,20   ;200 ms
;   rcall Delay_x10ms
;   cbi   PORTB,START
;   rjmp  PreLoad   

;iRiver_Off:
;   sbi   PORTB,START
;   ldi   Delay,250   ;2500 ms
;   rcall Delay_x10ms
;   cbi   PORTB,START
;   clr   Count
;   rjmp  PreLoad   



   ;ldi   Delay,30


;Delay:
;   dec   Del1
;   brne  Delay
;   dec   Del2
;   brne  Delay
;   dec   Del3
;   brne  Delay;

  ; in    Port,PORTD
  ; sbrc  Port,PD5
  ; cbi   PORTD,PD5
  ; sbrs  Port,PD5
  ; sbi   PORTD,PD5
  ; rjmp  PreLoad






;OCR1A = 10800 -> 1 second => 11 -> 1 millisecond
; Delay Diskrete = 10 millisecond
Delay_x10ms:
   clr   Temp
   sts   TCCR1A,Temp
   sts   TCCR1B,Temp
   sts   TCCR1C,Temp
   sts   TCNT1H,Temp
   sts   TCNT1L,Temp

   ldi   Temp,(11*10)
   mul   Temp,Delay
   sts   OCR1AH,R1
   sts   OCR1AL,R0

   ldi   Temp,(1<<WGM12)|(5<<CS10)
   sts   TCCR1B,Temp

   in    Temp,TIFR1
   sbr   Temp,(1<<OCF1A)
   out   TIFR1,Temp
DLoop:
   in    Temp,TIFR1
   sbrs  Temp,OCF1A
   rjmp  DLoop
   ret

