TITLE Assignment #3     (Assignment3.asm)

; Author:                Chen Zou
; Last Modified:         19 July 2018
; OSU email address:     zouch@oregonstate.edu
; Course number/section: CS271-400
; Assignment Number:     #3            
; Due Date:              29 July 2018
; Description:           This program takes and validates a number within a specified range from user, 
;                        then calculates and displays the specified number of composite numbers.
                          

INCLUDE Irvine32.inc

LOWER_LIMIT = 1
UPPER_LIMIT = 400
COLUMNS = 10
ROWS = 20

.data
programTitle   BYTE      "Composite numbers       ", 0
programmer     BYTE      "Chen Zou", 0
programmerPmt  BYTE      "Programmed by ",0
instruction    BYTE      "Enter the number of composite numbers you would like to see. ", 10
               BYTE      "I will accept orders for up to 400 composites.", 0
EC1Msg         BYTE      "**EC1: Program will display the output in aligned columns.", 0
EC2Msg         BYTE      "**EC2: Program will display more composites, but show them on page at a time. ", 0
EC3Msg         BYTE      "**EC3: Program finds prime numbers and checks against only prime divisors. ", 0     
primeTest      DWORD     ?                             ;temp number for isPrime test
number         DWORD     ?                             ;number of composites to display                   
numberPmt      BYTE      "Enter the number of composites to display [1 .. 400]: ", 0
validationPmt  BYTE      "Out of range. Try again.", 0
value          DWORD     ?                             ;value of composite found during one step
pagePmt   	BYTE      "Press any key to continue...", 10, 10, 0
pageIndexMsg   BYTE      "This is the end of Page ", 0
pageIndex      DWORD     0
certifyPmt     BYTE      "Results certified by ", 0
column         DWORD     0                             ;column index for current number
row            DWORD     0                             ;row index for current number
exitMsg        BYTE      " Goodbye.", 0
digitCount     DWORD     0                             ;count of digits of composite numbers
moreMsg        BYTE      "How many more composites would you like to see? enter 0 or nondigit to quit: ", 0
moreNumber     DWORD     0                             ;additional number of composites to be printed for EC2
moreValidation BYTE      "Please enter an number greater or equal to 1: ", 0
lastComposite  DWORD     0                             ;start point for additional composite test for EC2


.code
main PROC

     
     call      introduction                       ;Introduction programmer and instruction
     call      getData                            ;get value for number of composites
     call      showComposites                     ;find and display composite numbers
     call      showMore                           ;display more composite numbers
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
     mov       edx, OFFSET programTitle
     call      WriteString
     mov       edx, OFFSET programmerPmt
     call      WriteString
     mov       edx, OFFSET programmer
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

     RET      

introduction ENDP


;-----------------------------------------------------------------------------------------
getData PROC
; Description:       Prodcedure to get user input of number of composite numbers.
; Receivers:         none
; Returns:           user input values for global variable number
; Preconditions:     none
; Registers changed: eax, edx
;-----------------------------------------------------------------------------------------
;get and validate user input for the number of Fibonacci term
     mov       edx, OFFSET numberPmt
     call      WriteString
     call      ReadInt
     mov       ebx, UPPER_LIMIT
     call      validate
     mov       number, eax
     RET

getData ENDP     
 
 
;-----------------------------------------------------------------------------------------
validate PROC
; Description:       Prodcedure to valiate user input 
;                    instructions.
; Receivers:         eax as user input, ebx as upper limit
; Returns:           eax if valid, error message if invalid
; Preconditions:     none
; Registers changed: ebx
;-----------------------------------------------------------------------------------------  
     cmp       ebx, eax
     jb        ValidationError
     mov       ebx, LOWER_LIMIT
     cmp       ebx, eax
     jg        ValidationError        
     jmp       ValidationOK   

;if input is out of range, promt user to reenter until input valid
ValidationError:
     mov       edx, OFFSET validationPmt
     call      WriteString
     call      CrLf
     call      CrLf
     call      getData

ValidationOK:  
     RET

validate ENDP


;-----------------------------------------------------------------------------------------
showComposites PROC
; Description:       Prodcedure to display the composite numbers of user specified number.
; Receivers:         ecx as user specified number
; Returns:           none
; Preconditions:     none
; Registers changed: eax, ecx, edx
;-----------------------------------------------------------------------------------------  
;set up loop control
     mov       ecx, number                   
                      
