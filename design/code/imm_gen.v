module imm_gen(
  input [24:0] instr,
  input [3:0] immsel,
  output reg signed[31:0] imm 
);
//RISBUJ in order is 0 - 5

always @(*) begin
    case (immsel)
        0: imm = 32'b0;
        1: imm = {{20{instr[24]}},instr[24:13]};
        2: imm = {{20{instr[24]}},instr[24:18],instr[4:0]};
        3: imm = {{19{instr[24]}},instr[24],instr[0],instr[23:18],instr[4:1],1'b0};
        4: imm = {instr[24:5],12'b0};
        5: imm = {{11{instr[24]}},instr[24],instr[12:5],instr[13],instr[23:14],1'b0};
        6: imm = {{27{instr[24]}},instr[17:13]};//includes shamt
    endcase
end

endmodule