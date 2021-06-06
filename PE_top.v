`timescale 1ns/1ns
module PE_top();


parameter col_length = 8;
parameter word_length = 8;
parameter double_word_length = 16;
parameter kernel_size = 5;
parameter image_size = 28;


reg clk,rst,in_valid;
reg [double_word_length-1:0] in_channel;
wire out_valid;
//weight in
reg [col_length*1 -1:0]weight_cols;
reg [col_length*1 -1:0]weight_rows;
reg signed [word_length*1 -1:0]weight_value;

//pixel data
reg [double_word_length-1:0] feature_valid_num;
reg signed [col_length*4 -1:0]feature_cols;
reg signed [col_length*4 -1:0]feature_rows;
reg signed [word_length*4 -1:0]feature_value;


//iter
integer i,j,k;

initial begin
    #0      rst = 0;
            clk = 1;
    #10     rst = 1;
    #10     rst = 0;
    #100    in_valid = 1;

            for (i=0;i<32;i=i+1)begin
                weight_value = 8'b11100110;
                feature_value[word_length-1:0] = 8'b00011010; // + i+2 <<wordlength + i+3 <<wordlength*2 + i+4 <<wordlength*3);
                feature_value[word_length*2-1:word_length*1] = (i+2)<<4;
                feature_value[word_length*3-1:word_length*2] = (i+3)<<4;
                feature_value[word_length*4-1:word_length*3] = (i+4)<<4;
                in_channel = 'd5;
                weight_cols = 'd1;
                weight_rows = 'd2;

                feature_cols[col_length-1:0] = 3; 
                feature_cols[col_length*2-1:col_length*1] = 4;
                feature_cols[col_length*3-1:col_length*2] = 5;
                feature_cols[col_length*4-1:col_length*3] = 6;

                feature_rows[col_length-1:0] = 6; 
                feature_rows[col_length*2-1:col_length*1] = 5;
                feature_rows[col_length*3-1:col_length*2] = 4;
                feature_rows[col_length*4-1:col_length*3] = 3;
                #10;
            end
    #1000;
    
end




always #5 clk = ~clk;




PE_UNIT #(
    .col_length(col_length), 
    .word_length(word_length), 
    .double_word_length(double_word_length), 
    .kernel_size(kernel_size), 
    .image_size(image_size)
    ) pe( 
    .clk(clk), 
    .rst(rst), 
    .in_valid(in_valid),
    .in_channel(in_channel),
    .feature_valid_num(16'd49), 
    .feature_value(feature_value), 
    .feature_cols(feature_cols),
    .feature_rows(feature_rows), 
    .weight_valid_num(16'd12),
    .weight_value(weight_value), 
    .weight_cols(weight_cols),
    .weight_rows(weight_cols), 
    .out_valid(out_valid), 
    .data_out()
);







endmodule