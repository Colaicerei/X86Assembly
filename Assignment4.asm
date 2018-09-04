TITLE Assignment #4     (Assignment4.asm)

; Author:                Chen Zou
; Last Modified:         29 July 2018
; OSU email address:     zouch@oregonstate.edu
; Course number/section: CS271-400
; Assignment Number:     #4            
; Due Date:              5 Aug 2018
; Description:           This program takes and validates a number between 20 and 100 from user as the count of a new array, 
;                        then generates random numbers between 100 and 999 into a file, then reads the file into the array.
;                        The program displays the unsorted array, then sorts the array using recursive quick sort algorithm, 
;                        then calculates and displays the median vallue, then the sorted list.
;                        Note: The program is implemented using floating-point numbers and the floating-point processor.
;                              The numbers are displayed by both row and column order.         
                          

INCLUDE Irvine32.inc

MIN = 10
MAX = 200
LO = 100
HI = 999
COLUMNS = 10
ROWS = 10


.data
programTitle   BYTE      "Sorting Random Integers         ", 0
programmer     BYTE      "Chen Zou", 0
programmerPmt  BYTE      "Programmed by ",0
instruction    BYTE      "This program generates random numbers in the range [100 .. 999] to a file, then fill an array of user specified", 10
               BYTE      "count with the numbers from the file. It then displays the original list, sorts the list, and calculates the ", 10
               BYTE      "median value. Finally, it displays the list sorted in descending order.", 0
ECMsg          BYTE      "**EC1: Program will display the numbers ordered by column instead of by row.", 10
               BYTE      "**EC2: Program will use a recursive sorting algorithm (quick sort).", 10
               BYTE      "**EC3: Program is implemented using floating-point numbers andd the floating-point processor. ", 10     
               BYTE      "**EC4: Program generates the numbers into a file, then read the file into the array.", 10
               BYTE      "**EC5: Program displays prime number in red and composite numbers in yellow. ", 0
fileName       BYTE      "Array.txt", 0
fileHandle     HANDLE    ?
badFile        BYTE      "Error opening file! Now filling array directly!... ", 0
arrayCount     DWORD     ?                             ;number of composites to display 
list           DWORD     200 DUP(?)
numberPmt      BYTE      "How many numbers should be generated? [10 .. 200]: ", 0
validationPmt  BYTE      "Invalid input.", 0
unsortedPmt    BYTE      "The unsorted random numbers: ", 10, 0
iMedianPmt     BYTE      "The rounded median is: ", 0
fMedianPmt     BYTE      "The median in float point is: ", 0
sortedPmt      BYTE      "The sorted list: ", 10, 0
rDisplayPmt    BYTE      "Display by row: ",10, 0
cDisplayPmt    BYTE      "Display by column: ", 10, 0
certifyPmt     BYTE      "Results certified by Chen Zou. ", 0
exitMsg        BYTE      " Goodbye.", 0               


.code
main PROC
     call      Randomize                          ;random seed

;introduction
     push      OFFSET programTitle                ;ebp+24
     push      OFFSET programmerPmt               ;ebp+20
     push      OFFSET programmer                  ;ebp+16
     push      OFFSET ECMsg                       ;ebp+12
     push      OFFSET instruction                 ;ebp+8   
     call      introduction                       ;Introduction programmer and instruction
     
;get user input     
     push      OFFSET arrayCount
     push      OFFSET numberPmt
     push      OFFSET validationPmt   
     call      getData                            ;get user input for array count

;generate numbers into file and fill array from file and display **source: textbook
     ;create file
     mov       edx, OFFSET fileName
     call      CreateOutputFile
     mov       fileHandle, eax
     cmp       eax, INVALID_HANDLE_VALUE          ;error found?
     je        noFile                             ;If the filename is bad, fill array directly
     
     ;generate numbers and write to file
     push      fileHandle
     push      arrayCount                         ;push the count of array
     call      fillFile                           ;create array from file
     mov       eax, fileHandle
     call      CloseFile
     
     ;Open file for input
     mov       edx, OFFSET fileName
     call      OpenInputFile

     cmp       eax, INVALID_HANDLE_VALUE
     je        NoFile                             ;fill array normally if invalid file
     mov       fileHandle, eax


     ;fill array from file
     push      OFFSET list                        ;push address of array to be filled
     push      arrayCount 
     push      fileHandle
     call      fileFillArray

     mov       eax, fileHandle
     call      CloseFile
     jmp       FillComplete

