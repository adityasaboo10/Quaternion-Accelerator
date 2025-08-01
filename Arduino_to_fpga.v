`timescale 1ns / 1ps

module spi_slave(
    input sclk,
    input rst,
    input mosi,
    input cs,
    output reg [15:0] q0, q1, q2, q3,
    output reg data_ready
    );
    
    reg [15:0] shift_reg = 16'd0; 
    reg [3:0] bit_count = 4'd0;
    reg [1:0] out_count = 2'd0;
    
    always @(posedge sclk) begin
        if (rst) begin
            q0 <= 16'b0;
            q1 <= 16'b0;
            q2 <= 16'b0;
            q3 <= 16'b0;
            data_ready <= 0;
            shift_reg <= 0;
            bit_count <= 0;
            out_count <= 0;
        end
        else if (~cs) begin
            data_ready <= 0;
            if (bit_count != 4'd15) begin
                shift_reg <= {mosi, shift_reg [15:1]};
                bit_count <= bit_count + 1;
            end
            else if (bit_count == 4'd15) begin
                bit_count <= 0;
                case (out_count)
                    2'd0: begin
                            q0 <= {mosi, shift_reg [15:1]};                            
                            out_count <= out_count + 1;
                          end
                    2'd1: begin
                            q1 <= {mosi, shift_reg [15:1]};                            
                            out_count <= out_count + 1;
                          end
                    2'd2: begin
                            q2 <= {mosi, shift_reg [15:1]};                           
                            out_count <= out_count + 1;
                          end
                    2'd3: begin
                            q3 <= {mosi, shift_reg [15:1]};                            
                            out_count <= 0;
                            data_ready <= 1;
                          end
                endcase               
            end
        end
    end        
endmodule
