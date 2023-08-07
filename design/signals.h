/* Your Code Below! Enable the following define's
 * and replace ??? with actual wires */
// ----- signals -----
// You will also need to define PC properly
`define F_PC                pc
`define F_INSN              instr

`define D_PC                pc_d
`define D_OPCODE            instrd[6:0]
`define D_RD                instrd[11:7]
`define D_RS1               addr_rs1
`define D_RS2               addr_rs2
`define D_FUNCT3            instrd[14:12]
`define D_FUNCT7            instrd[31:25]
`define D_IMM               imm
`define D_SHAMT             imm[4:0]

`define R_WRITE_ENABLE      reg_enable
`define R_WRITE_DESTINATION addr_rd
`define R_WRITE_DATA        data_rd
`define R_READ_RS1          addr_rs1
`define R_READ_RS2          addr_rs2
`define R_READ_RS1_DATA     data_rs1
`define R_READ_RS2_DATA     data_rs2

`define E_PC                pc_x
`define E_ALU_RES           alu_out
`define E_BR_TAKEN          c.pc_sel

`define M_PC                pc_m
`define M_ADDRESS           rs1_m
`define M_RW                mem_we
`define M_SIZE_ENCODED      instrm[13:12]
`define M_DATA              mem_out

`define W_PC                pc_w
`define W_ENABLE            reg_write
`define W_DESTINATION       addr_rd
`define W_DATA              data_rd


`define IMEMORY             mem_1
`define DMEMORY             dm

// ----- signals -----

// ----- design -----
`define TOP_MODULE                 pd
// ----- design -----
