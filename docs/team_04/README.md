# STARS 2024 Design Final Project

## TEAM NAME
* Travis Jakl
* Andy Hu
* Mary Francis
* Michael Li
* Duc Pham
* Dhruv Khatri

## Project Type
Our group designed and implemented a RISC-V 32-bit CPU with a serial UART input and outputs to a VGA display. The CPUs peripherals cooperate with the CPU via memory mapped I/O. Given the proper instructions, our CPU can serve multiple purposes, such as doing calculations, running games, and much more. 

## Pin Layout
Note that on the final chip, there are 38 gpio of which you have access to 34.
The first number represents the GPIO on the physical board. The second number
in brackets represents the number in your verilog code

00[00] Input/Output: h_out (VGA)
01[--] Input/Output: Pin_Function
02[--] Input/Output: Pin_Function
03[--] Input/Output: Pin_Function
04[--] Input/Output: Pin_Function
05[01] Input/Output: v_out (VGA)
06[02] Input/Output: pixel_data (VGA) 
07[03] Input/Output: opcode_error (control unit does not recognize instruction) 
08[04] Input/Output: alu_error (ALU does not recognize instruction)
09[05] Input/Output: Rx (UART input)
10[06] Input/Output: Pin_Function
11[07] Input/Output: Pin_Function
12[08] Input/Output: Pin_Function
13[09] Input/Output: Pin_Function 
14[10] Input/Output: Pin_Function 
15[11] Input/Output: Pin_Function 
16[12] Input/Output: Pin_Function 
17[13] Input/Output: Pin_Function 
18[14] Input/Output: Pin_Function 
19[15] Input/Output: Pin_Function 
20[16] Input/Output: Pin_Function 
21[17] Input/Output: Pin_Function 
22[18] Input/Output: Pin_Function 
23[19] Input/Output: Pin_Function 
24[20] Input/Output: Pin_Function 
25[21] Input/Output: Pin_Function 
26[22] Input/Output: Pin_Function 
27[23] Input/Output: Pin_Function 
28[24] Input/Output: Pin_Function 
29[25] Input/Output: Pin_Function
30[26] Input/Output: Pin_Function
31[27] Input/Output: Pin_Function
32[28] Input/Output: Pin_Function
33[29] Input/Output: Pin_Function
34[30] Input/Output: Pin_Function
35[31] Input/Output: Pin_Function
36[32] Input/Output: Pin_Function
37[33] Input/Output: Pin_Function
38[34] Input/Output: Pin_Function

## Supporting Equipment
* VGA Female Breakout Connector
* 

## RTL Diagrams
All the stuff from the proposal goes here, obviously updated from the time you did the proposal to the final layout
Include more than just block diagrams, including sub-block diagrams, state-transition diagrams, flowcharts, and timing diagrams.  If you include an image, a short (0.5-1 sentence description) is required.
You may also place other files within this folder.

## Statement from Purdue
Pending

