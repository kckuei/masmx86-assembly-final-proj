TITLE Project 6 - String Primitives and Macros     (proj6_kueik.asm)

; Author: 				Kevin Kuei
; Last Modified:			November 29, 2022
; Description:				Final Class Portfolio Project
; 
; A program that reads in 10 numbers, validates and converts them from their ASCII representation,
; performs calculations with them, then displays the numbers and results by converting them from 
; their numeric representations back to ASCII. 
; 
; This program implements two variants: 
;	1) one implementation that reads, prints, and manipulates signed integers using the ReadVal, 
;	   WriteVal procedures, and
;	2) another implementation for floating point numbers using the ReadFloatVal, WriteFloatVal 
;	   procedures.
; 
; The signed integer implementation stores the input numbers in memory as SDWORDs. ReadlVal checks 
; the user string for invalid characters and garuntees the input to fit inside a SDWORD range 
; (-2147483648 to +2147483647) by checking for numerical over/underflow, otherwise the user is re-
; prompted for new input. 
; 
; The floating point implementation stores the numbers in memory as 80-bit extended precision float 
; values (REAL10). ReadFloatVal also checks the user string for invalid characters, but does not check 
; for under/overflow.
; 
; The program implements two companion helper macros, mGetString and mDisplayString. The macros work in
; concert with the ReadVal, WriteVal, ReadFloatVal, WriteFloatVal procedures for prompting the user, 
; and returning ASCII strings, or displaying ASCII strings. 
;
; Assumptions:
;	Assumes that the total sum of the valid numbers will fit inside a 32 bit register.
;   Assumes that the SUM of floating point inputs will fit inside an extended precision float REAL10.
;
; EXAMPLE PROGRAM OUTPUT:
;
;		PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures
;		Written by: Kevin Kuei
;		
;		EC: Implements the floating point variation of the project.
;		
;		Please provide 10 signed decimal integers.
;		Each number needs to be small enough to fit inside a 32 bit register. After you have
;		finished inputting the raw numbers I will display a list of the integers, their sum,
;		and their average value.
;		
;		Afterwards, enter 10 floating point numbers, and I will display a list of the floating
;		point values, their sum, and their average value in scientific notation.
;		
;		Please enter an signed number: =67-
;		ERROR: You did not enter a signed number or your number was too big.
;		Please try again: 37373kjdfdf
;		ERROR: You did not enter a signed number or your number was too big.
;		Please try again: 234567898765432345678
;		ERROR: You did not enter a signed number or your number was too big.
;		Please try again: -+23232
;		ERROR: You did not enter a signed number or your number was too big.
;		Please try again: -2147483649
;		ERROR: You did not enter a signed number or your number was too big.
;		Please try again: +2147483649
;		ERROR: You did not enter a signed number or your number was too big.
;		Please try again: 156
;		Please enter an signed number: 34
;		Please enter an signed number: -186
;		Please enter an signed number: -145
;		Please enter an signed number: 16
;		Please enter an signed number: +23
;		Please enter an signed number: 000051
;		Please enter an signed number: 0
;		Please enter an signed number: 56
;		Please enter an signed number: 11
;		
;		You entered the following numbers:
;		156, 34, -186, -145, 16, 23, 51, 0, 56, 11
;		The sum of these numbers is: 16
;		The truncated average is: 1
;		
;		Please enter an signed floating point number: -123.23456
;		Please enter an signed floating point number: 99.99999
;		Please enter an signed floating point number: 44.98
;		Please enter an signed floating point number: 1.1
;		Please enter an signed floating point number: 2.2
;		Please enter an signed floating point number: 3.3
;		Please enter an signed floating point number: 9.9@
;		ERROR: You did not enter a signed number or your number was too big.
;		Please try again: 9.9
;		Please enter an signed floating point number: 10.10
;		Please enter an signed floating point number: 48.66
;		Please enter an signed floating point number: 77.7
;		
;		You entered the following numbers:
;		-1.2323456e2, +9.9999990e1, +4.4980000e1, +1.1000000e0, +2.2000000e0, +3.3000000e0, +9.9000000e0, +1.0100000e1, +4.8660000e1, +7.7700000e1
;		The sum of these numbers is: +1.7470543e2
;		The floating point average is: +1.7470543e1
;		
;		Thanks for playing!


INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; MACRO that prompts the user for input, and then saves it to a string address.
; A global constant MAXSIZE is used to specify the maximum buffer size / bytes that
; will be read. The input is validated elsewhere in ReadVal.
;
; Preconditions: none.
;
; Postconditions: none.
;
; Receives:
;	m_promptAddr - prompt string that gets displayed to user (pass by reference).
;	m_userStringAddr - output string (pass by reference).
;	m_bytesReadAddr - number of bytes read (pass by reference). 
;	MAXSIZE - global constant for max buffer/bytes to read.
;
; returns:
;   m_userStringAddr - gets populated with user input.
;   m_bytesReadAddr - gets populated with number of bytes read.
; ---------------------------------------------------------------------------------
mGetString MACRO  m_promptAddr:REQ, m_userStringAddr:REQ, m_bytesReadAddr:REQ
  PUSHAD

  ; Prompts user for input.
  MOV	EDX, m_promptAddr
  CALL	WriteString

  ; Reads user input.
  MOV	ECX, MAXSIZE 		; Buffer size, bytes read will be <= buffer size.
  MOV	EDX, m_userStringAddr	; Destination address.
  CALL	ReadString

  ; Copies EAX to mem address referenced by EDI.
  MOV	EDI, m_bytesReadAddr
  CLD
  STOSD

  POPAD
ENDM


; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; MACRO that takes a string (pass by address) representing ascii values, and then displays it.
;
; Preconditions: none.
;
; Postconditions: none.
;
; Receives:
;	m_outStringAddr - address offset of the byte array to display (pass by reference).
;	m_charCount - number of characters/bytes to print (pass by value).
;
; returns: none.
; ---------------------------------------------------------------------------------
mDisplayString MACRO  m_outStringAddr, m_charCount
  PUSHAD

  ; Prints the string byte array.
  MOV	ECX, m_charCount
_loopAsciiPrint:
  MOV	AL, [m_outStringAddr]
  CALL	WriteChar
  INC	m_outStringAddr
  LOOP	_loopAsciiPrint	

  POPAD
ENDM


; Declare global constants.
MAXSIZE		=	100		; Max buffer size for user input.
MAXARRSIZE	=	10		; Max signed integer array size.


