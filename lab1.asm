# Hello, World!

.data      ##Data declaration section

out_string: .asciiz "\nHello, World!\n"  ##String to be printed

.text  ##Assembly language instructions go in text segment

main: ##Start of the code section
li $v0, 4  # system call for printing string = 4
la $a0, out_string #load address of string to be printed into $a0
syscall # call operating system to perforn operation # specified in $v0
#syscall takes its arguments from $a0, $a1, ...
li $v0, 10 #terminate program
syscall

