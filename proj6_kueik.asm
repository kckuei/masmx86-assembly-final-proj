TITLE Project 6 - String Primitives and Macros     (proj6_kueik.asm)

; Author: 				Kevin Kuei
; Last Modified:			November 23, 2022
; Description:				Assembly Final Project
; 
; A program that reads in 10 signed decimal integers, validates and converts them from their
; ascii representation to SDWORDs, performs calculations with them, and then echos the input
; values and results to console by converting SDWORDS back to their ascii representation. 
; 
; The program implements two macros, mGetString and mDisplayString. mGetString prompts, gets
; and returns user input as an ascii string. mDisplayString takes a supplied ascii string, and 
; prints it.
; 
; The two macros work in concert with two procedures ReadVal and WriteVal, which essessentially 
; replace the Irvine procedures, ReadInt and WriteInt, respectively.
; 
; ReadVal takes the return ascii string from invoking mGetString, converts it to a SDWORD, 
; validates it, then returns it to the main scope. WriteVal takes a SDWORD values, converts it 
; to an ascii string, and then prints it by invoking mDisplayString
; 
; Assumptions:
;	Assumes that the total sum of the valid numbers will fit inside a 32 bit register.
; 
;
; EXAMPLE PROGRAM OUTPUT:
;
;	PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures
;	Written by: Kevin Kuei
;	
;	Please provide 10 signed decimal integers.
;	Each number needs to be small enough to fit inside a 32 bit register. After you have
;	finished inputting the raw numbers I will display a list of the integers, their sum,
;	and their average value.
;	
;	Please enter an signed number:
;	ERROR: You did not enter a signed number or your number was too big.
;	Please try again: =67-
;	ERROR: You did not enter a signed number or your number was too big.
;	Please try again: 37373kdfdfhjdf
;	ERROR: You did not enter a signed number or your number was too big.
;	Please try again: 1234567890987654323456789
;	ERROR: You did not enter a signed number or your number was too big.
;	Please try again: -+23232
;	ERROR: You did not enter a signed number or your number was too big.
;	Please try again: 156
;	Please enter an signed number: 34
;	Please enter an signed number: -186
;	Please enter an signed number: -145
;	Please enter an signed number: 16
;	Please enter an signed number: +23
;	Please enter an signed number: 51
;	Please enter an signed number: 0
;	Please enter an signed number: 56
;	Please enter an signed number: 11
;	
;	You entered the following numbers:
;	156, 34, -186, -145, 16, 23, 51, 0, 56, 11
;	The sum of these numbers is: 16
;	The truncated average is: 1
;	
;	Thanks for playing!
;


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
MAXSIZE		=		100			; Max buffer size for user input.
MAXARRSIZE	=		10			; Max signed integer array size.


; Declare data segment variables (only referenced directly in main PROC).
.data
introTxt	BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures",13,10
			BYTE	"Written by: Kevin Kuei",13,10,13,10
			BYTE	"Please provide 10 signed decimal integers.",13,10  
			BYTE	"Each number needs to be small enough to fit inside a 32 bit register. After you have",13,10
			BYTE	"finished inputting the raw numbers I will display a list of the integers, their sum,",13,10
			BYTE	"and their average value.",13,10,13,10,0 
promptTxt	BYTE	"Please enter an signed number: ",0
errorTxt	BYTE	"ERROR: You did not enter a signed number or your number was too big.",13,10
        	BYTE	"Please try again: ",0 
inputedTxt	BYTE	13,10,"You entered the following numbers:",13,10,0
sumText		BYTE	13,10,"The sum of these numbers is: ",0
truncAvgTxt	BYTE	13,10,"The truncated average is: ",0
goodbyeTxt	BYTE	13,10,13,10,"Thanks for playing!",13,10,0
userVal		SDWORD	?				; For storing the return output from ReadVal.
userIntArr	SDWORD	MAXSIZE DUP(?)	; For storing an array of return values from ReadVal.
userSum		SDWORD	?				; For storing the sum of userIntArr.
userAvg		SDWORD	?				; For storing the truncated average of userIntArr.


.code
main PROC

  ; Prints greeting, author, program description.
  MOV	EDX, OFFSET introTxt
  CALL	WriteString


  ; Loads MAXARRSIZE signed integers into userIntArr using indirect operands (register indirect) approach.
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


  ; Displays the 10 user-selected signed integers.
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
  JE	_skipComma
  MOV	AL, 44
  CALL	WriteChar
  MOV	AL, 32
  CALL	WriteChar
_skipComma:
  ADD	ESI, 4					; Increment to next SDWORD value in array.
  LOOP _loopPrint


  ; Computes and displays the sum.
  ;  Print preamble sum text.
  MOV	EDX, OFFSET sumText
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


  ; Computes and displays the truncated average.
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


  ; Prints farewell.
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
;   - input cannot exceed 11 characters (10 digits for max range + 1 digit for sign).
;   - signs '+' or '-' are only allowed for the first character. 
;   - a single '+' or '-' character is interpreted as zero.
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
  LOCAL l_numInt:DWORD				; local DWORD numInt, used for ascii calc.
  LOCAL l_numIntSigned:SDWORD			; local SDWORD numInt, used for ascii calc.
  LOCAL l_numChar:DWORD				; local DWORD numChar, used for ascii calc.
  LOCAL	l_signFlag:DWORD			; local DWORD signFlag, used for ascii calc.
  LOCAL l_temp:QWORD
  
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
  ;  allow up to 11 characters to be read, including the sign character.