; Declare data segment variables (only referenced directly in main PROC).
.data
introTxt	BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures",13,10
		BYTE	"Written by: Kevin Kuei",13,10,13,10
		BYTE	"EC: Implements the floating point variation of the project.",13,10,13,10
		BYTE	"Please provide 10 signed decimal integers.",13,10  
		BYTE	"Each number needs to be small enough to fit inside a 32 bit register. After you have",13,10
		BYTE	"finished inputting the raw numbers I will display a list of the integers, their sum,",13,10
		BYTE	"and their average value.",13,10,13,10
		BYTE	"Afterwards, enter 10 floating point numbers, and I will display a list of the floating",13,10
		BYTE	"point values, their sum, and their average value in scientific notation.",13,10,13,10,0
promptTxt	BYTE	"Please enter an signed number: ",0
promptTxtF	BYTE	"Please enter an signed floating point number: ",0
errorTxt	BYTE	"ERROR: You did not enter a signed number or your number was too big.",13,10
        	BYTE	"Please try again: ",0 
inputedTxt	BYTE	13,10,"You entered the following numbers:",13,10,0
sumTxt		BYTE	13,10,"The sum of these numbers is: ",0
truncAvgTxt	BYTE	13,10,"The truncated average is: ",0
avgTxt		BYTE	13,10,"The floating point average is: ",0
goodbyeTxt	BYTE	13,10,13,10,"Thanks for playing!",13,10,0
userVal		SDWORD	?			
userIntArr	SDWORD	MAXSIZE DUP(?)
userSum		SDWORD	?			
userAvg		SDWORD	?			

; Floating point variables.
userFloatArr	REAL10	MAXARRSIZE DUP(0.0)
userFloatVal	REAL10	0.0
userFloatSum	REAL10	0.0
userFloatAvg	REAL10	0.0
oneHalf		REAL8	0.5
ten		REAL8	10.0
pwrOf10		DWORD	1, 10, 1000, 10000, 100000, 10000000, 100000000, 1000000000



.code
main PROC
  ; ==================================================
  ; SIGNED INTEGER IMPLEMENTATION
  ; ==================================================

  ; -------------------------------------------------
  ; Prints greeting, author, program description.
  ; -------------------------------------------------
  MOV	EDX, OFFSET introTxt
  CALL	WriteString

  ; -------------------------------------------------
  ; Reads 10 signed integer values into memory.
  ; -------------------------------------------------
  ;  Initializes loop counter, and indirect register.
  MOV	ECX, MAXARRSIZE
  MOV	EDI, OFFSET userIntArr
_loopInts:
  ;  Reads the user input by pushing input args to stack and calling ReadVal.
  PUSH	OFFSET promptTxt			
  PUSH	OFFSET errorTxt
  PUSH	OFFSET userVal
  CALL	ReadVal					; Read value in userVal.
  ;  Copies userVal from mem to EBX.
  MOV	EBX, userVal				
  MOV	[EDI], EBX					
  ADD	EDI, 4					; Increment to next SDWORD value in array.
  LOOP  _loopInts

  ; -------------------------------------------------
  ; Displays the 10 user-selected signed integers.
  ; -------------------------------------------------
  ;  Prints preamble input text.
  MOV	EDX, OFFSET inputedTxt
  CALL	WriteString
  ;  Initializes loop counter, and sets source array.
  MOV	ECX, MAXARRSIZE
  MOV	ESI, OFFSET userIntArr
  ;  Begin main print loop.
_loopPrint:
  ;  Writes the current SDWORD.
  MOV	EAX, [ESI]
  PUSH	EAX
  CALL	WriteVal
_printComma:
  ;  Prints a comma and space if not the last character
  CMP	ECX, 1
  JE	_skipComma2
  MOV	AL, 44
  CALL	WriteChar
  MOV	AL, 32
  CALL	WriteChar
_skipComma2:
  ADD	ESI, 4					; Increment to next SDWORD value in array.
  LOOP _loopPrint

  ; -------------------------------------------------
  ; Computes and displays the sum.
  ; -------------------------------------------------
  ;  Print preamble sum text.
  MOV	EDX, OFFSET sumTxt
  CALL	WriteString
  ;  Initializes loop counter, source, accumulator.
  MOV	ECX, MAXARRSIZE
  MOV	ESI, OFFSET userIntArr
  MOV	EAX, 0		
  ;  Begin main loop for summing values.
_loopSum:
  ADD	EAX, [ESI]
  ADD	ESI, 4					; Increment to next SDWORD value in array.
  LOOP _loopSum
  MOV	userSum, EAX
  ;  Prints the sum.
  PUSH	userSum
  CALL	WriteVal

  ; -------------------------------------------------
  ; Computes and displays the truncated average.
  ; -------------------------------------------------
  ;  Prints the preamble avg. text.
  MOV	EDX, OFFSET truncAvgTxt
  CALL	WriteString
  ;  Computes the truncated average by integer divison.
  MOV	EAX, userSum				; The quotient in EAX.
  MOV	EBX, MAXARRSIZE				; The divisor in EBX.
  CDQ						; For 32-bit divison, EAX must be sign-extended into EDX.
  IDIV	EBX					; Signed integer division. Quotient in EAX.
  MOV	userAvg, EAX
  ;  Prints the truncated average.
  PUSH	userAvg
  CALL	WriteVal

  CALL	Crlf
  CALL	Crlf


  ; ==================================================
  ; FLOATING POINT IMPLEMENTATION
  ; ==================================================

  ; -------------------------------------------------
  ; Reads 10 float values into memory.
  ; -------------------------------------------------
  ;  Initialize loop and input parameters.
  MOV	ECX, MAXARRSIZE		
  MOV	EBX, TYPE userFloatArr
  MOV	EDI, OFFSET userFloatArr
_L1:
  ;  Reads the user input and stores it at the current array address.
  FINIT
  PUSH	OFFSET promptTxtF			
  PUSH	OFFSET errorTxt
  CALL  ReadFloatVal			; User input in ST(0).
  FSTP	userFloatVal			; ST(0) to userFloatVal.

  FLD	userFloatVal
  FSTP	REAL10 PTR [EDI]
  ADD	EDI, EBX			
  LOOP _L1

  ; -------------------------------------------------
  ; Displays the 10 user-selected float values.
  ; -------------------------------------------------
  ;  Prints preamble input text.
  MOV	EDX, OFFSET inputedTxt
  CALL	WriteString
  ;  Initializes counter, array address, size of type.
  MOV	ECX, MAXARRSIZE		
  MOV	EBX, TYPE userFloatArr
  MOV	EDI, OFFSET userFloatArr
