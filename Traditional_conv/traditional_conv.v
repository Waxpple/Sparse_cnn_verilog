module traditional_conv
#(
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
    input [kernel_size*kernel_size*word_length-1 :0] weight_value,
    input [word_length-1:0] pixels_0_0,
    input [word_length-1:0] pixels_0_1,
    input [word_length-1:0] pixels_0_2,
    input [word_length-1:0] pixels_0_3,
    input [word_length-1:0] pixels_0_4,
    input [word_length-1:0] pixels_1_0,
    input [word_length-1:0] pixels_1_1,
    input [word_length-1:0] pixels_1_2,
    input [word_length-1:0] pixels_1_3,
    input [word_length-1:0] pixels_1_4,
    input [word_length-1:0] pixels_2_0,
    input [word_length-1:0] pixels_2_1,
    input [word_length-1:0] pixels_2_2,
    input [word_length-1:0] pixels_2_3,
    input [word_length-1:0] pixels_2_4,
    input [word_length-1:0] pixels_3_0,
    input [word_length-1:0] pixels_3_1,
    input [word_length-1:0] pixels_3_2,
    input [word_length-1:0] pixels_3_3,
    input [word_length-1:0] pixels_3_4,
    input [word_length-1:0] pixels_4_0,
    input [word_length-1:0] pixels_4_1,
    input [word_length-1:0] pixels_4_2,
    input [word_length-1:0] pixels_4_3,
    input [word_length-1:0] pixels_4_4,
    output [word_length*2-1:0] result,
    output reg out_valid
    
);
reg [1:0] curr_state,next_state;
parameter IDLE = 2'b00;
parameter CAL = 2'b01;
parameter WAIT = 2'b10;
parameter DONE = 2'b11;

reg [double_word_length-1:0] counter,next_counter;


genvar i;

reg [kernel_size*kernel_size*word_length*2-1:0] data_out,next_data_out;

assign result = $signed(data_out[(0+1)*word_length*2-1 -:word_length*2]) + $signed(data_out[(1+1)*word_length*2-1 -:word_length*2]) + $signed(data_out[(2+1)*word_length*2-1 -:word_length*2]) + $signed(data_out[(3+1)*word_length*2-1 -:word_length*2]) + $signed(data_out[(4+1)*word_length*2-1 -:word_length*2]) + $signed(data_out[(5+1)*word_length*2-1 -:word_length*2]) + $signed(data_out[(6+1)*word_length*2-1 -:word_length*2]) + $signed(data_out[(7+1)*word_length*2-1 -:word_length*2]) + $signed(data_out[(8+1)*word_length*2-1 -:word_length*2]) + $signed(data_out[(9+1)*word_length*2-1 -:word_length*2]) + $signed(data_out[(10+1)*word_length*2-1 -:word_length*2]) + $signed(data_out[(11+1)*word_length*2-1 -:word_length*2]) + $signed(data_out[(12+1)*word_length*2-1 -:word_length*2]) + $signed(data_out[(13+1)*word_length*2-1 -:word_length*2]) + $signed(data_out[(14+1)*word_length*2-1 -:word_length*2]) + $signed(data_out[(15+1)*word_length*2-1 -:word_length*2]) + $signed(data_out[(16+1)*word_length*2-1 -:word_length*2]) + $signed(data_out[(17+1)*word_length*2-1 -:word_length*2]) + $signed(data_out[(18+1)*word_length*2-1 -:word_length*2]) + $signed(data_out[(19+1)*word_length*2-1 -:word_length*2]) + $signed(data_out[(20+1)*word_length*2-1 -:word_length*2]) + $signed(data_out[(21+1)*word_length*2-1 -:word_length*2]) + $signed(data_out[(22+1)*word_length*2-1 -:word_length*2]) + $signed(data_out[(23+1)*word_length*2-1 -:word_length*2]) + $signed(data_out[(24+1)*word_length*2-1 -:word_length*2]);

