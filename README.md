# Assembly Final Project: Low-Level I/O
* Computer architecture and assembly final project implemented/written in IA-32 x86 MASM assembly. 
* Implements and demos low-level I/O procedures for reading/writing signed integers and floating point values, similar to the functionality afforded by the Irvine library functions `ReadInt`, `WriteInt`, `ReadFloat`, and `WriteFloat`.
* Procedures implemented:
  * `ReadVal` and `WriteVal` for signed integers (32 bit signed integers).
  * `ReadFloatVal` and `WriteFloatVal` for floating point numbers (80 bit extended precision floats).

## Program Description
The program reads in 10 numbers, validates and converts them from their ASCII representation, performs calculations with them, then displays the numbers and results by converting them from their numeric representations back to ASCII. 

The program implements two variants, which are executed one after the other: **(1)** one implementation that reads, prints, and manipulates signed integers using the `ReadVal`, `WriteVal` procedures, and **(2)** another implementation for floating point numbers using the `ReadFloatVal`, `WriteFloatVal` procedures.
 
The signed integer implementation stores the input numbers in memory as `SDWORD`'s. `ReadlVal` checks the user string for invalid characters and garuntees the input to fit inside a `SDWORD` range (-2147483648 to +2147483647) by checking for numerical over/underflow, otherwise the user is re-prompted for new input. 

The floating point implementation stores the numbers in memory as 80-bit extended precision float values (`REAL10`). `ReadFloatVal` also checks the user string for invalid characters, but does not check for under/overflow.

In accordance with program specifications, the program implements two companion helper macros, `mGetString` and `mDisplayString`. The macros work in concert with the `ReadVal`, `WriteVal`, `ReadFloatVal`, `WriteFloatVal` procedures for prompting the user, and returning ASCII strings, or displaying ASCII strings. 


### Valididation Rules
The following validation rules apply for user inputs:
#### Signed Integers
* input cannot exceed 25 characters. 
* must be a valid digit 0-9 (no letters, symbols, special characters, etc.).
* must fall within range of SDWORD, i.e. -2147483648 to +2147483647.
* signs '+' or '-' are only allowed for the first character. 
* a single '+' or '-' character is interpreted as zero.
* Valid inputs: 0,109,-2147483648,+2147483647,2147483647,-000002147483648,+02147483647
* Invalid inputs:
  * -2147483649 (underflow)
  * +2147483649 (overflow)
  * 2728fdf2dde (invalida characters)
  * !420@!1337  (invalida characters)
  * (null value)
#### Floating Point Values
* must be a valid digit 0-9 (no letters, symbols, special characters, etc.).
* only 1 decimal point allowed. 
* signs '+' or '-' are only allowed for the first character. 
* Valid inputs: -6, 232., 0232, 00232, .232, .0232, +.232, -0.232, +.232, +232, -232, 232
* Valid inputs (interpreted as zero): ., +., -., 0, -0
* Invalid inputs: 232dkj2, -232kjd2, 232@! 


### Example Execution

```assembly
PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures
Written by: Kevin Kuei

EC: Implements the floating point variation of the project.

Please provide 10 signed decimal integers.
Each number needs to be small enough to fit inside a 32 bit register. After you have
finished inputting the raw numbers I will display a list of the integers, their sum,
and their average value.

Afterwards, enter 10 floating point numbers, and I will display a list of the floating
point values, their sum, and their average value in scientific notation.

Please enter an signed number: =67-
ERROR: You did not enter a signed number or your number was too big.
Please try again: 37373kjdfdf
ERROR: You did not enter a signed number or your number was too big.
Please try again: 234567898765432345678
ERROR: You did not enter a signed number or your number was too big.
Please try again: -+23232
ERROR: You did not enter a signed number or your number was too big.
Please try again: -2147483649
ERROR: You did not enter a signed number or your number was too big.
Please try again: +2147483649
ERROR: You did not enter a signed number or your number was too big.
Please try again: 156
Please enter an signed number: 34
Please enter an signed number: -186
Please enter an signed number: -145
Please enter an signed number: 16
Please enter an signed number: +23
Please enter an signed number: 000051
Please enter an signed number: 0
Please enter an signed number: 56
Please enter an signed number: 11
		
You entered the following numbers:
156, 34, -186, -145, 16, 23, 51, 0, 56, 11
The sum of these numbers is: 16
The truncated average is: 1
		
Please enter an signed floating point number: -123.23456
Please enter an signed floating point number: 99.99999
Please enter an signed floating point number: 44.98
Please enter an signed floating point number: 1.1
Please enter an signed floating point number: 2.2
Please enter an signed floating point number: 3.3
Please enter an signed floating point number: 9.9@
ERROR: You did not enter a signed number or your number was too big.
Please try again: 9.9
Please enter an signed floating point number: 10.10
Please enter an signed floating point number: 48.66
Please enter an signed floating point number: 77.7
		
You entered the following numbers:
-1.2323456e2, +9.9999990e1, +4.4980000e1, +1.1000000e0, +2.2000000e0, +3.3000000e0, +9.9000000e0, +1.0100000e1, +4.8660000e1, +7.7700000e1
The sum of these numbers is: +1.7470543e2
The floating point average is: +1.7470543e1
		
Thanks for playing!
```