_L2:
  ;  Prints the floats.
  FINIT
  FLD	REAL10 PTR [EDI]
  CALL	WriteFloatVal
  
  ;  Prints a comma and space if not the last character
  CMP	ECX, 1
  JE	_skipComma
  MOV	AL, 44
  CALL	WriteChar
  MOV	AL, 32
  CALL	WriteChar
  _skipComma:
  ADD	EDI, EBX
  LOOP _L2

  ; -------------------------------------------------
  ; Computes and displays the sum .
  ; -------------------------------------------------
  ;  Prints preamble input text.
  MOV	EDX, OFFSET sumTxt
  CALL	WriteString
  ;  Initializes counter, array address, size of type.
  MOV	ECX, MAXARRSIZE		
  MOV	EBX, TYPE userFloatArr
  MOV	EDI, OFFSET userFloatArr
  ;  Initializes the FPU stack with the first array value, 
  ;  and updates counters and address.
  FINIT
  FLD	REAL10 PTR [EDI]
  DEC	ECX
  ADD	EDI, EBX
_LSUM:
  ;  Sums the results.
  FLD	REAL10 PTR [EDI]
  FADD
  ADD	EDI, EBX
  LOOP _LSUM
  FSTP	userFloatSum
  ;  Prints the sum.
  FLD	userFloatSum
  CALL	WriteFloatVal

  ; -------------------------------------------------
  ; Computes and displays the average.
  ; -------------------------------------------------
  ;  Prints preamble input text.
  MOV	EDX, OFFSET AvgTxt
  CALL	WriteString
  ;  Computes the average.
  FINIT
  FLD	userFloatSum		; ST(0) = float sum
  MOV	EAX, MAXARRSIZE
  MOV	userVal, EAX		; Array size in EAX.
  FILD	userVal			; ST(1) = array size, ST(1) = float sum
  FDIV				; ST(0) = ST(1)/ST(0) = sum/array size
  FSTP	userFloatAvg
  ;  Prints the average.
  FLD	userFloatAvg
  CALL	WriteFloatVal

  ; -------------------------------------------------
  ; Prints farewell.
  ; -------------------------------------------------
  MOV	EDX, OFFSET goodbyeTxt
  CALL	WriteString


  ; Exits to operating system.
  Invoke ExitProcess,0	
main ENDP


; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; PROCEDURE that prompts the user for an input, converts it from its ascii representation
; and then returns it. Invokes the mGetString macro to prompt and get the user input in the 
; form of a string of digits. Input validation is performed, and the user is repeatedly 
; prompted until a valid input is obtained. The following validations are performed:
;
;   - must be valid digit (no letters, symbols, special characters, etc.)
;   - input cannot exceed 25 characters. 
;	- must fall within range of SDWORD, i.e. -2147483648 to +2147483647.
;   - signs '+' or '-' are only allowed for the first character. 
;   - a single '+' or '-' character is interpreted as zero.
;	- VALID examples:
;	  0, 109, -2147483648,  +2147483647, 2147483647, -000002147483648,  +02147483647
;	- INVALID examples:
;	  -2147483649 (underflow)
;	  +2147483649 (overflow)
;	  2728fdf2dde (invalida characters)
;	  !420@!1337  (invalida characters)
;		      (null)
;	  123456789012345678901234567890 (more than 25 characters)
; 
; ReadVal then converts the validated string of ascii digits to its numeric representation 
; (SDWORD), and then stores it a memory variable that is passed by reference.
; 
; Preconditions: none.
;
; Postconditions: none.
;
; Receives:
;   [EBP+8] - address offset for SDWORD to store returned signed integer.
;   [EBP+12] - address offset for error prompt that gets displayed to user.
;   [EBP+16] - address offset for standard prompt that gets displayed to user.
;   MAXSIZE - global constant of max size of the byte array for storing user input.
;
; returns:
;   [EBP+8] - populates the address pointed to by mem with the return SDWORD.
; ---------------------------------------------------------------------------------
ReadVal PROC
  ; Declares local variables.
  LOCAL	l_bytesRead:DWORD			; local DWORD bytesRead, used in MACRO call.
  LOCAL	l_userString[MAXSIZE]:BYTE		; local BYTE array userString, used in MACRO call.
  LOCAL l_numInt:SDWORD				; local SDWORD numInt, used for ascii calc.
  LOCAL l_numChar:SDWORD			; local SDWORD numChar, used for ascii calc.
  LOCAL l_sign:SDWORD				; local SDWORD sign, used for ascii calc.
  LOCAL	l_signFlag:DWORD			; local DWORD signFlag, used for ascii calc.
  LOCAL	l_a:SDWORD, l_b:SDWORD			; local SDWORDs, used for ascii calc.
  
  ; Preserves flags and registers.
  PUSHAD
  PUSHFD

  ; Displays initial prompt.
  LEA	EAX, l_userString
  LEA	EBX, l_bytesRead
  mGetString [EBP+16], EAX, EBX			; Returns user input in l_userString
						; Returns bytes read in l_bytesRead
  
  ; Validates the string and converts from ascii to SDWORD.
  ;
  ;  Checks if byte length/character count is zero, and reprompts if it is.
_checkZeroBytes:
  MOV	EAX, l_bytesRead
  CMP	EAX, 0
  JE	_reprompt				; Jumps if zero characters.

  ;  Checks max bytes read. Since feasible range for SDWORD is -2,147,483,648 to +2,147,483,647, 
  ;  a minimum of 11 characters should be allowed. Limit to 25 character input.
_checkMaxBytesRead:
  CMP	l_bytesRead, 25
  JG	_reprompt				; Jumps if more than 25 characters entered.
  JMP	_asciiToSDWORD

  ;  Re-prompts the user with error message.
_reprompt:
  LEA	EAX, l_userString
  LEA	EBX, l_bytesRead
  mGetString [EBP+12], EAX, EBX
  JMP	_checkZeroBytes

  ;  Attempts to convert user string from ascii value to signed integer SDWORD. The sign and
  ;  magnitude of the user string are stored seperately until validation is finished.
_asciiToSDWORD:

  ;  Initialize loop parameters.
  MOV	l_numInt, 0			; Initialize local numInt = 0.
  MOV	l_sign, 1			; Initialize local sign = 1 for positive (-1 for negative).
  MOV	l_signFlag, 0			; Initialize local signFlag = 0 for positive (1 for negative).
  MOV	ECX, l_bytesRead		; Loop counter set to local bytesRead.
  LEA	EAX, l_userString		; Put local effective address of userString in ESI.
  MOV	ESI, EAX			;
  CLD					; Clear direction flag (increments ESI).

 ;  Begin main loop over the string characters. 