reg next_out_valid;
always @(*) begin
    
    case(curr_state)
    IDLE: begin
        if (in_valid) begin
            next_state = CAL;
            next_counter = counter + 'd1;
            next_data_out[(0+1)*word_length*2-1 -:word_length*2] = $signed(pixels_0_0) * $signed(weight_value[(0+1)*word_length-1 -: word_length]);
            next_data_out[(1+1)*word_length*2-1 -:word_length*2] = $signed(pixels_1_0) * $signed(weight_value[(1+1)*word_length-1 -: word_length]);
            next_data_out[(2+1)*word_length*2-1 -:word_length*2] = $signed(pixels_2_0) * $signed(weight_value[(2+1)*word_length-1 -: word_length]);
            next_data_out[(3+1)*word_length*2-1 -:word_length*2] = $signed(pixels_3_0) * $signed(weight_value[(3+1)*word_length-1 -: word_length]);
            next_data_out[(4+1)*word_length*2-1 -:word_length*2] = $signed(pixels_4_0) * $signed(weight_value[(4+1)*word_length-1 -: word_length]);
            next_data_out[(5+1)*word_length*2-1 -:word_length*2] = $signed(pixels_0_1) * $signed(weight_value[(5+1)*word_length-1 -: word_length]);
            next_data_out[(6+1)*word_length*2-1 -:word_length*2] = $signed(pixels_1_1) * $signed(weight_value[(6+1)*word_length-1 -: word_length]);
            next_data_out[(7+1)*word_length*2-1 -:word_length*2] = $signed(pixels_2_1) * $signed(weight_value[(7+1)*word_length-1 -: word_length]);
            next_data_out[(8+1)*word_length*2-1 -:word_length*2] = $signed(pixels_3_1) * $signed(weight_value[(8+1)*word_length-1 -: word_length]);
            next_data_out[(9+1)*word_length*2-1 -:word_length*2] = $signed(pixels_4_1) * $signed(weight_value[(9+1)*word_length-1 -: word_length]);
            next_data_out[(10+1)*word_length*2-1 -:word_length*2] = $signed(pixels_0_2) * $signed(weight_value[(10+1)*word_length-1 -: word_length]);
            next_data_out[(11+1)*word_length*2-1 -:word_length*2] = $signed(pixels_1_2) * $signed(weight_value[(11+1)*word_length-1 -: word_length]);
            next_data_out[(12+1)*word_length*2-1 -:word_length*2] = $signed(pixels_2_2) * $signed(weight_value[(12+1)*word_length-1 -: word_length]);
            next_data_out[(13+1)*word_length*2-1 -:word_length*2] = $signed(pixels_3_2) * $signed(weight_value[(13+1)*word_length-1 -: word_length]);
            next_data_out[(14+1)*word_length*2-1 -:word_length*2] = $signed(pixels_4_2) * $signed(weight_value[(14+1)*word_length-1 -: word_length]);
            next_data_out[(15+1)*word_length*2-1 -:word_length*2] = $signed(pixels_0_3) * $signed(weight_value[(15+1)*word_length-1 -: word_length]);
            next_data_out[(16+1)*word_length*2-1 -:word_length*2] = $signed(pixels_1_3) * $signed(weight_value[(16+1)*word_length-1 -: word_length]);
            next_data_out[(17+1)*word_length*2-1 -:word_length*2] = $signed(pixels_2_3) * $signed(weight_value[(17+1)*word_length-1 -: word_length]);
            next_data_out[(18+1)*word_length*2-1 -:word_length*2] = $signed(pixels_3_3) * $signed(weight_value[(18+1)*word_length-1 -: word_length]);
            next_data_out[(19+1)*word_length*2-1 -:word_length*2] = $signed(pixels_4_3) * $signed(weight_value[(19+1)*word_length-1 -: word_length]);
            next_data_out[(20+1)*word_length*2-1 -:word_length*2] = $signed(pixels_0_4) * $signed(weight_value[(20+1)*word_length-1 -: word_length]);
            next_data_out[(21+1)*word_length*2-1 -:word_length*2] = $signed(pixels_1_4) * $signed(weight_value[(21+1)*word_length-1 -: word_length]);
            next_data_out[(22+1)*word_length*2-1 -:word_length*2] = $signed(pixels_2_4) * $signed(weight_value[(22+1)*word_length-1 -: word_length]);
            next_data_out[(23+1)*word_length*2-1 -:word_length*2] = $signed(pixels_3_4) * $signed(weight_value[(23+1)*word_length-1 -: word_length]);
            next_data_out[(24+1)*word_length*2-1 -:word_length*2] = $signed(pixels_4_4) * $signed(weight_value[(24+1)*word_length-1 -: word_length]);
            next_out_valid = 'd1;
        end
        else begin
            next_state = IDLE;
            next_counter = counter;
            next_data_out = 'd0;
            next_out_valid = 'd0;
        end
    end
    CAL: begin
        if (counter ==image_size-(kernel_size/2)*2)begin
            if (in_valid)begin
                next_state = WAIT;
                next_counter = 'd0;
                next_data_out[(0+1)*word_length*2-1 -:word_length*2] = $signed(pixels_0_0) * $signed(weight_value[(0+1)*word_length-1 -: word_length]);
                next_data_out[(1+1)*word_length*2-1 -:word_length*2] = $signed(pixels_1_0) * $signed(weight_value[(1+1)*word_length-1 -: word_length]);
                next_data_out[(2+1)*word_length*2-1 -:word_length*2] = $signed(pixels_2_0) * $signed(weight_value[(2+1)*word_length-1 -: word_length]);
                next_data_out[(3+1)*word_length*2-1 -:word_length*2] = $signed(pixels_3_0) * $signed(weight_value[(3+1)*word_length-1 -: word_length]);
                next_data_out[(4+1)*word_length*2-1 -:word_length*2] = $signed(pixels_4_0) * $signed(weight_value[(4+1)*word_length-1 -: word_length]);
                next_data_out[(5+1)*word_length*2-1 -:word_length*2] = $signed(pixels_0_1) * $signed(weight_value[(5+1)*word_length-1 -: word_length]);
                next_data_out[(6+1)*word_length*2-1 -:word_length*2] = $signed(pixels_1_1) * $signed(weight_value[(6+1)*word_length-1 -: word_length]);
                next_data_out[(7+1)*word_length*2-1 -:word_length*2] = $signed(pixels_2_1) * $signed(weight_value[(7+1)*word_length-1 -: word_length]);
                next_data_out[(8+1)*word_length*2-1 -:word_length*2] = $signed(pixels_3_1) * $signed(weight_value[(8+1)*word_length-1 -: word_length]);
                next_data_out[(9+1)*word_length*2-1 -:word_length*2] = $signed(pixels_4_1) * $signed(weight_value[(9+1)*word_length-1 -: word_length]);
                next_data_out[(10+1)*word_length*2-1 -:word_length*2] = $signed(pixels_0_2) * $signed(weight_value[(10+1)*word_length-1 -: word_length]);
                next_data_out[(11+1)*word_length*2-1 -:word_length*2] = $signed(pixels_1_2) * $signed(weight_value[(11+1)*word_length-1 -: word_length]);
                next_data_out[(12+1)*word_length*2-1 -:word_length*2] = $signed(pixels_2_2) * $signed(weight_value[(12+1)*word_length-1 -: word_length]);
                next_data_out[(13+1)*word_length*2-1 -:word_length*2] = $signed(pixels_3_2) * $signed(weight_value[(13+1)*word_length-1 -: word_length]);
                next_data_out[(14+1)*word_length*2-1 -:word_length*2] = $signed(pixels_4_2) * $signed(weight_value[(14+1)*word_length-1 -: word_length]);
                next_data_out[(15+1)*word_length*2-1 -:word_length*2] = $signed(pixels_0_3) * $signed(weight_value[(15+1)*word_length-1 -: word_length]);
                next_data_out[(16+1)*word_length*2-1 -:word_length*2] = $signed(pixels_1_3) * $signed(weight_value[(16+1)*word_length-1 -: word_length]);
                next_data_out[(17+1)*word_length*2-1 -:word_length*2] = $signed(pixels_2_3) * $signed(weight_value[(17+1)*word_length-1 -: word_length]);
                next_data_out[(18+1)*word_length*2-1 -:word_length*2] = $signed(pixels_3_3) * $signed(weight_value[(18+1)*word_length-1 -: word_length]);
                next_data_out[(19+1)*word_length*2-1 -:word_length*2] = $signed(pixels_4_3) * $signed(weight_value[(19+1)*word_length-1 -: word_length]);
                next_data_out[(20+1)*word_length*2-1 -:word_length*2] = $signed(pixels_0_4) * $signed(weight_value[(20+1)*word_length-1 -: word_length]);
                next_data_out[(21+1)*word_length*2-1 -:word_length*2] = $signed(pixels_1_4) * $signed(weight_value[(21+1)*word_length-1 -: word_length]);
                next_data_out[(22+1)*word_length*2-1 -:word_length*2] = $signed(pixels_2_4) * $signed(weight_value[(22+1)*word_length-1 -: word_length]);
                next_data_out[(23+1)*word_length*2-1 -:word_length*2] = $signed(pixels_3_4) * $signed(weight_value[(23+1)*word_length-1 -: word_length]);
                next_data_out[(24+1)*word_length*2-1 -:word_length*2] = $signed(pixels_4_4) * $signed(weight_value[(24+1)*word_length-1 -: word_length]);
                next_out_valid = 'd0;
            end
            else begin
                next_state = DONE;
                next_counter = 'd0;
                next_data_out = data_out;
                next_out_valid = 'd0;
            end
        end
        else begin
            next_state = CAL;
            next_counter = counter + 'd1;
            next_data_out[(0+1)*word_length*2-1 -:word_length*2] = $signed(pixels_0_0) * $signed(weight_value[(0+1)*word_length-1 -: word_length]);
            next_data_out[(1+1)*word_length*2-1 -:word_length*2] = $signed(pixels_1_0) * $signed(weight_value[(1+1)*word_length-1 -: word_length]);
            next_data_out[(2+1)*word_length*2-1 -:word_length*2] = $signed(pixels_2_0) * $signed(weight_value[(2+1)*word_length-1 -: word_length]);
            next_data_out[(3+1)*word_length*2-1 -:word_length*2] = $signed(pixels_3_0) * $signed(weight_value[(3+1)*word_length-1 -: word_length]);
            next_data_out[(4+1)*word_length*2-1 -:word_length*2] = $signed(pixels_4_0) * $signed(weight_value[(4+1)*word_length-1 -: word_length]);
            next_data_out[(5+1)*word_length*2-1 -:word_length*2] = $signed(pixels_0_1) * $signed(weight_value[(5+1)*word_length-1 -: word_length]);
            next_data_out[(6+1)*word_length*2-1 -:word_length*2] = $signed(pixels_1_1) * $signed(weight_value[(6+1)*word_length-1 -: word_length]);
            next_data_out[(7+1)*word_length*2-1 -:word_length*2] = $signed(pixels_2_1) * $signed(weight_value[(7+1)*word_length-1 -: word_length]);
            next_data_out[(8+1)*word_length*2-1 -:word_length*2] = $signed(pixels_3_1) * $signed(weight_value[(8+1)*word_length-1 -: word_length]);
            next_data_out[(9+1)*word_length*2-1 -:word_length*2] = $signed(pixels_4_1) * $signed(weight_value[(9+1)*word_length-1 -: word_length]);
            next_data_out[(10+1)*word_length*2-1 -:word_length*2] = $signed(pixels_0_2) * $signed(weight_value[(10+1)*word_length-1 -: word_length]);
            next_data_out[(11+1)*word_length*2-1 -:word_length*2] = $signed(pixels_1_2) * $signed(weight_value[(11+1)*word_length-1 -: word_length]);
            next_data_out[(12+1)*word_length*2-1 -:word_length*2] = $signed(pixels_2_2) * $signed(weight_value[(12+1)*word_length-1 -: word_length]);
            next_data_out[(13+1)*word_length*2-1 -:word_length*2] = $signed(pixels_3_2) * $signed(weight_value[(13+1)*word_length-1 -: word_length]);
            next_data_out[(14+1)*word_length*2-1 -:word_length*2] = $signed(pixels_4_2) * $signed(weight_value[(14+1)*word_length-1 -: word_length]);
            next_data_out[(15+1)*word_length*2-1 -:word_length*2] = $signed(pixels_0_3) * $signed(weight_value[(15+1)*word_length-1 -: word_length]);
            next_data_out[(16+1)*word_length*2-1 -:word_length*2] = $signed(pixels_1_3) * $signed(weight_value[(16+1)*word_length-1 -: word_length]);
            next_data_out[(17+1)*word_length*2-1 -:word_length*2] = $signed(pixels_2_3) * $signed(weight_value[(17+1)*word_length-1 -: word_length]);
            next_data_out[(18+1)*word_length*2-1 -:word_length*2] = $signed(pixels_3_3) * $signed(weight_value[(18+1)*word_length-1 -: word_length]);
            next_data_out[(19+1)*word_length*2-1 -:word_length*2] = $signed(pixels_4_3) * $signed(weight_value[(19+1)*word_length-1 -: word_length]);
            next_data_out[(20+1)*word_length*2-1 -:word_length*2] = $signed(pixels_0_4) * $signed(weight_value[(20+1)*word_length-1 -: word_length]);
            next_data_out[(21+1)*word_length*2-1 -:word_length*2] = $signed(pixels_1_4) * $signed(weight_value[(21+1)*word_length-1 -: word_length]);
            next_data_out[(22+1)*word_length*2-1 -:word_length*2] = $signed(pixels_2_4) * $signed(weight_value[(22+1)*word_length-1 -: word_length]);
            next_data_out[(23+1)*word_length*2-1 -:word_length*2] = $signed(pixels_3_4) * $signed(weight_value[(23+1)*word_length-1 -: word_length]);
            next_data_out[(24+1)*word_length*2-1 -:word_length*2] = $signed(pixels_4_4) * $signed(weight_value[(24+1)*word_length-1 -: word_length]);
            next_out_valid = 'd1;
        end
    end
    WAIT: begin
        if (counter==kernel_size-2)begin
            next_state = CAL;
            next_counter = 'd1;
            next_data_out[(0+1)*word_length*2-1 -:word_length*2] = $signed(pixels_0_0) * $signed(weight_value[(0+1)*word_length-1 -: word_length]);
            next_data_out[(1+1)*word_length*2-1 -:word_length*2] = $signed(pixels_1_0) * $signed(weight_value[(1+1)*word_length-1 -: word_length]);
            next_data_out[(2+1)*word_length*2-1 -:word_length*2] = $signed(pixels_2_0) * $signed(weight_value[(2+1)*word_length-1 -: word_length]);
            next_data_out[(3+1)*word_length*2-1 -:word_length*2] = $signed(pixels_3_0) * $signed(weight_value[(3+1)*word_length-1 -: word_length]);
            next_data_out[(4+1)*word_length*2-1 -:word_length*2] = $signed(pixels_4_0) * $signed(weight_value[(4+1)*word_length-1 -: word_length]);
            next_data_out[(5+1)*word_length*2-1 -:word_length*2] = $signed(pixels_0_1) * $signed(weight_value[(5+1)*word_length-1 -: word_length]);
            next_data_out[(6+1)*word_length*2-1 -:word_length*2] = $signed(pixels_1_1) * $signed(weight_value[(6+1)*word_length-1 -: word_length]);
            next_data_out[(7+1)*word_length*2-1 -:word_length*2] = $signed(pixels_2_1) * $signed(weight_value[(7+1)*word_length-1 -: word_length]);
            next_data_out[(8+1)*word_length*2-1 -:word_length*2] = $signed(pixels_3_1) * $signed(weight_value[(8+1)*word_length-1 -: word_length]);
            next_data_out[(9+1)*word_length*2-1 -:word_length*2] = $signed(pixels_4_1) * $signed(weight_value[(9+1)*word_length-1 -: word_length]);
            next_data_out[(10+1)*word_length*2-1 -:word_length*2] = $signed(pixels_0_2) * $signed(weight_value[(10+1)*word_length-1 -: word_length]);
            next_data_out[(11+1)*word_length*2-1 -:word_length*2] = $signed(pixels_1_2) * $signed(weight_value[(11+1)*word_length-1 -: word_length]);
            next_data_out[(12+1)*word_length*2-1 -:word_length*2] = $signed(pixels_2_2) * $signed(weight_value[(12+1)*word_length-1 -: word_length]);
            next_data_out[(13+1)*word_length*2-1 -:word_length*2] = $signed(pixels_3_2) * $signed(weight_value[(13+1)*word_length-1 -: word_length]);
            next_data_out[(14+1)*word_length*2-1 -:word_length*2] = $signed(pixels_4_2) * $signed(weight_value[(14+1)*word_length-1 -: word_length]);
            next_data_out[(15+1)*word_length*2-1 -:word_length*2] = $signed(pixels_0_3) * $signed(weight_value[(15+1)*word_length-1 -: word_length]);
            next_data_out[(16+1)*word_length*2-1 -:word_length*2] = $signed(pixels_1_3) * $signed(weight_value[(16+1)*word_length-1 -: word_length]);
            next_data_out[(17+1)*word_length*2-1 -:word_length*2] = $signed(pixels_2_3) * $signed(weight_value[(17+1)*word_length-1 -: word_length]);
            next_data_out[(18+1)*word_length*2-1 -:word_length*2] = $signed(pixels_3_3) * $signed(weight_value[(18+1)*word_length-1 -: word_length]);
            next_data_out[(19+1)*word_length*2-1 -:word_length*2] = $signed(pixels_4_3) * $signed(weight_value[(19+1)*word_length-1 -: word_length]);
            next_data_out[(20+1)*word_length*2-1 -:word_length*2] = $signed(pixels_0_4) * $signed(weight_value[(20+1)*word_length-1 -: word_length]);
            next_data_out[(21+1)*word_length*2-1 -:word_length*2] = $signed(pixels_1_4) * $signed(weight_value[(21+1)*word_length-1 -: word_length]);
            next_data_out[(22+1)*word_length*2-1 -:word_length*2] = $signed(pixels_2_4) * $signed(weight_value[(22+1)*word_length-1 -: word_length]);
            next_data_out[(23+1)*word_length*2-1 -:word_length*2] = $signed(pixels_3_4) * $signed(weight_value[(23+1)*word_length-1 -: word_length]);
            next_data_out[(24+1)*word_length*2-1 -:word_length*2] = $signed(pixels_4_4) * $signed(weight_value[(24+1)*word_length-1 -: word_length]);
            next_out_valid = 'd1;
        end
        else begin
            next_state = WAIT;
            next_counter = counter +'d1;
            next_data_out = 'd0;
            next_out_valid = 'd0;
        end
    end
    DONE: begin
        next_state = DONE;
        next_counter = 'd0;
        next_data_out = 'd0;
        next_out_valid = 'd0;
    end
    endcase
    
end

always @(posedge clk or posedge rst) begin
    if(rst)begin
        counter <= 'd0;
        curr_state <= IDLE;
        data_out <= 'd0;
        out_valid <= 'd0;
    end
    else begin
        counter <= next_counter;
        curr_state <= next_state;
        data_out <= next_data_out;
        out_valid <= next_out_valid;
    end
end



endmodule