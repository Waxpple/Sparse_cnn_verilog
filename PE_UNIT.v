module PE_UNIT
#(
    
    parameter col_length = 8,
    parameter word_length = 8,
    parameter double_word_length = 16,
    parameter kernel_size = 5,
    parameter image_size = 7
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
assign curr_pixel = (curr_pixel_counter>feature_valid_num)?'d0:curr_pixel_counter;
assign curr_weight = (curr_weight_counter>weight_valid_num)?'d0:curr_weight_counter;
reg next_out_valid,out_valid_2;
//counter
reg [double_word_length-1:0] counter, next_counter;
//weight container
reg [word_length*4-1:0] weight_container;
reg [col_length*4-1:0] weight_cols_container, weight_next_cols_container;
reg [col_length*4-1:0] weight_rows_container, weight_next_rows_container;

//feature container
reg [word_length*16-1:0] feature_container, feature_next_container;
reg [col_length*16-1:0] feature_cols_container, feature_next_cols_container;
reg [col_length*16-1:0] feature_rows_container, feature_next_rows_container;
//input FF
reg signed [word_length*1 -1:0] reg_weight_value,reg_weight_value_2;
reg signed [word_length*4 -1:0] reg_feature_value,reg_feature_value_2;
reg [double_word_length-1:0] reg_in_channel,reg_in_channel_2;
reg signed [col_length-1:0] reg_weight_cols,reg_weight_cols_2;
reg signed [col_length-1:0] reg_weight_rows,reg_weight_rows_2;
reg signed [col_length*4-1:0] reg_feature_cols,reg_feature_cols_2;
reg signed [col_length*4-1:0] reg_feature_rows,reg_feature_rows_2;



wire signed [word_length*2-1:0] answer_1_1,answer_1_2,answer_1_3,answer_1_4,answer_2_1,answer_2_2,answer_2_3,answer_2_4,answer_3_1,answer_3_2,answer_3_3,answer_3_4,answer_4_1,answer_4_2,answer_4_3,answer_4_4; 
wire signed [col_length-1:0] col_answer_1_1,col_answer_1_2,col_answer_1_3,col_answer_1_4,col_answer_2_1,col_answer_2_2,col_answer_2_3,col_answer_2_4,col_answer_3_1,col_answer_3_2,col_answer_3_3,col_answer_3_4,col_answer_4_1,col_answer_4_2,col_answer_4_3,col_answer_4_4; 
wire signed [col_length-1:0] row_answer_1_1,row_answer_1_2,row_answer_1_3,row_answer_1_4,row_answer_2_1,row_answer_2_2,row_answer_2_3,row_answer_2_4,row_answer_3_1,row_answer_3_2,row_answer_3_3,row_answer_3_4,row_answer_4_1,row_answer_4_2,row_answer_4_3,row_answer_4_4; 

//answer is weight * feature

//assign answer_1_1 = (out_valid==1'b1)? $signed({ {word_length{weight_container[word_length-1]}},weight_container[word_length-1 -:word_length]}) * $signed({ {word_length{feature_container[(word_length*1)-1]}},feature_container[(word_length*1)-1 -:word_length]})  :'d0;
//assign answer_1_1 = (out_valid==1'b1)? $signed(weight_container[word_length-1:0] * feature_container[(word_length*1)-1 -:word_length]):'d0;
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

// perform fixpoint multiplication
// assign data_out[word_length*4 -1 -:word_length*4] = {{answer_1_4[(word_length+word_length/2)-1 -:word_length]},{answer_1_3[(word_length+word_length/2)-1 -:word_length]},{answer_1_2[(word_length+word_length/2)-1 -:word_length]},{answer_1_1[(word_length+word_length/2)-1 -:word_length]}};
// assign data_out[word_length*8 -1 -:word_length*4] = {{answer_2_4[(word_length+word_length/2)-1 -:word_length]},{answer_2_3[(word_length+word_length/2)-1 -:word_length]},{answer_2_2[(word_length+word_length/2)-1 -:word_length]},{answer_2_1[(word_length+word_length/2)-1 -:word_length]}};
// assign data_out[word_length*12 -1 -:word_length*4] = {{answer_3_4[(word_length+word_length/2)-1 -:word_length]},{answer_3_3[(word_length+word_length/2)-1 -:word_length]},{answer_3_2[(word_length+word_length/2)-1 -:word_length]},{answer_3_1[(word_length+word_length/2)-1 -:word_length]}};
// assign data_out[word_length*16 -1 -:word_length*4] = {{answer_4_4[(word_length+word_length/2)-1 -:word_length]},{answer_4_3[(word_length+word_length/2)-1 -:word_length]},{answer_4_2[(word_length+word_length/2)-1 -:word_length]},{answer_4_1[(word_length+word_length/2)-1 -:word_length]}};

