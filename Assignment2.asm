TITLE Assignment #2     (Assignment2.asm)

; Author:                Chen Zou
; Last Modified:         10 July 2018
; OSU email address:     zouch@oregonstate.edu
; Course number/section: CS271-400
; Assignment Number:     #2            
; Due Date:              15 July 2018
; Description:           This program takes and validates a number within a specified range from user, 
;                         then calculates and displays the Fibonacci numbers.
                          

INCLUDE Irvine32.inc

LOWER_LIMIT = 1
UPPER_LIMIT = 46
FIBONACCI1 = 1
COLUMNS = 5

.data
programTitle   BYTE      "Fibonacci numbers", 0
programmer     BYTE      "Chen Zou", 0
programmerPmt  BYTE      "Programmed by ",0
usernamePmt    BYTE      "What is your name? ", 0
userName       BYTE      32 DUP(0)                     ;user's name to be entered
userWelcome    BYTE      "Hello, ", 0
instruction    BYTE      "Enter the number of Fibonacci terms to be displayed."
               BYTE      10
               BYTE      "Give the number as an integer in the range [1..46].", 0
EC1Msg         BYTE      "**EC1: Program will display the numbers in alighed columns.", 0
EC2Msg         BYTE      "**EC2: Program will give user choice to replay."
               BYTE      10
               BYTE      "       It will also display one calculated number at a time with different colors for different columns.", 0
number         DWORD     ?                             ;number of Fibonacci terms to be entered                   
numberPmt      BYTE      "How many Fibonacci terms do you want? ", 0
validationPmt  BYTE      "Out of range. Enter a number in [1..46].", 0
result         DWORD     ?                             ;Fibonacci numbers for different terms
resultPmt      BYTE      "Results certified by ", 0
column         DWORD     1                             ;column displayed for current number, start from 1 for Fib(1) 
colorCode      DWORD     2                             ;initialize color
exitMsg        BYTE      "Goodbye, ", 0
replayMsg      BYTE      "Enter 1 to play gain, other numbers to quit.", 0
replayChoice   DWORD     ?                             ;user choice of replay or quit
count          DWORD     0                             ;count of digits of Fibonacci numbers


.code
main PROC

;Introduce programmer 
     mov       eax, colorCode                          ;set start color
     call      SetTextColor     
     mov       edx, OFFSET programTitle
     call      WriteString
     call      CrLf
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
     call      CrLf

;greeting to user
     ;get user name
     mov       edx, OFFSET usernamePmt
     call      WriteString
     mov       edx, OFFSET userName
     mov       ecx, SIZEOF userName
     call      ReadString
     
     ;say hello
     mov       edx, OFFSET userWelcome
     call      WriteString
     mov       edx, OFFSET userName
     call      WriteString
     call      CrLf
     call      CrLf
     
;Display instruction 
     mov       edx, OFFSET instruction
     call      WriteString
     call      CrLf
     call      CrLf

Start: 
;get and validate user input for the number of Fibonacci term
     mov       edx, OFFSET numberPmt
     call      WriteString
     call      ReadInt
     mov       number, eax
     mov       ebx, UPPER_LIMIT
     cmp       ebx, eax
     jb        ValidationError
     mov       ebx, LOWER_LIMIT
     cmp       ebx, eax
     ja        ValidationError        
     jmp       Calculation     

;if input is out of range, promt user to reenter until input valid
ValidationError:
     mov       edx, OFFSET validationPmt
     call      WriteString
     call      CrLf
     call      CrLf
     jmp       Start
  
Calculation:  
;initialize accumulator and display the first Fibonacci numer
     mov       eax, FIBONACCI1               ;initialize eax as first Fibonacci = 1
     mov       ebx, 0                        ;initialize ebx to zero to represent Fib(0)
     call      writeSpace                    ;fill up column with space
     call      WriteDec                      ;display Fib(1)
     mov       column, 1                     ;set column number to 1 after displayed Fib(1)

     ;set up loop control
     mov       ecx, number                   
     sub       ecx, 1                        ;number of Fabinacci terms calculations to loop
     cmp       ecx, 0                        ;check if ecx is 0
     je        certification                 ;skip loop if ecx is zero
     
             
;calculate and print the Fibonacci numbers from 2, as F(n) = F(n-1) + F(n-2)
   Fibloop:
     ;set up delay for display of numbers
     push      eax 
     mov       eax, 200
     call      Delay                         ;delay 0.3 sec
     pop       eax                           ;restore eax after used for delay

     push      eax                           ;save F(n-1) to stack
     add       eax, ebx                      ;get F(n) as sum of F(n-1) + F(n-2), eax is not F(n)
     push      eax                           ;save F(n) to stack
     add       colorCode, 3                  ;increase color code by 3
     cmp       colorCode, 15
     jbe       ColorOk                       ;jump to output numbers if color is not out of range (15)   
     sub       colorCode, 15                 ;reset color if greater than 15
       
   ColorOK:
     mov       eax, colorCode                ;print in color
     call      SetTextColor
     pop       eax                           ;restore eax=F(n) after used for set color      
     call      writeSpace                    ;write space to align columns     
     call      WriteDec                      ;display F(n)
     pop       ebx                           ;ebx now equals to F(n-1)
     inc       column                        ;update current column index
     cmp       column, COLUMNS            
     jb        ColumnOK                      ;continue to display at same line
     call      CrLf                          ;move to new line if column reached maximum limit
     sub       column, 5                     ;reset column numbers

   ColumnOK:
     loop      Fibloop
     mov       colorCode, 2                  ;reset color
     mov       eax, colorCode                
     call      SetTextColor
     
Certification:         
;display certification
     call      CrLf
     call      CrLf
     mov       edx, OFFSET resultPmt
     call      WriteString
     mov       edx, OFFSET programmer
     call      WriteString
     mov       AL, 46
     call      WriteChar
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
     mov       edx, OFFSET userName
     call      WriteString
     mov       AL, 46
     call      WriteChar
     call      CrLf

	exit      ;exit to operating system	                                
main ENDP


;-----------------------------------------------------------------------------------------
writeSpace PROC
; Description:       Prodcedure to calculate how many empty spaces are required to fill up
;                    the column and print those empty spaces.
; Receivers:         number in eax
; Returns:           none
; Preconditions:     number of digits in eax <15
; Registers changed: none
;------------------------------------------------------------------------------------------
     PUSHAD                                  ;save general purpose registers to stack

     ;count the digits of the number
     mov       ebx, 10
     mov       count, 0                      ;reset count to zero
   Divide10:  
     mov       edx, 0                                  
     div       ebx
     inc       count
     cmp       eax, 0                        ;if still have quotient, repeat dividing by 10
     jne       Divide10
        
     ;write spaces
     mov       eax, 15                       ;set total 15 spaces for every column      
     sub       eax, count                    ;get required empty spaces to fill up column
     mov       ecx, eax                      ;set up number of loops to write empty spaces
   WriteLoop:
     mov       al, 32
     call      WriteChar
     loop      WriteLoop

     POPAD                                   ;restore registers from stack
     RET      

writeSpace ENDP

END main
