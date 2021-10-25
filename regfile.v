module regfile
#(parameter BITS = 32)
(clk, ad1, ad2, adw, we, rs1, rs2, rsw);

    input             clk;
    input  [4:0]      ad1;  // rs1 address - read
    input  [4:0]      ad2;  // rs2 address - read
    input  [4:0]      adw;  // write port address
    input             we;   // write enable
    output [BITS-1:0] rs1;  // rs1 data 
    output [BITS-1:0] rs2;  // rs2 data 
    input  [BITS-1:0] rsw;  // write port data

    // Register file storage
    reg [BITS-1:0] registers[31:0]; // 32 x 32-bit
    reg [BITS-1:0] rs1;
    reg [BITS-1:0] rs2;

    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] <= 'b0;
        end
    end

    always @(posedge clk) begin
            registers[adw] = we ? rsw : registers[adw];
            rs1 <= (ad1) ? registers[ad1] : 'b0;
            rs2 <= (ad2) ? registers[ad2] : 'b0;
    end
endmodule