NoFile:
     push      OFFSET list                        ;push address of array to be filled
     push      arrayCount                         ;push the count of array
     call      NormalArray

FillComplete:

;display unsorted array

     push      OFFSET cDisplayPmt
     push      OFFSET rDisplayPmt
     push      OFFSET unsortedPmt
     push      OFFSET list                        ;push address of unsorted array
     push      arrayCount                         ;push the count of array
     call      displayList                        
     call      CrLf

;sort array with quick sort algorithm                 
     mov       eax, arrayCount                    ;count of array
     dec       eax                                ;get end index
     push      eax                                
     mov       eax, 0                             ;start index
     push      eax                                
     push      OFFSET list
     call      quickSort                          ;quick sort the list
     

;display median value     
     push      OFFSET fMedianPmt
     push      OFFSET iMedianPmt
     push      OFFSET list                        ;push address of array to be filled
     push      arrayCount                         ;push the count of array
     call      displayMedian  
     call      CrLf
     
;display sorted array
     push      OFFSET cDisplayPmt
     push      OFFSET rDisplayPmt
     push      OFFSET sortedPmt
     push      OFFSET list                        ;push address of sorted array
     push      arrayCount                         ;push the count of array
     call      displayList                        ;display sorted list

;farewell     
     push      OFFSET certifyPmt
     push      OFFSET exitMsg   
     call      farewell
     exit                                         ;exit to operating system
                    
main ENDP


;-----------------------------------------------------------------------------------------
introduction PROC
; Description:       Prodcedure to introduce the programmer and display program 
;                    instructions.
; Receivers:         multiple strings
; Returns:           none
; Preconditions:     none
; Registers changed: edx
;-----------------------------------------------------------------------------------------
;introduce programmer     
     push      ebp
     mov       ebp, esp

     mov       edx, [ebp+24]
     call      WriteString
     mov       edx, [ebp+20]
     call      WriteString
     mov       edx, [ebp+16]
     call      WriteString
     call      CrLf

;Display extra credit messages 
     mov       edx, [ebp+12]
     call      WriteString
     call      CrLf
     
;Display instruction 
     mov       edx, [ebp+8]
     call      WriteString
     call      CrLf
     call      CrLf

     pop       ebp
     RET       20                            ;clear the stack

introduction ENDP


;-----------------------------------------------------------------------------------------
getData PROC
; Description:       Prodcedure to get user input of number of composite numbers.
; Receivers:         arrayCount by reference, prompt messages
; Returns:           user input values for global variable arrayCount

; Preconditions:     none
; Registers changed: eax, ebx, edx, edi
;-----------------------------------------------------------------------------------------
     push      ebp
     mov       ebp, esp
Start:
     mov       edx, [ebp+12]
     call      WriteString
     call      ReadInt
     mov       ebx, MAX
     cmp       ebx, eax
     jb        ValidationError
     mov       ebx, MIN
     cmp       ebx, eax
     jg        ValidationError        
     jmp       ValidationOK   

;if input is out of range, promt user to reenter until input valid
ValidationError:
     mov       edx, [ebp+8]
     call      WriteString
     call      CrLf
     call      CrLf
     jmp       Start

ValidationOK:
     mov       edi, [ebp+16]
     mov       [edi], eax

     pop       ebp
     RET       12

getData ENDP


;-----------------------------------------------------------------------------------------
fillFile PROC
; Description:       Prodcedure to generate random numbers of user specified count into file.
; Receivers:         Filehandle, Arraycount
; Returns:           none
; Preconditions:     none
; Registers changed: eax, ecx, edx
;-----------------------------------------------------------------------------------------  
LOCAL    buffer:DWORD
     
     mov       ecx,[ebp+8]     

