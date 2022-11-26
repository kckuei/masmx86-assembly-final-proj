TITLE Project 6 - String Primitives and Macros (FPU)     (proj6_kueik_fpu.asm)

; Author: 					Kevin Kuei
; Last Modified:			November 25, 2022
; OSU email address: 		kueik@oregonstate.edu
; Course number/section:   	CS271 Section
; Project Number:			6                 
; Due Date:					December 4th, 2022
; Description:				CS-271 Final Class Portfolio Project
; 
; Floating Point implementation of the class project using FPU instructions.
;
; A program that reads in 10 signed decimal floats, converts them from their ascii 
; representation to REAL8, performs computations with them, and then prints results to 
; console by inverting the process, i.e. going from REAL8 to ascii representation.
; 
; This program implements two macros, mGetString and mDisplayString. mGetString prompts, gets
; and returns user input as an ascii string. mDisplayString takes a supplied ascii string, and 
; prints it.  The two macros work in concert with two procedures ReadFloatVal and WriteFloatVal, 
; which essessentially replace the Irvine procedures, ReadFloat and WriteFloat, respectively, 
; and which are restricted from use in this assignment. 
; 
; ReadFloatVal takes the return ascii string from invoking mGetString, converts it to a REAL8, 
; validates it, then returns it to the main scope. WriteFloatVal takes a REAL8 values, converts it 
; to an ascii string, and then prints it by invoking mDisplayString
; 
; Assumptions:
;	Assume that the total sum of the valid numbers will fit inside a 32 bit register.
; 
;
; EXAMPLE PROGRAM OUTPUT:
;


INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; MACRO that prompts the user for input, and saves it to a provided string address.
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
  MOV	ECX, MAXSIZE 			; Buffer size, bytes read will be <= buffer size.
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
; MACRO that accepts a string stored in a specified memory address and displays it. 
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


; Declare constants.
MAXSIZE		=		100				; Max buffer size for user input.
MAXARRSIZE	=		10				; Max signed integer array size.


; Declare data segment variables (only referenced directly in main PROC).
.data
introTxt	BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures",13,10
			BYTE	"Written by: Kevin Kuei",13,10,13,10
			BYTE	"Please provide 10 floating point numbers.",13,10  
			BYTE	"Each number needs to be small enough to fit inside a 32 bit register. After you have",13,10
			BYTE	"finished inputting the raw numbers I will display a list of the integers, their sum,",13,10
			BYTE	"and their average value.",13,10,13,10,0 
promptTxt	BYTE	"Please enter an signed number: ",0
errorTxt	BYTE	"ERROR: You did not enter a signed number or your number was too big.",13,10
        	BYTE	"Please try again: ",0 
inputedTxt	BYTE	13,10,"You entered the following numbers:",13,10,0
sumTxt		BYTE	13,10,"The sum of these numbers is: ",0
AvgTxt		BYTE	13,10,"The floating point average is: ",0
goodbyeTxt	BYTE	13,10,13,10,"Thanks for playing!",13,10,0
userVal		SDWORD	?				; For storing the return output from ReadVal.
userIntArr	SDWORD	MAXSIZE DUP(?)	; For storing an array of return values from ReadVal.
userSum		SDWORD	?				; For storing the sum of userIntArr.
userAvg		SDWORD	?				; For storing the truncated average of userIntArr.

; Create variables for floating point calculations.
userFloatVal	REAL8	0.
userFloatArr	REAL8	MAXARRSIZE DUP(0.)
userFloatSum	REAL8	0.
userFloatAvg	REAL8	0.

userFloatTest1	REAL8	-123.456
userFloatTest2	REAL8	+654.321


.code
main PROC
  ; -------------------------------------------------
  ; Prints greeting, author, program description.
  ; -------------------------------------------------
  MOV	EDX, OFFSET introTxt
  CALL	WriteString

  ; -------------------------------------------------
  ; Reads 10 float values (REAL8) into memory.
  ; -------------------------------------------------
  ;  Initialize loop and input parameters.
  MOV	ECX, MAXARRSIZE		
  MOV	EBX, TYPE userFloatArr
  MOV	EDI, OFFSET userFloatArr
  FINIT
_L1:
  ;  Reads the user input and stores it at the current array address.
  PUSH	OFFSET promptTxt			
  PUSH	OFFSET errorTxt
  PUSH	OFFSET userFloatVal
  CALL  ReadFloatVal			; User input in userFloatVal.
  
  FLD	userFloatVal
  FSTP	REAL8 PTR [EDI]
  ADD	EDI, EBX			
  LOOP _L1

  ; -------------------------------------------------
  ; Displays the 10 user-selected float (REAL8) values.
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
  FLD	REAL8 PTR [EDI]
  CALL	WriteFloat
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
  FLD	REAL8 PTR [EDI]
  DEC	ECX
  ADD	EDI, EBX
