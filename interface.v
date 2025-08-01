module SCL (
    input clk,
    input rst,
    input start,
    input stop,
    output reg clk_out
);

    reg [9:0] counter = 0;
    reg started = 0;
    
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            clk_out <= 1;
            counter <= 0;
            started <= 0;
        end        
        else begin
            if (start) begin
                started <= 1;
                clk_out <= 0;
            end
            if (started) begin
                if (counter == 250) begin
                    counter <= 0;
                    clk_out <= ~clk_out;
                end
                else begin
                    counter <= counter + 1;
                end 
            end
            if (stop) begin
                clk_out <= 1;
                counter <= 0;
                started <= 0;
            end                
        end
    end
endmodule

module i2c_controller(
    input clk,
    input rst,
    input start,
    input rw,
    input signed [15:0] data_x,
    input signed [15:0] data_y,
    input signed [15:0] data_z,
    
    output reg signed [15:0] x,
    output reg signed [15:0] y, 
    output reg signed [15:0] z, 
    
    inout wire scl,
    inout wire sda
);    
    
    reg [3:0] state = 0;
    reg started = 0;
    reg sda_reg = 1;
    reg signed [15:0] shift_reg = 0;
    reg stop = 0;
    reg [6:0] slave_addr = 7'h68;
    reg [8:0] register_addr_x_high = 8'h43;
    reg [8:0] register_addr_x_low = 8'h44;
    reg [8:0] register_addr_y_high = 8'h45;
    reg [8:0] register_addr_y_low = 8'h46;
    reg [8:0] register_addr_z_high = 8'h47;
    reg [8:0] register_addr_z_low = 8'h48;
    
    localparam IDLE = 0, START = 1, SLAVE_ADDR = 2, REG_ADDR_X_HIGH = 3, READ_DATA_X_HIGH = 4, REG_ADDR_X_LOW = 5,
               READ_DATA_X_LOW = 6, REG_ADDR_Y_HIGH = 7, READ_DATA_Y_HIGH = 8, REG_ADDR_Y_LOW = 9, READ_DATA_Y_LOW = 10,
               REG_ADDR_Z_HIGH = 11, READ_DATA_Z_HIGH = 12, REG_ADDR_Z_LOW = 13, READ_DATA_Z_LOW = 14, STOP = 15;
               
    integer i;
    integer j;
    integer k;
    integer l;
            
    SCL C (
        .clk(clk),
        .rst(rst),
        .start(start),
        .stop(stop),
        .clk_out(scl)
    );
    
    assign sda = sda_reg;
    
    always @(posedge clk) begin
        if(state == IDLE) begin
            sda_reg <= 1;            
            shift_reg <= 0;         
            stop <= 0;                              
            if (start) begin
                started <= 1;
            end
            if (started) begin
                    state <= START;
                    sda_reg <= 0;
            end
        end
    end
       
    always @(negedge scl) begin
        if (rst) begin
            state <= IDLE;
            started <= 0;
            sda_reg <= 1;   
            shift_reg <= 0;      
            stop <= 0;
            i <= 0;
            j <= 0;
            k <= 0;
            l <= 0;
        end
        else begin 
            case (state)                
                START: begin
                    state <= SLAVE_ADDR;
                    i <= 6;
                end
                SLAVE_ADDR: begin      
                    if (i >= 0 && i < 7) begin
                        sda_reg <= slave_addr[i];
                    i <= i - 1;
                    end 
                    else begin
                        sda_reg <= 0; // To WRITE register address 
                        state <= REG_ADDR_X_HIGH;
                        j <= 7;
                        k <= 15;
                        l <= 7;
                    end
                end
                REG_ADDR_X_HIGH: begin                                                               
                    if (j >= 0 && j < 8) begin
                            sda_reg <= register_addr_x_high[j];
                            j <= j - 1;
                    end 
                    else begin
                        sda_reg <= 0; // ACKNOWLEDGE
                        k <= 15;
                        l <= 15;
                        state <= READ_DATA_X_HIGH;
                    end
                end                   
                READ_DATA_X_HIGH: begin
                    if (k >= 8 && k < 16) begin
                        sda_reg <= data_x[k];
                        k <= k - 1;
                    end
                    if (l >= 9 && l < 16 && l == k + 1) begin
                        shift_reg[l] <= sda_reg;
                        l <= l - 1;
                    end
                    if (l == 8) begin
                        sda_reg <= 0; // ACKNOWLEDGE
                        l <= l - 1;
                        j <= 7;
                        state <= REG_ADDR_X_LOW;
                    end
                end
                REG_ADDR_X_LOW: begin                                                               
                    if (j >= 0 && j < 8) begin
                            sda_reg <= register_addr_x_low[j];
                            j <= j - 1;
                    end 
                    else begin
                        sda_reg <= 0; // ACKNOWLEDGE
                        k <= 7;
                        l <= 7;
                        state <= READ_DATA_X_LOW;
                    end
                end                   
                READ_DATA_X_LOW: begin
                    if (k >= 0 && k < 8) begin
                        sda_reg <= data_x[k];
                        k <= k - 1;
                    end
                    if (l >= 1 && l < 8 && l == k + 1) begin
                        shift_reg[l] <= sda_reg;
                        l <= l - 1;
                    end
                    if (l == 0) begin
                        sda_reg <= 0; // ACKNOWLEDGE
                        j <= 7;
                        x[15:1] <= shift_reg[15:1];
                        x[0] <= sda_reg;  
                        shift_reg <= 0;
                        state <= REG_ADDR_Y_HIGH;                          
                    end
                end
                REG_ADDR_Y_HIGH: begin                                                               
                    if (j >= 0 && j < 8) begin
                            sda_reg <= register_addr_y_high[j];
                            j <= j - 1;
                    end 
                    else begin
                        sda_reg <= 0; // ACKNOWLEDGE
                        k <= 15;
                        l <= 15;
                        state <= READ_DATA_Y_HIGH;
                    end
                end                   
                READ_DATA_Y_HIGH: begin
                    if (k >= 8 && k < 16) begin
                        sda_reg <= data_y[k];
                        k <= k - 1;
                    end
                    if (l >= 9 && l < 16 && l == k + 1) begin
                        shift_reg[l] <= sda_reg;
                        l <= l - 1;
                    end
                    if (l == 8) begin
                        sda_reg <= 0; // ACKNOWLEDGE
                        l <= l - 1;
                        j <= 7;
                        state <= REG_ADDR_Y_LOW;
                    end
                end
                REG_ADDR_Y_LOW: begin                                                               
                    if (j >= 0 && j < 8) begin
                            sda_reg <= register_addr_y_low[j];
                            j <= j - 1;
                    end 
                    else begin
                        sda_reg <= 0; // ACKNOWLEDGE
                        k <= 7;
                        l <= 7;
                        state <= READ_DATA_Y_LOW;
                    end
                end                   
                READ_DATA_Y_LOW: begin
                    if (k >= 0 && k < 8) begin
                        sda_reg <= data_y[k];
                        k <= k - 1;
                    end
                    if (l >= 1 && l < 8 && l == k + 1) begin
                        shift_reg[l] <= sda_reg;
                        l <= l - 1;
                    end
                    if (l == 0) begin
                        sda_reg <= 0; // ACKNOWLEDGE
                        j <= 7;
                        y[15:1] <= shift_reg[15:1];
                        y[0] <= sda_reg;  
                        shift_reg <= 0;
                        state <= REG_ADDR_Z_HIGH;
                    end
                end
                REG_ADDR_Z_HIGH: begin                                                               
                    if (j >= 0 && j < 8) begin
                            sda_reg <= register_addr_z_high[j];
                            j <= j - 1;
                    end 
                    else begin
                        sda_reg <= 0; // ACKNOWLEDGE
                        k <= 15;
                        l <= 15;
                        state <= READ_DATA_Z_HIGH;
                    end
                end                   
                READ_DATA_Z_HIGH: begin
                    if (k >= 8 && k < 16) begin
                        sda_reg <= data_z[k];
                        k <= k - 1;
                    end
                    if (l >= 9 && l < 16 && l == k + 1) begin
                        shift_reg[l] <= sda_reg;
                        l <= l - 1;
                    end
                    if (l == 8) begin
                        sda_reg <= 0; // ACKNOWLEDGE
                        l <= l - 1;
                        j <= 7;
                        state <= REG_ADDR_Z_LOW;
                    end
                end
                REG_ADDR_Z_LOW: begin                                                               
                    if (j >= 0 && j < 8) begin
                            sda_reg <= register_addr_z_low[j];
                            j <= j - 1;
                    end 
                    else begin
                        sda_reg <= 0; // ACKNOWLEDGE
                        k <= 7;
                        l <= 7;
                        state <= READ_DATA_Z_LOW;
                    end
                end                   
                READ_DATA_Z_LOW: begin
                    if (k >= 0 && k < 8) begin
                        sda_reg <= data_z[k];
                        k <= k - 1;
                    end
                    if (l >= 1 && l < 8 && l == k + 1) begin
                        shift_reg[l] <= sda_reg;
                        l <= l - 1;
                    end
                    if (l == 0) begin
                        sda_reg <= 0; // ACKNOWLEDGE
                        j <= 7;
                        z[15:1] <= shift_reg[15:1];
                        z[0] <= sda_reg;
                        shift_reg <= 0;  
                        state <= STOP;  
                    end
                end               
                STOP: begin
                    state <= IDLE;
                    started <= 0;
                    sda_reg <= 1;   
                    shift_reg <= 0;               
                    stop <= 1;
                end
            endcase
        end
    end
endmodule 


    


