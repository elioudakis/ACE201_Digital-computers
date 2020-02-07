##ACE 201-- LAB 4
##Authors: elioudakis, mlyrakis


.data ##Data declaration section

operationMsg: .asciiz "Please determine operation, entry (E), inquiry (I) or quit (Q):\n"
.align 2
lastNameMsg: .asciiz "Please enter last name:\n"
.align 2
firstNameMsg: .asciiz "Please enter first name:\n"
.align 2
phoneMsg: .asciiz "Please enter phone number:\n"
.align 2
printEntry_E_Msg: .asciiz "Thank you, the new entry is the following:\n"
.align 2
printEntry_I_Msg: .asciiz "The number is:\n"
.align 2
notFoundMsg: .asciiz "There is no such entry in the phonebook\n"
.align 2
retrieveMsg: .asciiz "Please enter the entry number you wish to retrieve:\n"
.align 2
invalidOperMsg: .asciiz "Invalid input! Please try again.\n"
.align 2
dotSpace: .asciiz ". "
.align 2 
noMoreEntriesMsg: .asciiz "You cannot add more than 10 entries in the phone book!\n"
.align 2

phonebook: .space 600   
.align 2


.text  ##Assembly language instructions
#####################################################################
#   Procedure main 
#
#   Table of registers:
#   $t0-- the user selection character
#   
#   $s0-- the phonebook address
#   $s1-- the number of records in phonebook
#####################################################################
main: ##Start of the code section

    la $s0, phonebook

    jal Prompt_User
    move $t0, $v0  #in $v0 was the return value of Prompt_User

    ##In order to support E, e, I, i and Q, q , we
    ## convert the user's selection to lowercase.
    ori $t0, $t0, 0x00000020

    beq $t0, 0x00000065, go_Get_Entry  
    beq $t0, 0x00000069, go_Print_Entry
    beq $t0, 0x00000071, Exit

    #If not e, i, q:   ##Show a message and go again to the start of the program
    li $v0, 4
    la $a0, invalidOperMsg
    syscall
    j main

    go_Get_Entry:
    move $a0, $s0  ##the address of the phonebook, used as an argument
    move $a1, $s1  ##the number of records in the phonebook, given as argument
    jal Get_Entry
    move $s1, $v0
    j main 

    go_Print_Entry:
    move $a0, $s0  ##the address of the phonebook, used as an argument
    move $a1, $s1  ##the number of records in the phonebook, given as argument             
    jal Print_Entry
    j main


Exit:
    li $v0, 10          #terminate program
    syscall

#####################################################################
#   Procedure Prompt_User (no args)
#
#   Prints a prompt string on the screen and 
#       reads a character from the user.
#      The character is returned to main.
#####################################################################
Prompt_User: 
    ##Print the string asking the string
    li $v0, 4        
    la $a0, operationMsg  
    syscall

    ##Read the user's selection
    li $v0, 12
    syscall

    ##Keep the v0
    move $t0, $v0

    ##Print a newline character
    li $v0, 11
    li $a0, 0x0000000A  ##newline in ASCII
    syscall

    move $v0, $t0
    jr $ra