_loopString:
	  LODSB				; Loads a byte from ESI into AL, and decrements ESI.

	; Performs a check for sign entries (+/-) on the first character. If a sign value, sets
	; the local mem sign flag l_signFlag, and skips to end of loop at _endDigitsCheck.  All 
	; subsequent characters bypass to _digitsCheck.
	_checkFirstChar:
	  ; Checks if first character.
	  CMP	ECX, l_bytesRead
	  JNE	_digitsCheck		; Jumps if not the first character.
	  
	  ; Otherwise, consider a sign check when its the first character. 
	_positiveSign:
	  ; Check if ascii value 43 (corresponds to +).
	  CMP	AL, 43
	  JNE	_negativeSign		; Jumps if not +.
	  JMP	_endDigitsCheck
	
	_negativeSign:
	  ; Otherwise, check if ascii value 45 (corresponds to -).
	  CMP	AL, 45
	  JNE	_digitsCheck		; Jumps if not -.
	  MOV	l_sign, -1		; Sets the sign to -1 (negative).
	  MOV	l_signFlag, 1		; Sets the sign flag to 1 (negative).
	  JMP	_endDigitsCheck
	
	; Performs checks on whether ascii values are valid digits 0-9.
	_digitsCheck:
	  ; Checks if below ascii value 48.
	  CMP	AL, 48			; digit 0
	  JL	_rePrompt
	
	  ; Checks if above ascii value 57.
	  CMP	AL, 57			; digit 9
	  JG	_rePrompt
	
	  ; Otherwise, its a valid digit. Then convert from ascii value to integer
	  ; by the following iterative algorithm:  
	  ;		NumInt = a           + b
	  ;		       = 10 * NumInt + sign(NumInt)*(NumChar - 48)
	  ; The routine also checks for numerical overflow/underflow during multiplication
	  ; and addition, i.e. values must be in range -2147483648 to +2147483647.

	  ;  Fetch the current character ascii value into local numChar.
	  MOVZX	EDX, AL				; Zero-extend NumChar from AL to into EDX.
	  MOV	l_numChar, EDX			; Copy to local numChar.

	  ;  Compute a term,  10 * NumInt.
	  MOV	EAX, 10
	  IMUL	l_numInt			; Signed mult. as NumInt can be negative.
	  JO	_reprompt			; Jumps if numerical over/underflow.
	  MOV	l_a, EAX

	  ;  Compute b term, sign(NumInt)*(NumChar - 48).
	  MOV	EAX, l_numChar
	  SUB	EAX, 48
	  MUL	l_sign
	  MOV	l_b, EAX
	
	  ;  Sums the a and b terms, and update numInt.
	  MOV	EAX, l_a
	  ADD	EAX, l_b
	  JO	_reprompt			; Jumps if numerical over/underflow.
	  MOV	l_numInt, EAX			; Update numInt for next iter.

	_endDigitsCheck:
	  LOOP	_loopString			; Decrements ECX and jumps until ECX = 0.
	
_endLoop:

  ; Save validated value to destination address.
  MOV   EDI, [EBP+8]			; Destination address in EDI.
  MOV   EAX, l_numInt			; Signed integer in EAX.
  STOSD					; Copies from EAX to mem address pointed by EDI.

  ;MOV	EDI, [EBP+8]
  ;MOV	EAX, l_numInt
  ;MOV	[EDI], EAX

  ; Restore flags and registers.
  POPFD
  POPAD

  RET  12			; 12 bytes for 3 parameters * 4 bytes each.
ReadVal ENDP


; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; PROCEDURE that takes a SDWORD (passed by values), converts it to it's ascii representation
; and then displays it.
; 
; WriteVal converts the SDWORD to a string of ascii digits. The algorithm works by first 
; parsing the passed SDWORD as a byte array (ascii values), and storing it in l_outStringArr. 
; This results in an initial array, but with the ascii values flipped in relation to the digits
; in the SDWORD.
; 
; The values are reversed by copying them from l_outStringArr into another local array l_revStringArr. 
; l_revStringArr.  An ascii '-' is also added to the byte array if the SDWORD is negative.
; Finally, the mDisplayString macro is invoked by passing l_revStringArr to display it.
; 
; Preconditions: none.
;
; Postconditions: none.
;
; Receives:
;   [EBP+8] - user passed SDWORD (passed by value).
;	MAXARRSIZE - global constant of the max array size.
;
; returns: none.
; ---------------------------------------------------------------------------------
WriteVal PROC
  ; Declare local variables.
  LOCAL	l_outStringArr[MAXARRSIZE+1]:BYTE	; local BYTE string array outStringArr for storing ascii values.
  LOCAL l_revStringArr[MAXARRSIZE+1]:BYTE   	; local BYTE string array revStringArr for storing reversed array.
  						;   size is MAXARRSIZE+1 to consider the sign.
  LOCAL	l_charCount:DWORD			; local DWORD charCount for max character count of signed int.
  LOCAL l_N_signed:SDWORD			; local SDWORD N_signed, for checking initial sign of passed value.
  LOCAL	l_N:DWORD				; local DWORD N, for calculating the ascii digits.
  LOCAL	l_sign:DWORD				; local DWORD sign, flag used for determining whether to prepend '-'.

  ; Preserve flags and registers.
  PUSHAD
  PUSHFD

  ; Initialize character count and sign flag.
  MOV	l_charCount, 0
  MOV	l_sign, 0					; 0 for positive.

  ; Checks and sets a sign flag for the passed SDWORD. 
  ;  Copies the SDWORD from stack to local mem l_N_signed, and checks its sign.
  MOV	EAX, [EBP + 8]
  MOV	l_N_signed, EAX
  CMP	l_N_signed, 0				
  JGE	_next						; Jumps if positive value.
  ;  Sets ths sign flag if it is negative.
  MOV	l_sign, 1					; 1 for negative.
  NEG	l_N_signed					; Two's negation for negative.

  ; Main routine for converting SDWORD to ascii values. Each of the SDWORD digits will be converted 
  ; to its ascii equivalent and stored in byte array l_outStringArr. This results in a byte 
  ; array with ascii values that are reversed in relation to the digits in the passed SDWORD.
