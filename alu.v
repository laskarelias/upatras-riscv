 module alu
#(parameter BITS = 32)
(clk, instr, a, b, res_r);

    input             clk;
	input  [BITS-1:0] a;        // rs1
	input  [BITS-1:0] b;        // rs2
	input  [31:0]     instr;
	output [BITS-1:0] res_r;
	reg    [BITS-1:0] res;       //result register
	reg    [BITS-1:0] res_r;
	
	initial begin
        res = 0;
    end

    always @(posedge clk) begin
        casex ({instr[31:25], instr[14:12], instr[6:0]})
            'b00000000000110011:          // ADD
                res = a + b; 
            'b01000000000110011:          // SUB
                res = a - b; 
            'b00000000010110011:          // SLL
                res = a << b[4:0]; 
            'b00000000100110011:          // SLT
                res = ($signed(a) < $signed(b)) ? 'b1 : 'b0;
            'b00000000110110011:          // SLTU
                res = (a < b) ? 'b1 : 'b0;
            'b00000001000110011:          // XOR
                res = a ^ b;
            'b00000001010110011:          // SRL
                res = a >> b[4:0];
            'b01000001010110011:          // SRA
                res = a >>> b[4:0];
            'b00000001100110011:          // OR
                res = a | b;
            'b00000001110110011:          // AND
                res = a & b;
            'bxxxxxxx0000010011:          // ADDI
                res = a + b;
            'bxxxxxxx0100010011:          // SLTI
                res = ($signed(a) < $signed(b)) ? 'b1 : 'b0;
            'bxxxxxxx0100010011:          // SLTIU
                res = (a < b) ? 'b1 : 'b0;
            'bxxxxxxx1000010011:          // XORI
                res = a ^ b;
            'bxxxxxxx1100010011:          // ORI
                res = a | b;
            'bxxxxxxx1110010011:          // ANDI
                res = a & b;
            'b00000000010010011:          // SLLI
                res = a << b[4:0];
            'b00000001010010011:          // SRLI
                res = a >> b[4:0];
            'b01000001010010011:          // SRAI
                res = a >>> b[4:0];
            default:
                res = a + b;
        endcase 
        res_r <= res;
    end	
	
endmodule