;check and print if the number is composite
     mov       eax, 4                        ;first composite number is 4
CompositeLoop:
     ;check if number is composite
     call      isComposite                   ;check if it is composite
     cmp       edx, 0
     jne       NotComposite                  ;skip printing if edx(quotient) is not zero
     
;print the number if edx(quotient) is zero
     call      writeSpace                    ;write space to align columns     
     call      WriteDec                      ;display value of composite number
     mov       lastComposite, eax            ;save last composite number

;check if new line is required for display     
     inc       column                        ;update current column index
     cmp       column, COLUMNS            
     jb        ContinueCheck                 ;continue to display at same line
     call      CrLf                          ;move to new line if column reached maximum limit
     sub       column, COLUMNS               ;reset column numbers
     inc       row                           ;increase row number
     
;check if new page is required 
     cmp       row, ROWS            
     jb        ContinueCheck                 ;continue to display at same line
     call      newPage                       ;get new page if rows exceed limit

     jmp       ContinueCheck

  NotComposite:
     inc       ecx                           ;offset the change to ecx to make it only counts for Composite numbers       
      
  ContinueCheck:   
     inc       eax
     loop      CompositeLoop
     
     RET
showComposites ENDP



;-----------------------------------------------------------------------------------------
showMore PROC
; Description:       Prodcedure to display more composite numbers of user specified number.
; Receivers:         ecx as user specified number
; Returns:           none
; Preconditions:     none
; Registers changed: eax, ecx, edx
;-----------------------------------------------------------------------------------------  
GetMore:
;get user input for how many more composites
     call      CrLf
     mov       edx, OFFSET moreMsg
     call      WriteString
     call      readInt

;validate user input, zero to quit
     cmp       eax, 0
     je        noMoreCheck
     mov       ebx, LOWER_LIMIT
     cmp       ebx, eax
     jg        MoreError        
     jmp       MoreOK   

;if input is less than 1, promt user to reenter until input valid
MoreError:
     mov       edx, OFFSET moreValidation
     call      WriteString
     call      CrLf
     call      CrLf
     jmp       GetMore

MoreOK:
;set up loop control
     mov       ecx, eax
                      
;check and print if the number is composite
     mov       eax, lastComposite            ;restore previous composite number
     inc       eax                           ;set start number for more composite check
CompositeLoop:
     ;check if number is composite
     call      isComposite                   ;check if it is composite
     cmp       edx, 0
     jne       NotComposite                  ;skip printing if edx(quotient) is not zero
     
;print the number if edx(quotient) is zero
     call      writeSpace                    ;write space to align columns     
     call      WriteDec                      ;display value of composite number

;check if new line is required for display     
     inc       column                        ;update current column index
     cmp       column, COLUMNS            
     jb        ContinueCheck                 ;continue to display at same line
     call      CrLf                          ;move to new line if column reached maximum limit
     sub       column, COLUMNS               ;reset column numbers
     inc       row                           ;increase row number
     
;check if new page is required 
     cmp       row, ROWS            
     jb        ContinueCheck                 ;continue to display at same line
     call      newPage                       ;get new page if rows exceed limit

     jmp       ContinueCheck

  NotComposite:
     inc       ecx                           ;offset the change to ecx to make it only counts for Composite numbers       
      
  ContinueCheck:   
     inc       eax
     loop      CompositeLoop

  noMoreCheck:     
     RET

showMore ENDP

;-----------------------------------------------------------------------------------------
isComposite PROC
; Description:       Prodcedure to check if a number is composite against known prime number.
; Receivers:         eax as number to be tested
; Returns:           edx if it is zero
; Preconditions:     none
; Registers changed: ebx, edx
;-----------------------------------------------------------------------------------------  
     mov       value, eax
     mov       ebx, 2                        ;prime number start from 2
            
   CheckAgainstPrime: 
;check if ebx is <= sqrt(test number) since we donot need bigger divisor
     push      edx                           ;save edx before multiply
     mov       eax, ebx
     mul       ebx                           ;eax^2 vs checked number, as we only need check the sqrt(number) of prime
     pop       edx                           ;restore edx
     cmp       eax, value                    ;check if ebx is within the required divisor range for the value to be checked
     ja        checkComplete                 ;if all available prime divisors are tested, jump to return

