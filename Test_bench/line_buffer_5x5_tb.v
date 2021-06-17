`timescale 1ns/1ns
module line_buffer_5x5_tb();
parameter col_length = 8;
parameter word_length = 8;
parameter double_word_length = 16;
parameter kernel_size = 5;
parameter image_size = 36;

reg clk;
reg rst;
reg signed [word_length-1:0] data_in;
reg in_valid;
reg [10368-1 :0] pe_input_feature_value='h00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_f0_dd_39_f3_f7_06_02_f7_02_f6_fc_15_f9_ff_15_08_fe_fb_f0_01_e5_09_00_f9_1d_fa_f6_ec_00_00_00_00_00_00_00_00_fd_f2_fb_f2_eb_f3_fa_f3_12_fc_f8_0b_03_fe_f1_f6_07_f7_eb_0a_17_f5_05_01_18_1f_f1_09_00_00_00_00_00_00_00_00_07_04_f3_0c_fa_f6_01_0d_07_e5_06_f8_0e_0b_f9_03_fc_e1_0b_f2_15_fa_0d_ee_08_f9_ed_ff_00_00_00_00_00_00_00_00_f8_fc_fa_f8_e8_07_f2_0f_00_da_08_fb_03_06_f2_f0_07_03_06_fb_e9_f5_13_06_fa_0d_05_0a_00_00_00_00_00_00_00_00_f1_0d_f6_03_fa_03_17_1c_06_e4_13_03_11_0c_f4_15_fb_0d_fd_07_02_0b_f5_0e_ea_e0_ee_04_00_00_00_00_00_00_00_00_f2_fb_01_01_e7_01_ea_07_0e_fc_08_1f_1a_04_fa_ef_02_00_d8_fa_eb_ee_0d_f1_f4_ff_01_fd_00_00_00_00_00_00_00_00_18_eb_f2_08_12_04_0b_fb_f7_0a_00_0b_05_f7_f2_0a_1a_e6_15_0e_29_12_f8_08_dd_f9_0f_10_00_00_00_00_00_00_00_00_05_df_02_07_f1_fe_01_0c_dc_fb_fb_fb_16_15_e8_f8_02_fe_0e_10_0d_fb_fa_02_fd_e5_03_09_00_00_00_00_00_00_00_00_f5_f9_fd_e5_05_0a_03_04_0c_0a_1d_0f_0e_1b_fb_26_f2_ec_08_08_f8_03_08_1b_fc_19_f7_f4_00_00_00_00_00_00_00_00_13_00_fc_13_00_1e_12_fc_11_15_11_00_f7_dd_f6_05_0d_f3_1a_13_fd_18_0e_f1_14_09_dd_0a_00_00_00_00_00_00_00_00_ed_e6_f1_06_ed_fc_fb_fe_10_07_f0_17_15_03_07_f5_0a_13_06_13_fa_1c_07_05_03_ee_eb_f1_00_00_00_00_00_00_00_00_dc_09_f6_fc_fb_04_d9_f9_08_01_08_18_15_25_e6_fe_f9_03_f1_fc_f3_fb_0e_00_f2_f0_0a_f7_00_00_00_00_00_00_00_00_06_0b_f8_26_f5_0c_e6_09_f7_fe_fa_04_fa_0b_dc_f8_12_e4_f3_f5_02_0a_f9_20_fd_04_12_fa_00_00_00_00_00_00_00_00_fb_03_15_e2_ef_f4_01_19_0c_fd_fc_fc_03_0f_18_f2_05_e9_f2_22_04_ef_f5_03_fd_10_f4_e2_00_00_00_00_00_00_00_00_0b_07_02_ec_f8_01_0e_fe_fc_03_ef_eb_f1_f9_04_06_09_15_fc_01_03_f9_0d_ec_f2_2a_e9_01_00_00_00_00_00_00_00_00_0b_12_e9_ff_e9_0d_f3_0f_e4_02_08_0d_e9_e3_fc_05_f3_f6_fd_ee_fc_e4_f5_f3_ef_e1_06_f5_00_00_00_00_00_00_00_00_0b_00_16_e1_f2_f1_06_03_ff_fa_07_f3_09_f7_0a_0a_0c_ff_1f_f4_0f_ef_fb_15_02_e6_fd_f9_00_00_00_00_00_00_00_00_08_f1_ff_f1_eb_11_f4_ea_fd_f3_f0_05_0a_e9_05_0a_f7_e8_f7_f2_11_f4_03_f5_13_e9_fb_fc_00_00_00_00_00_00_00_00_04_fb_0a_01_f9_04_00_03_f7_fb_0b_2c_13_0a_10_ec_08_eb_17_fa_1e_05_18_f4_02_01_0a_03_00_00_00_00_00_00_00_00_ff_02_f6_f9_f6_00_07_01_01_f2_0d_19_fc_05_ef_f3_0c_e7_0d_e1_07_09_26_ff_f8_0a_cf_f1_00_00_00_00_00_00_00_00_e9_08_04_ff_fe_e4_dc_fa_05_fc_23_09_ff_03_09_04_18_1a_f4_02_d7_2a_ed_09_07_14_f0_ff_00_00_00_00_00_00_00_00_0f_09_0f_f8_08_f1_21_02_27_fc_f8_fb_ef_11_ee_f9_17_13_01_2c_04_f6_1c_e8_f7_f8_fa_08_00_00_00_00_00_00_00_00_13_f6_11_24_fb_00_f4_09_0d_ff_ff_2c_f2_0f_2b_e0_fa_0c_04_25_fa_0a_0c_0c_15_f9_07_f6_00_00_00_00_00_00_00_00_fa_f7_07_20_f8_17_10_07_0a_07_1a_04_0b_f6_ff_1a_ef_e6_03_02_06_1f_fb_0c_06_f9_ff_04_00_00_00_00_00_00_00_00_1c_ec_f8_09_fc_20_e8_0e_f6_ed_f6_1c_00_e9_f6_07_15_f1_06_12_f9_e7_ef_08_ed_fb_16_fd_00_00_00_00_00_00_00_00_13_0d_fa_df_f0_09_e6_fd_f5_09_03_fa_17_fa_2f_16_ff_09_10_04_09_fe_fd_0d_f6_f2_e3_e2_00_00_00_00_00_00_00_00_f1_12_1b_ed_fb_18_fe_fd_01_1b_01_01_f3_1d_ff_07_0f_fe_05_ef_ef_38_fc_fb_ee_fc_f0_0e_00_00_00_00_00_00_00_00_02_37_0c_f4_1e_e1_04_f4_f4_0a_22_06_01_f0_00_00_1d_0d_fd_1f_f4_06_02_fe_07_ec_12_f7_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00;

wire out_valid,out_valid_2;
wire signed [word_length-1:0] pixels_0_0,pixels_0_1,pixels_0_2,pixels_0_3,pixels_0_4,pixels_1_0,pixels_1_1,pixels_1_2,pixels_1_3,pixels_1_4,pixels_2_0,pixels_2_1,pixels_2_2,pixels_2_3,pixels_2_4,pixels_3_0,pixels_3_1,pixels_3_2,pixels_3_3,pixels_3_4,pixels_4_0,pixels_4_1,pixels_4_2,pixels_4_3,pixels_4_4;
reg [kernel_size*kernel_size*word_length-1 :0] weight_value;
reg signed [word_length*2-1:0] temp;
wire signed [word_length*2-1:0] result;
//iter
integer i,j,k;

initial begin
    #0      rst = 0;
            clk = 1;
            weight_value = 'h19_05_00_0b_fc_ed_12_f6_02_f7_08_0d_05_dd_fc_ed_f1_ff_09_fa_00_07_f2_ee_e7;
            //weight_value = {25{16'h0010}};
    #10     rst = 1;
    #10     rst = 0;
    #100    in_valid = 1;
            for (i=0;i<(image_size*image_size);i=i+1)begin
                data_in[word_length-1:0] = {pe_input_feature_value[(i+1)*word_length-1 -:word_length]};
                //data_in[word_length-1:0] = i+1;
                #10;
            end
    #1000;
    $finish;
    
end




always #5 clk = ~clk;

always @(posedge clk or posedge rst) begin
    if (rst)begin
        temp <= 16'hFFFF;
    end
    else if (out_valid_2)begin
        temp <= result;
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
    .out_valid(out_valid)
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
    .in_valid(out_valid),
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
    .out_valid(out_valid_2)
);


endmodule