_LSUM:
  ;  Sums the results.
  FLD	REAL8 PTR [EDI]
  FADD
  ADD	EDI, EBX
  LOOP _LSUM
  FST	userFloatSum
  ;  Prints the sum.
  CALL	WriteFloat

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
  FILD	userVal				; ST(1) = array size, ST(1) = float sum
  FDIV						; ST(0) = ST(1)/ST(0) = sum/array size
  FST	userFloatAvg
  ;  Prints the average.
  CALL	WriteFloat

  ; -------------------------------------------------
  ; Prints farewell.
  ; -------------------------------------------------
  MOV	EDX, OFFSET goodbyeTxt
  CALL	WriteString

  ; -------------------------------------------------
  ; Exits to operating system.
  ; -------------------------------------------------
  Invoke ExitProcess,0	
main ENDP


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
;	- must not empty/null input.
;   - must be valid digit (no letters, symbols, special characters, etc.).
;   - input cannot exceed 100 characters.
;   - signs '+' or '-' are only allowed for the first character.
;	- the following are VALID inputs:
;		-6, 232., 0232, 00232, .232, .0232, +.232, -0.232, +.232, +232, -232, 232
;   - the folllowing are also VALID inputs (get interpreted as zero):
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
;	PUSH	OFFSET userFloatVal
;	CALL	ReadFloatVal
;
; Postconditions: none.
;
; Receives:
;   [EBP+8] - address offset for return/destination floating point value REAL8.
;   [EBP+8] - address offset for error prompt that gets displayed to user.
;   [EBP+12] - address offset for standard prompt that gets displayed to user.
;   MAXSIZE - global constant of max size of the byte array for storing user input.
;
; returns:
;	[EBP+8] - Populates the floating point value REAL8. 
;   ST(0) - Retuns the float on top of the FPU stack.
; ---------------------------------------------------------------------------------
ReadFloatVal PROC
  ; Declares local variables.
  LOCAL	l_bytesRead:DWORD		
  LOCAL	l_userString[MAXSIZE]:BYTE
  LOCAL	l_floatVal:REAL10
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
; Reads the user input, validates it, and finds the decimal location.
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
  mGetString [EBP+16], EAX, EBX			; Returns user input in l_userString
										; Returns bytes read in l_bytesRead

  ; Validates the string and converts from ascii to float.
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
  ;  Displays error message due to invalid input and re-prompts user for string.
  ;  It is encessary to re-intialize flags, counters
  MOV	l_signFlag, 0
  MOV	l_signInpFlag, 0
  MOV	l_decPointFlag, 0
  MOV	l_decPointLoc, 0
  LEA	EAX, l_userString
  LEA	EBX, l_bytesRead
  mGetString [EBP+12], EAX, EBX
  JMP	_checkZeroBytes

_asciiToFloat:
  ;  Sets up main loop parameters.
  MOV	ECX, l_bytesRead		; Loop counter set to local bytesRead.
  LEA	EAX, l_userString		; Put local effective address of userString in ESI.
  MOV	ESI, EAX				
  CLD							; Clear direction flag (increments ESI).

  ; Begin main loop over the string characters. 
  _loopString:
	; Performs a check for sign entries (+/-) on the first character. If a sign value, sets
	; the local mem sign flag l_signFlag, and skips to end of loop at _endDigitsCheck.  All 
	; subsequent characters bypass to _digitsCheck.
	  LODSB						; Loads a byte from ESI into AL, and decrements ESI.
	_checkFirstChar:
	  ; Checks if first character.
	  CMP	ECX, l_bytesRead
	  JNE	_decimalCheck		; Jumps if not the first character.

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
	
	_decimalCheck:
	  ; Performs check for decimal value '.'.
	  CMP	AL, 46				; .
	  JNE	_digitsCheck		; Jumps if digit.
	  ; Check if we already flagged a decimal. If not, updates the found
	  ; decimal flag, and decimal point byte count/location.
	  CMP	l_decPointFlag, 1	
	  JE	_rePrompt			; Jumps if found previous decimal.
	  MOV	l_decPointFlag, 1	; Updates the decimal flag.
	  MOV	EBX, l_bytesRead	; Updates decimal location.
	  SUB	EBX, ECX
	  MOV	l_decPointLoc, EBX
	  JMP	_endDigitsCheck		; Skips digit checks.
	
	_digitsCheck:
	  ; Performs checks on whether ascii values are valid digits 0-9.
	  CMP	AL, 48				; 0
	  JL	_rePrompt
	  CMP	AL, 57				; 9
	  JG	_rePrompt

	_endDigitsCheck:
	  LOOP	_loopString			; Decrements ECX and jumps until ECX = 0.
