module dmemory(
    input wire clock,
    input wire read_write,
    input wire [31:0] address,
    input wire[1:0] access_size,
    input wire [31:0] data_in,
    output reg [31:0] data_out
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
        if (access_size>0)begin
            memory[address+1] <= data_in[15:8];
            if (access_size>1)begin
                memory[address+2] <= data_in[23:16];
                memory[address+3] <= data_in[31:24];
            end
        end
    end
    if (access_size>1)
        data_out = {memory[address+3],memory[address+2],memory[address+1],memory[address]};
    else if (access_size>0)
        data_out = {{16{1'b0}}, memory[address+1],memory[address]};
    else
        data_out = {{24{1'b0}}, memory[address]};

end


endmodule