;if ebx is in range, check if it is prime
     mov       eax, ebx   
     PUSHAD
     call      isPrime                       
     cmp       edx, 0
     POPAD   
     je        NotPrime                      ;skip division test if it is not prime, i.e. edx has 0 remainder
;division if it is prime
     mov       eax, value                    ;restore eax to the checked value before each division
     mov       edx, 0
     cdq
     div       ebx
     cmp       edx, 0
     je        checkComplete                 ;jump out of loop if found composite

   NotPrime:       
     inc       ebx                           ;increase ebx to check next number
     jmp       checkAgainstPrime             ;continue to check if not found

   CheckComplete:
     mov       eax, value                    ;restore eax before return
     RET

isComposite ENDP     


;-----------------------------------------------------------------------------------------
isPrime PROC
; Description:       Prodcedure to check if a divisor from composite test is prime.
; Receivers:         eax as number to be tested
; Returns:           edx if it is not zero
; Preconditions:     none
; Registers changed: ebx, esi, edx
;-----------------------------------------------------------------------------------------  
     mov       primeTest, eax
     mov       ebx, 2
     mov       edx, 1                        ;initialize edx to 1
     
     CheckPrime: 
     push      edx
     mov       eax, ebx
     mul       ebx                           ;ebx^2 vs checked number, as we only need check the sqrt(number) of test value
     pop       edx
     cmp       eax, primeTest                ;check if it is within the required divisor range for the value to be checked
     ja        checkComplete                 ;if all available divisors are tested, jump to return
     
     mov       eax, primeTest                ;restore eax to the checked value before each division
     mov       edx, 0
     cdq
     div       ebx
     cmp       edx, 0
     je        checkComplete                 ;jump out of loop if found composite (i.e. not prime)
     inc       ebx                           ;check against next divisor
     jmp       checkPrime                    ;continue to check

   checkComplete:
     mov       eax, primeTest                ;restore eax before return
     RET

isPrime ENDP 


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
     call      CrLf
     mov       edx, OFFSET certifyPmt
     call      WriteString
     mov       edx, OFFSET programmer
     call      WriteString
     mov       AL, 46
     call      WriteChar

;display goodbye
     mov       edx, OFFSET exitMsg
     call      WriteString
     call      CrLf
                  
     RET
farewell ENDP


;-----------------------------------------------------------------------------------------
writeSpace PROC
; Description:       Prodcedure to calculate how many empty spaces are required to fill up
;                    the column and print those empty spaces.
; Receivers:         number in eax
; Returns:           none
; Preconditions:     number of digits in eax <8
; Registers changed: none
;------------------------------------------------------------------------------------------
     PUSHAD                                  ;save general purpose registers to stack

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
     mov       eax, 8                        ;set total 8 spaces for every column      
     sub       eax, digitCount               ;get required empty spaces to fill up column
     mov       ecx, eax                      ;set up number of loops to write empty spaces
   WriteLoop:
     mov       al, 32
     call      WriteChar
     loop      WriteLoop

     POPAD                                   ;restore registers from stack
     RET      

writeSpace ENDP


;-----------------------------------------------------------------------------------------
newPage PROC
; Description:       Prodcedure to wait for user key enter and create new page.
; Receivers:         none
; Returns:           none
; Preconditions:     row number exceed 10
; Registers changed: none
;------------------------------------------------------------------------------------------
     PUSHAD                                  ;save general purpose registers to stack
     
     mov       edx, OFFSET pageIndexMsg      ;display page information
     call      WriteString
     inc       pageIndex
     mov       eax, pageIndex
     call      WriteDec
     call      CrLf
     call      CrLf

     mov       edx, OFFSET pagePmt           ;display new page prompt
     call      WriteString
     sub       row, ROWS                       ;reset row numbers

LookForKey:                                  ;copied from irvine library help     
     mov  eax,50          ; sleep, to allow OS to time slice
     call Delay           ; (otherwise, some key presses are lost)
     call ReadKey         ; look for keyboard input
     jz   LookForKey      ; no key pressed yet
           
     POPAD
     RET

newPage ENDP

END main
