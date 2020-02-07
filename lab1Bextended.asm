# Hello World!  
# Extended version


.data ##Data declaration section

ask_string: .asciiz "Give a string (max.32 characters)\n"
out_string1: .asciiz "Hello "  ##String to be printed
your_string: .space 32   ##32bytes space in memory to store the string
out_string2: .asciiz " World!"  ##String to be printed
newLineString: .asciiz "\n"
emptyString: .asciiz ""

.text  ##Assembly language instructions go in text segment

main: #Start of the code section

##Print the asking string
li $v0, 4           # system call for printing string = 4
la $a0, ask_string  #load address of string to be printed into $a0
syscall             # call operating system to perforn operation # specified in $v0
                    #syscall takes its arguments from $a0, $a1, ...

##Reading the your_string
li $v0, 8
la $a0, your_string
li $a1, 32
syscall

##to change the "\n" of the string with "\0"
li $t0, 0 #counter
li $t1, 31 #end

loop:
beq $t0, $t1, end           #go to end when t1 equals t2
lb $a3,your_string($t0)     #loading one character
lb $t2,newLineString($0)
lb $t3,emptyString                                          
beq $a3, $t2, foundEnd
addi $t0, $t0, 1            #add 1 to t0
j loop                      #jump to the start of the loop

foundEnd:
sb $t3,your_string($t0)

end:                        #When the loop ends, the code will continue from here

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

