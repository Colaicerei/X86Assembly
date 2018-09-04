TITLE Assignment #5A     (Assignment5.asm)

; Author:                Chen Zou
; Last Modified:         11 Aug 2018
; OSU email address:     zouch@oregonstate.edu
; Course number/section: CS271-400
; Assignment Number:     #5            
; Due Date:              12 Aug 2018
; Description:           This program prompts user to enter 10 numbers in string format, then validate and convert the string 
;                        to integers. The programs then calculate the sum and average of the numbers, and displays the list, 
;                        the sum and average values in string format. 
 
                          

INCLUDE Irvine32.inc

ECMIN = -2147483648
ECMAX = 2147483647
LO = 48       ;ASCII code of digit 0
HI = 57       ;ASCII code of digit 9


;-----------------------------------------------------------------------------------------
displayString    MACRO bufferOffset
; Description:       Prodcedure to display string parameter
; Receivers:         address of strings
; Returns:           none
; Registers changed: edx
;-----------------------------------------------------------------------------------------
     push      edx                           ;Save edx register
     mov       edx, bufferOffset
     call      WriteString
     
     pop       edx                           ;Restore edx
ENDM

;-----------------------------------------------------------------------------------------
getString      MACRO inStringOffset, length
; Description:       Prodcedure to get string from user 
; Receivers:         offset and length of string to get
; Returns:           none
; Preconditions:     none
; Registers changed: none
;-----------------------------------------------------------------------------------------
LOCAL     numberPmt
.data
numberPmt      BYTE      "Please enter an integer: ", 0

.code
     push      ecx
     push      edx

     displayString OFFSET numberPmt
     
     mov       edx, inStringOffset
     mov       ecx, length
     call      ReadString
     
     pop       edx
     pop       ecx
ENDM


.data
programTitle   BYTE      "Designing Low-level I/O Procedures         ", 0
programmer     BYTE      "Chen Zou", 0
programmerPmt  BYTE      "Programmed by ",0
instruction    BYTE      "Please provide 10 unsigned or signed decimal integers. ", 10
               BYTE      "Each number needs to be small enough to fit inside a 32 bit register. ", 10
               BYTE      "After you have finished inputting the raw numbers I will display a list of the integers, ", 10
               BYTE      "their sum, and their average value. ", 10, 0
ECMsg          BYTE      "**EC1: Number seach line of user input/displays running subtotal of user specified numbers.", 10
               BYTE      "**EC2: Handles signed integers.", 10
               BYTE      "**EC3: Read Val and Write Val procedures are recursive. ", 10, 0     
               ;BYTE      "**EC4: implements ReadVal/WriteVal for floating point values,using the FPU.", 10
               ;BYTE      "**EC5: handles input/output with interrupts instead of ReadString and WriteString. ", 10, 0


;numberPmt      BYTE      "Please enter an integer number: ", 0
inputString    BYTE      20 DUP(?)
outputString   BYTE      20 DUP(?)
;sLength        DWORD     ?
list           DWORD     10 DUP(?)
arraysize      DWORD     10
sumOfArray     DWORD     0                                  ;sum of the numbers from user input
validationPmt  BYTE      "ERROR: you did not enter an unsigned number or your number was too big. ", 10
               BYTE      "Please try again: ", 0
displayPmt     BYTE      10, "You entered the following numbers: ", 10, 0
seperation     BYTE      ",  ", 0
sumPmt         BYTE      10, "The sum of these numbers is: ", 0
avePmt         BYTE      10, "The average is: ", 0
subtotalPmt    BYTE      "     The subtotal of current numbers you entered is: ", 0
certifyPmt     BYTE      "Results certified by Chen Zou. ", 0
exitMsg        BYTE      " Thanks for playing!", 0               


.code
main PROC
     
;introduction
     call      introduction                       ;Introduction programmer and instruction

;get user input to fill array    
     push      OFFSET list
     push      arraysize
     call      fillArray                           ;get user input string and convert to number then fill array

;display array
     push      OFFSET list                        ;push address of unsorted array
     push      arraysize                          ;push the size of array
     call      displayList                        
     call      CrLf

