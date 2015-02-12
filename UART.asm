.EQU FOSC = 11059200   ;Hz
.EQU BAUD = 115200     ;Bit/s

.EQU UBRR = ((FOSC/16/BAUD) - 1)


UART_Init:
   clr   Temp
   sts   (rUCnt + 0),Temp
   sts   (rUCnt + 1),Temp
   sts   (rUPtr + 0),Temp
   sts   (rUPtr + 1),Temp
   sts   (rUCS + 0),Temp
   sts   (rUCS + 1),Temp
   ldi   Mode,EAST2_WAIT_START
   sts   rUMode,Mode

   sbi   DDRD,PD1

   ldi   Temp,Byte2(UBRR)
   sts   UBRR0H,Temp
   ldi   Temp,Byte1(UBRR)
   sts   UBRR0L,Temp
   
   clr   Temp
   sts   UCSR0A,Temp

   ldi   Temp,(1<<RXCIE0)|(1<<RXEN0)|(1<<TXEN0)|(0<<TXCIE0)
   sts   UCSR0B,Temp

   ldi   Temp,(0<<UMSEL00)|(0<<UPM00)|(0<<USBS0)|(3<<UCSZ00)|(0<<UCPOL0)
   sts   UCSR0C,Temp
   ret


UART_Tx:
   ;push  U_Data
   lds   Temp,UCSR0A
   sbr   Temp,(1<<TXC0)
   sts   UCSR0A,Temp
   ;pop   U_Data
   sts   UDR0,U_Data
UT_Wait:
   lds   Temp,UCSR0A
   sbrs  Temp,TXC0
   rjmp  UT_Wait
   ret


UART_Rx:
   ;push  U_Data
UR_Wait:
   lds   Temp,UCSR0A
   sbrs  Temp,RXC0
   rjmp  UR_Wait
   ;pop   U_Data
   lds   U_Data,UDR0
   ret




UART_RxC:
   in    USREG,SREG
   lds   U_Data,UDR0
   push  Mode
   lds   Mode,rUMode
URC_Start:
   cpi   Mode,EAST2_WAIT_START
   brne  URC_SizeL
   ldi   Temp,EAST2_START
   cpse  U_Data,Temp
   rjmp  URC_Error
   ldi   Mode,EAST2_WAIT_SIZEL
   ;rcall UART_Tx
   rjmp  URC_End
URC_SizeL:
   cpi   Mode,EAST2_WAIT_SIZEL
   brne  URC_SizeH
   sts   (rUCnt + 0),U_Data
   sts   (rUSize + 0),U_Data
   ldi   Mode,EAST2_WAIT_SIZEH
   ;rcall UART_Tx
   rjmp  URC_End
URC_SizeH:
   cpi   Mode,EAST2_WAIT_SIZEH
   brne  URC_Data
   sts   (rUCnt + 1),U_Data
   sts   (rUSize + 1),U_Data

   push  U_RegL
   push  U_RegH

   ldi   U_RegL,Byte1(rUBuffer)
   ldi   U_RegH,Byte2(rUBuffer)
   sts   (rUPtr + 0),U_RegL
   sts   (rUPtr + 1),U_RegH

   clr   U_Reg
   sts   (rUCS + 0),U_Reg
   sts   (rUCS + 1),U_Reg

   pop   U_RegH
   pop   U_RegL

   ldi   Mode,EAST2_WAIT_DATA
   ;rcall UART_Tx
   rjmp  URC_End
URC_Data:
   cpi   Mode,EAST2_WAIT_DATA
   brne  URC_Stop

   ;ldi   Mode,EAST2_WAIT_STOP
   ;cp    U_Count,U_Size
   ;brsh  URC_Stop

   push  U_RegL
   push  U_RegH

   lds   U_RegL,(rUPtr + 0)
   lds   U_RegH,(rUPtr + 1)
   st    Y+,U_Data
   sts   (rUPtr + 0),U_RegL
   sts   (rUPtr + 1),U_RegH

   lds   U_RegL,(rUCS + 0)
   lds   U_RegH,(rUCS + 1)
   add   U_RegL,U_Data
   clr   U_Data
   adc   U_RegH,U_Data
   sts   (rUCS + 0),U_RegL
   sts   (rUCS + 1),U_RegH

   lds   U_RegL,(rUCnt + 0)
   lds   U_RegH,(rUCnt + 1)
   sbiw  U_Reg,1
   sts   (rUCnt + 0),U_RegL
   sts   (rUCnt + 1),U_RegH

   pop   U_RegH
   pop   U_RegL
   brne  URC_End

   ldi   Mode,EAST2_WAIT_STOP
   rjmp  URC_End
URC_Stop:
   ;cp    U_Count,U_Size
   ;brne  URC_CS
   ;ldi   Temp,33
   ;cp    IO,Temp
   cpi   Mode,EAST2_WAIT_STOP
   brne  URC_CSL
   cpi   U_Data,EAST2_STOP
   brne  URC_Error
   ;inc   U_Count
   ldi   Mode,EAST2_WAIT_CSL
   ;rcall UART_Tx
   rjmp  URC_End
