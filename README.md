# Assembly Final Project: Low-Level I/O
* Computer architecture and assembly [final project](https://github.com/kckuei/masmx86-assembly-final-proj/blob/main/combined.asm) implemented/written in [IA-32 x86 MASM assembly](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html). 
* Implements and demos low-level I/O procedures for reading/writing signed integers and floating point values, similar to the functionality afforded by the Irvine library functions `ReadInt`, `WriteInt`, `ReadFloat`, and `WriteFloat`.
* Procedures implemented:
  * `ReadVal` and `WriteVal` for signed integers (32 bit signed integers).
  * `ReadFloatVal` and `WriteFloatVal` for floating point numbers (80 bit extended precision floats).

## Program Description
The program reads in 10 numbers, validates and converts them from their [ASCII](https://www.asciitable.com/) representation, performs calculations with them, then displays the numbers and results by converting them from their numeric representations back to ASCII. 

The program implements two variants, which are executed one after the other: **(1)** one implementation that reads, prints, and manipulates signed integers using the `ReadVal`, `WriteVal` procedures, and **(2)** another implementation for floating point numbers using the `ReadFloatVal`, `WriteFloatVal` procedures.
 
The signed integer implementation stores the input numbers in memory as `SDWORD`'s. `ReadlVal` checks the user string for invalid characters and garuntees the input to fit inside a `SDWORD` range (-2147483648 to +2147483647) by checking for numerical over/underflow, otherwise the user is re-prompted for new input. 

The floating point implementation stores the numbers in memory as 80-bit extended precision float values (`REAL10`). `ReadFloatVal` also checks the user string for invalid characters, but does not check for under/overflow.

In accordance with program specifications, the program implements two companion helper macros, `mGetString` and `mDisplayString`. The macros work in concert with the `ReadVal`, `WriteVal`, `ReadFloatVal`, `WriteFloatVal` procedures for prompting the user, and returning ASCII strings, or displaying ASCII strings. 

## Program Requirements
The program requirements are detailed in the the [REQUIREMENTS.MD](https://github.com/kckuei/masmx86-assembly-final-proj/blob/main/REQUIREMENTS.md).

## Input Valididation Rules
The following validation rules apply for user inputs:
### Signed Integers
* input cannot exceed 25 characters. 
* must be a valid digit 0-9 (no letters, symbols, special characters, etc.).
* must fall within range of SDWORD, i.e. -2147483648 to +2147483647.
* signs '+' or '-' are only allowed for the first character. 
* a single '+' or '-' character is interpreted as zero.
* Valid inputs: 0,109,-2147483648,+2147483647,2147483647,-000002147483648,+02147483647
* Invalid inputs:
  * -2147483649 (underflow)
  * +2147483649 (overflow)
  * 2728fdf2dde (invalid characters)
  * !420@!1337  (invalid characters)
  * (null value)
### Floating Point Values
* must be a valid digit 0-9 (no letters, symbols, special characters, etc.).
* only 1 decimal point allowed.
* signs '+' or '-' are only allowed for the first character. 
* Valid inputs: -6, 232., 0232, 00232, .232, .0232, +.232, -0.232, +.232, +232, -232, 232
* Valid inputs (interpreted as zero): ., +., -., 0, -0
* Invalid inputs: 232dkj2, -232kjd2, 232@! 

## Example Execution

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
In accordance with the algorithm above, each individual digit is accumulated into a signed integer `SDWORD` `numInt` as follows: 

```python
numInt = 10 * numInt + sign_numInt*(numChar - 48)
```

The `sign_numInt` term is set to 1 for positive and -1 for negative input, and is necessary to accumulate the correct `numInt` for either sign.

Overflow occurs if on accumulation, the `SDWORD` `numInt` exceeds the range 2^-31 to 2^31-1 (-2,147,483,648 to +2,147,483,647). Under/overflow conditions are considered for by checking the overflow flag (OF) and using a conditional jump `JO` (OF=1) for reprompting the user. It is important to check for under/overflow on both the multiplication (`10 * numInt`) and addition (`10 * numInt + sign_numInt*(numChar - 48)`) in accumulating `numInt`. 

Some additional readings on checking under/overflow: [link1](https://stackoverflow.com/questions/2399269/checking-for-underflow-overflow-in-c), [link2](
https://stackoverflow.com/questions/199333/how-do-i-detect-unsigned-integer-overflow).

### WriteVal Implementation
Converts an SDWORD to ASCII string using the following [algorithm](https://www.geeksforgeeks.org/program-to-print-ascii-value-of-all-digits-of-a-given-number/) as reference, written in a HLL (C++):

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

#### The importance of 'Double-Dereferencing'

A silly, but small amateur mistake which induced much headache while debugging. What I thought were disparate/seperate isolated issues when implementing my signed integer and floating point implementations all turned out to be related to not properly 'double-dereferencing' my passed addresses. 

For example, suppose we want to return a value from a procedure called within `main`, passing in one stack parameter using the [stdcall](https://github.com/kckuei/masmx86-assembly-final-proj/blob/main/assets/stack-convention.png) approach. That value is passed by address (located at [EBP+8]).

If working with integers, in general AVOID:

```assembly
MOV EBX, localIntVal
MOV [EBP+8], EBX
```
But DO:

```assembly
; Using move
MOV EBX, [EBP+8]
MOV EAX, localIntVal
MOV [EBX], EAX
```

OR

```assembly
; Using string primitives
MOV EDI, [EBP+8]
MOV EAX, localIntVal
STOSD
```

Similarly, with floating point values, in general AVOID:

```assembly
FINIT
FST localIntVal
FST REAL PTR [EBP+8]
```

But DO:

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

## Floating Point Implementation Notes

My initial idea for implementing the `WriteFloatVal` procedure was to try accessing the [sign, exponent, and mantissa](https://en.wikipedia.org/wiki/IEEE_754) bits of a float directly (e.g. [link1](http://www.website.masmforum.com/tutorials/fptute/fpuchap2.htm), [link2]( https://stackoverflow.com/questions/15238467/get-the-first-bit-of-the-eax-register-in-x86-assembly-language)), then doing some calculations to recover the decimal representations.

![real4](./assets/real4.svg)

Skimming through the docs, I then found a useful command `FXTRACT` which returns the, exponent and significand in the FPU stack. However, these value were in fractional binary form. On googling the best way to convert it to decimal representation, I found this useful [Stack Overflow thread](https://stackoverflow.com/questions/44572003/fxtract-instruction-example), which goes over the math, and provides an example. I was able to tweak/repurpose the example to obtain the exponent and significand in decimal form that I needed.

The main math underlying the transformation is the [change of base formula]( https://en.wikipedia.org/wiki/Logarithm#Change_of_base). The equation is stated as follows:

$$ {\log_b x} = \frac{\log_d x}{\log_d b} $$

On substituting $b=2$, $d=10$, and rearranging for the decimal term:

$$ {\log_{10} fval} =  {\log_2 fval} \cdot {\log_{10} 2} $$

Conveniently, there are a number of helper functions for performing the math and related manipulations, such as `FYL2X` (which performs $y\cdot\log_2 x$), `FLDL2T` (which loads $\log_2 10$), and `FSCALE` (which does `2^ST(0) + ST(1)`), and `F2XM1` (which computes `2^ST(0) - 1`)

With the significand and exponent values in decimal form at hand, I thought it would be a relatively clear path to implementing the `WriteFloatVal` procedure next. However, printing the values in scientific notation proved to be fairly challenging! Round off/precision error, as well as my frustration were in great abundance. 

My eureka moment came when I realized that the best way to deal with the rounding/precision errors was to multiply the values by a large power of 10, then add 0.5 to force rounding upstream in the lower decimal places, then dividing back by the large power of 10 (as opposed to trying to deal with rounding digits in the downstream directions). This works so long as the large power of 10 that you mutiply by is greater than the number of decimal places that are desired to display (an example is given below).

For example, suppose you store `44.68`, but the significand ends up being stored as `4.4679999999999999999--` (where the '--' indicates more trailing digits). Well, take `4.4679999999999999999--`, multiply it by `1000000`, add `0.5`, then divide back by`1000000` like so:

```
4.4679999999999999999-- * 1000000 = 44679999.999999999999--   ; Multiply by large power of 10, e.g. 1e6
44679999.999999999999-- + 0.5	  = 44680000.499999999999--   ; Add 0.5
44680000.499999999999-- / 1000000 = 4.4680000499999999999--   ; Divide back by a large power of 10
```

Now it's possible to march forward through the lower decimal digit positions and obtain the correct values by iteratively multiplying by powers of 10, casting/truncating the value to an integer, and dividing by 10 for the remainder. 

Some other useful commands were `FILD` for loading integer values, `FISTP` for storing integer values, `FRNDINT` for rounding in accordance with the control word, and the `FISTTP` instruction which performs true truncation of floating point values. 

## Closing
Assembly programming has been my first foray and exposure into a low-ish level programming paradigm. This assignment was a really challenging project by far, especially the floating point implementation part! However, I learned a lot, and really enjoyed tackling it. In the words of my TA:
> The idea is to implement from scratch. The EC is basically re-doing the whole project but with floats intead of integers. It's not a lot of points per hour spent (**at least for mere mortals**). But it does seem like a fun challenge if you have the time.

Although many a restless night, I guess now I can say I am no mere mortal. 🥲
