module dep_checker(
    input wire[31:0] instr,
    output reg[4:0] read1, read2, write
);

always @(*) begin
    if (instr[5:0] == 'b100011)
        write = 0;
    else 
        write = instr[11:7];

    if (instr[4:0] == 'b10111 || instr[4:0] == 'b01111)
        read1 = 0;
    else
        read1 = instr[19:15];

    if (instr[5:0] == 'b100011 || instr[5:0] == 'b110011)
        read2 = instr[24:20];
    else 
        read2 = 0;

end
endmodule