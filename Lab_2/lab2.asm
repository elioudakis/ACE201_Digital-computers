#Description
#Course: ACE201
#Lab: 2nd

.data ##Data declaration section

enter1msg: .asciiz "Please enter the 1st Number:\n" 
enterOperMsg: .asciiz "Please enter the operation:\n" 
enter2msg: .asciiz "Please enter the 2nd Number:\n" 
resultMsg: .asciiz "The result is: " 
operation: .asciiz "    "  #4bytes
unknown_oper: .asciiz "Unknown operation!"
divZeroMsg: .asciiz "Cannot divide by 0!"
quotientMsg: .asciiz "Quotient: "
remainderMsg: .asciiz " and Remainder: "


.text  ##Assembly language instructions

main: ##Start of the code section

###REGISTERS TABLE
### $s1 -- the ASCII code of the operation symbols, to compare
### $t0 -- number1
### $t1 -- number2
### $t2 -- operation symbol, given by user
### $t3 -- the result (in division, it is used for the quotient)
### $t4 -- only in division, is used for the remainder


##Print the string asking the 1st number
li $v0, 4        # system call for printing string = 4   
la $a0, enter1msg  
syscall             

##Reading and storing number1 to $t0
li $v0, 5       # system call for reading integer = 5           
syscall 
move $t0, $v0   #the same as addi $t0, $v0, 0  
    

##Print the string asking the operation symbol                    
li $v0, 4        # system call for printing string = 4   
la $a0, enterOperMsg  
syscall            

##Reading the operation symbol and store it in $t2
li $v0,8        # system call for reading string = 8
la $a0,operation
syscall 
lb $t2, operation    #load only the 1st byte of the string (which is the operation symbol) to the $t2.     

##Print the string asking the 2nd number                  
li $v0, 4        # system call for printing string = 4   
la $a0, enter2msg  
syscall             

##Reading and storing number2 to $t1
li $v0, 5        # system call for reading integer = 5          
syscall 
move $t1, $v0   #the same as addi $t1, $v0, 0        

##Check if we have an addition
li $s1, 0x0000002B
beq $t2, $s1, op_add

##Check if we have a subtraction
li $s1, 0x0000002D
beq $t2, $s1, op_sub

##Check if we have a multiplication
li $s1, 0x0000002A
beq $t2, $s1, op_mul

##Check if we have a division
li $s1, 0x0000002F
beq $t2, $s1, op_div

##If we have reached here, we had an unknown operation
li $v0, 4           # system call for printing string = 4
la $a0, unknown_oper 
syscall
j exit

op_add:  
    add $t3, $t0, $t1
    j print_Result
op_sub:
    sub $t3, $t0, $t1
    j print_Result
op_mul:
    mul $t3, $t0, $t1
    j print_Result
op_div:
    ##Check for division by zero
    li $t3, 0
    beq $t3, $t1, divWithZero

    div $t0, $t1
    mfhi $t4    # remainder to $t4
    mflo $t3    # quotient to $t3
 
    j print_Result_division

print_Result:
    li $v0, 4       # system call for printing string = 4    
    la $a0, resultMsg  
    syscall 

    li $v0, 1       # system call for printing integer = 1
    move $a0, $t3        
    syscall 
    j exit

print_Result_division:
    li $v0, 4       # system call for printing string = 4    
    la $a0, resultMsg  
    syscall 
    
    li $v0, 4       # system call for printing string = 4
    la $a0, quotientMsg
    syscall

    li $v0, 1       # system call for printing integer = 1
    move $a0, $t3
    syscall
    

    li $v0,4        # system call for printing string = 4
    la $a0, remainderMsg
    syscall

    li $v0, 1       # system call for printing integer = 1
    move $a0, $t4
    syscall

    j exit

divWithZero:
    li $v0, 4        # system call for printing string = 4   
    la $a0, divZeroMsg 
    syscall 

    j exit

exit:
    li $v0, 10          #terminate program
    syscall
