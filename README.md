# MASM x86 Assembly Final Project
Implements and demonstrates two procedures written in MASMx86 that emulate the Irvine library functions `ReadInt` and `WriteInt`. 

## Program Description
Implements a program that reads in 10 signed decimal integers, validates and converts them from their [ascii](https://www.asciitable.com/) representation and stores them in a `SDWORD` array, performs computations with them, and then echos the input values and results to console by converting the `SDWORD`s back to their ascii representation.

The program implements two helper macros, `mGetString` and `mDisplayString`. `mGetString` prompts, gets and returns user input as an ascii string. `mDisplayStrin`g takes a supplied ascii string, and prints it.  The two macros work in concert with two procedures `ReadVal` and `WriteVal`, which essessentially replace the Irvine procedures, `ReadInt` and `WriteInt`, respectively.

`ReadVal` works by taking the return ascii string from invoking `mGetString`, converting it to a `SDWORD`, validating it, then returning it to the main scope where it gets saved to a `SDWORD` array.  `WriteVal` works by taking passed `SDWORD` values, converting them to ascii strings or `BYTE` arrays, and then printing the strings by invoking `mDisplayString`.
 
## Other Implementation Notes

### ReadVal Implementation
Converts an ascii string to SDWORD using the following algorithm, written in high-level language (python):

```python
 numInt = 0
  get numString
  for numChar in numString:
    if 48 <= numChar <= 57:
      numInt = 10 * numInt + (numChar - 48)
    else:
      break
```

For example, an input string of '109' would be processed in the following manner:
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

### WriteVal Implementation
Converts an SDWORD to ascii string using the algorithm detailed [here](https://www.geeksforgeeks.org/program-to-print-ascii-value-of-all-digits-of-a-given-number/).


## Program Requirements
The program requirements are detailed in the the REQUIREMENTS.MD.
