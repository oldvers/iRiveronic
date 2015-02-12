iRiver_Init:
   cbi   PORTB,iSTART
   sbi   DDRB,iSTART
   cbi   PORTC,iVOLM
   sbi   DDRC,iVOLM
   cbi   PORTC,iVOLP
   sbi   DDRC,iVOLP
   cbi   PORTB,iBACK
   sbi   DDRB,iBACK
   cbi   PORTB,iNEXT
   sbi   DDRB,iNEXT
   ret

iRiver_On:
iRiver_Mute:
   sbi   PORTB,iSTART
   ldi   Delay,20   ;200 ms
   rcall Delay_x10ms
   cbi   PORTB,iSTART
   ret

iRiver_Off:
   sbi   PORTB,iSTART
   ldi   Delay,250   ;2500 ms
   rcall Delay_x10ms
   cbi   PORTB,iSTART
   ret

iRiver_VolM:
   sbi   PORTC,iVOLM
   ldi   Delay,20   ;200 ms
   rcall Delay_x10ms
   cbi   PORTC,iVOLM
   ret

iRiver_VolP:
   sbi   PORTC,iVOLP
   ldi   Delay,20   ;200 ms
   rcall Delay_x10ms
   cbi   PORTC,iVOLP
   ret

iRiver_Back:
   sbi   PORTB,iBACK
   ldi   Delay,20   ;200 ms
   rcall Delay_x10ms
   cbi   PORTB,iBACK
   ret

iRiver_Next:
   sbi   PORTB,iNEXT
   ldi   Delay,20   ;200 ms
   rcall Delay_x10ms
   cbi   PORTB,iNEXT
   ret
