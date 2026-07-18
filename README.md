# assembly-bubble-sort
Bubble Sort algorithm implemented in assembly using nasm assembler.
This assembly program sort an array of 1 byte unsigned values (0 - 255) in Windows 64 bits, and print to windows console the sorted array using printf function from C Library.

Generate object file: nasm -f win64 bubbleSort.asm -o bubbleSort.obj
Link object file into executable using gcc: gcc bubbleSort.obj -o bubbleSort.exe
