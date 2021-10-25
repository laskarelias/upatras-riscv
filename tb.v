module test();
    reg clk;
   
	initial begin
		$dumpfile("test.vcd");
		$dumpvars(0, test);
	end
	
	always #5 clk = !clk;

    cpu2 #(.BITS(32)) t1(clk);
    
	initial begin
	        clk = 0;
	        
	  #200 $finish;	
		
	end

endmodule