_next:
  ;  Initialize destination address, and unsigned N for calculations.
  LEA	EDI, l_outStringArr			; Address of local outStringArr in EDI.

  MOV	EAX, l_N_signed				; Copies l_N_signed to l_N.
  MOV	l_N, EAX				
  
  ;  Populates the array with ascii values (digits 0-9).
_loopAsciiDigits:
	  ; Perform signed integer division, N // 10 to get quotient and remainder. 
	  MOV	EAX, l_N			; The quotient (local N) in EAX.
	  MOV	EBX, 10				; The divisor in EBX.
	  CDQ					; For 32-bit divison, EAX must be sign-extended into EDX.
	  IDIV	EBX				; Signed integer division. 
						; Quotient in EAX. N gets updated to equal the quotient.
						; Remainder in EDX. Remainder gets stored in the array.

	  ; Shift the remainder by 48 to get its ascii representation (0 starts at ascii value 48).
	  ADD	EDX, 48

	  ; Updates N to the quotient for next iteration.
	  MOV	l_N, EAX

	  ; Stores the remainder on the array (current address pointer in EDI).
	  MOV	EAX, EDX			; Copies remainder to accumulator EAX.
	  CLD
	  STOSB					; Copies byte from accumulator AL to mem address in EDI.
						; Then increments EDI.
	  INC	l_charCount			; Increments the character account.

	  ; Check loop exit condition.
	  CMP	l_N, 0
	  JG	_loopAsciiDigits		; Jumps while N > 0.

  ;  Append ascii value (45)'-' if negative. We add the sign at the end of the string
  ;  since the digits are saved in reverse order.
  CMP	l_sign, 0
  JE	_skipSign		; Jumps/skips prepending if sign is zero (positive). 

  MOV	AL, 45			; (45)'-' in AL (one byte).
  CLD				; Clears direction flag (increments).
  STOSB				; Copies the byte in AL to address in EDI.
				; Then increments EDI to move to next array value.
  INC	l_charCount		; Increments the character account.
_skipSign:

  ; Recall the ascii values in l_outStringArr are in reverse order. Reverse the ordering
  ; by copying the values into l_revStringArr in reverse order. E.g.,  321- becomes -123.
  ;  Initialize loop counter and indices.
  MOV    ECX, l_charCount
  LEA    ESI, l_outStringArr	; Sets source as outStringArr address
  ADD    ESI, ECX
  DEC	 ESI
  LEA    EDI, l_revStringArr	; Sets destination as revStringArr address
  ;  Reverses the string.
_revLoop:
  STD				; Sets direction flag (decrements).
  LODSB				; load from source, decrement ESI.
  CLD				; Clear direction flag (increments).
  STOSB				; Move to destination, increment EDI.
  LOOP   _revLoop

  ; Assigns reverse string address for printing.
  LEA	EDI, l_revStringArr
  mDisplayString	EDI, l_charCount

  ; Restore flags and registers.
  POPFD
  POPAD

  RET	4			; 4 bytes for 1 SDWORD value.
WriteVal ENDP


; ---------------------------------------------------------------------------------
; Name: ReadFloatVal
;
; PROCEDURE that prompts the user for an input string representing a float, validates, 
; and then returns it via the FPU stack.
; 
; ReadFloatVal invokes the mGetString macro to display a prompt, and recieve user input.
; Then, the user input is validated. If the user inputs an invalid input, an error prompt
; is displayed, and the user is reprompted for a new input by re-invoking mGetString.
; 
; Validation is performed as follows:
;
;   - must not empty/null input.
;   - must be valid digit (no letters, symbols, special characters, etc.).
;   - input cannot exceed 100 characters.
;   - signs '+' or '-' are only allowed for the first character.
;	- the following are VALID inputs:
;		-6, 232., 0232, 00232, .232, .0232, +.232, -0.232, +.232, +232, -232, 232
;       - the folllowing are also VALID inputs (get interpreted as zero):
;		., +., -., 0, -0
;	- the following are INVALID inputs:
;		232dkj2, -232kjd2, 232@! 
;
; ReadVal then converts the validated string of ascii digits to its numeric representation 
; (REAL8), and then passes it back by returning it in the top of the FPU stack (ST(0) register).
; 
; Preconditions: Must call FINIT before call, e.g.:
;
;	FINIT
;	PUSH	OFFSET promptTxt			
;	PUSH	OFFSET errorTxt
;	CALL	ReadFloatVal
;
; Postconditions: Alters the FPU stack and flags.
;
; Receives:
;   [EBP+12] - address offset for return/destination floating point value REAL8.
;   [EBP+8] - address offset for error prompt that gets displayed to user.
;   MAXSIZE - global constant of max size of the byte array for storing user input.
;
; returns:
;   ST(0) - Retuns the float on top of the FPU stack.
; ---------------------------------------------------------------------------------
ReadFloatVal PROC
  ; Declares local variables.
  LOCAL	l_bytesRead:DWORD		
  LOCAL	l_userString[MAXSIZE]:BYTE
  LOCAL	l_floatVal:REAL10
  LOCAL	l_floatValFrac:REAL10
  LOCAL l_floatFracDivisor:REAL10
  LOCAL l_numChar:DWORD	
  LOCAL	l_signFlag:DWORD
  LOCAL	l_signInpFlag:DWORD
  LOCAL l_decPointFlag:DWORD
  LOCAL l_decPointLoc:DWORD
  LOCAL l_count:DWORD
  lOCAL	l_mem:DWORD
  ; Preserves flags and registers.
  PUSHAD
  PUSHFD

; ------------------------------------------------------------------------------
; Prompts the user with a message, and reads their input. Defines re-prompt blocks 
; for invalid user inputs.
; ------------------------------------------------------------------------------
  ; Initialize values. 
  MOV	l_count, 0			
  MOV	l_signFlag, 0			; 0 for positive sign, 1 otherwise.
  MOV	l_signInpFlag, 0		; 0 if character digit, 1 otherwise.
  MOV	l_decPointFlag, 0		; 0 for decimal not yet encountered, 1 otherwise. 
					; Readings ints when 0, fractional when 1.
  MOV	l_decPointLoc, 0

  ; Initial trial prompt and input.
  LEA	EAX, l_userString
  LEA	EBX, l_bytesRead
  mGetString [EBP+12], EAX, EBX			; Returns user input in l_userString
						; Returns bytes read in l_bytesRead

_checkZeroBytes:
  ;  Checks if byte length/character count is zero, and reprompts if it is.
  MOV	EAX, l_bytesRead
  CMP	EAX, 0
  JE	_reprompt				; Jumps if zero characters.

