module memtest();
	reg         clk;
    reg  [63:0] address;
    reg  [63:0] data;
    wire [63:0] data_wire;
    reg  [2:0]  width;
    reg         write_enable;
    
 	initial begin
		$dumpfile("memtest.vcd");
        $dumpvars(0, memtest);
	end

	always #5 clk = !clk;

	mem #(.BITS(64)) memtst(clk, address, write_enable, width, data_wire);
    defparam memtst.file = "memtest.mem";

    assign data_wire = write_enable ? data : 'bz;

    initial begin
        clk = 0;
        #0  address = 'h000000000000000;
            write_enable = 0;
            width = 'b000; 
        #10 width += 'b1;
        #10 width += 'b1;
        #10 width += 'b1;
        #10 address += 'h8;
            width = 'b000;
        #10 width = 'b100;
        #20 address = 'b0;
            width = 'b010;
            write_enable = 'b1;
            data  = 'hAAAAAAAABBBBBBBB;
        #10 write_enable = 'b0;
        #10 width = 'b110;
        #10 width = 'b011;
        #20 $finish;
    end
endmodule