;calculate and display the sum and average                
     push      OFFSET list                        ;push address of array to be filled
     push      arraysize                          ;push the size of array
     call      displayResult 
     call      CrLf

;farewell     
     call      farewell
     exit                                         ;exit to operating system
                    
main ENDP


;-----------------------------------------------------------------------------------------
introduction PROC
; Description:       Prodcedure to introduce the programmer and display program 
;                    instructions.
; Receivers:         none
; Returns:           none
; Preconditions:     none
; Registers changed: edx
;-----------------------------------------------------------------------------------------
;introduce programmer     
     ;push      ebp
     ;mov       ebp, esp

     displayString OFFSET programTitle
     displayString OFFSET programmerPmt
     displayString OFFSET programmer
     call      CrLf
     call      CrLf
     displayString OFFSET ECMsg
     call      CrLf
     displayString OFFSET instruction      
     call      CrLf

     ;pop       ebp
     RET       

introduction ENDP


;-----------------------------------------------------------------------------------------
readVal2 PROC
; Description:       Prodcedure to get string input, then convert to number recursively
; Receivers:         address of input string, string length
; Returns:           eax as converted number
; Preconditions:     none
; Registers changed: eax, ebx, edx
;-----------------------------------------------------------------------------------------
local     multiplier:DWORD      ;for conversion
     mov       multiplier, 10

     ;push      ebp
     ;mov       ebp, esp
     push      ecx
     push      edi

     mov       ecx, [ebp+8]
     mov       edi, [ebp+12]

     xor       ebx, ebx                           ;clear ebx

     ;Base Case to exit - last character  
     cmp       ecx, 1                          
     je        conversion         
        
     dec       ecx
     add       edi, 1
     push      edi
     push      ecx
     call      ReadVal2 

conversion:
     mov       eax, 0                             ;reset eax before load string
     mov       edx, 0                             ;reset edx to check overflow/carry
     lodsb     [edi]                              ;load first character of [edi] to eax

     ;convert character to digit and append digit to number by multipling 10 &add new digit
     sub       eax, LO

     xchg      eax, ebx
     mul       multiplier
     add       eax, ebx
     mov       ebx, eax                           ;save current conversion results
   
     pop       edi
     pop       ecx
     ;pop       ebp
     RET       8      

readVal2 ENDP


;-----------------------------------------------------------------------------------------
readVal PROC
; Description:       Prodcedure to get and validate user input in string then push it to 
;                    readVal2 for conversion         
; Receivers:         none
; Returns:           eax as valid number
; Preconditions:     none
; Registers changed: eax, ebx, ecx, edx, esi
;-----------------------------------------------------------------------------------------
LOCAL     tempInput[15]:BYTE
LOCAL     sLength:DWORD

getting:  
     LEA       edx, tempInput
     getString edx, SIZEOF tempInput 
     
validate:
     ;set up loop counter, put the string addresses in esi
     mov       sLength, eax                       ;save string length

     ;check if first digit is '-'
     lea       esi, tempInput
     mov       eax, [esi]
     cmp       al, 45
     je        negative
 
 positive:
     ;set up loop counter, put the string addresses in esi
     mov       ecx, sLength
     lea       esi, tempInput
     
     ;check each character to determine if it is all digits
checkDigit:
     lodsb                                   ;load character to eax
     ;check if individual character is digit
     cmp       al, LO
     jl        ValidationError
     cmp       al, Hi
     jg        ValidationError

     loop      checkDigit
     jmp       AllDigit    

;if input invalid, promt user to reenter until input valid
ValidationError:
     displayString  OFFSET ValidationPmt
     call      CrLf
     jmp       getting

AllDigit:
     lea       esi, tempInput
     push      esi                                ;push address of string 
     push      sLength                            ;push string length
     call      readVal2
     jc        ValidationError                    ;check if last digit caused carry
     cmp       edx, 0
     jne       ValidationError                    ;check if any digit before last caused carry
     cmp       eax, ECMAX                         ;check if it is above 2147483647
     ja        ValidationError
     jmp       inputOK
 
 negative:
     ;set up loop counter, put the the second character address in esi
     mov       ecx, sLength
     dec       ecx
     lea       esi, tempInput
     inc       esi
     
     ;check each character to determine if it is all digits
