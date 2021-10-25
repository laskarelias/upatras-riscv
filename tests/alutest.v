module alutest();
    reg         clk;
    reg  [31:0] operation;
    reg  [31:0] a;
    reg  [31:0] b;
    wire [31:0] result;
    
    initial begin
        $dumpfile("alutest.vcd");
        $dumpvars(0, alutest);
    end

    always #5 clk = !clk;

    alu #(.BITS(32)) alutst(clk, operation, a, b, result);

    initial begin
        clk = 0;
        #0  a = 'h87654321;
            b = 'h89abcdef;
            operation = 'b0000000xxxxxxxxxx111xxxxx0110011;
        #10 operation = 'b0000000xxxxxxxxxx000xxxxx0110011;
        #10 b = 'h00000010;
            operation = 'b0000000xxxxxxxxxx001xxxxx0110011;
        #20 $finish;
    end
endmodule