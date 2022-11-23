# Project Requirements 

## Introduction
This program, the portfolio project for the class, is the final step up in difficulty. The purpose of this assignment is to reinforce concepts related to string primitive instructions and macros.
  1. Designing, implementing, and calling low-level I/O procedures
  2. Implementing and using macros.

## What you must do
### Program Description
* Implement and test two macros for string processing. These macros should use Irvine’s ReadString to get input from the user, and WriteString procedures to display output. 
	* mGetString :  Display a prompt (input parameter, by reference), then get the user’s keyboard input into a memory location (output parameter, by reference). You may also need to provide a count (input parameter, by value) for the length of input string you can accommodate and a provide a number of bytes read (output parameter, by reference) by the macro.
	* mDisplayString :  Print the string which is stored in a specified memory location (input parameter, by reference).
* Implement and test two procedures for signed integers which use string primitive instructions
	* ReadVal : 
	  1. Invoke the mGetString macro (see parameter requirements above) to get user input in the form of a string of digits.
	  2. Convert (using string primitives) the string of ascii digits to its numeric value representation (SDWORD), validating the user’s input is a valid number (no letters, symbols, etc).
	  3. Store this one value in a memory variable (output parameter, by reference). 
	* WriteVal : 
	  1. Convert a numeric SDWORD value (input parameter, by value) to a string of ASCII digits.
	  2. Invoke the mDisplayString macro to print the ASCII representation of the SDWORD value to the output.
* Write a test program (in main ) which uses the ReadVal and WriteVal procedures above to:
  1. Get 10 valid integers from the user. Your ReadVal will be called within the loop in main . Do not put your counted loop within ReadVal .
  2. Stores these numeric values in an array.
  3. Display the integers, their sum, and their truncated average.
* Your ReadVal will be called within the loop in main . Do not put your counted loop within ReadVal. 