assign data_out[word_length*2*4 -1 -:word_length*2*4] = {{answer_1_4},{answer_1_3},{answer_1_2},{answer_1_1}};
assign data_out[word_length*2*8 -1 -:word_length*2*4] = {{answer_2_4},{answer_2_3},{answer_2_2},{answer_2_1}};
assign data_out[word_length*2*12 -1 -:word_length*2*4] = {{answer_3_4},{answer_3_3},{answer_3_2},{answer_3_1}};
assign data_out[word_length*2*16 -1 -:word_length*2*4] = {{answer_4_4},{answer_4_3},{answer_4_2},{answer_4_1}};

//{4 3 2 1}
assign data_out_cols = {col_answer_4_4,col_answer_4_3,col_answer_4_2,col_answer_4_1, col_answer_3_4,col_answer_3_3,col_answer_3_2,col_answer_3_1, col_answer_2_4,col_answer_2_3,col_answer_2_2,col_answer_2_1, col_answer_1_4,col_answer_1_3,col_answer_1_2,col_answer_1_1};
assign data_out_rows = {row_answer_4_4,row_answer_4_3,row_answer_4_2,row_answer_4_1, row_answer_3_4,row_answer_3_3,row_answer_3_2,row_answer_3_1, row_answer_2_4,row_answer_2_3,row_answer_2_2,row_answer_2_1, row_answer_1_4,row_answer_1_3,row_answer_1_2,row_answer_1_1};

assign out_channel = reg_in_channel_2;



//state reg
always@(posedge clk or posedge rst)begin
    if(rst)begin
        curr_state <= IDLE;
    end
    else curr_state<= next_state;
end

