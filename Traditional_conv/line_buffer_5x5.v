module line_buffer_5x5#(
    parameter col_length = 8,
    parameter word_length = 8,
    parameter double_word_length = 16,
    parameter kernel_size = 5,
    parameter image_size = 28
)(
    input clk,
    input rst,
    input in_valid,
    input [word_length-1:0] data_in,
    output [word_length-1:0] pixels_0_0,
    output [word_length-1:0] pixels_0_1,
    output [word_length-1:0] pixels_0_2,
    output [word_length-1:0] pixels_0_3,
    output [word_length-1:0] pixels_0_4,
    output [word_length-1:0] pixels_1_0,
    output [word_length-1:0] pixels_1_1,
    output [word_length-1:0] pixels_1_2,
    output [word_length-1:0] pixels_1_3,
    output [word_length-1:0] pixels_1_4,
    output [word_length-1:0] pixels_2_0,
    output [word_length-1:0] pixels_2_1,
    output [word_length-1:0] pixels_2_2,
    output [word_length-1:0] pixels_2_3,
    output [word_length-1:0] pixels_2_4,
    output [word_length-1:0] pixels_3_0,
    output [word_length-1:0] pixels_3_1,
    output [word_length-1:0] pixels_3_2,
    output [word_length-1:0] pixels_3_3,
    output [word_length-1:0] pixels_3_4,
    output [word_length-1:0] pixels_4_0,
    output [word_length-1:0] pixels_4_1,
    output [word_length-1:0] pixels_4_2,
    output [word_length-1:0] pixels_4_3,
    output [word_length-1:0] pixels_4_4,
    output wire out_valid
);
reg [(image_size*word_length)-1 :0] line_0,next_line_0,line_1,next_line_1,line_2,next_line_2,line_3,next_line_3,line_4,next_line_4;
//28*4+1
reg [double_word_length-1:0] counter,next_counter;

assign out_valid = (counter > (image_size*4+4) &&  counter <=image_size*image_size)?1'd1:1'd0;

assign pixels_0_0 = {line_4[word_length*(4+1)-1 -:word_length]};
assign pixels_1_0 = {line_4[word_length*(3+1)-1 -:word_length]};
assign pixels_2_0 = {line_4[word_length*(2+1)-1 -:word_length]};
assign pixels_3_0 = {line_4[word_length*(1+1)-1 -:word_length]};
assign pixels_4_0 = {line_4[word_length*(0+1)-1 -:word_length]};
assign pixels_0_1 = {line_3[word_length*(4+1)-1 -:word_length]};
assign pixels_1_1 = {line_3[word_length*(3+1)-1 -:word_length]};
assign pixels_2_1 = {line_3[word_length*(2+1)-1 -:word_length]};
assign pixels_3_1 = {line_3[word_length*(1+1)-1 -:word_length]};
assign pixels_4_1 = {line_3[word_length*(0+1)-1 -:word_length]};
assign pixels_0_2 = {line_2[word_length*(4+1)-1 -:word_length]};
assign pixels_1_2 = {line_2[word_length*(3+1)-1 -:word_length]};
assign pixels_2_2 = {line_2[word_length*(2+1)-1 -:word_length]};
assign pixels_3_2 = {line_2[word_length*(1+1)-1 -:word_length]};
assign pixels_4_2 = {line_2[word_length*(0+1)-1 -:word_length]};
assign pixels_0_3 = {line_1[word_length*(4+1)-1 -:word_length]};
assign pixels_1_3 = {line_1[word_length*(3+1)-1 -:word_length]};
assign pixels_2_3 = {line_1[word_length*(2+1)-1 -:word_length]};
assign pixels_3_3 = {line_1[word_length*(1+1)-1 -:word_length]};
assign pixels_4_3 = {line_1[word_length*(0+1)-1 -:word_length]};
assign pixels_0_4 = {line_0[word_length*(4+1)-1 -:word_length]};
assign pixels_1_4 = {line_0[word_length*(3+1)-1 -:word_length]};
assign pixels_2_4 = {line_0[word_length*(2+1)-1 -:word_length]};
assign pixels_3_4 = {line_0[word_length*(1+1)-1 -:word_length]};
assign pixels_4_4 = {line_0[word_length*(0+1)-1 -:word_length]};



// Line Buffer
always @(*) begin
    next_line_0 = line_0;
    next_line_1 = line_1;
    next_line_2 = line_2;
    next_line_3 = line_3;
    next_line_4 = line_4;
    next_counter = counter + 'd1;
end

always @(posedge clk or posedge rst) begin
    if(rst)begin
        line_0 <= 'd0;
        line_1 <= 'd0;
        line_2 <= 'd0;
        line_3 <= 'd0;
        line_4 <= 'd0;
        
        counter <= 'd0;
    end
    else begin
        if(in_valid)begin
            line_0 <= (next_line_0 << word_length) + data_in;
            line_1 <= (next_line_1 << word_length) + next_line_0[(image_size*word_length)-1 -: word_length];
            line_2 <= (next_line_2 << word_length) + next_line_1[(image_size*word_length)-1 -: word_length];
            line_3 <= (next_line_3 << word_length) + next_line_2[(image_size*word_length)-1 -: word_length];
            line_4 <= (next_line_4 << word_length) + next_line_3[(image_size*word_length)-1 -: word_length];
            counter <= next_counter;
        end
        else begin
            line_0 <= 'd0;
            line_1 <= 'd0;
            line_2 <= 'd0;
            line_3 <= 'd0;
            line_4 <= 'd0;
            counter <= 'd0;
        end
    end
end
endmodule