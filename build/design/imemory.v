module imemory(
  input             clock,
  input  [31:0]      address,
  input  [31:0]      data_in,
  output [31:0] data_out,
  // output reg[31:0] data_out,
  input             read_write
);
    wire[31:0]      address_2;
    wire[31:0]      data_in_2;
    wire            read_write_2;
    localparam START_ADDR = 32'h01000000;

    (* ram_style = "block" *) reg[31:0] mem[0:`MEM_DEPTH / 4 - 1];
    //  array   vectors

    initial begin
        $readmemh(`MEM_PATH, mem);
    end
    wire[$clog2(`MEM_DEPTH) - 2:0] ea;
    wire[$clog2(`MEM_DEPTH) - 2:0] ea_2;

    assign ea   = (address   - START_ADDR) >> 2;
    assign ea_2 = (address_2 - START_ADDR) >> 2;

    assign data_out = mem[ea];
    // always @(posedge clock) begin
    //   data_out <= mem[ea];
    // end

    always @(posedge clock) begin
      if (read_write_2 == 1) begin
          mem[ea_2] <= data_in_2;
      end

    end
endmodule