negativeDigit:
     lodsb                                   ;load character to eax
     ;check if individual character is digit
     cmp       al, LO
     jl        ValidationError
     cmp       al, Hi
     jg        ValidationError

     loop      negativeDigit
     ;jmp       AllNDigit    

;AllNDigit:
     lea       esi, tempInput
     inc       esi
     push      esi                                ;push address string excluding '-' 
     mov       ecx, sLength
     dec       ecx
     push      ecx                                ;push string length excluding '-'

     call      readVal2
     jc        ValidationError                    ;check if last digit caused carry
     cmp       edx, 0
     jne       ValidationError                    ;check if any digit before last caused carry
     
     ;negate eax
     mov       eax, ebx
     mov       eax, 0
     sub       eax, ebx
     ;neg       eax
     cmp       eax, ECMIN                         ;check if it is below -2147483648
     jb        ValidationError
     call writeInt
     call crlf
     
     jmp       inputOK

inputOK:       ;return to fillArray procedure
      
     RET       

readVal ENDP


;-----------------------------------------------------------------------------------------
 fillArray PROC
; Description:       Prodcedure to fill array with converted user input
; Receivers:         array, arraycount
; Returns:           filled element
; Preconditions:     none
; Registers changed: eax, edx, edi
;-----------------------------------------------------------------------------------------
LOCAL     subtotal:DWORD
     mov       subtotal, 0
     ;push      ebp
     ;mov       ebp,esp  
     mov       ecx, [ebp+8]
     mov       edi, [ebp+12]

filling:
     ;number each line of user input
     push      eax
     mov       eax, 10
     inc       eax
     sub       eax, ecx
     call      CrLf
     call      WriteDec
     mov       AL, 46
     call      WriteChar
     pop       eax

     push      ecx
     call      readVal
     pop       ecx

     ;add valid number to array
    	mov		[edi], eax				;move eax to current element of array
  
     ;display running subtotal
     add       eax, subtotal
     displayString  OFFSET subtotalPmt
     call      writeInt
     call      CrLf
     mov       subtotal, eax
    
	add       edi, 4					;multiply the count by TYPE DWORD to check placement.
     loop      filling

     RET       8
fillArray ENDP


;-----------------------------------------------------------------------------------------
WriteVal PROC 
; Description:       Prodcedure to convert numbers to string  recursively and display.
; Receivers:         numeric value
; Returns:           string converted from the input
; Preconditions:     none
; Registers changed: eax, ebx, edx, edi
;-----------------------------------------------------------------------------------------
  LOCAL    tempString[2]:BYTE
     ;push      ebp
     ;mov       ebp, esp

     pushad
     ;get individual digits from right side by dividing 10 at a time
     mov       eax, [ebp+8]
     xor       edx, edx
     mov       ebx, 10
     div       ebx

     ;Base Case to exit - no quotient left  
     cmp       eax, 0                          
     je        conversion         
        
     push      eax
     call      WriteVal            
       
Conversion:
     LEA       edi, tempString
     add       edx, LO
     mov       eax, edx                      ;Convert number to character
     stosb                                   ;output to temp string for display
     mov       eax, 0
     stosb                                   ;fill with null character to end temp string

     LEA       edx, tempString
     call      WriteString
 
        
     popad
     ;pop   ebp
     RET 4

writeVal	ENDP
     
;-----------------------------------------------------------------------------------------
displayList PROC
; Description:       Prodcedure to display the numbers in an array.
; Receivers:         address of array, count of elements in array
; Returns:           none
; Preconditions:     count >=1
; Registers changed: eax, ecx, esi
;-----------------------------------------------------------------------------------------  
     push      ebp
     mov       ebp, esp
     displayString OFFSET displayPmt

;set up loop counter
     mov       ecx,[ebp+8]                   ;count of array
     mov       esi,[ebp+12]                  ;address of array
         
