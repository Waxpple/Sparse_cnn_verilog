`timescale 1ns/1ns
module PE_tb();


parameter col_length = 8;
parameter word_length = 8;
parameter double_word_length = 16;
parameter kernel_size = 5;
parameter image_size = 7;


reg clk,rst,in_valid;

wire out_valid;
//weight in
reg [416-1 :0] pe_input_feature_value='h00_00_00_0a_f7_fc_02_0f_f8_04_01_e5_fa_1a_ef_f4_fe_ed_10_07_ff_14_f1_f9_08_05_04_e7_f9_ec_e8_e5_24_00_03_d0_06_fc_07_dc_f4_00_00_07_14_fc_20_01_06_fb_fc_1a;

reg [224-1 :0] pe_input_weight_value='h00_00_00_10_e6_0f_ff_04_0e_13_14_00_f6_10_f6_06_0f_10_e1_f5_0a_eb_11_00_04_0f_f1_05;
reg [416-1 :0] pe_input_feature_cols='b00000000_00000000_00000000_00000110_00000101_00000100_00000011_00000010_00000001_00000000_00000110_00000101_00000100_00000011_00000010_00000001_00000000_00000110_00000101_00000100_00000011_00000010_00000001_00000000_00000110_00000101_00000100_00000011_00000010_00000001_00000000_00000110_00000101_00000100_00000011_00000010_00000001_00000000_00000110_00000101_00000100_00000011_00000010_00000001_00000000_00000110_00000101_00000100_00000011_00000010_00000001_00000000;
reg [416-1 :0] pe_input_feature_rows='b00000000_00000000_00000000_00000110_00000110_00000110_00000110_00000110_00000110_00000110_00000101_00000101_00000101_00000101_00000101_00000101_00000101_00000100_00000100_00000100_00000100_00000100_00000100_00000100_00000011_00000011_00000011_00000011_00000011_00000011_00000011_00000010_00000010_00000010_00000010_00000010_00000010_00000010_00000001_00000001_00000001_00000001_00000001_00000001_00000001_00000000_00000000_00000000_00000000_00000000_00000000_00000000;
reg [224-1 :0] pe_input_weight_cols='b00000000_00000000_00000000_00000100_00000011_00000010_00000001_00000000_00000100_00000011_00000010_00000001_00000000_00000100_00000011_00000010_00000001_00000000_00000100_00000011_00000010_00000001_00000000_00000100_00000011_00000010_00000001_00000000;
reg [224-1 :0] pe_input_weight_rows='b00000000_00000000_00000000_00000100_00000100_00000100_00000100_00000100_00000011_00000011_00000011_00000011_00000011_00000010_00000010_00000010_00000010_00000010_00000001_00000001_00000001_00000001_00000001_00000000_00000000_00000000_00000000_00000000;


//pixel data
reg [double_word_length-1:0] feature_valid_num,weight_valid_num;

//for test only
reg [11*11*word_length-1:0] result;
wire signed [word_length*16 -1:0]data_out;
wire signed [col_length*16 -1:0]data_out_cols;
wire signed [col_length*16 -1:0]data_out_rows;

//iter
integer i,j,k;

initial begin
    #0      rst = 0;
            clk = 1;
            feature_valid_num = 16'd12;
            weight_valid_num = 16'd27;
            result = 0;
    #10     rst = 1;
    #10     rst = 0;
    #100    in_valid = 1;

    #100000;
    
end

always@(posedge clk)begin
    result[11*(data_out_rows[col_length-1:0]+4)+(data_out_cols[col_length-1:0]+4)+1 -:word_length] <= data_out[word_length-1:0] + result[11*(data_out_rows[col_length-1:0]+4)+(data_out_cols[col_length-1:0]+4)+1 -:word_length];
end


always #5 clk = ~clk;




PE #(
    .col_length(col_length), 
    .word_length(word_length), 
    .double_word_length(double_word_length), 
    .kernel_size(kernel_size), 
    .image_size(image_size)
    ) pe_TOP( 
    .clk(clk), 
    .rst(rst), 
    .in_valid(in_valid),
    .feature_valid_num(feature_valid_num),
    .feature_value(pe_input_feature_value),
    .feature_cols(pe_input_feature_cols),
    .feature_rows(pe_input_feature_rows),
    .weight_valid_num(weight_valid_num),
    .weight_value(pe_input_weight_value),
    .weight_cols(pe_input_weight_cols),
    .weight_rows(pe_input_weight_rows),
    .data_out(data_out),
    .data_out_cols(data_out_cols),
    .data_out_rows(data_out_rows)
);







endmodule