//Bubble sort
MOV R0,data
MOV R1,#9 //LENGTH-1
MOV R2,#0 //R2=i
MOV R3,#0 //R3=j
MOV R4,#0 //R4=temp
//R7 for memaddr

Loop_j:
    CMP R1,R3
    BLE Loop_j_end

    MOV R2,#0
    Loop_i:
        CMP R1,R2
        BLE Loop_i_end

        ADD R7,R0,R2
        LDR R5,[R7]//R5=data[i]
        LDR R6,[R7,#1]//R6=data[i+1]
        CMP R5,R6
        BLE If_end

        MOV R4,R5
        MOV R5,R6
        MOV R6,R4
        STR R5,[R7]
        STR R6,[R7,#1]
        If_end:
        MOV R7,#1
        ADD R2,R2,R7
        B Loop_i
    Loop_i_end:
    MOV R7,#1
    ADD R3,R3,R7
    B Loop_j
Loop_j_end:
HALT

data:
    .word 23
    .word 1145
    .word 342
    .word -2
    .word 32767
    .word 2012
    .word 7
    .word 12
    .word -32768
    .word -253