URC_CSL:
   ;cp    IO,U_CS
   cpi   Mode,EAST2_WAIT_CSL
   brne  URC_CSH
;rcall UART_Tx
   lds   Temp,(rUCS + 0)
;mov U_Data,Temp
   cp    U_Data,Temp
   brne  URC_Error
   ldi   Mode,EAST2_WAIT_CSH
;rcall UART_Tx
   rjmp  URC_End
URC_CSH:
   cpi   Mode,EAST2_WAIT_CSH
   brne  URC_Error
;rcall UART_Tx
   lds   Temp,(rUCS + 1)
;mov U_Data,Temp
   cp    U_Data,Temp
   brne  URC_Error
   sbr   Flags,(1<<UF)
;rcall UART_Tx
URC_Error:
   clr   Temp
   sts   (rUCnt + 0),Temp
   sts   (rUCnt + 1),Temp
   ldi   Mode,EAST2_WAIT_START
URC_End:
   sts   rUMode,Mode
   pop   Mode
   out   SREG,USREG
   reti



;UART_RxCommand:
;   clr   U_Count
;URC_Wait:
;   rcall UART_Rx
;URC_Start:
;   cpi   U_Count,0
;   brne  URC_Size
;   cpi   U_Data,133
;   brne  URC_Error
;   inc   U_Count
;   rjmp  URC_Wait
;URC_Size:
;   cpi   U_Count,1
;   brne  URC_Block
;   mov   U_Size,U_Data
;   ldi   U_PtrL,Byte1(rCommand)
;   ldi   U_PtrH,Byte2(rCommand)
;   st    Y+,U_Size
;   subi  U_Size,-2
;   clr   U_CS
;   inc   U_Count
;   rjmp  URC_Wait
;URC_Block:
;   cp    U_Count,U_Size
;   brsh  URC_Stop
;   st    Y+,U_Data
;   eor   U_CS,U_Data
;   inc   U_Count
;   rjmp  URC_Wait
;URC_Stop:
;   cp    U_Count,U_Size
;   brne  URC_CS
;   cpi   U_Data,33
;   brne  URC_Error
;   inc   U_Count
;   rjmp  URC_Wait
;URC_CS:
;   cp    U_Data,U_CS
;   brne  URC_Error
;   rcall UART_CmdProc
;URC_Error:
;   ret
































UART_CmdProc:
   sbi   PORTD,STATUS
   ldi   U_PtrL,Byte1(rUBuffer)
   ldi   U_PtrH,Byte2(rUBuffer)
   lds   U_CntL,(rUSize + 0)
   lds   U_CntH,(rUSize + 1)
   ld    U_Addr,Y+
   ld    U_Cmd,Y+
   ld    U_Param,Y+
   sbiw  U_Ptr,1

   cpi   U_Addr,EAST2_DEVICE_ADDRESS
   breq  UCP_Connect
   rjmp  UCP_Error
;******
UCP_Connect:
   cpi   U_Cmd,CMD_CONNECT
   brne  UCP_Enter_Boot

   ldi   Temp,Byte1(IP_VERSION)
   st    Y+,Temp
   ldi   Temp,Byte2(IP_VERSION)
   st    Y+,Temp

   ldi   Temp,Byte1(IP_PROJECT_DATE)
   st    Y+,Temp
   ldi   Temp,Byte2(IP_PROJECT_DATE)
   st    Y+,Temp
   ldi   Temp,Byte3(IP_PROJECT_DATE)
   st    Y+,Temp
   ldi   Temp,Byte4(IP_PROJECT_DATE)
   st    Y+,Temp

   ldi   Temp,Byte1(IP_PROJECT_TIME)
   st    Y+,Temp
   ldi   Temp,Byte2(IP_PROJECT_TIME)
   st    Y+,Temp
   ldi   Temp,Byte3(IP_PROJECT_TIME)
   st    Y+,Temp
   ldi   Temp,Byte4(IP_PROJECT_TIME)
   st    Y+,Temp

   ldi   U_Cnt,8
   clr   Temp
UCPC_Loop:
   st    Y+,Temp
   dec   U_Cnt
   brne  UCPC_Loop

   clr   U_CntH
   ldi   U_CntL,20
   rjmp  UCP_End
;******
UCP_Enter_Boot:
   cpi   U_Cmd,CMD_BOOT_ENTER
   brne  UCP_Disconnect

   ldi   Temp,Byte1($A55A)
   sts   ($0100),Temp
   ldi   Temp,Byte2($A55A)
   sts   ($0101),Temp
   rcall WDT_On
UCPEB_WaitBoot:
   rjmp  UCPEB_WaitBoot
;******
UCP_Disconnect:
   cpi   U_Cmd,CMD_DISCONNECT
   brne  UCP_On
   rjmp  UCP_Success