_checkMaxBytesRead:
  ;  Checks max bytes read less than MAXSIZE. Since l_bytesRead <= MAXSIZE, if 
  ;  they are equal, then we have truncated the input, then invalid.
  CMP	l_bytesRead, MAXSIZE
  JE	_reprompt				; Jumps if equal.
  JMP	_asciiToFloat

_reprompt:
  ;  Displays error message due to invalid input and re-prompts user for string. We need to 
  ; re-intialize flags and counters as they may have been changed during the validation loop.
  MOV	l_signFlag, 0
  MOV	l_signInpFlag, 0
  MOV	l_decPointFlag, 0
  MOV	l_decPointLoc, 0
  LEA	EAX, l_userString
  LEA	EBX, l_bytesRead
  mGetString [EBP+8], EAX, EBX
  JMP	_checkZeroBytes


; ------------------------------------------------------------------------------
; Performs the main string validation and flag setting.
;
; Given a user a string, parses it by checking in sequence, each ascii character, 
; to determine the sign of the input string, if a decimal was provided, and if so, 
; the location of the decimal point in the string.
; The general hierarchy of the check is:  positive? > negative? > decimal? > digits?
; ------------------------------------------------------------------------------
_asciiToFloat:
  ;  Sets up main loop parameters.
  MOV	ECX, l_bytesRead		; Loop counter set to local bytesRead.
  LEA	EAX, l_userString		; Put local effective address of userString in ESI.
  MOV	ESI, EAX				
  CLD					; Clear direction flag (increments ESI).

  ;  Begin main loop over the string characters. 
  _loopString:
      ; Loads a byte from ESI into AL, and decrements ESI.
	  LODSB

	  ; We only check for a sign input on the first character. Otherwise, we expect a digit 0-9
	  ; or a decimal point '.'
	_checkFirstChar:
	  ; Checks if first character and if not skips to checking for a decimal.
	  CMP	ECX, l_bytesRead
	  JNE	_decimalCheck		; Jumps if not first character.

	_positiveSign:
	  ; Checks if ascii value 43 (+).
	  CMP	AL, 43
	  JE	_setSignInputFlag	; Jumps if '+'.

	_negativeSign:
	  ; Checks if ascii value 45 (-).
	  CMP	AL, 45
	  JE	_setSignFlag		; Jumps if '-'.
	  JMP	_decimalCheck		; Otherwise, jumps to check for '.'

	_setSignFlag:
	  ; Sets the sign flag if (-) sign found.
	  MOV	l_signFlag, 1		; Sets the sign flag to 1 (negative).

	_setSignInputFlag:
	  ; Sets the sign input flag if first character input is +/-.
	  MOV	l_signInpFlag, 1
	  JMP	_endDigitsCheck		; Skips digit checks.


	  ; Check if we already flagged a decimal. If not, updates the found decimal flag, and 
	  ; decimal point byte count/location. Otherwise, we have a double decimal input, and 
	  ; reprompt the user.
	_decimalCheck:
	  ;  Checks if equal to ascii code for decimal point.
	  CMP	AL, 46			; .
	  JNE	_digitsCheck		; Jumps if digit (not decimal).
	  ;  Checks for double decimal occurence, and jumps to digits if not.
	  CMP	l_decPointFlag, 1	
	  JE	_rePrompt		; Jumps if found previous decimal (flag already set).
	  MOV	l_decPointFlag, 1	; Otherwise, updates the decimal flag.
	  MOV	EBX, l_bytesRead	; Updates decimal location.
	  SUB	EBX, ECX
	  MOV	l_decPointLoc, EBX
	  JMP	_endDigitsCheck		; Skips digit checks.
	
	
	  ; Performs checks on whether ascii values are valid digits 0-9.
	_digitsCheck:
	  ;  Checks if less than ascii code for digit 0.
	  CMP	AL, 48			; 0
	  JL	_rePrompt
	  ;  Checks if greater than ascii code for digit 9.
	  CMP	AL, 57			; 9
	  JG	_rePrompt

	_endDigitsCheck:
	  LOOP	_loopString		; Decrements ECX and jumps until ECX = 0.
_endLoopString:


; ------------------------------------------------------------------------------
; Converts from ASCII representation to floating point value with extended
; precision, REAL10. The algorithm works as follows: 
; 
;    Computes the integer portion of the float with:
;		N = 10 * N  +  sign_float*(numChar - 48)
;
;    Computes the fractional integer portion of the float with:
;		N = N + sign_float*(numChar-48)/divisor
;		divisor *= 10
; 
; The integer and fractional components are summed at the end of the string.
; ------------------------------------------------------------------------------
  ;  Sets up main loop parameters.
  FLDZ							
  FSTP	l_floatVal			; Initializes l_floatVal to zero.

  FLDZ
  FSTP	l_floatValFrac			; Initializes l_floatValFrac to zero.
  
  MOV	EBX, 10					
  MOV	l_mem, EBX				
  FILD	l_mem					
  FSTP	l_floatFracDivisor		; Initializes l_floatFracDivisor to 10.

  MOV	l_count, 0			; Initializes current character count/position.
  MOV	ECX, l_bytesRead		; Loop counter set to local bytesRead.
  LEA	EAX, l_userString		; Put local effective address of userString in ESI.
  MOV	ESI, EAX			;

  CLD					; Clear direction flag (increments ESI).
