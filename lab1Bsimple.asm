# Hello World!

.data ##Data declaration section

ask_string: .asciiz "\nGive a string (max.32 characters)\n"
out_string1: .asciiz "Hello "  ##String to be printed
out_string2: .asciiz " World!"  ##String to be printed
your_string: .space 32    ###32bytes space in memory to store the string


.text  ##Assembly language instructions go in text segment

main:  ##Start of the code section

##Print the asking string
li $v0, 4           # system call for printing string = 4
la $a0, ask_string  #load address of string to be printed into $a0
syscall             # call operating system to perforn operation # specified in $v0
                    #syscall takes its arguments from $a0, $a1, ...
##Reading the your_string
li $v0, 8           # system call for reading string = 8
la $a0, your_string #load address of string to be read into $a0
li $a1, 32          #the length of the string is 32bytes
syscall             #call operating system to perforn operation specified in $v0

##Print Hello
li $v0, 4           # system call for printing string = 4
la $a0, out_string1 #load address of string to be printed into $a0
syscall             # call operating system to perforn operation # specified in $v0
                    #syscall takes its arguments from $a0, $a1, ...
##Print your_string
li $v0, 4           # system call for printing string = 4
la $a0, your_string #load address of string to be printed into $a0
syscall             # call operating system to perforn operation # specified in $v0
                    #syscall takes its arguments from $a0, $a1, ...
##Print World
li $v0, 4           # system call for printing string = 4
la $a0, out_string2 #load address of string to be printed into $a0
syscall             # call operating system to perforn operation # specified in $v0
                    #syscall takes its arguments from $a0, $a1, ...
li $v0, 10          #terminate program
syscall