randomloop: 
;generate random numbers within 100 to 999 range
     mov       eax,HI                             ;999
     sub       eax,LO                             ;999-100 = 899
     call      RandomRange                        ;eax in [0..899]
     add       eax,LO                             ;eax in [100..999]
     mov       buffer, eax
     push      ecx                                ;Save loop counter 
     mov       eax, [ebp+12]                      ;move filehandle to eax
     lea       edx, buffer
     mov       ecx, 4                             ;size of DWORD
     call      WriteToFile
     
     pop       ecx
     loop      randomLoop
     
     RET       8

fillFile ENDP

;-----------------------------------------------------------------------------------------
fileFillArray PROC 
; Description:       Prodcedure to generate random numbers into a file then use the data
;                    from the file to fill the array of user specified size.
; Receivers:         array by reference, arraycount by value, filehandle
; Returns:           none, but parameter array filled
; Preconditions:     none
; Registers changed: eax, ecx, ebx, edx
;-----------------------------------------------------------------------------------------
     push      ebp
     mov       ebp, esp

     mov       eax, [ebp+8]                       ;move filehandle to eax 
     mov       edx, [ebp+16]                      ;array address to edx
     mov       ebx, [ebp+12]
     imul      ebx, 4
     mov       ecx, ebx                           ;size of array
     call      ReadFromFile 
     
     pop       ebp
     RET       12

fileFillArray	ENDP


;-----------------------------------------------------------------------------------------
NormalArray PROC
; Description:       Prodcedure to generate random numbers into a file then use the data
;                    from the file to fill the array of user specified size.
; Receivers:         array by reference, arraycount by value
; Returns:           none, but parameter array filled
; Preconditions:     none
; Registers changed: eax, ecx, edi
;-----------------------------------------------------------------------------------------
;set up loop control
     push      ebp
     mov       ebp,esp
     mov       ecx,[ebp+8]                   ;count in ecx
     mov       edi,[ebp+12]                  ;address of array in edi

fillAgain:
     mov	     eax, HI
	sub	     eax, LO
	inc	     eax
	call      RandomRange
	add	     eax, LO
     
     mov       [edi],eax
     add       edi,TYPE DWORD
     loop      fillAgain
     pop       ebp

     RET       8

NormalArray	ENDP
     
;-----------------------------------------------------------------------------------------
displayList PROC
; Description:       Prodcedure to display the numbers in an array.
; Receivers:         address of array, count of elements in array, prompt strings
; Returns:           none
; Preconditions:     count >=1
; Registers changed: eax, ebx, ecx, edx, esi
;-----------------------------------------------------------------------------------------  
LOCAL sizeofArray:DWORD   
LOCAL column:DWORD  
    
     mov       column, 0                     ;initialize column
     mov       edx, [ebp+16]                 ;display list status
     call      WriteString

;get size of array and size per column for display
     mov       eax, [ebp+8]
     imul      eax, 4
     mov       sizeofArray, eax 
 
;Display list by row
     mov       ecx,[ebp+8]                   ;count of array
     mov       esi,[ebp+12]                  ;address of array
     mov       ebx, 0                        ;index of elements to be displayed
     mov       edx, [ebp+20]
     call      WriteString

displayRow:
     mov       eax, [esi + ebx]
     
     ;check if prime
     PUSHAD
     call      isPrime                       
     cmp       edx, 0
     POPAD  
     je        NotPrime
     
Prime:
     push      eax
     mov       eax, 13                       ;print in pink
     call      SetTextColor
     pop       eax
     jmp       DisplayStart
     
NotPrime:      
     push      eax
     mov       eax, 14                       ;print in yellow
     call      SetTextColor
     pop       eax    

DisplayStart:
     call      writeSpace
     call      WriteDec
     add       ebx, 4
     inc       column
     cmp       column, COLUMNS
     jb        sameRow
     ;create a new line if column number exceed available display columns
     call      CrLf
     mov       column, 0                     ;reset column index
sameRow:     
     loop      displayRow
     call      CrLf

;reset display color
     push      eax
     mov       eax, 2                        ;reset to green
     call      SetTextColor
     pop       eax 

