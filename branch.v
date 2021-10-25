module branch
#(parameter BITS = 32)
(clk, instr, a, b, br);

    input         clk;
    input  [BITS-1:0] a;
    input  [BITS-1:0] b;
    input  [31:0]     instr;
    output        br;

    reg           br;

    initial 
        br = 0;

    always @(posedge clk) begin
        casex ({instr[14:12], instr[6:0]})
            10'b0001100011 : begin // BEQ
                                 br <= (a == b) ? 1 : 0; 
                             end  
            10'b0011100011 : begin // BNE
            		         br <= (a != b) ? 1 : 0; 
            		     end   
            10'b1001100011 : begin // BLT
                                 br <= ($signed(a) <  $signed(b)) ? 1 : 0; 
                             end  
            10'b1011100011 : begin // BGE
                                 br <= ($signed(a) >= $signed(b)) ? 1 : 0; 
                             end   
            10'b1101100011 : begin // BLTU
                                 br <= (a <  b) ? 1 : 0; 
                             end  
            10'b1111100011 : begin // BGEU
                                 br <= (a >= b) ? 1 : 0;
                             end   
            10'bxxx1101111 : begin // JAL
                                 br <= 1;
                             end
            10'b0001100111 : begin // JALR
                                 br <= 1;
                             end   
            default        : begin 
                                 br <= 0;
                             end
        endcase
    end

endmodule