_loopLoadIntsToFloat:
    ; Loads the current ascii value character into l_numChar.
	LODSB				; Copy byte from ESI into AL, decrement ESI.
	MOVZX	EDX, AL			; Zero-extend NumChar from AL to into EDX.
	MOV	l_numChar, EDX		; Copy to local numChar.

	; Check to skip any sign character inputs.
	CMP	AL, 43			; +?
	JE	_endAccum		; Jump if +.
	CMP	AL, 45			; -?
	JE	_endAccum		; Jump if -.

	; Check if the stirng input was a pure INT (no decimal).
	CMP	l_decPointFlag, 0
	JE	_accumDecDigits		; Jumps if no decimal point.

	; Otherwise, check if the current count matches the decimal loc, and if so, skip the accumulation.
	MOV	EBX, l_decPointLoc	
	CMP	l_count, EBX
	JE	_endAccum		; Jump if yes.

	_accumDecDigits:
	; If the character is neither a sign or decimal, then we are accumulating either the integer part, 
	; or the decimal fraction part. Perform the accumulation based on the current count/pos. To the 
	; left of the decimal (if present), we accumulate integers. To the right of the decimal (if present),
	; we are accumulating decimals fractions.
	;  Jumps to integer accumulation directly if no decimal found.
	MOV	EBX, l_decPointFlag
	CMP	EBX, 0
	JE	_accumIntegerPart	; Jumps if l_decPointFlag = 1.
	;  Otherwise, we have a decimal.
	MOV	EBX, l_decPointLoc	
	CMP	l_count, EBX		; Current count < decimal point location?
	JL	_accumIntegerPart	; Jump to evaluate integer part if yes.
	JMP	_accumFractionalPart	; Otherwise, evaluating fractional part.


	; Accumulates the integer part of the float into l_floatVal using:
	;   num = 10 * num  +  sign_num*(numChar - 48)
	_accumIntegerPart:
	MOV	EBX, 10				
	MOV	l_mem, EBX
	FILD	l_mem			; FT(0) = 10
	FLD	l_floatVal		; FT(0) = l_floatVal, FT(1) = l_mem
	FMUL				; FT(0) = 10 * l_floatVal

	FILD	l_numChar		; FT(0) = numChar, FT(1) = 10 * l_floatVal 
	MOV	EBX, 48
	MOV	l_mem, EBX
	FILD	l_mem			; FT(0) = 48, FT(1) = numChar, FT(2) = 10 * l_floatVal 
	FSUB				; FT(0) = numChar - 48, FT(1) = 10 * l_floatVal

	CMP	l_signFlag, 0
	JE	_skipSignInvert		; Jumps if positive float.
	FCHS				; FT(0) = sign_floatVal*(numChar - 48), FT(1) = 10 * l_floatVal
	_skipSignInvert:
	FADD				; FT(0) = 10 * l_floatVal + sign_floatVal*(numChar - 48)

	FSTP	l_floatVal		; l_floatVal = FT(0)
	JMP	_endAccum		; Skips to loop update.

	; Accumulates the decimal fraction part of the float into l_floatValFrac using:
	;   num = num + sign_floatVal*(numChar-48)/divisor
	;	divisor *= 10
	_accumFractionalPart:
	FILD	l_numChar		; FT(0) = numChar
	MOV	EBX, 48
	MOV	l_mem, EBX			
	FILD	l_mem			; FT(0) = 48, FT(1) = numChar
	FSUB				; FT(0) = numChar - 48

	FLD	l_floatFracDivisor	; FT(0) = divisor, FT(1) = numChar - 48
	FDIV				; FT(0) = FT(1)/FT(0) = (numchar - 48)/divisor

	CMP	l_signFlag, 0
	JE	_skipSignInvert2	; Jumps if positive float.
	FCHS				; FT(0) = sign_floatVal*(numchar - 48)/divisor
	_skipSignInvert2:
	FLD	l_floatValFrac		; FT(0) = floatFrac, FT(1) = sign_floatVal*(numchar - 48)/divisor
	FADD				; FT(0) = floatFrac + sign_floatVal*(numchar - 48)/divisor
	
	FSTP	l_floatValFrac		; l_floatValFrac = FT(0)
 
	MOV	EBX, 10
	MOV	l_mem, EBX			
	FILD	l_mem			; FT(0) = 10
	FLD	l_floatFracDivisor	; FT(0) = divisor, FT(1) = 10
	FMUL				; FT(0) = 10*divisor
	FSTP	l_floatFracDivisor	; l_floatFracDivisor = FT(0).

	_endAccum:
	; Increments the character count and continues looping while ECX > 0.
	INC	l_count
	DEC	ECX			; Loop can only perform short jumps (-128 to +127 bytes).
	CMP	ECX, 0			; Must decrement and check manually.
	JNE	_loopLoadIntsToFloat	


  ; Combine integer and fractional parts of the float.
  FLD	l_floatVal
  FLD	l_floatValFrac
  FADD
  FSTP	l_floatVal

; ------------------------------------------------------------------------------
; Returns the resulting floating point value to destination address [EBP+8] and
; to the FPU stack in ST(0)
; ------------------------------------------------------------------------------
_returnFloat:
  FLD	l_floatVal			; Send float value to FPU stack ST(0).

  ; Restore flags and registers.
  POPFD
  POPAD
  ; Return and de-reference 12 bytes for 3 stack params.
  RET  12
ReadFloatVal ENDP


; ---------------------------------------------------------------------------------
; Name: WriteFloatVal
;
; PROCEDURE that takes a floating point value via the FPU stack, parses the floating
; point value into a signiciand and exponent in decimal form, then prints it in 
; scientific notation, 
; 
; For getting the significand and exponent of the float in decimal form, the procedure
; uses a slightly modified implementation of an example provided at:
;	https: //stackoverflow.com/questions/49266250/missing-operator-in-
;	expression-and-command-exited-with-code-1
; 
; Preconditions: Must call FINIT before call, e.g.:
;
;	FINIT
;	FLD	REAL10 PTR [userFloatVal]
;	Call	WriteFloatVal
;
; Postconditions: Alters the FPU stack and flags.
;
; Receives:
;	ST(0) - Float value at top of FPU stack. 
;
; Returns: none.
; ---------------------------------------------------------------------------------
WriteFloatVal PROC
  ; Declare local variables.
  LOCAL	userFloat:REAL8
  LOCAL fexp:REAL8
  LOCAL	fsig:REAL8
  LOCAL	signFlag:DWORD
  LOCAL newcw:WORD
  LOCAL	oldcw:WORD
  LOCAL	remainder:DWORD
  LOCAL	multiplier:DWORD
  LOCAL	count:DWORD
  LOCAL temp:SDWORD
  LOCAL	temp2:DWORD
  ; Preserves flags and registers.
  PUSHAD
  PUSHFD

  ; Save copy of float to local userFloat.
  FSTP	REAL8 PTR [userFloat]

  ; Initialize 
  MOV	signFlag, 0
  MOV	newcw, 1
  MOV	oldcw, 1

; ------------------------------------------------------------------------------
; Retrieves the sign of the float, sets the sign flag, and then negates the sign
; if negative, as the following calculations to convert the exponent and significand 
; to decimal fractions are for positive numbers only.
; ------------------------------------------------------------------------------
;  Sets the sign flag.
  FLDZ						; ST(0) = 0
  FLD	REAL8 PTR [userFloat]			; ST(0) = float, ST(1) = 0.
  CLC						; Carry flag CF must be cleared for JAE.
  FCOMI	ST, ST(1)				; Compare registers, is the float > 0?
  JAE	_skipSetSignFlag
  MOV	signFlag, 1
  FSTP	ST(0)
  FSTP	ST(0)

