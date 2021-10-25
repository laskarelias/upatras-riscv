module immgen
#(parameter BITS = 32)
(clk, instr, imm_en, imm);

    input             clk;
    input  [31:0]     instr;
    output            imm_en;
    output [BITS-1:0] imm;

    reg               imm_en;
    reg    [BITS-1:0] imm;

    initial begin
        imm <= 'b0;
        imm_en <= 0;
    end

    always @(posedge clk) begin
        casex (instr[6:0])
            7'b00x0011 : begin         // I-type - LB, LH, LW, ALU imm
                            imm <= $signed(instr[31:20]);   
                            imm_en <= 1;
                        end
            7'b1100111: begin          // I-type - JALR
                            imm <= $signed(instr[31:20]);   
                            imm_en <= 1;
                        end
            7'b0100011 : begin         // S-type - SW, SH, SB
                            imm <= $signed({instr[31:25], instr[11:7]});
                            imm_en <= 1;
                        end         
            7'b0x10111 : begin         // U-type - AUIPC, LUI
                            imm <= $signed(instr[31:12]);   
                            imm_en <= 1;
                        end
            7'b1100011 : begin         // B-type - BRANCH
                            imm <= $signed({instr[31], instr[7], instr[30:25], 
                                            instr[11:8], 1'b0});   
                            imm_en <= 1;
                        end
            7'b1101111 : begin         // J-type - JAL
                            imm <= $signed({instr[31], instr[19:12], instr[20], 
                                            instr[30:21], 1'b0});
                            imm_en <= 1;
                        end
            default    : begin 
                            imm <= 32'b0;
                            imm_en <= 0;
                        end
        endcase
    end

endmodule
