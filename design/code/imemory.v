module imemory(
    input wire clock,
    input wire [31:0] address,
    input wire [31:0] data_in,
    output reg [31:0] data_out,
    input wire read_write
);

reg [31:0] temp[`LINE_COUNT:0];
reg [7:0] memory[`MEM_DEPTH:0];


initial $readmemh(`MEM_PATH,temp);
initial begin
    integer i;
    for (i = 0;i<`LINE_COUNT;i=i+1) begin
        memory[4*i] = temp[i][7:0];
        memory[4*i+1] = temp[i][15:8];
        memory[4*i+2] = temp[i][23:16];
        memory[4*i+3] = temp[i][31:24];
    end
end

always @(posedge clock) begin
    if (read_write) begin //write
        memory[address] <= data_in[7:0];
        memory[address+1] <= data_in[15:8];
        memory[address+2] <= data_in[23:16];
        memory[address+3] <= data_in[31:24];
    end
    data_out = {memory[address+3],memory[address+2],memory[address+1],memory[address]};
    //$display("time=%0t address=%h data_in=%h data_out=%h",$time,address,data_in,data_out);
end

endmodule;