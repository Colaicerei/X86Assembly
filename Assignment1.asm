TITLE Assignment #1     (Assignment1.asm)

; Author:                Chen Zou
; Last Modified:         04 July 2018
; OSU email address:     zouch@oregonstate.edu
; Course number/section: CS271-400
; Assignment Number:     #1            
; Due Date:              8 July 2018
; Description:           This program validates and gets two numbers from user, to calculate the sum,  
;                        difference, product, quotient(round to .001), remainder, and displays results,
;                        repeats the process until user choose to quit, then exit with goodbye message. 

INCLUDE Irvine32.inc



.data
programTitle   BYTE      "         Assignment #1      by Chen Zou", 0
instruction    BYTE      "Enter 2 numbers, and I'll show you the sum, difference, product, quotient, and remainder.", 0
exitMsg        BYTE      "Impressed? Bye!", 0
EC1Msg         BYTE      "**EC1: Program will repeat until user chooses to quit.", 0
EC2Msg         BYTE      "**EC2: Program verifies second number <= the first number.", 0
EC3Msg         BYTE      "**EC3: The quotient is calaulted and displayed as floating-point number rounded to the nearest .001", 0
number1        DWORD     ?                             ;first number to be entered by user
number2        DWORD     ?                             ;second number to be entered by user 
number1Pmt     BYTE      "First number: ", 0
number2Pmt     BYTE      "Second number: ", 0
sum            DWORD     ?                             ;sum of first number and second number
difference     DWORD     ?                             ;difference of first number and second number
product        DWORD     ?                             ;product of first number and second number
quotient       DWORD     ?                             ;quotient of first number/second number
remainder      DWORD     ?                             ;remainder of first number/second number
replayMsg      BYTE      "Enter 1 to play gain, other numbers to quit.", 0
replayChoice   DWORD     ?                             ;user choice of replay or quit
validationMsg  BYTE      "Invalid input! number 2 must be less than or equal to number 1!", 0
plusSymbol     BYTE      " + ", 0
minusSymbol    BYTE      " - ", 0
timesSymbol    BYTE      " x ", 0
equalSymbol    BYTE      " = ", 0
remaindSymbol  BYTE      " remainder ", 0
quotientEC3    REAL4     ?                             ;quotient results in floating point 
enlarged       DWORD     ?                             ;floating point quotient results times 1000
intPart        DWORD     ?                             ;int part of floating point quotient
firstDec       DWORD     ?                             ;the first decimal place of floating point quotient
secondDec      DWORD     ?                             ;the second decimal place
thirdDec       DWORD     ?                             ;the third decimal place
EC3display     BYTE      "Or, the quotient result in floating point is: ", 0
thousand       DWORD     1000

.code
main PROC

;Introduce programmer 
     mov       edx, OFFSET programTitle
     call      WriteString
     call      CrLf

;Display extra credit messages 
     mov       edx, OFFSET EC1Msg
     call      WriteString
     call      CrLf
     mov       edx, OFFSET EC2Msg
     call      WriteString
     call      CrLf
     mov       edx, OFFSET EC3Msg
     call      WriteString
     call      CrLf
     call      CrLf

;Display instruction 
     mov       edx, OFFSET instruction
     call      WriteString
     call      CrLf
     call      CrLf
     
Start:     
;get user input for number 1
     mov       edx, OFFSET number1Pmt
     call      WriteString
     call      ReadInt
     mov       number1, eax
 
;get and validate user input for number 2
     mov       edx, OFFSET number2Pmt
     call      WriteString
     call      ReadInt
     mov       number2, eax
     mov       ebx, number1
     cmp       ebx, eax
     jb        ValidationError
     jae       Calculation  

ValidationError:
     mov       edx, OFFSET validationMsg
     call      WriteString
     call      CrLf
     call      CrLf
     jmp       Replay
  
Calculation:  
;calculate the required values
     ;calculate sum
     mov       eax, number1
     add       eax, number2            
     mov       sum, eax                
     
     ;calculate difference
     mov       eax, number1             
     sub       eax, number2             
     mov       difference, eax
     
     ;calculate product
     mov       eax, number1             
     mov       ebx, number2
     mul       ebx                      
     mov       product, eax
     
     ;calculate quotient and remainder
     mov       edx, 0              ;set edx to 0 to avoid overflow
     mov       eax, number1
     mov       ebx, number2
     cdq
     div       ebx                      
     mov       quotient, eax
     mov       remainder, edx

     ;floating division calculation for EC3, reference from Stackoverflow
     finit     
     fild       number1             ;load number1 into ST(0) 
     fidiv     number2             ;divide ST(0) by number 2
     fimul     thousand            ;preserve three decimal digits
     frndint   
     fidiv     thousand            ;reverse the fimul thousand
     fst       quotientEC3         ;save to quotientEC3
                 

;display the results
     ; display sum
     call      CrLf
     mov       eax, number1
     call      WriteDec
     mov       edx, OFFSET plusSymbol
     call      WriteString
     mov       eax, number2
     call      WriteDec
     mov       edx, OFFSET equalSymbol
     call      WriteString
     mov       eax, sum
     call      WriteDec
     call      CrLf

     ; display difference
     mov       eax, number1
     call      WriteDec
     mov       edx, OFFSET minusSymbol
     call      WriteString
     mov       eax, number2
     call      WriteDec
     mov       edx, OFFSET equalSymbol
     call      WriteString
     mov       eax, difference
     call      WriteDec
     call      CrLf

     ; display product
     mov       eax, number1
     call      WriteDec
     mov       edx, OFFSET timesSymbol
     call      WriteString
     mov       eax, number2
     call      WriteDec
     mov       edx, OFFSET equalSymbol
     call      WriteString
     mov       eax, product
     call      WriteDec
     call      CrLf

     ; display quotient and remainder
     mov       eax, number1
     call      WriteDec
     mov       al, 32
     call      WriteChar
     mov       al, 246
     call      WriteChar
     mov       al, 32
     call      WriteChar
     mov       eax, number2
     call      WriteDec
     mov       edx, OFFSET equalSymbol
     call      WriteString
     mov       eax, quotient
     call      WriteDec
     mov       edx, OFFSET remaindSymbol
     call      WriteString
     mov       eax, remainder
     call      WriteDec
     call      CrLf
     

     ;display quotient in floating point
     mov       edx, OFFSET EC3display
     call      WriteString
     fld       quotientEC3         ;load floating quotient into ST(0) 
     fimul     thousand            ;times thousand
     fist      enlarged            ;store the result to enlarged as integer
     mov       edx, 0 
     mov       eax, enlarged
     mov       ebx, 10             
     cdq
     div       ebx                 ;get third decimal number
     mov       thirdDec, edx    
     cdq                           
     div       ebx                 ;get second decimal number
     mov       secondDec, edx        
     cdq
     div       ebx                 ;get first decimal number
     mov       firstDec, edx         
     call      WriteDec            ;display integer part
     mov       al, 46         
     call      WriteChar           ;display dot
     mov       eax, firstDec
     call      WriteDec            ;display first, second and third decimal
     mov       eax, secondDec
     call      WriteDec
     mov       eax, thirdDec
     call      WriteDec
     call      CrLf 
     call      CrLf

Replay:
     mov       edx, OFFSET replayMsg
     call      WriteString
     call      CrLf
     call      ReadInt
     mov       replayChoice, eax
     cmp       eax,1
     je        Start

     
;exit with message
     mov       edx, OFFSET exitMsg
     call      WriteString
     call      CrLf

	exit      ;exit to operating system	                                
main ENDP

END main
