module pd(
  input clock,
  input reset
);

reg [31:0] pc, pc_d, pc_x,pc_m, pc_w;
wire [31:0] instr;
reg [31:0] instrd, instrx, instrm, instrw;

wire [31:0] imm;
reg [31:0]data_rd;
wire [31:0]data_rs1,data_rs2;

wire reg_write;
reg [31:0]alu_out;
wire [3:0]alu_sel;
wire a_sel;
wire b_sel;
wire pc_sel;
wire mem_we;
wire [3:0]imm_sel;
wire br_un;
reg brlt;
reg breq;
wire [1:0] wb_sel;
wire [31:0] mem_out;

wire [4:0]addr_rs1;
wire [4:0]addr_rs2;
wire [4:0]addr_rd;

reg [4:0]addr_rs1x;
reg [4:0]addr_rs2x;

reg [2:0] stall_point;
reg [31:0] mem_datain;

assign addr_rs1 = instrd[6:0] == 'b0110111 ? 0 : instrd[19:15]; // uses 0 reg for lui
assign addr_rs2 = instrd[24:20];


always @(posedge clock or posedge reset) begin
    if (reset)
        pc <= 32'h01000000;
    else begin
        pc <= stall_point>0? pc: pc_sel? alu_out: pc +4;
    end

end

reg [31:0] data_in;

imemory mem_1(
  .clock(clock),
  .address(pc),
  .data_in(data_in),
  .data_out(instr),
  .read_write(0)
);

controller c(
  .clock(clock),
  .instrd(instrd),
  .instrx(instrx),
  .instrm(instrm),
  .instrw(instrw),
  .pc_sel(pc_sel),
  .imm_sel(imm_sel),
  .br_un(br_un),
  .br_eq(breq),
  .br_lt(brlt),
  .a_sel(a_sel),
  .b_sel(b_sel),
  .reg_wen(reg_write),
  .alu_sel(alu_sel),
  .wb_sel(wb_sel),
  .mem_we(mem_we),
  .addr_rd(addr_rd)
);

register_file r(
  .clock(clock),
  .addr_rd(addr_rd),
  .addr_rs1(addr_rs1),
  .addr_rs2(addr_rs2),
  .data_rs1(data_rs1),
  .data_rs2(data_rs2),
  .data_rd(data_rd),
  .write_enable(reg_write)
);

imm_gen i(
  .instr(instrx[31:7]),
  .immsel(imm_sel),
  .imm(imm)
);

reg signed [31:0]data_rs1_s;
reg signed [31:0]data_rs2_s;
reg signed [31:0]alua_s;
reg signed [31:0]alub_s;
reg [31:0]alua;
reg [31:0]alub;
reg [31:0]rs1_m;
reg [31:0]rs2_m;
reg [31:0]rs1_x;
reg [31:0]rs2_x;
reg [31:0]rs1_d;
reg [31:0]rs2_d;
reg [31:0]wb_out;

reg[31:0] instrs[3:0];
reg[31:0] sign_extended_imm;

wire[4:0] read1[3:0];
wire[4:0] read2[3:0];
wire[4:0] write[3:0];

genvar j;
generate
  for (j=0;j<4;j=j+1) begin
    dep_checker dep(instrs[j],read1[j],read2[j],write[j]);
  end
endgenerate


