#ACE201_LAB3

.data ##Data declaration section

enterMsg: .asciiz "Please Enter your String:\n"
.align 2
processedMsg: .asciiz "The Processed String is:\n"
.align 2
givenStr: .space 100
.align 2
processedStr: .space 100
.align 2


.text  ##Assembly language instructions

main: ##Start of the code section

jal Get_Input
jal Process
jal Print_Output
j Exit  ##end of program

###########################################################
#   Procedure Get_Input
#   
#   Show the prompt for entering the string, reading it and
#       storing it as givenStr
#
###########################################################
Get_Input:
    ##Print the string asking the string
    li $v0, 4        # system call for printing string = 4   
    la $a0, enterMsg  
    syscall 

    ##Reading the string
    li $v0,8        # system call for reading string = 8
    la $a0,givenStr
    syscall 

    jr $ra


###########################################################
#   Procedure Process
#
#   Table of registers
#   $t0--the pointer for the given string
#   $t1--the pointer for the processed string
#   $t2--the word we are currently processing
#   $t3--the byte we are currently processing
#   $t4--counter for the words (until 25)
#   $t5--counter or the bytes (until 3)
#   $t6--FLAG-space_has_been_written
#
###########################################################
Process:
    la $t0, givenStr
    la $t1, processedStr
 
    li $t4, 0
    li $t6, 0
    
   

    loop_word:
        beq $t4, 25, end_loop
        lw $t2, ($t0)

        li $t5, 0
        loop_byte:
        beq $t5, 4, end_loop_byte

            andi $t3, $t2, 0x000000FF #Masking
            #
            ##Processing a single byte
            #


            #if it is the "\n" character
            beq $t3, 0x0000000A , process_newline
            
            #if it is a number from 0 to 9
            bge $t3, 0x00000030, second_check_number
            j first_check_uppercase 
            second_check_number:
            ble $t3, 0x00000039, process_keep

            #if it is an uppercase letter
            first_check_uppercase:
            bge $t3, 0x00000041, second_check_uppercase
            j first_check_lowercase 
            second_check_uppercase:
            ble $t3, 0x0000005A, process_uppercase 

            #if it is a lowercase letter
            first_check_lowercase:
            bge $t3, 0x00000061, second_check_lowercase
            j space_or_symbol 
            second_check_lowercase:
            ble $t3, 0x0000007A, process_keep

            #if it is a space or a symbol
            space_or_symbol:
            j process_else

            process_uppercase:
                li $t6, 0
                addi $t3, $t3, 0x00000020
                sb $t3, 0($t1)
                addi $t1, $t1, 1
                j continue_to_next_byte

            process_keep:
                li $t6, 0
                sb $t3, 0($t1)
                addi $t1, $t1, 1
                j continue_to_next_byte

            process_newline:
                li $t6, 0
                sb $t3, 0($t1)
                li $t3, 0x000000000 #The NUL in ASCII, end of string.
                sb $t3, 1($t1)
                jr $ra ##we have ended 

            process_else:
                beq $t6, 0, put_space
                j continue_to_next_byte
                put_space:
                        li $t3, 0x00000020 #the space in ASCII
                        sb $t3, 0($t1)
                        li $t6, 1 #FLAG -- we have written a space
                        addi $t1, $t1, 1
                        j continue_to_next_byte


            continue_to_next_byte:

            #Doing the shift and incrementing the counter
            srl $t2, $t2, 8
            addi $t5, $t5, 1
        j loop_byte
        end_loop_byte:
        addi $t0, $t0, 4
        addi $t4, $t4, 1
    j loop_word
    
    end_loop:
        jr $ra


###########################################################
#   Procedure Print_Output
#
#   Printing a message and the processed string
#
###########################################################
Print_Output:
    ##Print the processed string message
    li $v0, 4        # system call for printing string = 4   
    la $a0, processedMsg  
    syscall 

    ##Print the processed string
    li $v0, 4        # system call for printing string = 4   
    la $a0, processedStr  
    syscall 

    jr $ra

###########################################################
Exit:
    li $v0, 10          #terminate program
    syscall
