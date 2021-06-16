module PE_UNIT_NEW
#(
    
    parameter col_length = 8,
    parameter word_length = 8,
    parameter double_word_length = 16,
    parameter kernel_size = 5,
    parameter image_size = 28,
    parameter matrix_width = 4
)
(
    //outer signal
    input clk,
    input rst,
    input in_valid,
    output reg out_valid,

    
    //weight in
    input [double_word_length-1:0] weight_valid_num,
    input [col_length*1 -1:0]weight_cols,
    input [col_length*1 -1:0]weight_rows,
    input signed [word_length*1 -1:0]weight_value,

    //pixel data
    input [double_word_length-1:0] feature_valid_num,
    input signed [col_length*4 -1:0]feature_cols,
    input signed [col_length*4 -1:0]feature_rows,
    input signed [word_length*4 -1:0]feature_value,
    
    //output data
    output signed [word_length*2*16 -1:0]data_out,
    output signed [col_length*16 -1:0]data_out_cols,
    output signed [col_length*16 -1:0]data_out_rows,

    //valid signal
    input signed [double_word_length-1:0] in_channel,
    output signed [double_word_length-1:0] out_channel,

    
    //output counter status
    output [double_word_length-1:0] curr_pixel,
    output [double_word_length-1:0] curr_weight
);

//state
parameter IDLE = 2'b00;
parameter LOAD_WEIGHT = 2'b01;
parameter LOAD_FULL_IMAGE = 2'b10;
parameter DONE = 2'b11;
reg [1:0] curr_state,next_state;

//output state
reg [double_word_length-1:0] curr_pixel_counter,next_curr_pixel_counter,curr_weight_counter,next_curr_weight_counter;
assign curr_pixel = (curr_pixel_counter==feature_valid_num)?'d0:curr_pixel_counter;
assign curr_weight = (curr_weight_counter>weight_valid_num)?'d0:curr_weight_counter;
reg next_out_valid;
//counter
reg [double_word_length-1:0] counter, next_counter;
//weight container
reg [word_length*matrix_width-1:0] weight_container,next_weight_container;
reg [col_length*matrix_width-1:0] weight_cols_container, next_weight_cols_container;
reg [col_length*matrix_width-1:0] weight_rows_container, next_weight_rows_container;

//feature container
reg [word_length*matrix_width*matrix_width-1:0] feature_container, next_feature_container;
reg [col_length*matrix_width*matrix_width-1:0] feature_cols_container, next_feature_cols_container;
reg [col_length*matrix_width*matrix_width-1:0] feature_rows_container, next_feature_rows_container;


wire signed [word_length*2-1:0] answer_1_1,answer_1_2,answer_1_3,answer_1_4,answer_2_1,answer_2_2,answer_2_3,answer_2_4,answer_3_1,answer_3_2,answer_3_3,answer_3_4,answer_4_1,answer_4_2,answer_4_3,answer_4_4; 
wire signed [col_length-1:0] col_answer_1_1,col_answer_1_2,col_answer_1_3,col_answer_1_4,col_answer_2_1,col_answer_2_2,col_answer_2_3,col_answer_2_4,col_answer_3_1,col_answer_3_2,col_answer_3_3,col_answer_3_4,col_answer_4_1,col_answer_4_2,col_answer_4_3,col_answer_4_4; 
wire signed [col_length-1:0] row_answer_1_1,row_answer_1_2,row_answer_1_3,row_answer_1_4,row_answer_2_1,row_answer_2_2,row_answer_2_3,row_answer_2_4,row_answer_3_1,row_answer_3_2,row_answer_3_3,row_answer_3_4,row_answer_4_1,row_answer_4_2,row_answer_4_3,row_answer_4_4; 