;display list by column
     mov       ecx,[ebp+8]                   ;count of array
     mov       esi,[ebp+12]                  ;address of array in edi
     mov       ebx, 0                        ;index of elements to be displayed
     mov       edx, [ebp+24]
     call      WriteString
     mov       column, 0
displayColumn:
     mov       eax, [esi + ebx]

     ;check if prime
     PUSHAD
     call      isPrime                       
     cmp       edx, 0
     POPAD  
     je        NotPrime1
     
Prime1:
     push      eax
     mov       eax, 13                       ;print in pink
     call      SetTextColor
     pop       eax
     jmp       DisplayColumnStart
     
NotPrime1:      
     push      eax
     mov       eax, 14                       ;print in yellow
     call      SetTextColor
     pop       eax    

DisplayColumnStart:
     call      writeSpace
     call      WriteDec
     inc       column
     add       ebx, 40
     cmp       ebx, sizeofArray
     jb        sameLine

     ;create a new line if column number exceed available display columns
     call      CrLf
     mov       eax, 40
     imul      eax, column
     sub       ebx, eax
     add       ebx, 4                        
     mov       column, 0                     ;reset column index
sameLine:     
     loop      displayColumn
     
;reset display color
     push      eax
     mov       eax, 2                ;reset to green
     call      SetTextColor
     pop       eax 
     
     RET       20

displayList ENDP

;-----------------------------------------------------------------------------------------
quickSort PROC       ;code modified based on NASM code on stackOverflow (Author: pushebp)
; Description:       Prodcedure to use recursive quick sort algorithm to sort a list passed
;                    as argument.
; Receivers:         array by reference, low and hign indexes of list
; Returns:           none
; Preconditions:     none
; Registers changed: eax, ebx, ecx, edx, esi, edi
;-----------------------------------------------------------------------------------------  
     push      ebp
     mov       ebp, esp

     push      edi
     push      esi
     push      ebx

     mov       eax, [ebp + 12]               ;start index i
     mov       ebx, [ebp + 16]               ;end index
     mov       esi, [ebp + 8]                ;save address of first element to esi

     ;base case for exit, if low >= high
     cmp       eax, ebx
     jnl       sortComplete

     mov       ecx, eax                       ;ecx = j, = sid
     mov       edx, [esi + (4 * ebx)]         ;pivot element, array[end], edx = pivot

partition:
     ;for j = start; j < end; j++
     cmp       ecx, ebx                        ;if ecx < end index
     jnl       SwapEnd
     ;if array[j] <= pivot
     cmp       edx, [esi + (4*ecx)]
     jg        continue
     ;swap array[i], array[j]
     push      ebx
     LEA       ebx, [esi + 4*ecx]
     push      ebx
     LEA       ebx, [esi + 4*eax]
     push      ebx
     call      swap
     pop       ebx
     inc       eax                           ;i++

continue:
     add       ecx, 1
     jmp       partition
SwapEnd:
     ;swap array[i], array[end]
     push      ecx
     LEA       ecx, [esi + 4*eax]
     push      ecx
     LEA       ecx, [esi + 4*ebx]
     push      ecx
     call      swap
     pop       ecx

     ;push      [esi + (4*eax)]               ;push array[i]
     ;push      [esi + (4*ebx)]               ;push array[end]
     ;pop       [esi + (4*eax)]               ;pop array[end] to array[i]
     ;pop       [esi + (4*ebx)]               ;pop array[i] to array[end]

     ;sort(array, start, i - 1)
     sub       eax, 1
     push      eax                           ;push i-1
     push      [ebp + 12]                    ;push start index
     push      [ebp + 8]                     ;push array
     call      quicksort
     
     ;sort(array, i + 1, end)
     add       esp, 8
     pop       eax                           
     add       eax, 1                        
     push      [ebp + 16]                    ;push end index
     push      eax                           ;push i+1
     push      [ebp + 8]                     ;push array
     call      quickSort
     add       esp, 12

sortComplete:
     pop       ebx
     pop       esi
     pop       edi

     pop       ebp
     RET               
               
 quickSort ENDP     