#####################################################################
# PRINT ENTRY and subroutines
#####################################################################
#   Procedure Print_Entry 
#
#   Registers Table 
#   $t0 -- copy of the argument $a0 (the phonebook)
#   $t1 -- the number of record to retrieve, given by user
#   $t2 -- used for comparisons
#   $t3 -- used for additions 
#   $t4 -- the number of records in the phonebook
#####################################################################
Print_Entry:
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $a0, 4($sp)
    sw $a1, 0($sp)

    la $t0, 0($a0) ##loading the argument
    move $t4, $a1

    ##Print the string asking for the number of record to retrieve
    li $v0, 4        # system call for printing string = 4   
    la $a0, retrieveMsg  
    syscall
    
    ##Reading the number of record to retrieve
    li $v0, 5 ##the number will be returned in $v0
    syscall
    move $t1, $v0

    ##
    ## If the number of record to retrieve is smaller than 1, we are sure
    ##  that the record does not exist.
    ##
    li $t2, 0
    sgt $t2, $t1, $t2
    beq $t2, $zero, print_no_found_msg

    ##
    ## Check if the number of record to retrieve is less or equal than the
    ##  number of records in the phonebook.
    ##
    addi $t4, $t4, 1
    slt $t2, $t1, $t4
    beq $t2, $zero, print_no_found_msg

    ##
    ## Placing the pointer to the record we want to print
    ##
    li $t3, 60
    mul $t3, $t1, $t3
    add $t0, $t0, $t3  

    li $v0, 4
    la $a0, printEntry_I_Msg  
    syscall

    li $v0, 1
    move $a0, $t1  ##Printing the record's number
    syscall

    li $v0, 4
    la $a0,dotSpace  
    syscall 

    ##
    ## Calling the three subroutines
    ##
    move $a0, $t0
    jal Print_Last_Name 
    jal Print_First_Name
    jal Print_Number
    j end
    
    print_no_found_msg:
        li $v0, 4
        la $a0, notFoundMsg
        syscall
        j end

    end:
    lw $a1, 0($sp)
    lw $a0, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12
    jr $ra

#####################################################################
#   Procedure Print_Last_Name 
#
#   Registers Table    
#    $t0 -- the space character (ASCII 0x0020)
#    $t1 -- the newline character (ASCII 0x000A)
#    $t2 -- the byte being processed
#####################################################################
Print_Last_Name:
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $a0, 0($sp)

    la $t1,0x0000000A  #the newline character

    la $t2, 0($a0)

    ##
    ## In a loop, we will print one by one the characters of the last name, 
    ##    until finding a "\n". We will print a space instead of it. Then, the 
    ##    first name wiil be printed in the same line.
    ##

    loop_while_not_newline_last:
        lb $t0, 0($t2)
        beq  $t0, $t1, found_a_newline_last
        li $v0, 11
        move $a0, $t0
        syscall
        addi $t2, $t2, 1
        j loop_while_not_newline_last

    found_a_newline_last:
        li $v0, 11
        li $t0, 0x00000020 #a space character
        move $a0, $t0
        syscall   

    lw $a0, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8

    jr $ra

#####################################################################
#   Procedure Print_First_Name 
#
#   Registers Table 
#    $t0 -- the space character (ASCII 0x0020)
#    $t1 -- the newline character (ASCII 0x000A)
#    $t2 -- the byte being processed     
#####################################################################
Print_First_Name: 
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $a0, 0($sp)

    la $t1,0x0000000A  #the newline character

  
    la $t2, 20($a0)  

    ## In a loop, we will print one by one the characters of the first name, 
    ##    until finding a "\n". We will print a space instead of it. Then, the 
    ##    telephone number wiil be printed in the same line.

    loop_while_not_newline_first:
        lb $t0, 0($t2)
        beq  $t0, $t1, found_a_newline_first
        li $v0, 11
        move $a0, $t0
        syscall
        addi $t2, $t2, 1
        j loop_while_not_newline_first

    found_a_newline_first:
        li $v0, 11
        li $t0, 0x00000020 #a space character
        move $a0, $t0
        syscall 

    lw $a0, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8

    jr $ra

#####################################################################
#   Procedure Print_Number 
#   Registers Table 
#    $t0 -- the address where we will read the record
#     
#####################################################################
Print_Number:
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $a0, 0($sp)

    la $t0, 40($a0)

    li $v0, 4       
    move $a0, $t0  
    syscall

    lw $a0, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8

    jr $ra