assign answer_1_1 = (out_valid==1'b1)? $signed( {{word_length{weight_container[word_length*1-1]}},{weight_container[word_length*1-1 -:word_length]}} * {{word_length{feature_container[(word_length*1)-1] }},{feature_container[(word_length*1)-1 -:word_length]}} ):'d0;
assign answer_1_2 = (out_valid==1'b1)? $signed( {{word_length{weight_container[word_length*1-1]}},{weight_container[word_length*1-1 -:word_length]}} * {{word_length{feature_container[(word_length*2)-1] }},{feature_container[(word_length*2)-1 -:word_length]}} ):'d0;
assign answer_1_3 = (out_valid==1'b1)? $signed( {{word_length{weight_container[word_length*1-1]}},{weight_container[word_length*1-1 -:word_length]}} * {{word_length{feature_container[(word_length*3)-1] }},{feature_container[(word_length*3)-1 -:word_length]}} ):'d0;
assign answer_1_4 = (out_valid==1'b1)? $signed( {{word_length{weight_container[word_length*1-1]}},{weight_container[word_length*1-1 -:word_length]}} * {{word_length{feature_container[(word_length*4)-1] }},{feature_container[(word_length*4)-1 -:word_length]}} ):'d0;

assign answer_2_1 = (out_valid==1'b1)? $signed( {{word_length{weight_container[word_length*2-1]}},{weight_container[word_length*2-1 -:word_length]}} * {{word_length{feature_container[(word_length*5)-1] }},{feature_container[(word_length*5)-1 -:word_length]}} ):'d0;
assign answer_2_2 = (out_valid==1'b1)? $signed( {{word_length{weight_container[word_length*2-1]}},{weight_container[word_length*2-1 -:word_length]}} * {{word_length{feature_container[(word_length*6)-1] }},{feature_container[(word_length*6)-1 -:word_length]}} ):'d0;
assign answer_2_3 = (out_valid==1'b1)? $signed( {{word_length{weight_container[word_length*2-1]}},{weight_container[word_length*2-1 -:word_length]}} * {{word_length{feature_container[(word_length*7)-1] }},{feature_container[(word_length*7)-1 -:word_length]}} ):'d0;
assign answer_2_4 = (out_valid==1'b1)? $signed( {{word_length{weight_container[word_length*2-1]}},{weight_container[word_length*2-1 -:word_length]}} * {{word_length{feature_container[(word_length*8)-1] }},{feature_container[(word_length*8)-1 -:word_length]}} ):'d0;

assign answer_3_1 = (out_valid==1'b1)? $signed( {{word_length{weight_container[word_length*3-1]}},{weight_container[word_length*3-1 -:word_length]}} * {{word_length{feature_container[(word_length*9)-1] }},{feature_container[(word_length*9)-1 -:word_length]}} ):'d0;
assign answer_3_2 = (out_valid==1'b1)? $signed( {{word_length{weight_container[word_length*3-1]}},{weight_container[word_length*3-1 -:word_length]}} * {{word_length{feature_container[(word_length*10)-1] }},{feature_container[(word_length*10)-1 -:word_length]}} ):'d0;
assign answer_3_3 = (out_valid==1'b1)? $signed( {{word_length{weight_container[word_length*3-1]}},{weight_container[word_length*3-1 -:word_length]}} * {{word_length{feature_container[(word_length*11)-1] }},{feature_container[(word_length*11)-1 -:word_length]}} ):'d0;
assign answer_3_4 = (out_valid==1'b1)? $signed( {{word_length{weight_container[word_length*3-1]}},{weight_container[word_length*3-1 -:word_length]}} * {{word_length{feature_container[(word_length*12)-1] }},{feature_container[(word_length*12)-1 -:word_length]}} ):'d0;

assign answer_4_1 = (out_valid==1'b1)? $signed( {{word_length{weight_container[word_length*4-1]}},{weight_container[word_length*4-1 -:word_length]}} * {{word_length{feature_container[(word_length*13)-1] }},{feature_container[(word_length*13)-1 -:word_length]}} ):'d0;
assign answer_4_2 = (out_valid==1'b1)? $signed( {{word_length{weight_container[word_length*4-1]}},{weight_container[word_length*4-1 -:word_length]}} * {{word_length{feature_container[(word_length*14)-1] }},{feature_container[(word_length*14)-1 -:word_length]}} ):'d0;
assign answer_4_3 = (out_valid==1'b1)? $signed( {{word_length{weight_container[word_length*4-1]}},{weight_container[word_length*4-1 -:word_length]}} * {{word_length{feature_container[(word_length*15)-1] }},{feature_container[(word_length*15)-1 -:word_length]}} ):'d0;
assign answer_4_4 = (out_valid==1'b1)? $signed( {{word_length{weight_container[word_length*4-1]}},{weight_container[word_length*4-1 -:word_length]}} * {{word_length{feature_container[(word_length*16)-1] }},{feature_container[(word_length*16)-1 -:word_length]}} ):'d0;



//rows/cols is feature rows/cols - weight rows/cols
assign col_answer_1_1 = (out_valid==1'b1)? $signed( feature_cols_container[col_length-1   -: col_length]) - $signed( weight_cols_container[col_length-1 -: col_length]):'d0;
assign col_answer_1_2 = (out_valid==1'b1)? $signed( feature_cols_container[col_length*2-1 -: col_length]) - $signed( weight_cols_container[col_length-1 -: col_length]):'d0;
assign col_answer_1_3 = (out_valid==1'b1)? $signed( feature_cols_container[col_length*3-1 -: col_length]) - $signed( weight_cols_container[col_length-1 -: col_length]):'d0;
assign col_answer_1_4 = (out_valid==1'b1)? $signed( feature_cols_container[col_length*4-1 -: col_length]) - $signed( weight_cols_container[col_length-1 -: col_length]):'d0;

assign col_answer_2_1 = (out_valid==1'b1)? $signed( feature_cols_container[col_length*5-1 -: col_length]) - $signed( weight_cols_container[(col_length*2)-1 -: col_length]):'d0;
assign col_answer_2_2 = (out_valid==1'b1)? $signed( feature_cols_container[col_length*6-1 -: col_length]) - $signed( weight_cols_container[(col_length*2)-1 -: col_length]):'d0;
assign col_answer_2_3 = (out_valid==1'b1)? $signed( feature_cols_container[col_length*7-1 -: col_length]) - $signed( weight_cols_container[(col_length*2)-1 -: col_length]):'d0;
assign col_answer_2_4 = (out_valid==1'b1)? $signed( feature_cols_container[col_length*8-1 -: col_length]) - $signed( weight_cols_container[(col_length*2)-1 -: col_length]):'d0;

assign col_answer_3_1 = (out_valid==1'b1)? $signed( feature_cols_container[col_length*9-1 -: col_length]) - $signed( weight_cols_container[(col_length*3)-1 -: col_length]):'d0;
assign col_answer_3_2 = (out_valid==1'b1)? $signed( feature_cols_container[col_length*10-1 -: col_length]) - $signed( weight_cols_container[(col_length*3)-1 -: col_length]):'d0;
assign col_answer_3_3 = (out_valid==1'b1)? $signed( feature_cols_container[col_length*11-1 -: col_length]) - $signed( weight_cols_container[(col_length*3)-1 -: col_length]):'d0;
assign col_answer_3_4 = (out_valid==1'b1)? $signed( feature_cols_container[col_length*12-1 -: col_length]) - $signed( weight_cols_container[(col_length*3)-1 -: col_length]):'d0;

assign col_answer_4_1 = (out_valid==1'b1)? $signed( feature_cols_container[col_length*13-1 -: col_length]) - $signed( weight_cols_container[(col_length*4)-1 -: col_length]):'d0;
assign col_answer_4_2 = (out_valid==1'b1)? $signed( feature_cols_container[col_length*14-1 -: col_length]) - $signed( weight_cols_container[(col_length*4)-1 -: col_length]):'d0;
assign col_answer_4_3 = (out_valid==1'b1)? $signed( feature_cols_container[col_length*15-1 -: col_length]) - $signed( weight_cols_container[(col_length*4)-1 -: col_length]):'d0;
assign col_answer_4_4 = (out_valid==1'b1)? $signed( feature_cols_container[col_length*16-1 -: col_length]) - $signed( weight_cols_container[(col_length*4)-1 -: col_length]):'d0;

//
assign row_answer_1_1 = (out_valid==1'b1)? $signed( feature_rows_container[col_length-1   -: col_length]) - $signed( weight_rows_container[col_length-1 -: col_length]):'d0;
assign row_answer_1_2 = (out_valid==1'b1)? $signed( feature_rows_container[col_length*2-1 -: col_length]) - $signed( weight_rows_container[col_length-1 -: col_length]):'d0;
assign row_answer_1_3 = (out_valid==1'b1)? $signed( feature_rows_container[col_length*3-1 -: col_length]) - $signed( weight_rows_container[col_length-1 -: col_length]):'d0;
assign row_answer_1_4 = (out_valid==1'b1)? $signed( feature_rows_container[col_length*4-1 -: col_length]) - $signed( weight_rows_container[col_length-1 -: col_length]):'d0;

assign row_answer_2_1 = (out_valid==1'b1)? $signed( feature_rows_container[col_length*5-1 -: col_length]) - $signed( weight_rows_container[(col_length*2)-1 -: col_length]):'d0;
assign row_answer_2_2 = (out_valid==1'b1)? $signed( feature_rows_container[col_length*6-1 -: col_length]) - $signed( weight_rows_container[(col_length*2)-1 -: col_length]):'d0;
assign row_answer_2_3 = (out_valid==1'b1)? $signed( feature_rows_container[col_length*7-1 -: col_length]) - $signed( weight_rows_container[(col_length*2)-1 -: col_length]):'d0;
assign row_answer_2_4 = (out_valid==1'b1)? $signed( feature_rows_container[col_length*8-1 -: col_length]) - $signed( weight_rows_container[(col_length*2)-1 -: col_length]):'d0;

assign row_answer_3_1 = (out_valid==1'b1)? $signed( feature_rows_container[col_length*9-1 -: col_length]) - $signed( weight_rows_container[(col_length*3)-1 -: col_length]):'d0;
assign row_answer_3_2 = (out_valid==1'b1)? $signed( feature_rows_container[col_length*10-1 -: col_length]) - $signed( weight_rows_container[(col_length*3)-1 -: col_length]):'d0;
assign row_answer_3_3 = (out_valid==1'b1)? $signed( feature_rows_container[col_length*11-1 -: col_length]) - $signed( weight_rows_container[(col_length*3)-1 -: col_length]):'d0;
assign row_answer_3_4 = (out_valid==1'b1)? $signed( feature_rows_container[col_length*12-1 -: col_length]) - $signed( weight_rows_container[(col_length*3)-1 -: col_length]):'d0;

assign row_answer_4_1 = (out_valid==1'b1)? $signed( feature_rows_container[col_length*13-1 -: col_length]) - $signed( weight_rows_container[(col_length*4)-1 -: col_length]):'d0;
assign row_answer_4_2 = (out_valid==1'b1)? $signed( feature_rows_container[col_length*14-1 -: col_length]) - $signed( weight_rows_container[(col_length*4)-1 -: col_length]):'d0;
assign row_answer_4_3 = (out_valid==1'b1)? $signed( feature_rows_container[col_length*15-1 -: col_length]) - $signed( weight_rows_container[(col_length*4)-1 -: col_length]):'d0;
assign row_answer_4_4 = (out_valid==1'b1)? $signed( feature_rows_container[col_length*16-1 -: col_length]) - $signed( weight_rows_container[(col_length*4)-1 -: col_length]):'d0;

assign data_out[word_length*2*4 -1 -:word_length*2*4] = {{answer_1_4},{answer_1_3},{answer_1_2},{answer_1_1}};
assign data_out[word_length*2*8 -1 -:word_length*2*4] = {{answer_2_4},{answer_2_3},{answer_2_2},{answer_2_1}};
assign data_out[word_length*2*12 -1 -:word_length*2*4] = {{answer_3_4},{answer_3_3},{answer_3_2},{answer_3_1}};
assign data_out[word_length*2*16 -1 -:word_length*2*4] = {{answer_4_4},{answer_4_3},{answer_4_2},{answer_4_1}};

//{4 3 2 1}
assign data_out_cols = {col_answer_4_4,col_answer_4_3,col_answer_4_2,col_answer_4_1, col_answer_3_4,col_answer_3_3,col_answer_3_2,col_answer_3_1, col_answer_2_4,col_answer_2_3,col_answer_2_2,col_answer_2_1, col_answer_1_4,col_answer_1_3,col_answer_1_2,col_answer_1_1};
assign data_out_rows = {row_answer_4_4,row_answer_4_3,row_answer_4_2,row_answer_4_1, row_answer_3_4,row_answer_3_3,row_answer_3_2,row_answer_3_1, row_answer_2_4,row_answer_2_3,row_answer_2_2,row_answer_2_1, row_answer_1_4,row_answer_1_3,row_answer_1_2,row_answer_1_1};



always @(*) begin
    case(curr_state)
    IDLE: begin
        if(in_valid) begin
            next_state = LOAD_WEIGHT;
            next_counter = counter + 'd1;
            next_out_valid = 'd1;
            //load weight
            if(counter[1:0]=='d0)begin
                next_weight_container[word_length*1-1 -: word_length] = weight_value;
                next_weight_container[word_length*2-1 -: word_length] = weight_container[word_length*2-1 -: word_length];
                next_weight_container[word_length*3-1 -: word_length] = weight_container[word_length*3-1 -: word_length];
                next_weight_container[word_length*4-1 -: word_length] = weight_container[word_length*4-1 -: word_length];
            end
            else if(counter[1:0]=='d1) begin
                next_weight_container[word_length*1-1 -: word_length] = weight_container[word_length*1-1 -: word_length];
                next_weight_container[word_length*2-1 -: word_length] = weight_value;
                next_weight_container[word_length*3-1 -: word_length] = weight_container[word_length*3-1 -: word_length];
                next_weight_container[word_length*4-1 -: word_length] = weight_container[word_length*4-1 -: word_length];
            end
            else if(counter[1:0]=='d2) begin
                next_weight_container[word_length*1-1 -: word_length] = weight_container[word_length*1-1 -: word_length];
                next_weight_container[word_length*2-1 -: word_length] = weight_container[word_length*2-1 -: word_length];
                next_weight_container[word_length*3-1 -: word_length] = weight_value;
                next_weight_container[word_length*4-1 -: word_length] = weight_container[word_length*4-1 -: word_length];
            end
            else if(counter[1:0]=='d3) begin
                next_weight_container[word_length*1-1 -: word_length] = weight_container[word_length*1-1 -: word_length];
                next_weight_container[word_length*2-1 -: word_length] = weight_container[word_length*2-1 -: word_length];
                next_weight_container[word_length*3-1 -: word_length] = weight_container[word_length*3-1 -: word_length];
                next_weight_container[word_length*4-1 -: word_length] = weight_value;
            end

            // next_weight_container[(counter+'d1)*word_length-1 -:word_length] = weight_value;
            next_weight_cols_container[(counter+'d1)*col_length-1 -:col_length] = weight_cols;
            next_weight_rows_container[(counter+'d1)*col_length-1 -:col_length] = weight_rows;
            next_curr_weight_counter = curr_weight_counter + 'd1;
            //load feature
            next_feature_container = {feature_container<<(word_length*matrix_width)} | {{((matrix_width-1)*word_length){1'b0}},feature_value};
            next_feature_cols_container = {feature_cols_container<<(col_length*matrix_width)} | {{((matrix_width-1)*col_length){1'b0}},feature_cols};
            next_feature_rows_container = {feature_rows_container<<(col_length*matrix_width)} | {{((matrix_width-1)*col_length){1'b0}},feature_rows};
            next_curr_pixel_counter = curr_pixel_counter + 'd1;

        end
        else begin
            next_state = IDLE;
            next_counter = counter;
            next_out_valid = 'd0;
            //not load weight
            next_weight_container = weight_container;
            next_curr_weight_counter = curr_weight_counter;
            next_weight_cols_container = weight_cols_container;
            next_weight_rows_container = weight_rows_container;
            //not load feature
            next_feature_container = feature_container;
            next_feature_cols_container = feature_cols_container;
            next_feature_rows_container = feature_rows_container;
            next_curr_pixel_counter = curr_pixel_counter;
        end
    end
    LOAD_WEIGHT:begin
        if(counter=='d4)begin
            next_state = LOAD_FULL_IMAGE;
            next_counter = counter + 'd1;
            next_out_valid = 'd1;
            //not load weight
            next_weight_container = weight_container;
            next_weight_cols_container = weight_cols_container;
            next_weight_rows_container = weight_rows_container;
            next_curr_weight_counter = curr_weight_counter;
            //load feature
            next_feature_container = {feature_container<<(word_length*matrix_width)} | {{((matrix_width-1)*word_length){1'b0}},feature_value};
            next_feature_cols_container = {feature_cols_container<<(col_length*matrix_width)} | {{((matrix_width-1)*col_length){1'b0}},feature_cols};
            next_feature_rows_container = {feature_rows_container<<(col_length*matrix_width)} | {{((matrix_width-1)*col_length){1'b0}},feature_rows};
            next_curr_pixel_counter = curr_pixel_counter + 'd1;
        end
        else begin
            next_state = LOAD_WEIGHT;
            next_counter = counter + 'd1;
            next_out_valid = 'd1;
            //load weight
            if(counter[1:0]=='d0)begin
                next_weight_container[word_length*1-1 -: word_length] = weight_value;
                next_weight_container[word_length*2-1 -: word_length] = weight_container[word_length*2-1 -: word_length];
                next_weight_container[word_length*3-1 -: word_length] = weight_container[word_length*3-1 -: word_length];
                next_weight_container[word_length*4-1 -: word_length] = weight_container[word_length*4-1 -: word_length];
            end
            else if(counter[1:0]=='d1) begin
                next_weight_container[word_length*1-1 -: word_length] = weight_container[word_length*1-1 -: word_length];
                next_weight_container[word_length*2-1 -: word_length] = weight_value;
                next_weight_container[word_length*3-1 -: word_length] = weight_container[word_length*3-1 -: word_length];
                next_weight_container[word_length*4-1 -: word_length] = weight_container[word_length*4-1 -: word_length];
            end
            else if(counter[1:0]=='d2) begin
                next_weight_container[word_length*1-1 -: word_length] = weight_container[word_length*1-1 -: word_length];
                next_weight_container[word_length*2-1 -: word_length] = weight_container[word_length*2-1 -: word_length];
                next_weight_container[word_length*3-1 -: word_length] = weight_value;
                next_weight_container[word_length*4-1 -: word_length] = weight_container[word_length*4-1 -: word_length];
            end
            else if(counter[1:0]=='d3) begin
                next_weight_container[word_length*1-1 -: word_length] = weight_container[word_length*1-1 -: word_length];
                next_weight_container[word_length*2-1 -: word_length] = weight_container[word_length*2-1 -: word_length];
                next_weight_container[word_length*3-1 -: word_length] = weight_container[word_length*3-1 -: word_length];
                next_weight_container[word_length*4-1 -: word_length] = weight_value;
            end
            next_weight_cols_container[(counter+'d1)*col_length-1 -:col_length] = weight_cols;
            next_weight_rows_container[(counter+'d1)*col_length-1 -:col_length] = weight_rows;
            next_curr_weight_counter = curr_weight_counter + 'd1;
            //load feature
            next_feature_container = {feature_container<<(word_length*matrix_width)} | {{((matrix_width-1)*word_length){1'b0}},feature_value};
            next_feature_cols_container = {feature_cols_container<<(col_length*matrix_width)} | {{((matrix_width-1)*col_length){1'b0}},feature_cols};
            next_feature_rows_container = {feature_rows_container<<(col_length*matrix_width)} | {{((matrix_width-1)*col_length){1'b0}},feature_rows};
            next_curr_pixel_counter = curr_pixel_counter + 'd1;
        end
    end
    LOAD_FULL_IMAGE:begin
        if((|feature_valid_num[1:0])? counter ==(feature_valid_num>>2):counter ==(feature_valid_num>>2)-1 )begin
            if(curr_weight_counter>'d27)begin
                next_state = DONE;
                next_counter = counter;
                next_out_valid = 'd1;
                //not load weight
                next_weight_container = weight_container;
                next_weight_cols_container = weight_cols_container;
                next_weight_rows_container = weight_rows_container;
                next_curr_weight_counter = curr_weight_counter;
                //not load feature
                next_feature_container = {feature_container<<(word_length*matrix_width)} | {{((matrix_width-1)*word_length){1'b0}},feature_value};
                next_feature_cols_container = {feature_cols_container<<(col_length*matrix_width)} | {{((matrix_width-1)*col_length){1'b0}},feature_cols};
                next_feature_rows_container = {feature_rows_container<<(col_length*matrix_width)} | {{((matrix_width-1)*col_length){1'b0}},feature_rows};
                next_curr_pixel_counter = 'd0;
            end
            else begin
                next_state = LOAD_WEIGHT;
                next_counter = 'd0;
                next_out_valid = 'd1;
                //load weight
                if(counter[1:0]=='d0)begin
                    next_weight_container[word_length*1-1 -: word_length] = weight_value;
                    next_weight_container[word_length*2-1 -: word_length] = weight_container[word_length*2-1 -: word_length];
                    next_weight_container[word_length*3-1 -: word_length] = weight_container[word_length*3-1 -: word_length];
                    next_weight_container[word_length*4-1 -: word_length] = weight_container[word_length*4-1 -: word_length];
                end
                else if(counter[1:0]=='d1) begin
                    next_weight_container[word_length*1-1 -: word_length] = weight_container[word_length*1-1 -: word_length];
                    next_weight_container[word_length*2-1 -: word_length] = weight_value;
                    next_weight_container[word_length*3-1 -: word_length] = weight_container[word_length*3-1 -: word_length];
                    next_weight_container[word_length*4-1 -: word_length] = weight_container[word_length*4-1 -: word_length];
                end
                else if(counter[1:0]=='d2) begin
                    next_weight_container[word_length*1-1 -: word_length] = weight_container[word_length*1-1 -: word_length];
                    next_weight_container[word_length*2-1 -: word_length] = weight_container[word_length*2-1 -: word_length];
                    next_weight_container[word_length*3-1 -: word_length] = weight_value;
                    next_weight_container[word_length*4-1 -: word_length] = weight_container[word_length*4-1 -: word_length];
                end
                else if(counter[1:0]=='d3) begin
                    next_weight_container[word_length*1-1 -: word_length] = weight_container[word_length*1-1 -: word_length];
                    next_weight_container[word_length*2-1 -: word_length] = weight_container[word_length*2-1 -: word_length];
                    next_weight_container[word_length*3-1 -: word_length] = weight_container[word_length*3-1 -: word_length];
                    next_weight_container[word_length*4-1 -: word_length] = weight_value;
                end
                next_weight_cols_container[(counter+'d1)*col_length-1 -:col_length] = weight_cols;
                next_weight_rows_container[(counter+'d1)*col_length-1 -:col_length] = weight_rows;
                next_curr_weight_counter = curr_weight_counter;
                //load feature and reLOAD
                next_feature_container = {feature_container<<(word_length*matrix_width)} | {{((matrix_width-1)*word_length){1'b0}},feature_value};
                next_feature_cols_container = {feature_cols_container<<(col_length*matrix_width)} | {{((matrix_width-1)*col_length){1'b0}},feature_cols};
                next_feature_rows_container = {feature_rows_container<<(col_length*matrix_width)} | {{((matrix_width-1)*col_length){1'b0}},feature_rows};
                next_curr_pixel_counter = 'd0;
            end
            
        end
        else begin
            next_state = LOAD_FULL_IMAGE;
            next_counter = counter + 'd1;
            next_out_valid = 'd1;
            //not load weight
            next_weight_container = weight_container;
            next_weight_cols_container = weight_cols_container;
            next_weight_rows_container = weight_rows_container;
            next_curr_weight_counter = curr_weight_counter;
            //load feature
            next_feature_container = {feature_container<<(word_length*matrix_width)} | {{((matrix_width-1)*word_length){1'b0}},feature_value};
            next_feature_cols_container = {feature_cols_container<<(col_length*matrix_width)} | {{((matrix_width-1)*col_length){1'b0}},feature_cols};
            next_feature_rows_container = {feature_rows_container<<(col_length*matrix_width)} | {{((matrix_width-1)*col_length){1'b0}},feature_rows};
            next_curr_pixel_counter = curr_pixel_counter + 'd1;
        end
    end
    DONE:begin
            next_state = DONE;
            next_counter = counter;
            next_out_valid = 'd0;
            //not load weight
            next_weight_container = weight_container;
            next_weight_cols_container = weight_cols_container;
            next_weight_rows_container = weight_rows_container;
            next_curr_weight_counter = curr_weight_counter;
            //not load feature
            next_feature_container = feature_container;
            next_feature_cols_container = feature_cols_container;
            next_feature_rows_container = feature_rows_container;
            next_curr_pixel_counter = curr_pixel_counter;
    end
    endcase
end

always @(posedge clk or posedge rst) begin
    if(rst)begin
        curr_state <= IDLE;
        counter <= 'd0;
        out_valid <= 'd0;
        //value container
        weight_container <='d0;
        feature_container <='d0;
        //cols/rows container
        weight_cols_container <='d0;
        weight_rows_container <='d0;
        feature_cols_container <='d0;
        feature_rows_container <='d0;
        //data_counter
        curr_weight_counter <= 'd0;
        curr_pixel_counter <= 'd0;
    end
    else begin
        curr_state <= next_state;
        counter <= next_counter;
        out_valid <= next_out_valid;
        //value container
        weight_container <= next_weight_container;
        feature_container <= next_feature_container;
        //cols/rows container
        weight_cols_container <= next_weight_cols_container;
        weight_rows_container <= next_weight_rows_container;
        feature_cols_container <= next_feature_cols_container;
        feature_rows_container <= next_feature_rows_container;
        //data_counter
        curr_weight_counter <= next_curr_weight_counter;
        curr_pixel_counter <= next_curr_pixel_counter;
    end
end
endmodule