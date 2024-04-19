# KaiserLake
### A pipelined, superscalar processor with UBC CPEN211 Simple-Risc-Machine ISA
### 使用UBC CPEN211 Simple-Risc-Machine指令集的超标量流水线CPU（顺序双发射）

## Features

- Five-stage pipeline with comprehensive hazard control
- Synthesizable on Quartus with Cyclone-V FPGA
- Build-in branch prediction support, default static branch predictor
- Superscaler design, issue **two instructions** per cycle
- Separate Instruction-Memory and Data-Memory to resolve conflict and minimize bubbles


## Instruction Set Architecture

>Note: The purpose of this project is to explore modern processor designs. 
>If you are still taking [CPEN211](https://ece.ubc.ca/courses/cpen-211/), this project is **not helpful** for you.
>**Do not** use code in this project as part of your course submission. 
> Content in this project my not contain what you are expected to submit,
> also it may not pass the course autograder (compatibility issues).

SRM ISA has 17 instructions for data processing, memory operation and branch control. 
Detailed encodings are listed below:
![图片](https://github.com/wele0612/Kaiserlake/assets/59970710/93c4b90d-7a83-4e59-8bcf-eed6a5bfa87d)
![图片](https://github.com/wele0612/Kaiserlake/assets/59970710/137a9f23-016f-4948-a824-ff8b599dadf4)


> Note: ISA tables are referenced from the course material, they are **not** part of this open-source project. 

## Build

KaiserLake is developed with `Quartus Prime 18.1` and `ModelSim 10.5b`. 

KaiserLake is tested with Cyclone-V FPGA on DE1-SoC. Other Verilog software tools and FPGAs may also work, but you may have to modify the top module and pin assignments.

#### Build process
1. Add all .sv files to your project. 
2. Use `KaiserLake_top` as your top module.
3. Create or modify `data.txt` to initialize system RAM.

## Memories

To minimize read/write comflict, KaiserLake has separate I.M. and D.M.  for the CPU.

SRM ISA requires 16bit memory data bitwidth and 9bit address space.
The memory mapping are shown below:
| Address | Function | Note |
| ------ | ------ | ------ |
| `0x000~0x0ff` | Internal RAM  | Initialize with data.txt |
| `0x100~0x1ff` |Peripherals | Access via LDR and STR |

When compiled, both I.M. and D.M. will be initialzed with `data.txt`.
System reset will reset the program counter to `0x00` and your program will start from there.
**I.M. will stay unchanged while the CPU is running. All `LDR`/`STR` instructions are directed to D.M.**

You may add your custom Peripherals to the bus. 
**Important:** consecutive memory access are not guaranteed volatile. If volatile behavior is essential, insert at least one other instruction (such as NOP) between two `LDR`/`STR`.