_endLoopString:


; ------------------------------------------------------------------------------
; Converts from ascii representation to floating REAL10.
; 
; Algorithm works as follows: 
;   1. First load the sequence of digits (integer and fractional) together into mem.
;	2. Determine the number of decimal places, and convert that to a divisor term.
;   3. Divide the floating point value by the divisor to obtain correct value.
;     E.g. 123.567		has 7 characters
;          123567		is the sequence of digits
;		   The decimal is at loc 3.
;		   n = # fractional places = 7 - 3 - 1 = 3
;		   divisor = 10^3 = 1000
;		   Divide 123567 by 1000 = 123.567
;	  Note: if no decimal, then skip steps 2 and 3.
;           if +/- for the first character, we skip it.
; ------------------------------------------------------------------------------
  ;  Sets up main loop parameters.
  MOV	EBX, 0					; Initializes l_floatVal to zero.
  MOV	l_mem, EBX				; (I know, looks so inefficient -_-'' 
  FINIT							;  probably a better way to do this)
  FILD	l_mem
  FSTP	l_floatVal

  MOV	l_count, 0				; Current character count.
  MOV	ECX, l_bytesRead		; Loop counter set to local bytesRead.
  LEA	EAX, l_userString		; Put local effective address of userString in ESI.
  MOV	ESI, EAX				
  CLD							; Clear direction flag (increments ESI).
_loopLoadIntsToFloat:
    ; Loads the current ascii value character into l_numChar.
	LODSB						; Copy byte from ESI into AL, decrement ESI.
	MOVZX	EDX, AL				; Zero-extend NumChar from AL to into EDX.
	MOV	l_numChar, EDX			; Copy to local numChar.

	; Check to skip any sign character inputs.
	CMP	AL, 43		; +
	JE	_endAccum
	CMP	AL, 45		; -
	JE	_endAccum

	; Check to skip the decimal point location if current character count matches it.
	; We only want to do this check if the string input was a pure INT (no decimal).
	CMP	l_decPointFlag, 0
	JE	_accumDecInt			; Jumps if no decimal was input.
	MOV	EBX, l_decPointLoc		; Otherwise, does the current count match decimal loc?
	CMP	l_count, EBX
	JE	_endAccum				; Jump if yes.

	_accumDecInt:
	; Accumulates all the integers (decimal and fractional) into l_floatVal using:
	; num = 10 * num + (NumChar - 48)
	FINIT						; Inits FPU
	MOV		EBX, 10				
	MOV		l_mem, EBX
	FILD	l_mem				; FT(0) = 10
	FLD		l_floatVal			; FT(0) = l_floatVal, FT(1) = l_mem
	FMUL						; FT(0) = 10 * l_floatVal
	FILD	l_numChar			; FT(0) = numChar, FT(1) = 10 * l_floatVal 
	FADD						; FT(0) = 10 * l_floatVal + numChar
	MOV		EBX, 48
	MOV		l_mem, EBX
	FILD	l_mem				; FT(0) = 48, FT(1) = 10 * l_floatVal + numChar
	FSUB						; FT(0) = 10 * l_floatVal + numChar - 48
	FSTP	l_floatVal			; l_floatVal = FT(0)

	_endAccum:
	; Increments the character count and continues looping while ECX > 0.
	INC		l_count
	DEC		ECX					; Loop can only perform short jumps (-128 to +127 bytes).
	CMP		ECX, 0				; Must decrement and check manually.
	JNE		_loopLoadIntsToFloat		


; Skip fractionalizing step if the locDecPint equals the l_bytesread-1, as this implies
; there are no trailing decimal digits.
  MOV	EAX, l_bytesRead
  DEC	EAX
  CMP	EAX, l_decPointLoc
  JE	_applySign

