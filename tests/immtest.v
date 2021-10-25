module immtest();
	reg         clk;
    reg  [31:0] instruction;
    wire [31:0] immediate;
    wire        immediate_enable;
    
 	initial begin
		$dumpfile("immtest.vcd");
        $dumpvars(0, immtest);
	end

	always #5 clk = !clk;

	immgen #(.BITS(32)) immtst(clk, instruction, immediate_enable, immediate);

    initial begin
        clk = 0;
        #0  instruction = 'bxxxxxxxxxxxxxxxxxxxxxxxxx0110011;  // R-type
        #10 instruction = 'b100010001000xxxxxxxxxxxxx0000011;  // I-type
        #10 instruction = 'b1000100xxxxxxxxxxxxx010000100011;  // S-type
        #10 instruction = 'b0100000xxxxxxxxxxxxx010011100011;  // B-type
        #10 instruction = 'b10101010101010101010xxxxx0110111;  // U-type
        #10 instruction = 'b00001000100110101010xxxxx1101111;  // J-type
        #20 $finish;
    end
endmodule