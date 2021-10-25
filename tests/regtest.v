module regtest();
    reg         clk;
    reg  [4:0]  address_a;
    reg  [4:0]  address_b;
    reg  [4:0]  address_write;
    reg         write_enable;
    wire [31:0] data_a;
    wire [31:0] data_b;
    reg  [31:0] data_write;

    initial begin
        $dumpfile("regtest.vcd");
        $dumpvars(0, regtest);
    end

    always #5 clk = !clk;

    regfile #(.BITS(32)) rftst(clk, address_a, address_b, address_write, write_enable, data_a, data_b, data_write);

    initial begin
        clk = 0;
        #0  data_write = 'haabbccdd;
            address_write = 'h01;
            write_enable = 'b1;
        #15 address_a = 'h01;
            address_b = 'h02;
            data_write = 'haaaaaaaa;
        #2  address_b = 'h01;
        #3  address_b = 'h02;
            data_write = 'hffffffff;
            address_write = 'h02;
            write_enable = 'b1;
        #8  data_write = 'ha0a0a0a0;
        #2  data_write = 'h12345678;
            address_write = 'h00;
        #10 address_b = 'h0;
            write_enable = 'b0;
        #10 address_a = 'h02;
            address_b = 'h01;
        #20 $finish;
    end
endmodule