_fractionalizeFloat:
  ; Corrects the float for the fractional component.
  ;  Skips if no decimal was input.
  CMP	l_decPointFlag, 0
  JE	_applySign				; Jumps if no decimal.

  ;  Computes the number of fractional places as:
  ;		n = # dec. places =  byte length - dec point loc
  ;		Then decrement n by 1 if a decimal is present.
  MOV	EBX, l_bytesRead		
  SUB	EBX, l_decPointLoc
  DEC	EBX		
  MOV	l_mem, EBX				; Copy to l_mem.

  ;  Computes the divisor. E.g., 
  ;    if n = 1, divisior = 10
  ;    if n = 2, divisior = 100
  ;    if n = 3, divisior = 1000
  ;    ...
  MOV	ECX, l_mem
  MOV	EBX, 10
  MOV	EAX, 1
  _l1:
    MUL		EBX
    LOOP	_l1					; Divisor in EAX.
  
  ; Divides the float value by the divisor to obtain the correct floating point value.
  FINIT
  FLD	l_floatVal				; FT(0) = l_floatVal
  MOV	l_mem, EAX
  FILD	l_mem					; FT(0) = divisor, FT(1) = l_floatVal
  FDIV							; FT(0) = l_floatVal/divisor
  FSTP	l_floatVal				; l_floatVal = FT(0)


_applySign:
  ; Applies the sign to the magnitude, if applicable.
  CMP	l_signFlag, 0
  JE	_returnFloat
  FINIT
  FLD	l_floatVal
  FCHS
  FSTP	l_floatVal

; ------------------------------------------------------------------------------
; Returns the resulting floating point value to destination address [EBP+8] and
; to the FPU stack in ST(0)
; ------------------------------------------------------------------------------
_returnFloat:
  FINIT
  FLD	l_floatVal			; to FPU stack
  MOV	EDI, [EBP+8]
  FST	REAL8 PTR [EDI]		; userFloatVal

  ;; ***For testing purposes only.***
  ;; ***Note: can't view value in debugger unless it is a REAL4 (32bit) or REAL8 (64bit)***
  ;FINIT
  ;FLD	l_floatVal
  ;CALL	WriteFloat

  ; Restore flags and registers.
  POPFD
  POPAD
  ; Return and de-reference 12 bytes for 3 stack params.
  RET  12
ReadFloatVal ENDP


; ---------------------------------------------------------------------------------
; Name: WriteFloatVal
;
; PROCEDURE 
; 
; Preconditions: none.
;
; Postconditions: none.
;
; Receives:
; returns:
; ---------------------------------------------------------------------------------
WriteFloatVal PROC
; IN PROGRESS
;
; Strategy
;  How to extract the decimal and fractional integers?
;   123.456
;   
;   integer part
;   				r	q
;   123 / 10  		3	12	
;   12 / 10			2	1
;   1 / 10			1	0
;   
;   gives integers 	3, 2, 1, which can be reversed
;   
;   fractional apart
;   
;   0.456 * 10			4.56
;   0.56 * 10			5.6
;   0.6 * 10			6.0
;   
;   gives fractional integers 4, 5, 6
;  
; 
; http://www.website.masmforum.com/tutorials/fptute/fpuchap2.htm
; REAL 4
; 1 sign bit, 8 exponent bits, 23 mantissa
; REAL8
; 1 sign bit, 11 exponent bits, 52 mantissa
; 
; Want print 1 decimal, mantissa, exponent, e.g.  +5.9600E+00
; If we get the address, should be able to read and print them.
	
  FINIT
  FLD	userFloatTest1
  FLD	userFloatTest2

; https://stackoverflow.com/questions/15238467/get-the-first-bit-of-the-eax-register-in-x86-assembly-language
; Obtaining a bit from a register involves an and operation with a mask that has a 1 in the bit position of interest, and 0 in all other bits. Then optionally, a rotate right or a rotate left to move the bit into the desired position in the result.
; Get first bit.
  MOV	EAX, OFFSET userFloatTest1
  MOV   EBX, EAX
  AND   EBX, 01


  MOV	EAX, OFFSET userFloatTest2
  MOV   EBX, EAX
  AND   EBX, 01

  CALL	WriteDec

  ; https://docs.oracle.com/cd/E18752_01/html/817-5477/eoizy.html
  ; https://cs.fit.edu/~mmahoney/cse3101/float.html
  


WriteFloatVal ENDP



testing	PROC

;  ; Continually prompt user for float (REAL10).
;_TEST:
;  FINIT
;  PUSH	OFFSET promptTxt			
;  PUSH	OFFSET errorTxt
;  PUSH	OFFSET userFloatVal
;  CALL  ReadFloatVal
;  FLD	userFloatVal
;  CALL	WriteFloat
;  JMP	_TEST


testing	ENDP


;END WriteFloatVal
END main