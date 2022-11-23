# MASM x86 Assembly Final Project
Implements and demonstrates two procedures written in MASMx86 asssembly that emulate the Irvine library functions `ReadInt` and `WriteInt`. 

## Program Description
Implements a program that reads in 10 signed decimal integers, validates and converts them from their [ascii](https://www.asciitable.com/) representation and stores them in a `SDWORD` array, performs computations with them, and then echos the input values and results to console by converting the `SDWORD`s back to their ascii representation.

The program implements two helper macros, `mGetString` and `mDisplayString`. `mGetString` prompts, gets and returns user input as an ascii string. `mDisplayStrin`g takes a supplied ascii string, and prints it.  The two macros work in concert with two procedures `ReadVal` and `WriteVal`, which essessentially replace the Irvine procedures, `ReadInt` and `WriteInt`, respectively.

`ReadVal` works by taking the return ascii string from invoking `mGetString`, converting it to a `SDWORD`, validating, and then returning it.  `WriteVal` works by taking passed `SDWORD` values, converting them to ascii strings or `BYTE` arrays, and then printing the strings by invoking `mDisplayString`.
 
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

`numInt` functions like an accumulator register, which gets multiplied by 10 each iteration to advance the digits place we are inserting into.

#### Signs
To consider sign, simply check on the first ascii character if it is (45)'-' or (43)'+', and save the value accordingly.


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

Given a signed SDWORD value of +240, the `SDWORD` would hence be converted to ascii as follows:

```
240 -> 	 2 	 4 	 0	digits
	(50)	(52)	(48)	ascii
```

However, the digits would be returned in reverse order, i.e. 240 gets returned as (48)'0', (52)'4', (50)'2'. Then, the array needs to either be reversed by copying it in another array, or reading the array in reverse. 

#### Signs
To consider sign, prepend/append an ascii (45)'-' in the event the `SDWORD` is signed.


## Program Requirements
The program requirements are detailed in the the REQUIREMENTS.MD.