always @(*) begin
  //forwarding

    //mx
    instrs[0] = instrd;
    instrs[1] = instrx;
    instrs[2] = instrm;
    instrs[3] = instrw;


    // forward into alua
    if (instrm[11:7] != 'b0000011 && write[2]!=0 && write[2] == read1[1])
      rs1_x = rs1_m;
    else if (write[3] !=0 && write[3] == read1[1])
      rs1_x = data_rd;
    else
      rs1_x =  rs1_d;

    // forward into alub
    if (instrm[11:7] != 'b0000011 && write[2]!=0 && write[2] == read2[1])
      rs2_x = rs1_m;
    else if (write[3] !=0 && write[3] == read2[1])
      rs2_x = data_rd;
    else
      rs2_x = rs2_d;

    if (instrm[6:0] == 'b0100011 && write[3]!=0 && read2[2] == write[3])
      mem_datain = data_rd;
    else
      mem_datain = rs2_m;

    alua = a_sel? pc_x : rs1_x;
    alub = b_sel? imm : rs2_x;
    // stalls

    //do write after write

    alua_s = alua;
    alub_s = alub;
    data_rs1_s = rs1_x;
    data_rs2_s = rs2_x;

    stall_point = 0;

    //stalls
    //1 is fetch
    //2 is decode
    //3 is execute
    //dependencies
    // 3 is at writeback
    // 2 is at mem
    // 1 is at ex
    // 0 is decode

    // dx 
    // if some of the write outputs are the same then it means it doesn't need to stall
    // because the value will be overwritten and then bypassed
    if (write[3]!=0 && write[1] != write[3] && write[2] != write[3]&& 
        (write[3] == read1[0] ||  write[3] == read2[0]))
      if (instrx[6:5] == 'b11)
        stall_point = 3;
      else
        stall_point = 2;
      
    //second reg of store never needs to be stalled for
    if ((instrm[6:0] == 'b0000011) 
        && (write[2] == read1[1] || (instrx[6:0]!='b11 && write[2] == read2[1])))
      stall_point = 3;


    // mx


  //branch comparison block
  breq = rs1_x == rs2_x;

  if (br_un)
    brlt = rs1_x < rs2_x;
  else
    brlt = data_rs1_s < data_rs2_s;

  
  //alu
  case (alu_sel[2:0])
    0: alu_out = alu_sel[3]? alua- alub : alua + alub;
    1: alu_out = alua << alub[4:0];
    2: alu_out = {31'b0,alua_s < alub_s};
    3: alu_out = {31'b0,alua < alub};
    4: alu_out = alua ^ alub;
    5: alu_out = alu_sel[3] ? (alua_s >>> alub[4:0]) : alua_s >> alub_s[4:0];
    6: alu_out = alua | alub;
    7: alu_out = alua & alub;
  endcase


    if (instrm[13:12]>1)
        sign_extended_imm = mem_out;
    else if (instrm[13:12]>0)
        sign_extended_imm = {instrm[14]? {16{1'b0}}: {16{mem_out[15]}}, mem_out[15:0]};
    else
        sign_extended_imm = {instrm[14]? {24{1'b0}}: {24{mem_out[7]}}, mem_out[7:0]};
  
  //writeback
  case (wb_sel)
    0: wb_out = sign_extended_imm;
    1: wb_out = rs1_m;
    2: wb_out = pc_m+4;
    default: wb_out = rs1_m;
  endcase
end

always @(posedge clock) begin

  if (stall_point<2) begin
    instrd<= (pc_sel || stall_point==1)?'h13:instr;
    pc_d <= pc_sel||stall_point==1?0:pc;
  end else begin
    instrd <= instrd;
    pc_d <= pc_d;
  end

  if (stall_point<3) begin
    instrx<= pc_sel||stall_point==2?'h13:instrd;
    pc_x <=  pc_sel||stall_point==2?0:pc_d;
    rs1_d <= data_rs1;
    rs2_d <= data_rs2;
  end else begin
    instrx <= instrx;
    pc_x <= pc_x;
    rs1_d <= rs1_x;
    rs2_d <= rs2_x;
  end
  
  if (stall_point<4) begin
    instrm<= stall_point==3?'h13:instrx;
    pc_m <=  stall_point==3?0:pc_x;
    rs1_m <= alu_out;
    rs2_m <= rs2_x;
  end else begin
    instrm <= instrm;
    pc_m <= pc_m;
    rs1_m <= rs1_m;
    rs2_m <= mem_datain;
  end

  if (stall_point<5) begin
    instrw <= stall_point==4?'h13:instrm;
    pc_w <= stall_point==4?0:pc_m;
    data_rd <= wb_out;
  end else begin
    instrw <= instrw;
    pc_w <= pc_w;
    data_rd <= data_rd;
  end

  //$display("%x,%x,%x,%x,%x",pc,pc_d,pc_x,pc_m,pc_w);
  if (instrw == 'h73)
    $finish();

end

dmemory dm(
  .clock(clock),
  .read_write(mem_we),
  .address(rs1_m),
  .access_size(instrm[13:12]),
  .data_in(mem_datain),
  .data_out(mem_out)
);

endmodule