_skipSetSignFlag:
  ;  Negates the sign of the float.
  CMP	signFlag, 0
  JE	_getExponentSignificand			; Jumps if positive number.
  FLD	REAL8 PTR [userFloat]			; ST(0) = float.
  FCHS						; Change the sign of ST(0).
  FSTP	REAL8 PTR [userFloat]

; ------------------------------------------------------------------------------
; Extracts/computes the significand and exponent in decimal from from the float.
; ------------------------------------------------------------------------------
_getExponentSignificand:
  ; Retrieve exponent and significand of the float.
  FLD	REAL8 PTR [userFloat]

  ;  Gets the exponent in decimal form by:
  ;  fexp = truncate(log_10(fvar))
  FLD	ST(0)
  FLDLG2				; Push log10(2) onto the FPU stack.
  FXCH	ST(1)				; ST(2) = fvar, ST(1) = log_10(2), ST(0) = fvar
  FYL2X					; log_10(fvar) = log_10(2) * log_2(fvar)
  FSTCW [oldcw]				; Store FPU control word
  MOV	DX, [oldcw]
  OR	DX, 0c000h			; Sets rounding mode = 3, toward zero.
  MOV	[newcw], DX
  FLDCW [newcw]
  FRNDINT				; Truncate log_10(fvar).
  FLDCW [oldcw]				; Restore old rounding mode.
  FST	REAL8 PTR [fexp]

  ;  Gets the significand in decimal form by: 
  ;  fsig = fvar / 10^(fexp)
  FLDL2T				; ST(2) = fvar, ST(1) = fexp, ST(0) = log_2(10)
  FMULP					; m = log_2(10) * fexp
  FLD	ST(0)
  FRNDINT				; Integral part of m
  FXCH	ST(1)				; ST(2) = fvar, ST(1) = integer, ST(0) = m
  FSUB	ST(0), ST(1)			; Fractional part of
  F2XM1					; Computes ST(0): (2^ST(0) - 1)
  FLD1					; Push +1 onto the PFU stack.
  FADDP					; 2^(fraction)
  FSCALE				; 10^fexp = 2^(integer) * 2^(fraction)
  FSTP	ST(1)				; ST(1) = fvar, ST(0) = 10^fexp
  FDIVP					; fvar / 10^fexp
  FSTP	REAL8 PTR [fsig]

; ------------------------------------------------------------------------------
; Prints the float in scientific notation. 
; ------------------------------------------------------------------------------

  ;  Ensures that significand has at least 1 integer, and adjusts exponent as needed.
  FLD	fsig
  FISTTP DWORD PTR [temp2]
  CMP	temp2, 1
  JGE	_skipInc
  FLD	fsig
  FLD	ten
  FMUL
  FSTP	REAL8 PTR [fsig]
  FLD	fexp
  FLD1
  FSUB
  FSTP	REAL8 PTR [fexp]
  _skipInc:


  ; Print the sign of the float.
  CMP	signFlag, 1
  JE	_setNegChar
  MOV	AL, 43				; +
  JMP	_P1
  _setNegChar:
  MOV	AL, 45				; -
  _P1:
  CALL	WriteChar


  ; Prints the significand digits.
  MOV	ECX, 8				; Sets no. digits of significand to display.
  MOV	DWORD PTR multiplier, 10	; Sets multiplier to 10.
  MOV	count, 0			; Sets current character count to 0.
_L1:
  ;  This is the magic step! 
  ;  To deal with rounding issues, we multiply by a large power of 10, and add 
  ;  0.5 to force rounding upstream to lower decimal digits locations. Once rounded, 
  ;  we divide back by a large power of 10. 
  FILD	DWORD PTR [pwrOf10+7*4]					
  FLD	REAL8 PTR [fsig]		; Multiplies fsig by 1000000000.
  FMUL	
  
  FLD	REAL8 PTR [oneHalf]		; Add 1/2 to fsig to force rounding.
  FADD

  FILD	DWORD PTR [pwrOf10+7*4]					
  FDIV
  FSTP	REAL8 PTR [fsig]		; Divides fsig by 1000000000.

  ;  Now we are ready to iterate through the digits and print them.
  ;  Does multiplier * significand and returns it to local temp using
  ;  rounding truncation.
  FILD	DWORD PTR [multiplier]
  FLD	REAL8 PTR [fsig]
  FMUL					; (10's multiplier) * significand
  FISTTP DWORD PTR [temp]		; Performs rounding truncation and stores in temp.
  

  ;  Performs integer division to get the remainder (digit 0-9).
  MOV	EAX, temp			; Dividend in EAX.
  MOV	EDX, 0				; Clear high dividend.
  MOV	EBX, 10				; Divisor
  DIV	EBX				; Quotient in EAX. 
					; Remainder in EDX.

  ;  Perform another round of integer division with the quotient. 
  MOV	EDX, 0				; Clear high dividend.
  DIV	EBX				; Dividend (previous quotient) in EAX. 
					; Divisor still 10 in EBX.
					; Remainder in EDX.
  MOV	remainder, EDX			; Save remainder

  ;  Prints the ascii representation of the digit.
  MOV	EDX, remainder
  ADD	EDX, 48				; Adds 48 to get ascii value.
  MOV	EAX, EDX			; Ascii value in EDX.
  CALL	WriteChar			; Writes the character.

  ;  Prints a trailing decimal if its the first digit.
  CMP	count, 0
  JG	_skipDecimalPrint
  MOV	EAX, 46				; 46 (.)
  CALL	WriteChar			; Writes the character.
  _skipDecimalPrint:

  ;  Updates the multiplier for next iteration.
  MOV	EAX, multiplier
  MOV	EBX, 10
  MUL	EBX
  MOV	multiplier, EAX			; scale multiplier by 10
  INC	count
  LOOP	_L1
_endL1:


  ; Prints the exponent.
  ;  Scientific 'e'.
  MOV	AL, 101				; 101 (e)
  CALL	WriteChar
  ;  Loads the exponent into temp.
  FLD	fexp
  FISTTP temp
  ;  Prints the exponent, including sign.
  MOV	EAX, temp
  PUSH	temp
  CALL	WriteVal


  ; Restore flags and registers.
  POPFD
  POPAD
  ; Return and de-reference 4 bytes.
  RET  4
WriteFloatVal ENDP


END main