## Program Requirements
The program requirements are detailed in the the [REQUIREMENTS.MD](https://github.com/kckuei/masmx86-assembly-final-proj/blob/main/REQUIREMENTS.md).
 
## Project Implementation Notes

### ReadVal Implementation
Converts an ASCII string to `SDWORD` using the following algorithm as reference, written in a HLL (python):

```python
 numInt = 0
  get numString
  for numChar in numString:
    if 48 <= numChar <= 57:
      numInt = 10 * numInt + (numChar - 48)
    else:
      break
```

The digits 0 to 9 in ASCII correspond to values of 48 to 57. For example, an input ascii string of '109' would be parsed to a SDWORD in the following manner:

```
‘1’ = (49)
49 - 48 = 1
numInt = 10 x (0) + 1 = 1
‘0’ = 48
48 - 48 = 0
numInt = 10 x ( 1 ) + 0 = 10
‘9’ = 57
57 - 48 = 9
numInt = 10 x ( 10 ) + 9 = 109
```

In the above code, `numInt` acts like an accumulator register, which gets multiplied by 10 each iteration to advance the digits place we are inserting (adding) into.

#### Input Validation and Sign
Valid characters are the ASCII values between 48-47 (digits 0-9). Sign inputs are limited to the first character position. The first character is checked against ASCII values 45 (-) and 43 (+) to determine the sign, and the sign value and flag updated if negative. Any non-digits (!@#$%^&*{}[]()<>asdf...) are immediately invalid. By virtue of checking the sign on the first character, any repeat or out of position +/- signs would illict an invalid flag.

An `SDWORD` spans -2,147,483,648 to +2,147,483,647, hence the buffer size for bytes read should be at minimum 11 characters to accomodate all possible values. However, to allow for zero frontal padding (e.g. +0000420, -000069), the program allows for a max of 25 character input. More than 25 character input raises an invalid flag.

#### Numerical Under/Overflow
To check for numerical underflow, we accumulate the numbers into a signed integer `SDWORD` `numInt` as follows: 

```python
numInt = 10 * numInt + sign_numInt*(numChar - 48)
```

The sign_numInt is set to 1 for positive, or -1 for negative input, and is necessary to accumulate the correct `numInt` for either sign. Under/overflow is considered for by checking the overflow flag (OV) on multiplication (`10 * numInt`) or addition (`10 * numInt + sign_numInt*(numChar - 48)`) in accumulating `numInt`. Overflow occurs if on accumulation, the `SDWORD` `numInt` exceeds the range 2^-31 to 2^31-1 (-2,147,483,648 to +2,147,483,647).

Some additional readings on checking under/overflow: [link1](https://stackoverflow.com/questions/2399269/checking-for-underflow-overflow-in-c), [link2](
https://stackoverflow.com/questions/199333/how-do-i-detect-unsigned-integer-overflow).

### WriteVal Implementation
Converts an SDWORD to ascii string using the following [algorithm](https://www.geeksforgeeks.org/program-to-print-ascii-value-of-all-digits-of-a-given-number/) as reference, written in a HLL (C++):

```c++
int convertToASCII(int N)
{
    while (N > 0) {
        int d = N % 10;
        cout << d << " ("
             << d + 48 << ")\n";
        N = N / 10;
    }
}
```

Given a signed `SDWORD` value of +240, the `SDWORD` would hence be converted to ascii as follows:

```
240 -> 	 2 	 4 	 0	digits
	(50)	(52)	(48)	ascii
```

However, according to the algorithm above, the digits would be returned in reverse order, i.e. 240 gets returned as (48)'0', (52)'4', (50)'2'. Hence, the array needs to either be reversed by copying it in another array, or reading the array in reverse when printing.

#### Signs
To consider sign, prepend/append an ASCII 45 (-) in the event the `SDWORD` is signed.

## Reflection and Conceptual Errors

### Common Mistakes

A mistake I encountered quite a lot of while working on this project were in my attempts to pass **single** value results back from procedures called within `main`. What I thought were disparate/seperate isolated issues when implementing my signed integer and floating point implementations all turned out to be related to not properly 'double-dereferencing' my passed addresses. 

For example, suppose we want to return a value from a procedure called within `main`, passing in one stack parameter (located at [EBP+8] using stdcall approach) of the offset address destination for the return value.

If working with integers, in general we should AVOID things like:

```assembly
MOV EBX, localIntVal
MOV [EBP+8], EBX
```
But DO things like:

```assembly
; Using move
MOV EBX, [EBP+8]
MOV EAX, localIntVal
MOV [EBX], EAX

; Using string primitives
MOV EDI, [EBP+8]
MOV EAX, localIntVal
STOSD
```

Similarly, with floating point values, in general we should AVOID doing:

```assembly
FINIT
FST localIntVal
FST REAL PTR [EBP+8]
```

But do things like:

```assembly
MOV EDI, [EBP+8]
FINIT
FST localIntVal
FST REAL PTR [EDI]
```

Or, alternatively, pass the parameter via the FPU stack.

```assembly
FINIT
PUSH OFFSET txt1
PUSH OFFSET txt2
PUSH val1
CALL myRroc      ; Return value on FPU stack, FT(0).
```

## Floating Point Unit Implementation (Extra Credit)
I also re-attmpted the project using FPU instructions in order to read and write floating point numbers. I got as far as implementing a `ReadFloatVal` procedure to do essentially what Irvine's `ReadFloat` procedure does, but wasn't able to finish my implementation of `WriteFloatVal` to replace Irvine's `WriteFloat`. 

Example output of the unfinished program using my implementation of `ReadFloatVal`, but Irvine's `WriteFloatVal` below:

```assembly
PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures
Written by: Kevin Kuei

Please provide 10 floating point numbers.
Each number needs to be small enough to fit inside a 32 bit register. After you have
finished inputting the raw numbers I will display a list of the integers, their sum,
and their average value.

Please enter an signed number: -1.1
Please enter an signed number: 2.2
Please enter an signed number: -3.3
Please enter an signed number: 4.4
Please enter an signed number: 5.5
Please enter an signed number: 6.6
Please enter an signed number: 7.7
Please enter an signed number: 8.8
Please enter an signed number: 9.9
Please enter an signed number: 10.10

You entered the following numbers:
-1.1000000E+000, +2.2000000E+000, -3.3000000E+000, +4.4000000E+000, +5.5000000E+000, +6.6000000E+000, +7.7000000E+000, +8.8000000E+000, +9.9000000E+000, +1.0100000E+001
The sum of these numbers is: +5.0800000E+001
The floating point average is: +5.0800000E+000

Thanks for playing!
```

My initial idea for implementing the `WriteFloatVal` procedure was to try accessing the [sign, exponent, and mantissa](https://en.wikipedia.org/wiki/IEEE_754) bits of a float directly (e.g. [link1](http://www.website.masmforum.com/tutorials/fptute/fpuchap2.htm), [link2]( https://stackoverflow.com/questions/15238467/get-the-first-bit-of-the-eax-register-in-x86-assembly-language)), then doing some calculations to recover the decimal representations.

Going through docs, I found a useful command `FXTRACT` which returns the, exponent and significand in the FPU stack in fractional binary form. Googling this a bit more, I found this useful [Stack Overflow thread](https://stackoverflow.com/questions/44572003/fxtract-instruction-example), which I was able to repurpose the example of to get the exponent and significand in decimal form. 

To print the values in scientific notation, there are couple things to keep in the mind:
* The float itself has a sign.
* The exponent can also be signed, but is always an integer.
* Irvine's equivalent procedure prints 7 fractional places and up to 3 exponent digits, e.g. -1.2938572E-001.

To print the significand, my psuedo-code would be as follows:
* Retrieve the float into `N`
* For the desired float display precision:
  * Perform integer division on `N`
  * Print the integer remainder
  * Multiply the `N` by 10
* If it is desired to round the last digit, terminate the loop 1 digit early, store it, then get the next and check if it is > 0.5. If yes, then increment the 2nd to last digit.

### Additional Resources
* https://docs.oracle.com/cd/E18752_01/html/817-5477/eoizy.html
* https://cs.fit.edu/~mmahoney/cse3101/float.html
