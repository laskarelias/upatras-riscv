module branchtest();
    reg         clk;
    reg  [31:0] instruction;
    reg  [31:0] a;
    reg  [31:0] b;
    wire        branch;
    
    initial begin
        $dumpfile("branchtest.vcd");
        $dumpvars(0, branchtest);
    end

    always #5 clk = !clk;

    branch #(.BITS(32)) branchtst(clk, instruction, a, b, branch);

    initial begin
        clk = 0;
        #0  instruction = 'bxxxxxxxxxxxxxxxxxxxxxxxxx1101111;
        #10 instruction = 'bxxxxxxxxxxxxxxxxxxxxxxxxx1100111;
        #10 instruction = 'bxxxxxxxxxxxxxxxxx000xxxxx1100011;
            a = 'hA;
            b = 'hB;
        #10 instruction = 'bxxxxxxxxxxxxxxxxx001xxxxx1100011;  
        #10 instruction = 'bxxxxxxxxxxxxxxxxx100xxxxx1100011;
        #10 instruction = 'bxxxxxxxxxxxxxxxxx101xxxxx1100011;
        #10 instruction = 'bxxxxxxxxxxxxxxxxx110xxxxx1100011;
        #10 instruction = 'bxxxxxxxxxxxxxxxxx111xxxxx1100011;
        #20 $finish;
    end

endmodule