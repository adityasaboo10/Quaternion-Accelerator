    module fpga_to_arduino_spi(
        input sclk,
        input rst,
        input cs,
        input [31:0] q0, q1, q2, q3,
        output reg miso, 
        output reg data_ready
    );
    
        reg [31:0] shift_reg = 0;
        reg [4:0] bit_count = 0;
        reg [1:0] out_count = 0;
        integer i = 0;
    
        reg load_shift = 1; 
        reg insert_x_cycle = 1;
        
        always @(posedge sclk) begin
            if (rst) begin
                shift_reg <= 0;
                miso <= 0;
                data_ready <= 0;
                bit_count <= 0;
                out_count <= 0;
                i <= 0;
                load_shift <= 1;
                insert_x_cycle <= 1; 
            end 
            else if (~cs) begin
                data_ready <= 0;
                
                if (insert_x_cycle) begin
                   
                    miso <= 1'bx;
                    bit_count <= 5'bx;
                    i <= 6'bx;
                    shift_reg <= 32'bx;
                    insert_x_cycle <= 0; 
                    load_shift <= 1;    
                end
                
                else if (load_shift) begin
            
                    case (out_count)
                        2'b00: shift_reg <= q0;
                        2'b01: shift_reg <= q1;
                        2'b10: shift_reg <= q2;
                        2'b11: shift_reg <= q3;
                    endcase
                    bit_count <= 0;   
                    i <= 0;           
                    load_shift <= 0;
                end 
                else begin
                    
                    miso <= shift_reg[i];
    
                    if (bit_count != 31) begin
                        bit_count <= bit_count + 1;
                        i <= i + 1;
                    end 
                    else begin
                        
                        out_count <= out_count + 1;
                        insert_x_cycle <= 1;  
                        load_shift <= 0 ;      
                        if (out_count == 2'b11)
                            data_ready <= 1;  
                    end
                end
            end
        end
    
    endmodule
