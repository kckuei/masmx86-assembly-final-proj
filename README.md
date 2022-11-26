# MASM x86 Assembly Final Project
Final project written in MASM x86 asssembly that implements and demonstrates two procedures which emulate the Irvine library functions `ReadInt` and `WriteInt`. 

## Program Description
Implements a program that reads in 10 signed decimal integers, validates and converts them from their [ascii](https://www.asciitable.com/) representation and stores them in a `SDWORD` array, performs computations with them, and then echos the input values and results to console by converting the `SDWORD`s back to their ascii representation.

The program implements two helper macros, `mGetString` and `mDisplayString`. `mGetString` prompts, gets and returns user input as an ascii string. `mDisplayString` takes a supplied ascii string, and prints it.  The two macros work in concert with two procedures `ReadVal` and `WriteVal`, which essessentially replace the Irvine procedures, `ReadInt` and `WriteInt`, respectively.

`ReadVal` works by taking the return ascii string from invoking `mGetString`, converting it to a `SDWORD`, validating, and then returning it.  `WriteVal` works by taking passed `SDWORD` values, converting them to ascii strings or `BYTE` arrays, and then printing the strings by invoking `mDisplayString`.

### Example Execution

```
PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures
Written by: Kevin Kuei

Please provide 10 signed decimal integers.
Each number needs to be small enough to fit inside a 32 bit register. After you have
finished inputting the raw numbers I will display a list of the integers, their sum,
and their average value.

Please enter an signed number:
ERROR: You did not enter a signed number or your number was too big.
Please try again: =67-
ERROR: You did not enter a signed number or your number was too big.
Please try again: 37373kdfdfhjdf
ERROR: You did not enter a signed number or your number was too big.
Please try again: 1234567890987654323456789
ERROR: You did not enter a signed number or your number was too big.
Please try again: -+23232
ERROR: You did not enter a signed number or your number was too big.
Please try again: 156
Please enter an signed number: 34
Please enter an signed number: -186
Please enter an signed number: -145
Please enter an signed number: 16
Please enter an signed number: +23
Please enter an signed number: 51
Please enter an signed number: 0
Please enter an signed number: 56
Please enter an signed number: 11

You entered the following numbers:
156, 34, -186, -145, 16, 23, 51, 0, 56, 11
The sum of these numbers is: 16
The truncated average is: 1

Thanks for playing!
```
 
## Implementation Notes

### ReadVal Implementation
Converts an ascii string to SDWORD using the following algorithm as reference, written in a high-level programming language (python):

```python
 numInt = 0
  get numString
  for numChar in numString:
    if 48 <= numChar <= 57:
      numInt = 10 * numInt + (numChar - 48)
    else:
      break
```

For example, an input ascii string of '109' would be parsed to a SDWORD in the following manner:
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

In the above code, `numInt` acts like an accumulator register, which gets multiplied by 10 each iteration to advance the digits place we are inserting into.

#### Signs
To consider sign, simply check on the first ascii character if it is (45)'-' or (43)'+', and save the value accordingly.

#### Input Validation
In addition to checking for a sign value on the first character, subsequent digits should should verify that ascii values are between 48-47 (digits 0-9). 

Since the feasible range for an `SDWORD` is 2^-31 to 2^31-1 (-2,147,483,648 to +2,147,483,647), a crude and incomplete initial validate step is allow up to 11 characters to be read, including the sign character. 

The range, however, would still need to be checked.

### WriteVal Implementation
Converts an SDWORD to ascii string using the following [algorithm](https://www.geeksforgeeks.org/program-to-print-ascii-value-of-all-digits-of-a-given-number/) as reference, written in a high-level programming language (C++):

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
To consider sign, prepend/append an ascii (45)'-' in the event the `SDWORD` is signed.


## Program Requirements
The program requirements are detailed in the the [REQUIREMENTS.MD](https://github.com/kckuei/masmx86-assembly-final-proj/blob/main/REQUIREMENTS.md).

## Reflection and Conceptual Errors

### Common Mistakes
In working on this project, some pretty simple yet annoying mistakes I made were in my attempts to pass single value results from procedures back to main (both for integer and floating point implementations). What I thought were disparate/seperate issues all turned out to be the same basic issue of not 'double-dereferencing' my addresses. 

For example, suppose we want to return a value from a procedure called withih main, passing in one stack parameter of the return address for a return value using the stdcall approach.

If working with integers, in general AVOID things like:

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

Similarly, with floating point values, in general AVOID doing:

```assembly
FINIT
FST localIntVal
FST REAL PTR [EBP+8]
```

But Do things like:

```assembly
MOV EDI, [EBP+8]
FINIT
FST localIntVal
FST REAL PTR [EDI]
```

or pass the parameter via the FPU stack.

```assembly
FINIT
PUSH OFFSET txt1
PUSH OFFSET txt2
PUSH val1
CALL myRroc      ; Return value on FPU stack, FT(0).
```
### Numerical Under/Overflow
This project doesn't explicitly check for numerical under/overflow of a `SDWORD`. It does a crude character number check instead, limiting the input to 11 characters max (on account for the fact the `SDWORD` ranges from -2^31 to 2^31-1), including an optional sign term as the first character.

However, I would probably implement something based on these two discussions ([link1](https://stackoverflow.com/questions/2399269/checking-for-underflow-overflow-in-c), [link2](
https://stackoverflow.com/questions/199333/how-do-i-detect-unsigned-integer-overflow)). I would incorporate it in the section that converts ascii values to their numerical representation, checking at each iteration if the summation would result in overflow.

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

Some ideas for tackling this would be to somehow parse the decimal integer from fractional digits:

```
E.g., 
Given 123.456 

integer part            REM     QUOT
123 / 10  		3	12	
12 / 10			2	1
1 / 10			1	0
gives integers 	3, 2, 1, which can be reversed to 1, 2, 3

fractional apart
0.456 * 10			4.56
0.56 * 10			5.6
0.6 * 10			6.0
gives fractional integers 4, 5, 6

Assemble 1, 2, 3 . 4, 5, 6
```

Another idea was to try accessing the [sign, exponent, and mantissa](https://en.wikipedia.org/wiki/IEEE_754) bits of a float directly (e.g. [link1](http://www.website.masmforum.com/tutorials/fptute/fpuchap2.htm), [link2]( https://stackoverflow.com/questions/15238467/get-the-first-bit-of-the-eax-register-in-x86-assembly-language)), then doing some calculations to recover the decimal representations.

### Additional Resources
* https://docs.oracle.com/cd/E18752_01/html/817-5477/eoizy.html
* https://cs.fit.edu/~mmahoney/cse3101/float.html
