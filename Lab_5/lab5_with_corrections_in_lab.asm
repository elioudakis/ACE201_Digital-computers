##ACE 201-- LAB 5
##Authors: elioudakis, mlyrakis

.data ##Data declaration section

enterMsg: .asciiz "\nPlease enter a number in the range 0-24, or Q to quit:\n"
.align 2

rangeErrorMsg: .asciiz "This number is outside the allowable range.\n"
.align 2

fibMsg: .asciiz "The Fibonacci number F00 is "
.align 2

tmpStr: .space 4  ##Used to get the input from the user and decide if it is a number or Q.
.align 2

.text  ##Assembly language instructions


#####################################################################
#   Procedure main
#
#   Registers Table 
#   $t1 -- temp, used for comparisons
#   $t2 -- temp, used for comparisons
#   $t3 -- return value of fib
#   $t4 -- return value of fib
#   $t5 -- the n 
#####################################################################
main: ##Start of the code section

    jal getInput

    #Getting the return value of getInput and restoring the $sp.
    lw $t5, 0($sp)
    addi $sp, $sp, 4 

    #Checking for exit.
    li $t1, -1
    beq $t5, $t1, exit

    ##If not exit, check if the number is included in the range 0-24. If yes,
    ##    give it as argument to the fib procedure. If no, print message.

    li $t2, 0
    slt $t1, $t5, $t2

    li $t2, 24
    sgt $t2, $t5, $t2

    add $t2, $t1, $t2
    beq $t2, $zero , call_fib


    ##The number is outside the range 0-24.
    li $v0, 4
    la $a0, rangeErrorMsg
    syscall
    j main



    call_fib:

        addi $sp, $sp, -12
        sw $t5, 4($sp)


        jal	fib

        lw $t3, 0($sp)
        lw $t4, 4($sp)
        addi $sp, $sp, 12
    


## Call the printing function, which will print the result


    ##Giving arguments, before calling the printFib
    addi $sp, $sp, -8
    sw $t5, 4($sp)
    sw $t4, 0($sp) 
    
    jal printFib

    j main

exit:
    li $v0, 10          #terminate program
    syscall

## A function to get the users input
#####################################################################
#   Procedure getInput 
#
#   Registers Table 
#   $t0 -- the string given by user
#   $t1 -- byte of the string given by user, to be processed
#   $t2 -- FLAG for comparisons
#   $t3 -- temporary-used for an ASCII newline character
# 
#####################################################################
getInput:
    ##Print the string asking for the input
    li $v0, 4
    la $a0, enterMsg
    syscall

    ##Read a string from the user

    li $v0, 8 
    la $a0, tmpStr
    syscall

    ##Process the string
    la $t0, tmpStr
    lb $t1, 0($t0)
    
    ##
    ## If we get Q from the user, we return the value (-1) to main, in order to exit.
    ##
    li $t2, 0x51  ##the Q in ascii code
    beq $t1, $t2, exitSignal
    j returnNumber

    ##
    ## The exitSignal label returns the value (-1), in main, in order to exit.
    ##
    exitSignal: 
        addi $sp, $sp, -4
        li $t2, -1
        sw $t2, 0($sp)
        jr $ra

    ##
    ## The returnNumber label returns an integer to main, in range 0-99, given by user.
    ##
    returnNumber:
        addi $t1, $t1, -48 #converting the first digit (ascii to integer)
        
        
        ######Checking if it is a one-digit number,

        lb $t2, 1($t0) #getting the second digit in ascii
        li $t3, 10 #the ascii newline in decimal
        beq $t2, $t3, ret

        
        
        addi $t2, $t2, -48 #converting the second digit (ascii to integer)


        ## Getting the integer ((10*first_digit)+second_digit)
        mul $t1, $t1, 10
        add $t1, $t1, $t2


    ret:
        ##Return the number
        addi $sp, $sp, -4
        sw $t1, 0($sp)
        ##Return to main
        jr $ra
    

## The Fibonacci function, returning F_n-1 and F_n-2
#####################################################################
#   Procedure fib
#
#   Registers Table 
#   $t0 -- used for the recursion
#   $t1 -- used for the recursion
#   $t2 -- used in the special case when n=0
#
#####################################################################

fib: 
    lw $t0, 4($sp)  ##Loading the argument (n).

    bne $t0, $zero, usual_case  

        li $t2, 1
        sw $t2, 0($sp)
        jr $ra

    usual_case: 

        addi $sp, $sp, -12  ##Incrementing the stack pointer (deserving space for the next call of fib() ).
        addi $t0, $t0, -1  ##Reducing n by one
        sw $ra, 8($sp)  ##Storing the return address, in order to have the ability to come back.
        sw $t0, 4($sp)  ##Storing the argument for the next call in the stack.

        jal fib         ##Recursive call

        lw $t0, 4($sp)  ##Reading fib(n-1)--loading from stack
        lw $t1, 0($sp)  ##Reading fib(n-2)--loading from stack
        lw $ra, 8($sp)     ##Restoring the return address
        addi $sp, $sp, 12  ##Free 12 bytes space from the stack

        add $t1, $t0, $t1  ##Adding fib(n-1) to fib(n-2)
        sw $t1, 4($sp)     ##Storing to the stack
        sw $t0, 0($sp)     ##Storing to the stack 

        jr $ra


## The output printing function, manipulating the string fibMsg
#####################################################################
#   Procedure printFib 
#
#   Registers Table 
#   $t0 -- Argument-the fibonacci number to be printed
#   $t1 -- Argument-the n number to be printed
#   $t2 -- Flag for the comparisons (used for sgt)
#   $t3 -- The address of the string to modify
#   $t4 -- Temporary storing ASCII characters
#
#####################################################################
printFib:
    lw $t0, 0($sp)  ##Getting 1st argument, the fibonacci number to be printed.
    lw $t1, 4($sp)  ##Getting 2nd argument, the n to modify the "fibMsg" string.
    addi $sp, $sp, 8  ##Restoring the $sp.



    ##Writing a space to the second digit's place, in order to avoid errors.
    la $t3, fibMsg
    li $t4, 0x0020 #a space character
    sb		$t4, 23($t3)		


    sgt $t2, $t1, 9 ##if n is smaller than 10, t2=0

    beq $t2, $zero, one_digited

    sgt $t2, $t1, 19 ##if n is smaller than 20, t2=0

    beq $t2, $zero, between10and19

    ##Between 20 and 24
    li $t4, 0x0032  ##the 2 in ASCII
    sb $t4, 22($t3)  ##storing the number 2 to the string


    addi $t1, $t1, -20  ##getting the second digit
    addi $t1, $t1, 48   ##converting the second digit to ASCII
    sb $t1, 23($t3)     ##storing the second digit to the string
    j printing



    one_digited:
        addi $t1, $t1, 48   ##converting the integer to ASCII 
        sb $t1, 22($t3)     ##storing to the string
        j printing

    between10and19:
        li $t4, 0x0031  ##the 1 in ASCII
        sb $t4, 22($t3)  ##storing the number 1 to the string 

        addi $t1, $t1, -10  ##getting the second digit
        addi $t1, $t1, 48   ##converting the second digit to ASCII
        sb $t1, 23($t3)     ##storing the secind digit to the string
        j printing

    printing:
        li $v0, 4
        la $a0, fibMsg  ##printing the message, containing n
        syscall

        li $v0, 1
        move $a0, $t0   ##printing the fibonacci number
        syscall


        jr $ra

