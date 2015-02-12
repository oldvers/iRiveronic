Panasonic_Init:
   cbi   PORTD,S1
   sbi   DDRD,S1
   cbi   PORTD,S2
   sbi   DDRD,S2
   cbi   PORTD,pLIGHT
   sbi   DDRD,pLIGHT

   sbi   PORTB,pMSIN

   cbi   PORTC,pSLEEP
   sbi   DDRC,pSLEEP
   cbi   PORTC,pMOTOR
   sbi   DDRC,pMOTOR
   ret

Panasonic_External:
   sbi   PORTD,S1
   sbi   PORTD,S2
   ldi   Delay,20
   rcall Delay_x10ms
   ret

Panasonic_Internal:
   cbi   PORTD,S1
   cbi   PORTD,S2
   ldi   Delay,20
   rcall Delay_x10ms
   ret

Panasonic_Light:
   clr   Temp
   cpse  Temp,Light
   rjmp  PL_Process
PL_Off:
   clr   Temp
   sts   TCCR2A,Temp
   sts   TCCR2B,Temp
   rjmp  PL_End
PL_Process:
   clr   Temp
   sts   TCNT2,Temp
   ldi   Temp,(0 << COM2A0) | (2 << COM2B0) | (3 << WGM20)
   sts   TCCR2A,Temp
   sts   OCR2B,Light
   ldi   Temp,(0 << WGM22) | (1 << CS20)
   sts   TCCR2B,Temp
PL_End:
   ldi   Delay,20
   rcall Delay_x10ms
   ret

Panasonic_Status:
   ;pIRRX
   sbic  PINB,pIRRX
   cbi   PORTD,STATUS
   sbis  PINB,pIRRX
   sbi   PORTD,STATUS
   ;pSLPIN
   sbic  PINB,pSLPIN
   cbi   PORTD,STATUS
   sbis  PINB,pSLPIN
   sbi   PORTD,STATUS
   ;pMSIN
   sbic  PINB,pMSIN
   cbi   PORTD,STATUS
   sbis  PINB,pMSIN
   sbi   PORTD,STATUS
   ;pCASS
   sbic  PINC,pCASS
   cbi   PORTD,STATUS
   sbis  PINC,pCASS
   sbi   PORTD,STATUS
   ret

Panasonic_Sleep_On:
   sbi   PORTC,pSLEEP
   ldi   Delay,20
   rcall Delay_x10ms
   ret

Panasonic_Sleep_Off:
   cbi   PORTC,pSLEEP
   ldi   Delay,20
   rcall Delay_x10ms
   ret

Panasonic_Motor_On:
   sbi   PORTC,pMOTOR
   ldi   Delay,20
   rcall Delay_x10ms
   ret

Panasonic_Motor_Off:
   cbi   PORTC,pMOTOR
   ldi   Delay,20
   rcall Delay_x10ms
   ret
