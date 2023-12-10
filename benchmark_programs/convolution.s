MOV R6,#0
MVN R6,R6 //SP, stack grow down from top
MOV R4,#0 //R4=temp
MOV R5,#0 //R5=i
While1_begin:
    MOV R4,length
    LDR R4,[R4]
    CMP R4,R5
    BLE While1_end

    MOV R3,#0 //R3=j
    While2_begin:

        MOV R4,length
        LDR R4,[R4]
        CMP R4,R3

        BLE While2_end
        MOV R0,arr_a
        MOV R1,arr_b
        ADD R0,R0,R5//a+i
        ADD R1,R1,R3//b+j
        LDR R0,[R0]
        LDR R1,[R1]
        BL Multiply
        MOV R1,result
        ADD R1,R1,R5
        ADD R1,R1,R3//R1=result[i+j]
        LDR R4,[R1]
        ADD R4,R0,R4
        STR R4,[R1]

        MOV R4,#1
        ADD R3,R3,R4
        B While2_begin
    While2_end:
    MOV R4,#1
    ADD R5,R5,R4
    B While1_begin

While1_end:
    HALT


Multiply://param: R0=a, R1=b Return: a*b
    STR R2,[R6,#-1]
    STR R3,[R6,#-2]
    STR R4,[R6,#-3]
    STR R5,[R6,#-4]
    MOV R5,#-4
    ADD R6,R6,R5 //push [R2-R5]

    //R0 ans
    //R1 a
    //R2 b
    //R3 j
    //R4 #16
    //R5 bit
    MOV R2,R0
    MOV R0,#0
    MOV R3,#0
    MOV R4,#8
    ADD R4,R4,R4//R4=16
    MOV R5,#1
    while_begin:
    CMP R4,R3
    BLE while_end //end while if 16>=j
    STR R4,[R6,#-1]
    STR R3,[R6,#-2]
    AND R4,R5,R2 //R4(temp)=bit&b
    MOV R3,#0
    CMP R3,R4

    BEQ if_not //R4==0
    ADD R0,R0,R1
    if_not:
    MOV R1,R1,LSL#1
    MOV R5,R5,LSL#1

    LDR R3,[R6,#-2] 
    MOV R4,#1
    ADD R3,R3,R4
    LDR R4,[R6,#-1]
    B while_begin
    
    while_end:

    MOV R5,#4
    ADD R6,R6,R5
    LDR R2,[R6,#-1]
    LDR R3,[R6,#-2]
    LDR R4,[R6,#-3]
    LDR R5,[R6,#-4]//pop [R2-R5]
    BX R7

length:
    .word 5

arr_a:
    .word 1
    .word -2
    .word 3
    .word -4
    .word 5

arr_b:
    .word 3
    .word -4
    .word 5
    .word -6
    .word 7

result:
    .word 0
    