_checkMaxBytesRead:
  CMP	l_bytesRead, 11
  JG	_reprompt				; Jumps if more than 11 characters entered.
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
  MOV	l_numInt, 0				; Initialize local numInt = 0.
  MOV	l_signFlag, 0				; Initialize local signFlag = 0 for positive (1 for negative).
  MOV	ECX, l_bytesRead			; Loop counter set to local bytesRead.
  LEA	EAX, l_userString			; Put local effective address of userString in ESI.
  MOV	ESI, EAX				;
  CLD						; Clear direction flag (increments ESI).

 ;  Begin main loop over the string characters. 
_loopString:
	  LODSB					; Loads a byte from ESI into AL, and decrements ESI.

	; Performs a check for sign entries (+/-) on the first character. If a sign value, sets
	; the local mem sign flag l_signFlag, and skips to end of loop at _endDigitsCheck.  All 
	; subsequent characters bypass to _digitsCheck.
	_checkFirstChar:
	  ; Checks if first character.
	  CMP	ECX, l_bytesRead
	  JNE	_digitsCheck			; Jumps if not the first character.
	  
	  ; Otherwise, consider a sign check when its the first character. 
	_positiveSign:
	  ; Check if ascii value 43 (corresponds to +).
	  CMP	AL, 43
	  JNE	_negativeSign			; Jumps if not +.
	  JMP	_endDigitsCheck
	
	_negativeSign:
	  ; Otherwise, check if ascii value 45 (corresponds to -).
	  CMP	AL, 45
	  JNE	_digitsCheck			; Jumps if not -.
	  MOV	l_signFlag, 1			; Sets the sign flag to 1 (negative).
	  JMP	_endDigitsCheck
	
	; Performs checks on whether ascii values are valid digits 0-9.
	_digitsCheck:
	  ; Checks if below ascii value 48.
	  CMP	AL, 48				; digit 0
	  JL	_rePrompt
	
	  ; Checks if above ascii value 57.
	  CMP	AL, 57				; digit 9
	  JG	_rePrompt
	
	  ; Otherwise, its a valid digit. Then convert from ascii value to integer
	  ; by the following iterative algorithm:  NumInt = 10 * NumInt + (NumChar - 48)
	  ;  Fetch the current character ascii value into local numChar.
	  MOVZX	EDX, AL				; Zero-extend NumChar from AL to into EDX.
	  MOV	l_numChar, EDX			; Copy to local numChar.
	
	  ;  Perform calculations in accumulator EAX.
	  MOV	EAX, 10			
	  MUL	l_numInt			; 10 * numInt in EAX.
	  ADD	EAX, l_numChar			; Adds numChar to EAX.
	  SUB	EAX, 48				; Subtract 48 from EAX.

	  MOV	l_numInt, EAX			; Update numInt for next iter.
	_endDigitsCheck:
	  LOOP	_loopString			; Decrements ECX and jumps until ECX = 0.
	
_endLoop:

  ; Initialize the signed integer with the magnitude.
  MOV	EAX, l_numInt
  MOV	l_numIntSigned, EAX

  ; Apply the sign, if applicable.
  CMP	l_signFlag, 0
  JE	_return					; Jumps if zero (+).
  NEG	l_numIntSigned				; Flip the sign of local numInt.

_return:
  ; Save validated value to destination address.
  MOV   EDI, [EBP+8]				; Destination address in EDI.
  MOV   EAX, l_numIntSigned			; Signed integer in EAX.
  STOSD						; Copies from EAX to mem address pointed by EDI.

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
  MOV	l_sign, 0				; 0 for positive.

  ; Checks and sets a sign flag for the passed SDWORD. 
  ;  Copies the SDWORD from stack to local mem l_N_signed, and checks its sign.
  MOV	EAX, [EBP + 8]
  MOV	l_N_signed, EAX
  CMP	l_N_signed, 0				
  JGE	_next					; Jumps if positive value.
  ;  Sets ths sign flag if it is negative.
  MOV	l_sign, 1				; 1 for negative.
  NEG	l_N_signed				; Two's negation for negative.

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
  JE	_skipSign				; Jumps/skips prepending if sign is zero (positive). 

  MOV	AL, 45					; (45)'-' in AL (one byte).
  CLD						; Clears direction flag (increments).
  STOSB						; Copies the byte in AL to address in EDI.
						; Then increments EDI to move to next array value.
  INC	l_charCount				; Increments the character account.
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


ReadFloatVal PROC
ReadFloatVal ENDP

WriteFloatVal PROC
WriteFloatVal ENDP


END main