;******
UCP_Error:
   clr   U_CntH
   ldi   U_CntL,3
   ldi   Temp,STATUS_ERROR
   sts   (rUBuffer + 2),Temp
   rjmp  UCP_End
;******
UCP_On:
   ldi   U_Data,CMD_IRIVER_ON
   cpse  U_Cmd,U_Data
   rjmp  UCP_Mute
   rcall iRiver_On
   rjmp  UCP_Success
UCP_Mute:
   ldi   U_Data,CMD_IRIVER_MUTE
   cpse  U_Cmd,U_Data
   rjmp  UCP_Off
   rcall iRiver_Mute
   rjmp  UCP_Success
UCP_Off:
   ldi   U_Data,CMD_IRIVER_OFF
   cpse  U_Cmd,U_Data
   rjmp  UCP_VolM
   rcall iRiver_Off
   rjmp  UCP_Success
UCP_VolM:
   ldi   U_Data,CMD_IRIVER_VOLM
   cpse  U_Cmd,U_Data
   rjmp  UCP_VolP
   rcall iRiver_VolM
   rjmp  UCP_Success
UCP_VolP:
   ldi   U_Data,CMD_IRIVER_VOLP
   cpse  U_Cmd,U_Data
   rjmp  UCP_Back
   rcall iRiver_VolP
   rjmp  UCP_Success
UCP_Back:
   ldi   U_Data,CMD_IRIVER_BACK
   cpse  U_Cmd,U_Data
   rjmp  UCP_Next
   rcall iRiver_Back
   rjmp  UCP_Success
UCP_Next:
   ldi   U_Data,CMD_IRIVER_NEXT
   cpse  U_Cmd,U_Data
   rjmp  UCP_External
   rcall iRiver_Next
   rjmp  UCP_Success
UCP_External:
   ldi   U_Data,CMD_PANASONIC_EXTERNAL
   cpse  U_Cmd,U_Data
   rjmp  UCP_Internal
   rcall Panasonic_External
   rjmp  UCP_Success
UCP_Internal:
   ldi   U_Data,CMD_PANASONIC_INTERNAL
   cpse  U_Cmd,U_Data
   rjmp  UCP_Light
   rcall Panasonic_Internal
   rjmp  UCP_Success
UCP_Light:
   ldi   U_Data,CMD_PANASONIC_LIGHT
   cpse  U_Cmd,U_Data
   rjmp  UCP_Sleep_On
   mov   Light,U_Param
   rcall Panasonic_Light
   rjmp  UCP_Success
UCP_Sleep_On:
   ldi   U_Data,CMD_PANASONIC_SLEEP_ON
   cpse  U_Cmd,U_Data
   rjmp  UCP_Sleep_Off
   mov   Light,U_Param
   rcall Panasonic_Sleep_On
   rjmp  UCP_Success
UCP_Sleep_Off:
   ldi   U_Data,CMD_PANASONIC_SLEEP_OFF
   cpse  U_Cmd,U_Data
   rjmp  UCP_Motor_On
   mov   Light,U_Param
   rcall Panasonic_Sleep_Off
   rjmp  UCP_Success
UCP_Motor_On:
   ldi   U_Data,CMD_PANASONIC_MOTOR_ON
   cpse  U_Cmd,U_Data
   rjmp  UCP_Motor_Off
   mov   Light,U_Param
   rcall Panasonic_Motor_On
   rjmp  UCP_Success
UCP_Motor_Off:
   ldi   U_Data,CMD_PANASONIC_MOTOR_OFF
   cpse  U_Cmd,U_Data
   rjmp  UCP_End
   mov   Light,U_Param
   rcall Panasonic_Motor_Off

UCP_Success:
   clr   U_CntH
   ldi   U_CntL,3
   ldi   Temp,STATUS_SUCCESS
   sts   (rUBuffer + 2),Temp

UCP_End:
   cbr   Flags,(1<<UF)
   cbi   PORTD,STATUS
   rcall UART_Tx_Answer
   ret














UART_Tx_Answer:
   clr   U_CSL
   clr   U_CSH
   ldi   U_PtrL,Byte1(rUBuffer)
   ldi   U_PtrH,Byte2(rUBuffer)

   ldi   U_Data,EAST2_START
   rcall UART_Tx

   mov   U_Data,U_CntL
   rcall UART_Tx

   mov   U_Data,U_CntH
   rcall UART_Tx

UTA_Loop:
   ld    U_Data,Y+
   clr   Temp
   add   U_CSL,U_Data
   adc   U_CSH,Temp
   rcall UART_Tx
   sbiw  U_CntL,1
   brne  UTA_Loop

   ldi   U_Data,EAST2_STOP
   rcall UART_Tx

   mov   U_Data,U_CSL
   rcall UART_Tx
   mov   U_Data,U_CSH
   rcall UART_Tx
   ret