#####################################################################
#  GET ENTRY and subroutines
#####################################################################
#   Procedure Get_Entry 
#
#   Registers Table    
#   $t0 -- counter for the loop printing the characters of a record
#   $t1 -- a flag for comparisons. Later, used to store a newline ASCII character.
#   $t2 -- copy of the argument
#   $t3 -- the character(byte) to be processed
#   $t4 -- counter of the phone book records
#   $t5 -- numerical value used for additions
#   $t6 -- the value for which the loop stops when printing a record (no more than 60)
#   $t7 -- numerical value used for additions
#
#####################################################################
Get_Entry:
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $a0, 4($sp)
    sw $a1, 0($sp)

    la $t2, 0($a0)
    move $t4, $a1

    addi $t4, $t4, 1
    mul $t5, $t4, 60

    add $t2, $t2, $t5 

    ##
    ## Checking if we already have 10 entries.
    ##
    li $t7, 11
    slt $t1, $t4, $t7
    beq $t1, $zero, print_no_more_entries

    ##
    ## Calling the three subroutines
    ##
    move $a0, $t2
    jal Get_Last_Name
    move $a0, $t2
    jal Get_First_Name
    move $a0, $t2
    jal Get_Number

    li $v0, 4        
    la $a0, printEntry_E_Msg  
    syscall

    li $v0, 1
    move $a0, $t4  ##Printing the entry number
    syscall

    li $v0, 4
    la $a0, dotSpace
    syscall

    ##
    ##Print last, first and tel in ONE line, using a loop which will check 
    ##  the 60 characters of the record and print only the useful, 
    ##  throwing away the \n and \0.
    ##

    la $t0, 0($t2)  #a copy of the given record's address. it will be modified
    li $t1, 0x0A #the newline
    #$zero to find the null
    addi $t6, $t2, 60 ##when to stop
    loop_printing:
        beq $t0, $t6, end_loop
        lb $t3, 0($t0)
        addi $t0, $t0, 1
        beq $t3, $t1, found_newline
        li $v0, 11
        move $a0, $t3
        syscall
        j loop_printing

    found_newline:
        li $t3, 0x20 #the space
        li $v0, 11
        move $a0, $t3
        syscall
        addi $t0, $t0, 2
        j loop_printing

    end_loop:
        li $t3, 0x0A
        move $a0, $t3
        syscall
        j end_getEntry

    print_no_more_entries:
        li $v0, 4
        la $a0, noMoreEntriesMsg
        syscall
        
    end_getEntry:
    move $v0, $t4
    lw $a1, 0($sp)
    lw $a0, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12
    jr $ra

#####################################################################
#   Procedure Get_Last_Name 
#
#   Registers Table 
#    $t0 -- the address where we will write the string given from user
#           
#####################################################################
Get_Last_Name:
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $a0, 0($sp)

    la $t0, 0($a0)
    
    ##Print the string asking for the last name
    li $v0, 4         
    la $a0, lastNameMsg  
    syscall

    ##Read the string
    li $v0, 8
    la $a0, 0($t0)
    li $a1, 21
    syscall

    lw $a0, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8
    jr $ra

#####################################################################
#   Procedure Get_First_Name 
#
#   Registers Table 
#    $t0 -- the address where we will write the string given from user
#            
#####################################################################
Get_First_Name:
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $a0, 0($sp)

    la $t0, 0($a0)

    ##Print the string asking for the first name
    li $v0, 4           
    la $a0, firstNameMsg  
    syscall

    ##Read the string
    li $v0, 8
    la $a0, 20($t0)
    li $a1, 21
    syscall

    lw $a0, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8
    jr $ra

#####################################################################
#   Procedure Get_Number 
#  
#   Registers Table  
#    $t0 -- the address where we will write the string given from user
#           
#####################################################################
Get_Number:
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $a0, 0($sp)

    la $t0, 0($a0)

    ##Print the string asking for the phone number
    li $v0, 4        
    la $a0, phoneMsg  
    syscall

    ##Read the string
    li $v0, 8
    la $a0, 40($t0)
    li $a1, 21
    syscall
    
    lw $a0, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8
    jr $ra