//next state logic
always@(*)begin
    case(curr_state)
    IDLE:           if(in_valid) begin
                        next_state = LOAD_WEIGHT;
                        next_counter = counter +'d1;
                        next_curr_pixel_counter = curr_pixel_counter+'d1;
                        next_curr_weight_counter = curr_weight_counter+'d1;
                        next_out_valid = 'd1;
                    end 
                    else begin
                        next_state = IDLE;
                        next_counter = counter;
                        next_curr_pixel_counter = curr_pixel_counter+'d1;
                        next_curr_weight_counter = curr_weight_counter +'d1;
                        next_out_valid = 'd0;
                    end
    LOAD_WEIGHT:    if(counter=='d4) begin 
                        next_state = LOAD_FULL_IMAGE;
                        next_counter = counter +'d1;
                        next_curr_pixel_counter = curr_pixel_counter+'d1;
                        next_curr_weight_counter = curr_weight_counter;
                        next_out_valid = 'd1;
                    end
                    else begin
                        next_state = LOAD_WEIGHT;
                        next_counter = counter +'d1;
                        next_curr_pixel_counter = curr_pixel_counter+'d1;
                        next_curr_weight_counter = (counter=='d3)?curr_weight_counter:curr_weight_counter+'d1;
                        next_out_valid = 'd1;
                    end
    LOAD_FULL_IMAGE:    if(counter== feature_valid_num) begin
                            if(curr_weight_counter > weight_valid_num)begin
                                next_state = DONE;
                                next_counter = 'd0;
                                next_curr_pixel_counter = 'd1;
                                next_curr_weight_counter = curr_weight_counter+'d1;
                                next_out_valid = 'd1;
                            end
                            else begin
                            next_state = IDLE;
                            next_counter = 'd0;
                            next_curr_pixel_counter = 'd1;
                            next_curr_weight_counter = curr_weight_counter+'d1;
                            next_out_valid = 'd1;
                            end
                        end
                        else begin 
                            next_state = LOAD_FULL_IMAGE;
                            next_counter = counter +'d1;
                            next_curr_pixel_counter = curr_pixel_counter+'d1;
                            next_curr_weight_counter = curr_weight_counter;
                            next_out_valid = 'd1;
                        end
    DONE:begin          next_state = DONE;
                        next_counter = counter;
                        next_curr_pixel_counter = curr_pixel_counter;
                        next_curr_weight_counter = curr_weight_counter;
                        next_out_valid = 'd0;
            end
    endcase
end



always@(*)begin
    feature_next_container = feature_container;

    weight_next_cols_container = weight_cols_container;
    weight_next_rows_container = weight_rows_container;
    
    feature_next_cols_container = feature_cols_container;
    feature_next_rows_container = feature_rows_container;
    
    
    
end

always@(posedge clk or posedge rst)begin
    if(rst)begin
        out_valid <= 'd0;
        out_valid_2 <= 'd0;
        counter <= 'd0;

        //value container
        weight_container <='d0;
        feature_container <='d0;
        //cols/rows container
        weight_cols_container <='d0;
        weight_rows_container <='d0;
        feature_cols_container <='d0;
        feature_rows_container <='d0;
        
        //input FF 
        reg_weight_value <= 'd0;
        reg_feature_value <= 'd0;
        reg_weight_value_2 <= 'd0;
        reg_feature_value_2 <= 'd0;
        reg_in_channel <= 'd0;
        reg_in_channel_2 <= 'd0;
        reg_weight_cols <= 'd0;
        reg_weight_cols_2 <= 'd0;
        reg_weight_rows <= 'd0;
        reg_weight_rows_2 <= 'd0;
        reg_feature_cols <= 'd0;
        reg_feature_cols_2 <= 'd0;
        reg_feature_rows <= 'd0;
        reg_feature_rows_2 <= 'd0;

        //output counter
        curr_weight_counter <= 'd0;
        curr_pixel_counter <= 'd0;
    end
    else begin
        if (in_valid)begin
            //input FF
            reg_feature_value <= feature_value;
            reg_feature_value_2 <= reg_feature_value;

            reg_weight_value <= weight_value;
            reg_weight_value_2 <= reg_weight_value;
            

            reg_in_channel <= in_channel;
            reg_in_channel_2 <= reg_in_channel;

            reg_weight_cols <= weight_cols;
            reg_weight_cols_2 <= reg_weight_cols;

            reg_weight_rows <= weight_rows;
            reg_weight_rows_2 <= reg_weight_rows;

            reg_feature_cols <= feature_cols;
            reg_feature_cols_2 <= reg_feature_cols;

            reg_feature_rows <= feature_rows;
            reg_feature_rows_2 <= reg_feature_rows;

            if(curr_state == LOAD_WEIGHT)begin
                //Mux can be parralle
                if (counter[1:0]=='d1) begin
                    weight_container[word_length-1 -:word_length] <= reg_weight_value_2;
                    weight_cols_container[col_length-1 -:col_length] <= reg_weight_cols_2;
                    weight_rows_container[col_length-1 -:col_length] <= reg_weight_rows_2;
                end
                else if (counter[1:0]=='d2) begin 
                    weight_container[word_length*2-1 -:word_length] <= reg_weight_value_2;
                    weight_cols_container[col_length*2-1 -:col_length] <= reg_weight_cols_2;
                    weight_rows_container[col_length*2-1 -:col_length] <= reg_weight_rows_2;
                end
                else if (counter[1:0]=='d3) begin
                    weight_container[word_length*3-1 -:word_length] <= reg_weight_value_2;
                    weight_cols_container[col_length*3-1 -:col_length] <= reg_weight_cols_2;
                    weight_rows_container[col_length*3-1 -:col_length] <= reg_weight_rows_2;
                end
                else begin 
                    weight_container[word_length*4-1 -:word_length] <= reg_weight_value_2;
                    weight_cols_container[col_length*4-1 -:col_length] <= reg_weight_cols_2;
                    weight_rows_container[col_length*4-1 -:col_length] <= reg_weight_rows_2;
                end
                // wrong method ! no shift
                //weight_cols_container <= (weight_next_cols_container << col_length) + reg_weight_cols_2;
                //weight_rows_container <= (weight_next_rows_container << col_length) + reg_weight_rows_2;
                //out_valid <= 'd1;
                
            end
            
            
            
            feature_container <= (feature_next_container << word_length*4) + reg_feature_value_2;
            
            feature_cols_container <= (feature_next_cols_container << col_length*4 ) + reg_feature_cols_2;
            feature_rows_container <= (feature_next_rows_container << col_length*4 ) + reg_feature_rows_2;
            out_valid_2 <= next_out_valid;
            out_valid <= out_valid_2;
            //calculate
            //
            curr_pixel_counter <= next_curr_pixel_counter;
            curr_weight_counter <= next_curr_weight_counter;    
            counter <= next_counter;
        end

        
        
    end
end
endmodule