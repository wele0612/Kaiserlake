//Calculate 3x3 determinat
//|0 1 2|
//|3 4 5|
//|6 7 8| (index)

    //|3  -6 -7|
    //|4   1  3|
    //|-1  8  4|

MOV R6,stack
MOV R4,#0 //R4=ans
MOV R5,matrix

//det=0*(4*8-7*5)+1*(6*5-3*8)+2*(3*7-4*6)
//=> 0*4*8 + 1*5*6 + 2*3*7 - 2*4*6 - 0*5*7 - 1*3*8
LDR R0,[R5,#2]
LDR R1,[R5,#4]
BL Multiply
LDR R1,[R5,#6]
BL Multiply
ADD R4,R4,R0

LDR R0,[R5,#0]
LDR R1,[R5,#5]
BL Multiply
LDR R1,[R5,#7]
BL Multiply
ADD R4,R4,R0

LDR R0,[R5,#1]
LDR R1,[R5,#3]
BL Multiply
LDR R1,[R5,#8]
BL Multiply
ADD R4,R4,R0

MVN R4,R4
MOV R0,#1
ADD R4,R4,R0 //R4=-R4

LDR R0,[R5,#0]
LDR R1,[R5,#4]
BL Multiply
LDR R1,[R5,#8]
BL Multiply
ADD R4,R4,R0

LDR R0,[R5,#1]
LDR R1,[R5,#5]
BL Multiply
LDR R1,[R5,#6]
BL Multiply
ADD R4,R4,R0

LDR R0,[R5,#2]
LDR R1,[R5,#3]
BL Multiply
LDR R1,[R5,#7]
BL Multiply
ADD R4,R4,R0

MOV R0,R4
HALT




Multiply://param: R0=a, R1=b Return: a*b
    STR R2,[R6,#1]
    STR R3,[R6,#2]
    STR R4,[R6,#3]
    STR R5,[R6,#4]
    MOV R5,#4
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
    STR R4,[R6,#1]
    STR R3,[R6,#2]
    AND R4,R5,R2 //R4(temp)=bit&b
    MOV R3,#0
    CMP R3,R4

    BEQ if_not //R4==0
    ADD R0,R0,R1
    if_not:
    MOV R1,R1,LSL#1
    MOV R5,R5,LSL#1

    LDR R3,[R6,#2] 
    MOV R4,#1
    ADD R3,R3,R4
    LDR R4,[R6,#1]
    B while_begin
    
    while_end:

    MOV R5,#-4
    ADD R6,R6,R5
    LDR R2,[R6,#1]
    LDR R3,[R6,#2]
    LDR R4,[R6,#3]
    LDR R5,[R6,#4]//pop [R2-R5]
    BX R7

matrix:
    .word 3
    .word -6
    .word -7
    .word 4
    .word 1
    .word 3
    .word -1
    .word 8
    .word 4
    //|3  -6 -7|
    //|4   1  3|
    //|-1  8  4|

stack:
    .word 0