DisplayNext:
     ;check if negative
     mov       eax, [esi]
     add       eax, 0
     js        negativeInt
   
   positiveInt:  
     push      [esi]
     call      writeVal                      ;display current number
     jmp       oneDone
  
  negativeInt:
     mov       al, 45
     call      WriteChar
     mov       eax, [esi]
     neg       eax
     push      eax
     call      writeVal
     

   oneDone:
     displayString  OFFSET seperation
     add       esi, 4                        ;esi pointing to next number
     loop      DisplayNext

     pop       ebp
     RET       8
DisplayList ENDP

;-----------------------------------------------------------------------------------------
displayResult PROC
; Description:       Prodcedure to calculate and display sum and average of an array.
; Receivers:         array by reference, array count by value
; Returns:           
; Preconditions:     none
; Registers changed: eax, ecx, edx, esi
;-----------------------------------------------------------------------------------------
LOCAL     sum:DWORD
;LOCAL     average:DWORD
LOCAL     ten:DWORD
LOCAL     count
     
     mov       sum, 0
     mov       ten, 10
     
     mov       ecx, [ebp+8]                  ;arraysize as loop counter
     mov       count, ecx                    ;assign arraysize to count
     mov       edi, [ebp+12]                 ;array address

     mov       eax, 0                        ;initialize eax
Summation:     ;add current element to the sum
     add       eax, [edi]
     add       edi, 4
     loop      Summation
     
     displayString  OFFSET sumPmt
     mov       sum, eax
     ;push      eax
     ;call      writeVal

      ;check if negative
     add       eax, 0
     js        negativeSum
   
  positiveSum:  
     ;display sum
     push      eax
     call      writeVal   
     
     ;calculate and diplay median in integer
     displayString  OFFSET avePmt     
     mov       eax, sum 
     mov       edx, 0
     div       count                         ;division

     push      eax
     call      WriteVal                      ;display integer part
     mov       al, 46         
     call      WriteChar                     ;display dot
     push      edx
     call      writeVal                      ;display decimal
     jmp       Done
  
  negativeSum:
     neg       eax
     push      eax
     mov       al, 45                        ;display negative sign
     call      WriteChar
     call      writeVal

     ;calculate and diplay median in integer
     displayString  OFFSET avePmt 
     mov       al, 45                        ;display negative sign
     call      WriteChar
     mov       eax, sum
     neg       eax
     mov       edx, 0
     div       count                         ;division

     push      eax
     call      WriteVal                      ;display integer part
     mov       al, 46         
     call      WriteChar                     ;display dot
     push      edx
     call      writeVal                      ;display decimal
     jmp       Done

Done:     
     RET       8     

displayResult ENDP  


;-----------------------------------------------------------------------------------------
farewell PROC
; Description:       Prodcedure to display certification and exit message.
; Receivers:         none
; Returns:           none
; Preconditions:     none
; Registers changed: edx, aL
;-----------------------------------------------------------------------------------------  

;display certification
     call      CrLf
     displayString OFFSET certifyPmt
     mov       AL, 46
     call      WriteChar

;display goodbye
     displayString OFFSET exitMsg 
     call      CrLf

     RET       
farewell ENDP


;-----------------------------------------------------------------------------------------
writeSpace PROC
; Description:       Prodcedure to calculate how many empty spaces are required to fill up
;                    the column and print those empty spaces.
; Receivers:         number to be filled with space
; Returns:           none
; Preconditions:     number of digits in eax <12
; Registers changed: none
;------------------------------------------------------------------------------------------
LOCAL     digitCount:DWORD                   ;count of digits of number to display

     PUSHAD                                  ;save general purpose registers to stack
     mov       eax, [ebp+8]

;count the digits of the number
     mov       ebx, 10
     mov       digitCount, 0                 ;reset count to zero
   Divide10:  
     mov       edx, 0                                  
     div       ebx
     inc       digitCount
     cmp       eax, 0                        ;if still have quotient, repeat dividing by 10
     jne       Divide10
        
;write spaces
     mov       eax, 11                       ;set total 11 spaces for every column      
     sub       eax, digitCount               ;get required empty spaces to fill up column
     mov       ecx, eax                      ;set up number of loops to write empty spaces
   WriteLoop:
     mov       al, 32
     call      WriteChar
     loop      WriteLoop

     POPAD                                   ;restore registers from stack
     RET       4     

writeSpace ENDP



END main
