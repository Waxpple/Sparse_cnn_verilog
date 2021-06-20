module conv#(
    parameter col_length = 8,
    parameter word_length = 8,
    parameter double_word_length = 16,
    parameter kernel_size = 5,
    parameter image_size = 36
)(
    input clk,
    input rst,
    input in_valid,
    input [kernel_size*kernel_size*word_length-1 :0] weight_value,
    input [word_length-1:0] data_in,
    output reg [(image_size-(kernel_size-kernel_size%2))*(image_size-(kernel_size-kernel_size%2))*word_length*2-1:0] data_out,
    output out_valid
);

wire signed [word_length-1:0] pixels_0_0,pixels_0_1,pixels_0_2,pixels_0_3,pixels_0_4,pixels_1_0,pixels_1_1,pixels_1_2,pixels_1_3,pixels_1_4,pixels_2_0,pixels_2_1,pixels_2_2,pixels_2_3,pixels_2_4,pixels_3_0,pixels_3_1,pixels_3_2,pixels_3_3,pixels_3_4,pixels_4_0,pixels_4_1,pixels_4_2,pixels_4_3,pixels_4_4;
wire line_buffer_5x5_out_valid,traditional_conv_out_valid;
reg [double_word_length-1:0] counter,next_counter;
wire signed [word_length*2-1:0] result;

always @(*) begin
    next_counter = counter + 'd1;
end

always @(posedge clk or posedge rst) begin
    if (rst)begin
        data_out <= 'd0;
        counter <= 'd0;
    end
    else if (traditional_conv_out_valid)begin
        data_out[(counter+1)*word_length*2-1 -: word_length*2] <= result;
        counter <= next_counter;
    end
end





line_buffer_5x5 #(
    .col_length(col_length), 
    .word_length(word_length), 
    .double_word_length(double_word_length), 
    .kernel_size(kernel_size), 
    .image_size(image_size)
) u1 (
    .clk(clk),
    .rst(rst),
    .in_valid(in_valid),
    .data_in(data_in),
    .pixels_0_0(pixels_0_0),
    .pixels_0_1(pixels_0_1),
    .pixels_0_2(pixels_0_2),
    .pixels_0_3(pixels_0_3),
    .pixels_0_4(pixels_0_4),
    .pixels_1_0(pixels_1_0),
    .pixels_1_1(pixels_1_1),
    .pixels_1_2(pixels_1_2),
    .pixels_1_3(pixels_1_3),
    .pixels_1_4(pixels_1_4),
    .pixels_2_0(pixels_2_0),
    .pixels_2_1(pixels_2_1),
    .pixels_2_2(pixels_2_2),
    .pixels_2_3(pixels_2_3),
    .pixels_2_4(pixels_2_4),
    .pixels_3_0(pixels_3_0),
    .pixels_3_1(pixels_3_1),
    .pixels_3_2(pixels_3_2),
    .pixels_3_3(pixels_3_3),
    .pixels_3_4(pixels_3_4),
    .pixels_4_0(pixels_4_0),
    .pixels_4_1(pixels_4_1),
    .pixels_4_2(pixels_4_2),
    .pixels_4_3(pixels_4_3),
    .pixels_4_4(pixels_4_4),
    .out_valid(line_buffer_5x5_out_valid)
);
traditional_conv
#(
    .col_length(col_length), 
    .word_length(word_length), 
    .double_word_length(double_word_length), 
    .kernel_size(kernel_size), 
    .image_size(image_size)
)
u2
(
    .clk(clk),
    .rst(rst),
    .in_valid(line_buffer_5x5_out_valid),
    .weight_value(weight_value),
    .pixels_0_0(pixels_0_0),
    .pixels_0_1(pixels_0_1),
    .pixels_0_2(pixels_0_2),
    .pixels_0_3(pixels_0_3),
    .pixels_0_4(pixels_0_4),
    .pixels_1_0(pixels_1_0),
    .pixels_1_1(pixels_1_1),
    .pixels_1_2(pixels_1_2),
    .pixels_1_3(pixels_1_3),
    .pixels_1_4(pixels_1_4),
    .pixels_2_0(pixels_2_0),
    .pixels_2_1(pixels_2_1),
    .pixels_2_2(pixels_2_2),
    .pixels_2_3(pixels_2_3),
    .pixels_2_4(pixels_2_4),
    .pixels_3_0(pixels_3_0),
    .pixels_3_1(pixels_3_1),
    .pixels_3_2(pixels_3_2),
    .pixels_3_3(pixels_3_3),
    .pixels_3_4(pixels_3_4),
    .pixels_4_0(pixels_4_0),
    .pixels_4_1(pixels_4_1),
    .pixels_4_2(pixels_4_2),
    .pixels_4_3(pixels_4_3),
    .pixels_4_4(pixels_4_4),
    .result(result),
    .out_valid(traditional_conv_out_valid),
    .done_signal(out_valid)
);
endmodule