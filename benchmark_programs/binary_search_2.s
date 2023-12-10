//二分查找算法
binary_search:
    MOV R0, data            // 将数组地址加载到R0
    MOV R1, #0              // 设置数组起始索引
    MOV R2, #20              // 设置数组结束索引
    MOV R3, find              // 设置要查找的目标值
    LDR R3, [R3]
    MOV R4, #0              // 中间引索
    MOV R5, #0              // 找到了吗？
    MOV R6, #0              // 用R3作为加减法临时的寄存器

binary_search_loop:
    CMP R2, R1              // 检查起始索引是否小于等于结束索引
    BLT binary_search_not_found // 如果不是，则结束查找

    ADD R4, R1, R2        // 计算 中间索引: (起始索引 + 结束索引) / 2
    MOV R6, #0
    ADD R4, R6, R4, LSR#1

    ADD R7, R4, R0      //计算中间元素的地址
    LDR R6, [R7]        // 加载中间元素到R6

    CMP R6, R3              // 比较中间元素和目标值
    BEQ binary_search_found // 如果相等，则找到目标值
    BLT binary_search_lower // 如果小于目标值，则在右半部分继续查找

    // 否则，在左半部分继续查找
    MOV R6, #-1
    ADD R2, R4, R6          // 设置结束索引为中间索引 - 1

    B binary_search_loop

binary_search_lower:
    MOV R1, R4              // 设置起始索引为中间索引 + 1
    MOV R6, #1
    ADD R1, R1, R6

    B binary_search_loop

binary_search_found:
    MOV R6, R4              // 存储目标值的索引到R6
    MOV R5 ,#1

    HALT

binary_search_not_found:
    // 没有找到目标值的处理
    MOV R5 ,#0
    HALT

data: 
    .word -27434
    .word -2444
    .word -1278
    .word -999
    .word -813
    .word -800
    .word -739
    .word -732
    .word -123
    .word 12
    .word 28
    .word 31
    .word 53
    .word 62
    .word 927
    .word 1043
    .word 1056
    .word 2057
    .word 4986
    .word 4999
    .word 10000

find:
    .word 10000