module register_file
#(parameter WIDTH=32)
(
    input wire clock,
    input wire [4:0] addr_rs1,
    input wire [4:0] addr_rs2,
    input wire [4:0] addr_rd,
    input wire [31:0] data_rd,
    output reg [31:0] data_rs1,
    output reg [31:0] data_rs2,
    input wire write_enable
);

(* ram_style = "block" *)reg [31:0] registers [WIDTH-1:0];

initial begin: reg_init
    integer i;
    for (i=0;i<WIDTH;i=i +1) begin
        if (i ==2)
            registers[i] = `MEM_DEPTH + 32'h01000000;
        else
            registers[i] = 32'b0;
    end
end

always @(posedge clock) begin
    if (write_enable && addr_rd != 0)
        registers[addr_rd] <= data_rd;
    data_rs1 = registers[addr_rs1];
    data_rs2 = registers[addr_rs2];
    //$display("->data_rd: %h addr_rd: %h we: %b",data_rd,addr_rd,write_enable);
    //$display("data_rs1: %h addr_rs1: %h",data_rs1,addr_rs1);
end


endmodule