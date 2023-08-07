module controller
(
    input wire clock,
    input wire[31:0] instrd,instrx,instrm,instrw,
    output reg pc_sel,
    output reg [3:0]imm_sel,
    output reg br_un,
    input wire br_eq,
    input wire br_lt,
    output reg a_sel,
    output reg b_sel,
    output reg reg_wen,
    output reg [3:0] alu_sel,
    output reg [1:0] wb_sel,
    output reg mem_we,
    output reg[4:0] addr_rd
);


always @(*) begin

    case (instrx[6:0])
        'b1100011: begin
            case (instrx[14:12])
                0:pc_sel = br_eq;
                1:pc_sel = ~br_eq;
                4,6:pc_sel = br_lt;
                5,7:pc_sel = ~br_lt;
            endcase
        end
        'b1101111,'b1100111:
            pc_sel = 1;
        default:
            pc_sel = 0;
    endcase

    case (instrx[6:0])

        'b0110011:begin
            a_sel = 0;
            b_sel = 0;
            alu_sel = {instrx[30],instrx[14:12]}; 
            imm_sel= 0;
        end
        //imm arithmetic instructions
        'b0010011: begin
            a_sel = 0;
            b_sel = 1;
            alu_sel = {instrx[14:12]==5? instrx[30]:1'b0,instrx[14:12]};//srli vs srai
            imm_sel = instrx[14:12] ==5 ? 6: 1;
        end
        //conditional branch instructions
        'b1100011: begin
            br_un = instrx[13];
            a_sel = 1;
            b_sel = 1;
            imm_sel = 3;
            alu_sel = 0;
        end
        //unconditional jump
        'b1101111,'b1100111: begin
            a_sel = instrx[3];
            b_sel = 1;
            imm_sel = instrx[3]? 5:1;
            alu_sel = 0;
        end
        // auipc
        'b0010111: begin
            a_sel = 1;
            b_sel = 1;
            imm_sel = 4;
            alu_sel = 0;
        end
        // lui
        'b0110111: begin
            imm_sel = 4;
            a_sel = 0;
            b_sel = 1;
            alu_sel = 0;
        end
        //load
        'b0000011: begin 
            imm_sel = 1;
            a_sel = 0;
            b_sel = 1;
            alu_sel = 0;
        end
        //store
        'b0100011: begin 
            imm_sel = 2;
            a_sel = 0;
            b_sel = 1;
            alu_sel = 0;
        end
        default: begin
            imm_sel = 0;
        end

    endcase

    //only store writes to mem
    mem_we = (instrm[6:0] == 'b0100011) ? 1: 0;

    
    case (instrm[6:0]) 
        'b1101111,'b1100111:
            wb_sel = 2;
        'b0000011:
            wb_sel = 0;
        default:
            wb_sel = 1;
    endcase
    
    addr_rd = instrw[11:7];
    //everything but nop store and branch write to reg
    reg_wen = (instrw[6:0] == 0 || instrw[5:0] == 'b100011) ? 0 :1;

   /* 
    if (opcode>0)
        $display("->a %b b %b opcode %b imm_sel %d",a_sel,b_sel,opcode,imm_sel);
        */
    
end

endmodule