;-----------------------------------------------------------------------------------------
swap PROC
; Description:       Prodcedure to exchange the positions of two elements in a array.
; Receivers:         array[i] (reference), array[j] (reference) to be exchanged
; Returns:           none, but values at parameter addresses swapped
; Preconditions:     none
; Registers changed: none
;-----------------------------------------------------------------------------------------  
     push      ebp
     mov       ebp, esp

     push      esi                           ;save registers
     push      edi
     mov	     esi, [ebp+12]                 ;load address of array[i]
     mov	     edi,	[ebp+8]                  ;load address of array[j]
     push      [esi]                    
     push      [edi]
     pop       [esi]
     pop       [edi]
     
     pop       edi                           ;restore registers
     pop       esi
  	pop       ebp
	ret       8    

swap ENDP  


;-----------------------------------------------------------------------------------------
displayMedian PROC
; Description:       Prodcedure to calculate and display median value of an array.
; Receivers:         array by reference, array count by value, prompt strings
; Returns:           
; Preconditions:     none
; Registers changed: eax, ebx, edx, esi
;-----------------------------------------------------------------------------------------  
LOCAL     tempMedian:DWORD                        ;value of two median numbers to be divided by 2
LOCAL     meanDiv:DWORD
LOCAL     enlarged:DWORD
LOCAL     ten:DWORD
     
     ;initialize local variables
     mov       meanDiv, 2
     mov       tempMedian, 0
     mov       ten, 10
     
     ;get index of median element
     mov       eax, [ebp+8]
     dec       eax                                ;decrease eax for median position calculation
     mov       ebx, 2
     mov       edx, 0
     div       ebx                                ;eax now has the index of first median number
     push      edx                                ;save edx for parity test of array count     
     
     ;find first median value, consider there is only one median for odd array but two for even array
     mov       ebx, 4
     mov       edx, 0
     mul       ebx                                
     
     mov       esi, [ebp+12]
     add       esi, eax                           ;esi is now the first median address     
     mov       ebx, [esi]                         ;save the first median number to ebx

     pop       edx                                ;restore edx for parity test of array count
     mov       eax, [esi + 4*edx]                 ;esi is not the second median address
     add       eax, ebx                           ;add the second median number, for odd array this is just the first median number
     mov       tempMedian, eax                    ;save the sum of two median numbers
    

     ;calculate and diplay median in integer
     mov       edx, [ebp+20]
     call      WriteString
     
     fild      tempMedian                    ;load tempMedian into ST(0) 
     fidiv     meanDiv                       ;divide ST(0) by number 2
     fimul     ten                           ;preserve the decimal digit
     fist      enlarged                      ;save the enlarged value for further calculation
     mov       edx, 0
     mov       eax, enlarged
     cdq
     div       ten                           ;get decimal number
     call      WriteDec                      ;display integer part
     mov       al, 46         
     call      WriteChar                     ;display dot
     mov       eax, edx
     call      WriteDec                      ;display decimal
     call      CrLf 
          
     ;calculate and dipaly median in float
     mov       edx, [ebp+16]
     call      WriteString
     fild      tempMedian 
     fild      meanDiv
     fdiv     
     call      WriteFloat 
     call      CrLf

     RET       16     

displayMedian ENDP  


;-----------------------------------------------------------------------------------------
farewell PROC
; Description:       Prodcedure to display certification and exit message.
; Receivers:         string messages
; Returns:           none
; Preconditions:     none
; Registers changed: edx, aL
;-----------------------------------------------------------------------------------------  
     push      ebp
     mov       ebp, esp

;display certification
     call      CrLf
     call      CrLf
     mov       edx, [ebp+12]
     call      WriteString
     mov       AL, 46
     call      WriteChar

;display goodbye
     mov       edx, [ebp+8]
     call      WriteString
     call      CrLf
     
     pop       ebp
     RET       8
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
LOCAL     digitCount:DWORD                   ;count of digits of number to display

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
isPrime PROC
; Description:       Prodcedure to check if a divisor from composite test is prime.
; Receivers:         eax as number to be tested
; Returns:           edx if it is not zero
; Preconditions:     none
; Registers changed: ebx, esi, edx
;-----------------------------------------------------------------------------------------  
LOCAL     PrimeTest:DWORD

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

END main
