module hazard
#(parameter BITS = 32)
(clk, instr, br, stop_o, hz_instr_o);
    input             clk;
    input      [31:0] instr;
    input             br;
    output            stop_o;
    output     [31:0] hz_instr_o;

    wire [31:0] rd1;
    wire [31:0] rd2;
    wire [31:0] wr1;
    wire [31:0] wr2;
    reg  [31:0] wr3;
    wire [31:0] prd1;
    wire [31:0] prd2;
    wire        halt1;
    wire        halt2;
    wire        halt_p;
    wire        stop;
    reg         br2;

    reg  [31:0] prev;
    reg  [31:0] prev2;
    reg   [2:0] count;

    initial begin
        prev  <= 'b0;
        count <= 'b0;
        wr3   <= 'b0;
        br2   <= 'b0;
    end

    always @(posedge clk) begin
        wr3   <= wr2;
        prev  <= br | br2   ? 32'b0 : 
                 count > 0 ? prev  : instr;
        count <= (halt1 && count == 0) ? 'd2 : 
                 (halt2 && count == 0) ? 'd1 : 
                 count                 ? count - 1 : 'b0;
        br2   <= br;
    end

    assign wr2 =  (count == 0) ? 
                  (prev[6:0]  == 7'b0110111 |   // LUI
                   prev[6:0]  == 7'b0010111 |   // AUIPC
                   prev[6:0]  == 7'b1101111 |   // JAL
                   prev[6:0]  == 7'b1100111 |   // JALR
                   prev[6:0]  == 7'b0000011 |   // LOAD
                   prev[6:0]  == 7'b0010011 |   // ALU Imm
                   prev[6:0]  == 7'b0110011 |   // ALU R-R
                   prev[6:0]  == 7'b0001111) ?  // FENCE
                                 ('b1 << prev[11:7])  & 'hFFFFFFFE : 'b0 : 'b0; 

    assign rd1  = (instr[6:0] == 7'b1100111 |   // JALR
                   instr[6:0] == 7'b1100011 |   // BRANCH
                   instr[6:0] == 7'b0000011 |   // LOAD
                   instr[6:0] == 7'b0100011 |   // STORE
                   instr[6:0] == 7'b0010011 |   // ALU Imm
                   instr[6:0] == 7'b0110011 |   // ALU R-R
                   instr[6:0] == 7'b0001111) ?  // FENCE
                                 ('b1 << instr[19:15]) & 'hFFFFFFFE : 'b0;

    assign prd1 =  (prev[6:0] == 7'b1100111 |   // JALR
                    prev[6:0] == 7'b1100011 |   // BRANCH
                    prev[6:0] == 7'b0000011 |   // LOAD
                    prev[6:0] == 7'b0100011 |   // STORE
                    prev[6:0] == 7'b0010011 |   // ALU Imm
                    prev[6:0] == 7'b0110011 |   // ALU R-R
                    prev[6:0] == 7'b0001111) ?  // FENCE
                                 ('b1 << prev[19:15]) & 'hFFFFFFFE : 'b0; 

    assign rd2  = (instr[6:0] == 7'b1100011 |   // BRANCH
                   instr[6:0] == 7'b0100011 |   // STORE
                   instr[6:0] == 7'b0110011) ?  // ALU R-R
                                 ('b1 << instr[24:20]) & 'hFFFFFFFE : 'b0; 

    assign prd2 = (prev[6:0]  == 7'b1100011 |   // BRANCH
                   prev[6:0]  == 7'b0100011 |   // STORE
                   prev[6:0]  == 7'b0110011) ?  // ALU R-R
                                 ('b1 << prev[24:20]) & 'hFFFFFFFE : 'b0;



    assign halt1      = (rd1 | rd2) & (wr2) ? 1 : 0;
    assign halt2      = (rd1 | rd2) & (wr3) ? 1 : 0;
    assign stop       = (halt1 | halt2 | (count != 0));
    assign stop_o     = (halt1 | (halt2 & (count != 1)));
    assign hz_instr_o = (br | br2)          ? 32'b0 : 
                        count > 0           ? hz_instr_o : prev;


endmodule
