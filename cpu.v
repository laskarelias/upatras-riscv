module cpu2
#(parameter BITS = 32)
(clk);

    input clk;
    
    reg  [BITS-1:0] pc;        // Program Counter / imem Address
    reg  [BITS-1:0] pc_if;     // PC on IF
    reg  [BITS-1:0] pc_id;     // PC on ID - for AUIPC
    reg  [BITS-1:0] pc_ex;     // PC on EX - for BRANCH
    reg  [BITS-1:0] pc_mem;    // PC on EX - for BRANCH
    reg  [BITS-1:0] pc_wb;     // PC on EX - for BRANCH
    
    wire [31:0] instr;
    reg  [31:0] p_if;      // Pipeline - after IF  register - stage 2 result
    reg  [31:0] p_id;      // Pipeline - after ID  register - stage 2 result
    reg  [31:0] p_ex;      // Pipeline - after EX  register - stage 3 result
    reg  [31:0] p_mem;     // Pipeline - after MEM register - stage 4 result
    reg  [31:0] p_wb;

    wire [31:0] hz_in;
    
    reg  [BITS-1:0] res_wb;     // carry ALU res to write on wb stage
    reg  [BITS-1:0] rs2_dmem0;  // carry contents of rs2 to store on dmem;
    reg  [BITS-1:0] rs2_dmem1;  // carry contents of rs2 to store on dmem;
    
    wire            br;         // branch enable;
    reg             clr;        // clear pipeline regs;
    wire            hz;

    //wire            hz_if;         // halt because of hazard
    //wire            hz_id;         // halt because of hazard
    //wire            hz_ex;         // halt because of hazard
    //wire            hz_mem;        // halt because of hazard
    //wire            hz_wb;         // halt because of hazard
    
    wire [BITS-1:0] a_rf;
    wire [BITS-1:0] b_rf;
    
    wire [BITS-1:0] imm;
    wire            imm_en;
    
    wire [BITS-1:0] a;
    wire [BITS-1:0] b;
    wire [BITS-1:0] res;
    
    wire [BITS-1:0] adw_dmem;
    wire [BITS-1:0] rs_dmem;
 
    wire            rf_we;
    wire [BITS-1:0] rf_wb;

    mem #(.BITS(BITS)) imem(clk, pc, 1'b0, 3'b010, instr);
    defparam imem.file = "instr.mem";


    hazard haz(clk, instr, br, hz, hz_in);

    regfile #(.BITS(BITS)) rf(
        .clk(clk),
        .ad1(hz_in[19:15]), // rs1 field
        .ad2(hz_in[24:20]), // rs2 field
        .adw(p_mem[11:7]),   // rd  field
        .we(rf_we),         // control logic
        .rs1(a_rf),         // rs1 data
        .rs2(b_rf),         // rs2 data
        .rsw(rf_wb)         // write-back from Data mem or ALU res
    ); 

    immgen #(.BITS(BITS)) ig(clk, hz_in, imm_en, imm);
        
    assign a = (p_id[6:0] == 7'b0010111) ||  // AUIPC
               (p_id[6:0] == 7'b1101111) ||  // JAL
               (p_id[6:0] == 7'b1100111) ||  // JALR
               (p_id[6:0] == 7'b1100011) ? pc_ex : a_rf;  // BRANCH
    assign b = imm_en ? imm : b_rf;

    branch #(.BITS(BITS)) brn(clk, p_id, a_rf, b_rf, br); 
    alu #(.BITS(BITS)) alu(clk, p_id, a, b, res);

    mem #(.BITS(BITS)) dmem(clk, res, dmem_we, p_ex[14:12], rs_dmem);
    defparam dmem.file = "data.mem";  

    assign dmem_we = p_ex[6:0] == 7'b0100011;
    assign rs_dmem = (dmem_we) ? rs2_dmem0 : 32'bz;

    assign rf_we = (p_mem[6:0] == 7'b0000011) || // LOAD
                   (p_mem[6:0] == 7'b0010011) || // ALU IMM
                   (p_mem[6:0] == 7'b0110011) || // ALU R-R
                   (p_mem[6:0] == 7'b0110111) || // LUI
                   (p_mem[6:0] == 7'b0010111) || // AUIPC
                   (p_mem[6:0] == 7'b1101111) || // JAL
                   (p_mem[6:0] == 7'b1100111) ?  1 : 0; // JALR
                   
    assign rf_wb = (p_mem[6:0] == 7'b0000011) ? rs_dmem : // DATA FROM DMEM
                   (p_mem[6:0] == 7'b0110111) ? {p_mem[31:12], 12'b0} : // IMM
                   (p_mem[6:0] == 7'b1101111) ? pc_mem : //JAL
                   (p_mem[6:0] == 7'b1100111) ? pc_mem : res_wb; // JALR

    initial begin 
        pc     = 'b0;
        pc_id  = 'b0;
        pc_ex  = 'b0;
        pc_mem = 'b0;
        pc_wb  = 'b0;

        p_if   = 'b0;
        p_id   = 'b0;
        p_ex   = 'b0;
        p_mem  = 'b0;
        p_wb   = 'b0;
    end
    
    always @(posedge clk) begin
        pc_if  <= (hz) ? pc_if  : pc;
        pc_id  <= (hz) ? pc_id  : pc_if;
        pc_ex  <= (hz) ? pc_ex  : pc_id;
        pc_mem <= (hz) ? pc_mem : pc_ex;
        pc_wb  <= (hz) ? pc_wb  : pc_mem;

        p_id   <= (br)  ? 32'b0 : hz_in;
        p_ex   <= (br)  ? 32'b0 : p_id;
        p_mem  <= (clr) ? 32'b0 : p_ex;
        p_wb   <= (clr) ? 32'b0 : p_mem;

        res_wb <= res;
        rs2_dmem0 <= b_rf;
        
        // Branch
        clr <= (br) ? 1 : 0;
        pc  <= (br) ? res : (hz) ? pc : pc + 4;
    end
    
endmodule
