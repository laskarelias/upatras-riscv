module mem
#(parameter BITS = 32)    
(clk, ad, we, b, rs);

    input            clk;
    input [BITS-1:0] ad;   // mem address 
    input            we;   // write enable
    input [2:0]      b;    // width
    inout [BITS-1:0] rs;   // mem data - read write port
    parameter file = "";
    integer i = 0;

    reg [7:0]      memory[4095:0];   // 4096 x 8-bit 
    reg [BITS-1:0] rs_data;

    initial begin
        for (i = 0; i < 4096; i = i + 1) begin
            memory[i] = 'b0;
        end
        rs_data = 'b0;
        $readmemh(file, memory, 0, 4095);
    end

    always @(posedge clk)
        if (we) begin
            memory[ad]     <= rs[7:0];
            memory[ad + 1] <= (b == 3'b001) || (b == 3'b010) || (b == 3'b011) ? 
                              rs[15:8]  : memory[ad + 1];
            memory[ad + 2] <= (b == 3'b010) || (b == 3'b011) ? 
                              rs[23:16] : memory[ad + 2];
            memory[ad + 3] <= (b == 3'b010) || (b == 3'b011) ? 
                              rs[31:24] : memory[ad + 3];
            if (BITS > 32) begin
                memory[ad + 4] <= (b == 3'b011) ? rs[39:32] : memory[ad + 4]; 
                memory[ad + 5] <= (b == 3'b011) ? rs[47:40] : memory[ad + 5]; 
                memory[ad + 6] <= (b == 3'b011) ? rs[55:48] : memory[ad + 6]; 
                memory[ad + 7] <= (b == 3'b011) ? rs[63:56] : memory[ad + 7]; 
            end
        end
        else begin
            case ({b})
                3'b000  : begin // LB
                              rs_data <= $signed(memory[ad]);             
                          end   
                3'b001  : begin // LH
                              rs_data <= $signed({memory[ad + 1], memory[ad]}); 
                          end   
                3'b010  : begin // LW
                              rs_data <= $signed({memory[ad + 3], memory[ad + 2], 
                                                  memory[ad + 1], memory[ad]}); 
                          end   
                3'b011  : begin // LD
                              rs_data <= $signed({memory[ad + 7], memory[ad + 6], 
                                                  memory[ad + 5], memory[ad + 4],
                                                  memory[ad + 3], memory[ad + 2], 
                                                  memory[ad + 1], memory[ad]}); 
                          end   
                3'b100  : begin // LBU
                              rs_data <= {memory[ad]};
                          end   
                3'b101  : begin // LHU
                              rs_data <= {memory[ad + 1], memory[ad]};
                          end   
                3'b110  : begin // LWU
                              rs_data <= {memory[ad + 3], memory[ad + 2], 
                                          memory[ad + 1], memory[ad]};
                          end
                default : begin 
                              rs_data <= 'b0; 
                          end
            endcase
        end
            
    assign rs = (we) ? 'bz : rs_data;

endmodule
