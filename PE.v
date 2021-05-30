module PE
#(
    
    parameter col_length = 5,
    parameter wordlength = 16
)
(
    input clk,
    input irst_n,
    input in_valid,
    input [15:0] pixels,
    input [5:0] in_channel,
    input [col_length*1 -1:0]weight_cols,
    input [col_length*1 -1:0]weight_rows,
    input signed [wordlength*1 -1:0]weight,

    input [col_length*4 -1:0]data_in_cols,
    input [col_length*4 -1:0]data_in_rows,
    input signed [wordlength*4 -1:0]data_in,
    output reg signed [5:0] out_channel,
    output signed [wordlength*16 -1:0]data_out,
    output reg unsigned [col_length*16 -1:0]data_out_cols,
    output reg unsigned [col_length*16 -1:0]data_out_rows,
    output reg out_valid
);

//state
parameter IDLE = 2'b00;
parameter LOAD_WEIGHT = 2'b01;
parameter LOAD_FULL_IMAGE = 2'b10;
reg [1:0] curr_state,next_state;


reg [15:0] counter, next_counter;
reg [wordlength*4-1:0] weight_container, next_weight_container;
reg [wordlength*16-1:0] activation_container, next_activation_container;
reg [col_length*16-1:0] cols_container, next_cols_container;
reg [col_length*16-1:0] rows_container, next_rows_container;
//input FF
reg signed [wordlength*1 -1:0] reg_weight,reg_weight_2;
reg signed [wordlength*4 -1:0] reg_data_in,reg_data_in_2;
reg [5:0] reg_in_channel,reg_in_channel_2;
reg signed [col_length-1:0] reg_weight_cols,reg_weight_cols_2;
reg signed [col_length-1:0] reg_weight_rows,reg_weight_rows_2;

reg signed [wordlength*4-1:0] reg_data_in_cols,reg_data_in_cols_2;
reg signed [wordlength*4-1:0] reg_data_in_rows,reg_data_in_rows_2;


wire signed [wordlength-1:0] answer_1_1,answer_1_2,answer_1_3,answer_1_4; 

assign answer_1_1 = weight_container[15:0] * activation_container[15:0];
assign answer_1_2 = weight_container[15:0] * activation_container[31:16];
assign answer_1_3 = weight_container[15:0] * activation_container[47:32];
assign answer_1_4 = weight_container[15:0] * activation_container[63:48];
assign data_out[63:0] = {answer_1_4,answer_1_3,answer_1_2,answer_1_1};
assign data_out[127:64] = {answer_1_4,answer_1_3,answer_1_2,answer_1_1};
assign data_out[191:128] = {answer_1_4,answer_1_3,answer_1_2,answer_1_1};
assign data_out[255:192] = {answer_1_4,answer_1_3,answer_1_2,answer_1_1};
//state reg
always@(posedge clk or negedge irst_n)begin
    if(!irst_n)begin
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
                    end 
                    else begin
                        next_state = IDLE;
                        next_counter = counter;
                    end
    LOAD_WEIGHT:    if(counter=='d4) begin 
                        next_state = LOAD_FULL_IMAGE;
                        next_counter = counter +'d1;
                    end
                    else begin
                        next_state = LOAD_WEIGHT;
                        next_counter = counter +'d1;
                    end
    LOAD_FULL_IMAGE:    if(counter== pixels) begin
                            next_state = LOAD_WEIGHT;
                            next_counter = 'd1;
                        end
                        else begin 
                            next_state = LOAD_FULL_IMAGE;
                            next_counter = counter +'d1;
                        end
    default:begin      next_state = IDLE;
                        next_counter = counter;
            end
    endcase
end



always@(*)begin
    
    
    next_weight_container = weight_container;
    next_activation_container = activation_container;
    next_cols_container = cols_container;
    next_rows_container = rows_container;
    

end

always@(posedge clk or negedge irst_n)begin
    if(!irst_n)begin
    
        //data_out <= 'd0;
        data_out_cols <= 'd0;
        data_out_rows <= 'd0;
        out_channel <= 'd0;
        out_valid <= 'd0;
        counter <= 'd0;
        weight_container <='d0;
        activation_container <='d0;
        activation_container <='d0;
        cols_container <='d0;
        rows_container <='d0;
        //input FF 
        reg_weight <= 'd0;
        reg_data_in <= 'd0;
        reg_weight_2 <= 'd0;
        reg_data_in_2 <= 'd0;
        reg_in_channel <= 'd0;
        reg_in_channel_2 <= 'd0;
        reg_weight_cols <= 'd0;
        reg_weight_cols_2 <= 'd0;
        reg_weight_rows <= 'd0;
        reg_weight_rows_2 <= 'd0;
        reg_data_in_cols <= 'd0;
        reg_data_in_cols_2 <= 'd0;
        reg_data_in_rows <= 'd0;
        reg_data_in_rows_2 <= 'd0;
    end
    else begin
        //status 1 load the weight and activation before full
        //push input into container

        //
        //Wrong method
        ////weight_container <= (next_weight_container << wordlength) + weight;
        //
        
        
        
        if (in_valid)begin
            //input FF
            reg_weight <= weight;
            reg_data_in <= data_in;
            reg_weight_2 <= reg_weight;
            reg_data_in_2 <= reg_data_in;
            reg_in_channel <= in_channel;
            reg_in_channel_2 <= reg_in_channel;
            reg_weight_cols <= weight_cols;
            reg_weight_cols_2 <= reg_weight_cols;
            reg_weight_rows <= weight_rows;
            reg_weight_rows_2 <= reg_weight_rows;
            reg_data_in_cols <= data_in_cols;
            reg_data_in_cols_2 <= reg_data_in_cols;
            reg_data_in_rows <= data_in_rows;
            reg_data_in_rows_2 <= reg_data_in_rows;
            if(curr_state == LOAD_WEIGHT)begin
                //Mux can be parralle
                if (counter[1:0]=='d1) weight_container[wordlength-1:0] <= reg_weight_2;
                else if (counter[1:0]=='d2) weight_container[wordlength*2-1:wordlength*1] <= reg_weight_2;
                else if (counter[1:0]=='d3) weight_container[wordlength*3-1:wordlength*2] <= reg_weight_2;
                else weight_container[wordlength*4-1:wordlength*3] <= reg_weight_2;
            end
            activation_container <= (next_activation_container << wordlength*4) + reg_data_in_2;


            //calculate
            //

            
        end
        counter <= next_counter;
        
    end
end
endmodule