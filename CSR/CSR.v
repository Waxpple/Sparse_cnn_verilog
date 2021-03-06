module CSR#
(
    parameter col_length = 8,
    parameter word_length = 8,
    parameter double_word_length = 16,
    parameter kernel_size = 5,
    parameter image_size = 28
)
(
    input clk,
    input rst,
    input in_valid,
    input [word_length-1:0] data_in,
    output out_valid,
    output reg [image_size*image_size*word_length-1:0] data_out,
    output reg [image_size*image_size*col_length-1:0] data_out_cols,
    output reg [image_size*image_size*col_length-1:0] data_out_rows,
    output [double_word_length-1:0] valid_num_out
);

reg [double_word_length-1:0] counter,next_counter;
reg [1:0] curr_state,next_state;
reg [double_word_length-1:0] valid_num,next_valid_num;

reg [word_length-1:0] value,next_value;
reg [col_length-1:0] col,next_col,row,next_row;

reg valid,next_valid;
assign out_valid = valid;
assign valid_num_out = valid_num;
parameter IDLE = 2'b00;
parameter CAL = 2'b01;
parameter DONE = 2'b10;
parameter EXCEPTION = 2'b11;
always @(*) begin
    case(curr_state)
    IDLE: begin
        if(in_valid)begin
            next_counter = counter + 'd1;
            next_state = CAL;
            if (|data_in)begin
                next_valid_num = valid_num + 'd1;
                next_value = {data_in};
                next_col = counter % image_size;
                next_row = counter / image_size;
            end
            else begin
                next_valid_num = valid_num;
                next_value = value;
                next_col = col;
                next_row = row;
            end
        end
        else begin
            next_counter = counter;
            next_state = IDLE;
            next_valid_num = valid_num;
            next_value = value;
            next_col = col;
            next_row = row;
        end
        next_valid = 'd0;
    end
    CAL: begin
        if (counter>image_size*image_size-1)begin
            next_counter = counter+ 1'd1;
            next_state = DONE;
            next_valid = 'd1;
            // if (|data_in)begin
            //     next_valid_num = valid_num + 'd1;
            //     next_value = {data_in};
            //     next_col = counter % image_size;
            //     next_row = counter / image_size;
            //     end
            // else begin
            next_valid_num = valid_num;
            next_value = value;
            next_col = col;
            next_row = row;
            //end
        end
        else begin
            next_counter = counter + 'd1;
            next_state = CAL;
            next_valid = 'd0;
            if (|data_in)begin
                next_valid_num = valid_num + 'd1;
                next_value = {data_in};
                next_col = counter % image_size;
                next_row = counter / image_size;
                end
            else begin
                next_valid_num = valid_num;
                next_value = value;
                next_col = col;
                next_row = row;
            end
        end
    end
    DONE: begin
        next_counter = counter;
        next_state = DONE;
        next_valid_num = valid_num;
        next_value = value;
        next_col = col;
        next_row = row;
        next_valid = 'd1;
    end
    EXCEPTION: begin
        next_counter = counter;
        next_state = EXCEPTION;
        next_valid_num = valid_num;
        next_value = value;
        next_col = col;
        next_row = row;
        next_valid = valid;
    end
    endcase
    
end
always @(posedge clk or posedge rst) begin
    if (rst)begin
        counter <= 'd0;
        curr_state <= IDLE;
        valid_num <= 'd0;
        data_out <= 'd0;
        data_out_cols <= 'd0;
        data_out_rows <= 'd0;
        value <= 'd0;
        col <= 'd0;
        row <= 'd0;
        valid <= 'd0;
    end
    else begin
        counter <= next_counter; 
        curr_state <= next_state;
        valid_num <= next_valid_num;
        value <= next_value;
        col <= next_col;
        row <= next_row;
        data_out[(valid_num)*word_length-1-:word_length] <= value;
        data_out_cols[(valid_num)*col_length-1-:col_length] <= col;
        data_out_rows[(valid_num)*col_length-1-:col_length] <= row;
        valid <= next_valid;
    end
end
endmodule