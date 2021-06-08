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
reg [416-1 :0] pe_input_feature_value='h00_00_00_18_00_1c_f0_f4_fc_18_0c_10_0c_0c_1c_0c_fc_1c_f0_08_e4_0c_0c_fc_ec_14_f8_f8_00_f4_08_fc_f4_04_e0_ec_18_e8_e0_e0_f8_00_ec_04_e8_18_fc_00_04_04_04_f4;
reg [224-1 :0] pe_input_weight_value='h00_00_00_f8_e4_14_e8_fc_ec_fc_ec_f4_10_f0_00_00_fc_fc_f4_fc_04_e0_f8_fc_04_08_0c_f0;
reg [416-1 :0] pe_input_feature_cols='b00000000_00000000_00000000_00000110_00000101_00000100_00000011_00000010_00000001_00000000_00000110_00000101_00000100_00000011_00000010_00000001_00000000_00000110_00000101_00000100_00000011_00000010_00000001_00000000_00000110_00000101_00000100_00000011_00000010_00000001_00000000_00000110_00000101_00000100_00000011_00000010_00000001_00000000_00000110_00000101_00000100_00000011_00000010_00000001_00000000_00000110_00000101_00000100_00000011_00000010_00000001_00000000;
reg [416-1 :0] pe_input_feature_rows='b00000000_00000000_00000000_00000110_00000110_00000110_00000110_00000110_00000110_00000110_00000101_00000101_00000101_00000101_00000101_00000101_00000101_00000100_00000100_00000100_00000100_00000100_00000100_00000100_00000011_00000011_00000011_00000011_00000011_00000011_00000011_00000010_00000010_00000010_00000010_00000010_00000010_00000010_00000001_00000001_00000001_00000001_00000001_00000001_00000001_00000000_00000000_00000000_00000000_00000000_00000000_00000000;
reg [224-1 :0] pe_input_weight_cols='b00000000_00000000_00000000_00000100_00000011_00000010_00000001_00000000_00000100_00000011_00000010_00000001_00000000_00000100_00000011_00000010_00000001_00000000_00000100_00000011_00000010_00000001_00000000_00000100_00000011_00000010_00000001_00000000;
reg [224-1 :0] pe_input_weight_rows='b00000000_00000000_00000000_00000100_00000100_00000100_00000100_00000100_00000011_00000011_00000011_00000011_00000011_00000010_00000010_00000010_00000010_00000010_00000001_00000001_00000001_00000001_00000001_00000000_00000000_00000000_00000000_00000000;

//pixel data
reg [double_word_length-1:0] feature_valid_num,weight_valid_num;

//for test only
reg [11*11*word_length*2-1:0] result;
wire signed [word_length*2*16 -1:0]data_out;
wire signed [col_length*16 -1:0]data_out_cols;
wire signed [col_length*16 -1:0]data_out_rows;

wire signed [word_length*2-1:0] answer_1_1,answer_1_2,answer_1_3,answer_1_4,answer_2_1,answer_2_2,answer_2_3,answer_2_4;
wire signed [word_length*2-1:0] answer_3_1,answer_3_2,answer_3_3,answer_3_4,answer_4_1,answer_4_2,answer_4_3,answer_4_4; 
wire signed [col_length-1:0] col_answer_1_1,col_answer_1_2,col_answer_1_3,col_answer_1_4,col_answer_2_1,col_answer_2_2,col_answer_2_3,col_answer_2_4,col_answer_3_1,col_answer_3_2,col_answer_3_3,col_answer_3_4,col_answer_4_1,col_answer_4_2,col_answer_4_3,col_answer_4_4; 
wire signed [col_length-1:0] row_answer_1_1,row_answer_1_2,row_answer_1_3,row_answer_1_4,row_answer_2_1,row_answer_2_2,row_answer_2_3,row_answer_2_4,row_answer_3_1,row_answer_3_2,row_answer_3_3,row_answer_3_4,row_answer_4_1,row_answer_4_2,row_answer_4_3,row_answer_4_4; 

assign {col_answer_4_4,col_answer_4_3,col_answer_4_2,col_answer_4_1, col_answer_3_4,col_answer_3_3,col_answer_3_2,col_answer_3_1, col_answer_2_4,col_answer_2_3,col_answer_2_2,col_answer_2_1, col_answer_1_4,col_answer_1_3,col_answer_1_2,col_answer_1_1}= data_out_cols;
assign {row_answer_4_4,row_answer_4_3,row_answer_4_2,row_answer_4_1, row_answer_3_4,row_answer_3_3,row_answer_3_2,row_answer_3_1, row_answer_2_4,row_answer_2_3,row_answer_2_2,row_answer_2_1, row_answer_1_4,row_answer_1_3,row_answer_1_2,row_answer_1_1}= data_out_rows;

assign {{answer_1_4},{answer_1_3},{answer_1_2},{answer_1_1}} = data_out[word_length*2*4 -1 -:word_length*2*4];
assign {{answer_2_4},{answer_2_3},{answer_2_2},{answer_2_1}} = data_out[word_length*2*8 -1 -:word_length*2*4];
assign {{answer_3_4},{answer_3_3},{answer_3_2},{answer_3_1}} = data_out[word_length*2*12 -1 -:word_length*2*4];
assign {{answer_4_4},{answer_4_3},{answer_4_2},{answer_4_1}} = data_out[word_length*2*16 -1 -:word_length*2*4];

wire signed  [word_length*2-1:0] pixels_0_0, pixels_0_1, pixels_0_2, pixels_0_3, pixels_0_4, pixels_0_5, pixels_0_6, pixels_0_7, pixels_0_8, pixels_0_9, pixels_0_10, pixels_1_0, pixels_1_1, pixels_1_2, pixels_1_3, pixels_1_4, pixels_1_5, pixels_1_6, pixels_1_7, pixels_1_8, pixels_1_9, pixels_1_10, pixels_2_0, pixels_2_1, pixels_2_2, pixels_2_3, pixels_2_4, pixels_2_5, pixels_2_6, pixels_2_7, pixels_2_8, pixels_2_9, pixels_2_10, pixels_3_0, pixels_3_1, pixels_3_2, pixels_3_3, pixels_3_4, pixels_3_5, pixels_3_6, pixels_3_7, pixels_3_8, pixels_3_9, pixels_3_10, pixels_4_0, pixels_4_1, pixels_4_2, pixels_4_3, pixels_4_4, pixels_4_5, pixels_4_6, pixels_4_7, pixels_4_8, pixels_4_9, pixels_4_10, pixels_5_0, pixels_5_1, pixels_5_2, pixels_5_3, pixels_5_4, pixels_5_5, pixels_5_6, pixels_5_7, pixels_5_8, pixels_5_9, pixels_5_10, pixels_6_0, pixels_6_1, pixels_6_2, pixels_6_3, pixels_6_4, pixels_6_5, pixels_6_6, pixels_6_7, pixels_6_8, pixels_6_9, pixels_6_10, pixels_7_0, pixels_7_1, pixels_7_2, pixels_7_3, pixels_7_4, pixels_7_5, pixels_7_6, pixels_7_7, pixels_7_8, pixels_7_9, pixels_7_10, pixels_8_0, pixels_8_1, pixels_8_2, pixels_8_3, pixels_8_4, pixels_8_5, pixels_8_6, pixels_8_7, pixels_8_8, pixels_8_9, pixels_8_10, pixels_9_0, pixels_9_1, pixels_9_2, pixels_9_3, pixels_9_4, pixels_9_5, pixels_9_6, pixels_9_7, pixels_9_8, pixels_9_9, pixels_9_10, pixels_10_0, pixels_10_1, pixels_10_2, pixels_10_3, pixels_10_4, pixels_10_5, pixels_10_6, pixels_10_7, pixels_10_8, pixels_10_9, pixels_10_10;

// assign pixels_0_0 = {result[1*word_length-1 -: word_length]};
// assign pixels_0_1 = {result[2*word_length-1 -: word_length]};
// assign pixels_0_2 = {result[3*word_length-1 -: word_length]};
// assign pixels_0_3 = {result[4*word_length-1 -: word_length]};
// assign pixels_0_4 = {result[5*word_length-1 -: word_length]};
// assign pixels_0_5 = {result[6*word_length-1 -: word_length]};
// assign pixels_0_6 = {result[7*word_length-1 -: word_length]};
// assign pixels_0_7 = {result[8*word_length-1 -: word_length]};
// assign pixels_0_8 = {result[9*word_length-1 -: word_length]};
// assign pixels_0_9 = {result[10*word_length-1 -: word_length]};
// assign pixels_0_10 = {result[11*word_length-1 -: word_length]};
// assign pixels_1_0 = {result[12*word_length-1 -: word_length]};
// assign pixels_1_1 = {result[13*word_length-1 -: word_length]};
// assign pixels_1_2 = {result[14*word_length-1 -: word_length]};
// assign pixels_1_3 = {result[15*word_length-1 -: word_length]};
// assign pixels_1_4 = {result[16*word_length-1 -: word_length]};
// assign pixels_1_5 = {result[17*word_length-1 -: word_length]};
// assign pixels_1_6 = {result[18*word_length-1 -: word_length]};
// assign pixels_1_7 = {result[19*word_length-1 -: word_length]};
// assign pixels_1_8 = {result[20*word_length-1 -: word_length]};
// assign pixels_1_9 = {result[21*word_length-1 -: word_length]};
// assign pixels_1_10 = {result[22*word_length-1 -: word_length]};
// assign pixels_2_0 = {result[23*word_length-1 -: word_length]};
// assign pixels_2_1 = {result[24*word_length-1 -: word_length]};
// assign pixels_2_2 = {result[25*word_length-1 -: word_length]};
// assign pixels_2_3 = {result[26*word_length-1 -: word_length]};
// assign pixels_2_4 = {result[27*word_length-1 -: word_length]};
// assign pixels_2_5 = {result[28*word_length-1 -: word_length]};
// assign pixels_2_6 = {result[29*word_length-1 -: word_length]};
// assign pixels_2_7 = {result[30*word_length-1 -: word_length]};
// assign pixels_2_8 = {result[31*word_length-1 -: word_length]};
// assign pixels_2_9 = {result[32*word_length-1 -: word_length]};
// assign pixels_2_10 = {result[33*word_length-1 -: word_length]};
// assign pixels_3_0 = {result[34*word_length-1 -: word_length]};
// assign pixels_3_1 = {result[35*word_length-1 -: word_length]};
// assign pixels_3_2 = {result[36*word_length-1 -: word_length]};
// assign pixels_3_3 = {result[37*word_length-1 -: word_length]};
// assign pixels_3_4 = {result[38*word_length-1 -: word_length]};
// assign pixels_3_5 = {result[39*word_length-1 -: word_length]};
// assign pixels_3_6 = {result[40*word_length-1 -: word_length]};
// assign pixels_3_7 = {result[41*word_length-1 -: word_length]};
// assign pixels_3_8 = {result[42*word_length-1 -: word_length]};
// assign pixels_3_9 = {result[43*word_length-1 -: word_length]};
// assign pixels_3_10 = {result[44*word_length-1 -: word_length]};
// assign pixels_4_0 = {result[45*word_length-1 -: word_length]};
// assign pixels_4_1 = {result[46*word_length-1 -: word_length]};
// assign pixels_4_2 = {result[47*word_length-1 -: word_length]};
// assign pixels_4_3 = {result[48*word_length-1 -: word_length]};
// assign pixels_4_4 = {result[49*word_length-1 -: word_length]};
// assign pixels_4_5 = {result[50*word_length-1 -: word_length]};
// assign pixels_4_6 = {result[51*word_length-1 -: word_length]};
// assign pixels_4_7 = {result[52*word_length-1 -: word_length]};
// assign pixels_4_8 = {result[53*word_length-1 -: word_length]};
// assign pixels_4_9 = {result[54*word_length-1 -: word_length]};
// assign pixels_4_10 = {result[55*word_length-1 -: word_length]};
// assign pixels_5_0 = {result[56*word_length-1 -: word_length]};
// assign pixels_5_1 = {result[57*word_length-1 -: word_length]};
// assign pixels_5_2 = {result[58*word_length-1 -: word_length]};
// assign pixels_5_3 = {result[59*word_length-1 -: word_length]};
// assign pixels_5_4 = {result[60*word_length-1 -: word_length]};
// assign pixels_5_5 = {result[61*word_length-1 -: word_length]};
// assign pixels_5_6 = {result[62*word_length-1 -: word_length]};
// assign pixels_5_7 = {result[63*word_length-1 -: word_length]};
// assign pixels_5_8 = {result[64*word_length-1 -: word_length]};
// assign pixels_5_9 = {result[65*word_length-1 -: word_length]};
// assign pixels_5_10 = {result[66*word_length-1 -: word_length]};
// assign pixels_6_0 = {result[67*word_length-1 -: word_length]};
// assign pixels_6_1 = {result[68*word_length-1 -: word_length]};
// assign pixels_6_2 = {result[69*word_length-1 -: word_length]};
// assign pixels_6_3 = {result[70*word_length-1 -: word_length]};
// assign pixels_6_4 = {result[71*word_length-1 -: word_length]};
// assign pixels_6_5 = {result[72*word_length-1 -: word_length]};
// assign pixels_6_6 = {result[73*word_length-1 -: word_length]};
// assign pixels_6_7 = {result[74*word_length-1 -: word_length]};
// assign pixels_6_8 = {result[75*word_length-1 -: word_length]};
// assign pixels_6_9 = {result[76*word_length-1 -: word_length]};
// assign pixels_6_10 = {result[77*word_length-1 -: word_length]};
// assign pixels_7_0 = {result[78*word_length-1 -: word_length]};
// assign pixels_7_1 = {result[79*word_length-1 -: word_length]};
// assign pixels_7_2 = {result[80*word_length-1 -: word_length]};
// assign pixels_7_3 = {result[81*word_length-1 -: word_length]};
// assign pixels_7_4 = {result[82*word_length-1 -: word_length]};
// assign pixels_7_5 = {result[83*word_length-1 -: word_length]};
// assign pixels_7_6 = {result[84*word_length-1 -: word_length]};
// assign pixels_7_7 = {result[85*word_length-1 -: word_length]};
// assign pixels_7_8 = {result[86*word_length-1 -: word_length]};
// assign pixels_7_9 = {result[87*word_length-1 -: word_length]};
// assign pixels_7_10 = {result[88*word_length-1 -: word_length]};
// assign pixels_8_0 = {result[89*word_length-1 -: word_length]};
// assign pixels_8_1 = {result[90*word_length-1 -: word_length]};
// assign pixels_8_2 = {result[91*word_length-1 -: word_length]};
// assign pixels_8_3 = {result[92*word_length-1 -: word_length]};
// assign pixels_8_4 = {result[93*word_length-1 -: word_length]};
// assign pixels_8_5 = {result[94*word_length-1 -: word_length]};
// assign pixels_8_6 = {result[95*word_length-1 -: word_length]};
// assign pixels_8_7 = {result[96*word_length-1 -: word_length]};
// assign pixels_8_8 = {result[97*word_length-1 -: word_length]};
// assign pixels_8_9 = {result[98*word_length-1 -: word_length]};
// assign pixels_8_10 = {result[99*word_length-1 -: word_length]};
// assign pixels_9_0 = {result[100*word_length-1 -: word_length]};
// assign pixels_9_1 = {result[101*word_length-1 -: word_length]};
// assign pixels_9_2 = {result[102*word_length-1 -: word_length]};
// assign pixels_9_3 = {result[103*word_length-1 -: word_length]};
// assign pixels_9_4 = {result[104*word_length-1 -: word_length]};
// assign pixels_9_5 = {result[105*word_length-1 -: word_length]};
// assign pixels_9_6 = {result[106*word_length-1 -: word_length]};
// assign pixels_9_7 = {result[107*word_length-1 -: word_length]};
// assign pixels_9_8 = {result[108*word_length-1 -: word_length]};
// assign pixels_9_9 = {result[109*word_length-1 -: word_length]};
// assign pixels_9_10 = {result[110*word_length-1 -: word_length]};
// assign pixels_10_0 = {result[111*word_length-1 -: word_length]};
// assign pixels_10_1 = {result[112*word_length-1 -: word_length]};
// assign pixels_10_2 = {result[113*word_length-1 -: word_length]};
// assign pixels_10_3 = {result[114*word_length-1 -: word_length]};
// assign pixels_10_4 = {result[115*word_length-1 -: word_length]};
// assign pixels_10_5 = {result[116*word_length-1 -: word_length]};
// assign pixels_10_6 = {result[117*word_length-1 -: word_length]};
// assign pixels_10_7 = {result[118*word_length-1 -: word_length]};
// assign pixels_10_8 = {result[119*word_length-1 -: word_length]};
// assign pixels_10_9 = {result[120*word_length-1 -: word_length]};
// assign pixels_10_10 = {result[121*word_length-1 -: word_length]};

assign pixels_0_0 = {result[1*word_length*2-1 -: word_length*2]};
assign pixels_1_0 = {result[2*word_length*2-1 -: word_length*2]};
assign pixels_2_0 = {result[3*word_length*2-1 -: word_length*2]};
assign pixels_3_0 = {result[4*word_length*2-1 -: word_length*2]};
assign pixels_4_0 = {result[5*word_length*2-1 -: word_length*2]};
assign pixels_5_0 = {result[6*word_length*2-1 -: word_length*2]};
assign pixels_6_0 = {result[7*word_length*2-1 -: word_length*2]};
assign pixels_7_0 = {result[8*word_length*2-1 -: word_length*2]};
assign pixels_8_0 = {result[9*word_length*2-1 -: word_length*2]};
assign pixels_9_0 = {result[10*word_length*2-1 -: word_length*2]};
assign pixels_10_0 = {result[11*word_length*2-1 -: word_length*2]};
assign pixels_0_1 = {result[12*word_length*2-1 -: word_length*2]};
assign pixels_1_1 = {result[13*word_length*2-1 -: word_length*2]};
assign pixels_2_1 = {result[14*word_length*2-1 -: word_length*2]};
assign pixels_3_1 = {result[15*word_length*2-1 -: word_length*2]};
assign pixels_4_1 = {result[16*word_length*2-1 -: word_length*2]};
assign pixels_5_1 = {result[17*word_length*2-1 -: word_length*2]};
assign pixels_6_1 = {result[18*word_length*2-1 -: word_length*2]};
assign pixels_7_1 = {result[19*word_length*2-1 -: word_length*2]};
assign pixels_8_1 = {result[20*word_length*2-1 -: word_length*2]};
assign pixels_9_1 = {result[21*word_length*2-1 -: word_length*2]};
assign pixels_10_1 = {result[22*word_length*2-1 -: word_length*2]};
assign pixels_0_2 = {result[23*word_length*2-1 -: word_length*2]};
assign pixels_1_2 = {result[24*word_length*2-1 -: word_length*2]};
assign pixels_2_2 = {result[25*word_length*2-1 -: word_length*2]};
assign pixels_3_2 = {result[26*word_length*2-1 -: word_length*2]};
assign pixels_4_2 = {result[27*word_length*2-1 -: word_length*2]};
assign pixels_5_2 = {result[28*word_length*2-1 -: word_length*2]};
assign pixels_6_2 = {result[29*word_length*2-1 -: word_length*2]};
assign pixels_7_2 = {result[30*word_length*2-1 -: word_length*2]};
assign pixels_8_2 = {result[31*word_length*2-1 -: word_length*2]};
assign pixels_9_2 = {result[32*word_length*2-1 -: word_length*2]};
assign pixels_10_2 = {result[33*word_length*2-1 -: word_length*2]};
assign pixels_0_3 = {result[34*word_length*2-1 -: word_length*2]};
assign pixels_1_3 = {result[35*word_length*2-1 -: word_length*2]};
assign pixels_2_3 = {result[36*word_length*2-1 -: word_length*2]};
assign pixels_3_3 = {result[37*word_length*2-1 -: word_length*2]};
assign pixels_4_3 = {result[38*word_length*2-1 -: word_length*2]};
assign pixels_5_3 = {result[39*word_length*2-1 -: word_length*2]};
assign pixels_6_3 = {result[40*word_length*2-1 -: word_length*2]};
assign pixels_7_3 = {result[41*word_length*2-1 -: word_length*2]};
assign pixels_8_3 = {result[42*word_length*2-1 -: word_length*2]};
assign pixels_9_3 = {result[43*word_length*2-1 -: word_length*2]};
assign pixels_10_3 = {result[44*word_length*2-1 -: word_length*2]};
assign pixels_0_4 = {result[45*word_length*2-1 -: word_length*2]};
assign pixels_1_4 = {result[46*word_length*2-1 -: word_length*2]};
assign pixels_2_4 = {result[47*word_length*2-1 -: word_length*2]};
assign pixels_3_4 = {result[48*word_length*2-1 -: word_length*2]};
assign pixels_4_4 = {result[49*word_length*2-1 -: word_length*2]};
assign pixels_5_4 = {result[50*word_length*2-1 -: word_length*2]};
assign pixels_6_4 = {result[51*word_length*2-1 -: word_length*2]};
assign pixels_7_4 = {result[52*word_length*2-1 -: word_length*2]};
assign pixels_8_4 = {result[53*word_length*2-1 -: word_length*2]};
assign pixels_9_4 = {result[54*word_length*2-1 -: word_length*2]};
assign pixels_10_4 = {result[55*word_length*2-1 -: word_length*2]};
assign pixels_0_5 = {result[56*word_length*2-1 -: word_length*2]};
assign pixels_1_5 = {result[57*word_length*2-1 -: word_length*2]};
assign pixels_2_5 = {result[58*word_length*2-1 -: word_length*2]};
assign pixels_3_5 = {result[59*word_length*2-1 -: word_length*2]};
assign pixels_4_5 = {result[60*word_length*2-1 -: word_length*2]};
assign pixels_5_5 = {result[61*word_length*2-1 -: word_length*2]};
assign pixels_6_5 = {result[62*word_length*2-1 -: word_length*2]};
assign pixels_7_5 = {result[63*word_length*2-1 -: word_length*2]};
assign pixels_8_5 = {result[64*word_length*2-1 -: word_length*2]};
assign pixels_9_5 = {result[65*word_length*2-1 -: word_length*2]};
assign pixels_10_5 = {result[66*word_length*2-1 -: word_length*2]};
assign pixels_0_6 = {result[67*word_length*2-1 -: word_length*2]};
assign pixels_1_6 = {result[68*word_length*2-1 -: word_length*2]};
assign pixels_2_6 = {result[69*word_length*2-1 -: word_length*2]};
assign pixels_3_6 = {result[70*word_length*2-1 -: word_length*2]};
assign pixels_4_6 = {result[71*word_length*2-1 -: word_length*2]};
assign pixels_5_6 = {result[72*word_length*2-1 -: word_length*2]};
assign pixels_6_6 = {result[73*word_length*2-1 -: word_length*2]};
assign pixels_7_6 = {result[74*word_length*2-1 -: word_length*2]};
assign pixels_8_6 = {result[75*word_length*2-1 -: word_length*2]};
assign pixels_9_6 = {result[76*word_length*2-1 -: word_length*2]};
assign pixels_10_6 = {result[77*word_length*2-1 -: word_length*2]};
assign pixels_0_7 = {result[78*word_length*2-1 -: word_length*2]};
assign pixels_1_7 = {result[79*word_length*2-1 -: word_length*2]};
assign pixels_2_7 = {result[80*word_length*2-1 -: word_length*2]};
assign pixels_3_7 = {result[81*word_length*2-1 -: word_length*2]};
assign pixels_4_7 = {result[82*word_length*2-1 -: word_length*2]};
assign pixels_5_7 = {result[83*word_length*2-1 -: word_length*2]};
assign pixels_6_7 = {result[84*word_length*2-1 -: word_length*2]};
assign pixels_7_7 = {result[85*word_length*2-1 -: word_length*2]};
assign pixels_8_7 = {result[86*word_length*2-1 -: word_length*2]};
assign pixels_9_7 = {result[87*word_length*2-1 -: word_length*2]};
assign pixels_10_7 = {result[88*word_length*2-1 -: word_length*2]};
assign pixels_0_8 = {result[89*word_length*2-1 -: word_length*2]};
assign pixels_1_8 = {result[90*word_length*2-1 -: word_length*2]};
assign pixels_2_8 = {result[91*word_length*2-1 -: word_length*2]};
assign pixels_3_8 = {result[92*word_length*2-1 -: word_length*2]};
assign pixels_4_8 = {result[93*word_length*2-1 -: word_length*2]};
assign pixels_5_8 = {result[94*word_length*2-1 -: word_length*2]};
assign pixels_6_8 = {result[95*word_length*2-1 -: word_length*2]};
assign pixels_7_8 = {result[96*word_length*2-1 -: word_length*2]};
assign pixels_8_8 = {result[97*word_length*2-1 -: word_length*2]};
assign pixels_9_8 = {result[98*word_length*2-1 -: word_length*2]};
assign pixels_10_8 = {result[99*word_length*2-1 -: word_length*2]};
assign pixels_0_9 = {result[100*word_length*2-1 -: word_length*2]};
assign pixels_1_9 = {result[101*word_length*2-1 -: word_length*2]};
assign pixels_2_9 = {result[102*word_length*2-1 -: word_length*2]};
assign pixels_3_9 = {result[103*word_length*2-1 -: word_length*2]};
assign pixels_4_9 = {result[104*word_length*2-1 -: word_length*2]};
assign pixels_5_9 = {result[105*word_length*2-1 -: word_length*2]};
assign pixels_6_9 = {result[106*word_length*2-1 -: word_length*2]};
assign pixels_7_9 = {result[107*word_length*2-1 -: word_length*2]};
assign pixels_8_9 = {result[108*word_length*2-1 -: word_length*2]};
assign pixels_9_9 = {result[109*word_length*2-1 -: word_length*2]};
assign pixels_10_9 = {result[110*word_length*2-1 -: word_length*2]};
assign pixels_0_10 = {result[111*word_length*2-1 -: word_length*2]};
assign pixels_1_10 = {result[112*word_length*2-1 -: word_length*2]};
assign pixels_2_10 = {result[113*word_length*2-1 -: word_length*2]};
assign pixels_3_10 = {result[114*word_length*2-1 -: word_length*2]};
assign pixels_4_10 = {result[115*word_length*2-1 -: word_length*2]};
assign pixels_5_10 = {result[116*word_length*2-1 -: word_length*2]};
assign pixels_6_10 = {result[117*word_length*2-1 -: word_length*2]};
assign pixels_7_10 = {result[118*word_length*2-1 -: word_length*2]};
assign pixels_8_10 = {result[119*word_length*2-1 -: word_length*2]};
assign pixels_9_10 = {result[120*word_length*2-1 -: word_length*2]};
assign pixels_10_10 = {result[121*word_length*2-1 -: word_length*2]};


//iter
integer i,j;

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
    if(out_valid)begin
        
        // result[ (($signed(col_answer_1_1)+4)+($signed(row_answer_1_1)+4)*11+1)*word_length-1 -:word_length] = $signed(result[ (($signed(col_answer_1_1)+4)+($signed(row_answer_1_1)+4)*11+1)*word_length-1 -:word_length]) + $signed(answer_1_1);
        // result[ (($signed(col_answer_1_2)+4)+($signed(row_answer_1_2)+4)*11+1)*word_length-1 -:word_length] = $signed(result[ (($signed(col_answer_1_2)+4)+($signed(row_answer_1_2)+4)*11+1)*word_length-1 -:word_length]) + $signed(answer_1_2);
        // result[ (($signed(col_answer_1_3)+4)+($signed(row_answer_1_3)+4)*11+1)*word_length-1 -:word_length] = $signed(result[ (($signed(col_answer_1_3)+4)+($signed(row_answer_1_3)+4)*11+1)*word_length-1 -:word_length]) + $signed(answer_1_3);
        // result[ (($signed(col_answer_1_4)+4)+($signed(row_answer_1_4)+4)*11+1)*word_length-1 -:word_length] = $signed(result[ (($signed(col_answer_1_4)+4)+($signed(row_answer_1_4)+4)*11+1)*word_length-1 -:word_length]) + $signed(answer_1_4);

        // result[ (($signed(col_answer_2_1)+4)+($signed(row_answer_2_1)+4)*11+1)*word_length-1 -:word_length] = $signed(result[ (($signed(col_answer_2_1)+4)+($signed(row_answer_2_1)+4)*11+1)*word_length-1 -:word_length]) + $signed(answer_2_1);
        // result[ (($signed(col_answer_2_2)+4)+($signed(row_answer_2_2)+4)*11+1)*word_length-1 -:word_length] = $signed(result[ (($signed(col_answer_2_2)+4)+($signed(row_answer_2_2)+4)*11+1)*word_length-1 -:word_length]) + $signed(answer_2_2);
        // result[ (($signed(col_answer_2_3)+4)+($signed(row_answer_2_3)+4)*11+1)*word_length-1 -:word_length] = $signed(result[ (($signed(col_answer_2_3)+4)+($signed(row_answer_2_3)+4)*11+1)*word_length-1 -:word_length]) + $signed(answer_2_3);
        // result[ (($signed(col_answer_2_4)+4)+($signed(row_answer_2_4)+4)*11+1)*word_length-1 -:word_length] = $signed(result[ (($signed(col_answer_2_4)+4)+($signed(row_answer_2_4)+4)*11+1)*word_length-1 -:word_length]) + $signed(answer_2_4);

        // result[ (($signed(col_answer_3_1)+4)+($signed(row_answer_3_1)+4)*11+1)*word_length-1 -:word_length] = $signed(result[ (($signed(col_answer_3_1)+4)+($signed(row_answer_3_1)+4)*11+1)*word_length-1 -:word_length]) + $signed(answer_3_1);
        // result[ (($signed(col_answer_3_2)+4)+($signed(row_answer_3_2)+4)*11+1)*word_length-1 -:word_length] = $signed(result[ (($signed(col_answer_3_2)+4)+($signed(row_answer_3_2)+4)*11+1)*word_length-1 -:word_length]) + $signed(answer_3_2);
        // result[ (($signed(col_answer_3_3)+4)+($signed(row_answer_3_3)+4)*11+1)*word_length-1 -:word_length] = $signed(result[ (($signed(col_answer_3_3)+4)+($signed(row_answer_3_3)+4)*11+1)*word_length-1 -:word_length]) + $signed(answer_3_3);
        // result[ (($signed(col_answer_3_4)+4)+($signed(row_answer_3_4)+4)*11+1)*word_length-1 -:word_length] = $signed(result[ (($signed(col_answer_3_4)+4)+($signed(row_answer_3_4)+4)*11+1)*word_length-1 -:word_length]) + $signed(answer_3_4);

        // result[ (($signed(col_answer_4_1)+4)+($signed(row_answer_4_1)+4)*11+1)*word_length-1 -:word_length] = $signed(result[ (($signed(col_answer_4_1)+4)+($signed(row_answer_4_1)+4)*11+1)*word_length-1 -:word_length]) + $signed(answer_4_1);
        // result[ (($signed(col_answer_4_2)+4)+($signed(row_answer_4_2)+4)*11+1)*word_length-1 -:word_length] = $signed(result[ (($signed(col_answer_4_2)+4)+($signed(row_answer_4_2)+4)*11+1)*word_length-1 -:word_length]) + $signed(answer_4_2);
        // result[ (($signed(col_answer_4_3)+4)+($signed(row_answer_4_3)+4)*11+1)*word_length-1 -:word_length] = $signed(result[ (($signed(col_answer_4_3)+4)+($signed(row_answer_4_3)+4)*11+1)*word_length-1 -:word_length]) + $signed(answer_4_3);
        // result[ (($signed(col_answer_4_4)+4)+($signed(row_answer_4_4)+4)*11+1)*word_length-1 -:word_length] = $signed(result[ (($signed(col_answer_4_4)+4)+($signed(row_answer_4_4)+4)*11+1)*word_length-1 -:word_length]) + $signed(answer_4_4);
        result[ (($signed(col_answer_1_1)+4)+($signed(row_answer_1_1)+4)*11+1)*word_length*2-1 -:word_length*2] = $signed(result[ (($signed(col_answer_1_1)+4)+($signed(row_answer_1_1)+4)*11+1)*word_length*2-1 -:word_length*2]) + $signed(answer_1_1);
        result[ (($signed(col_answer_1_2)+4)+($signed(row_answer_1_2)+4)*11+1)*word_length*2-1 -:word_length*2] = $signed(result[ (($signed(col_answer_1_2)+4)+($signed(row_answer_1_2)+4)*11+1)*word_length*2-1 -:word_length*2]) + $signed(answer_1_2);
        result[ (($signed(col_answer_1_3)+4)+($signed(row_answer_1_3)+4)*11+1)*word_length*2-1 -:word_length*2] = $signed(result[ (($signed(col_answer_1_3)+4)+($signed(row_answer_1_3)+4)*11+1)*word_length*2-1 -:word_length*2]) + $signed(answer_1_3);
        result[ (($signed(col_answer_1_4)+4)+($signed(row_answer_1_4)+4)*11+1)*word_length*2-1 -:word_length*2] = $signed(result[ (($signed(col_answer_1_4)+4)+($signed(row_answer_1_4)+4)*11+1)*word_length*2-1 -:word_length*2]) + $signed(answer_1_4);

        result[ (($signed(col_answer_2_1)+4)+($signed(row_answer_2_1)+4)*11+1)*word_length*2-1 -:word_length*2] = $signed(result[ (($signed(col_answer_2_1)+4)+($signed(row_answer_2_1)+4)*11+1)*word_length*2-1 -:word_length*2]) + $signed(answer_2_1);
        result[ (($signed(col_answer_2_2)+4)+($signed(row_answer_2_2)+4)*11+1)*word_length*2-1 -:word_length*2] = $signed(result[ (($signed(col_answer_2_2)+4)+($signed(row_answer_2_2)+4)*11+1)*word_length*2-1 -:word_length*2]) + $signed(answer_2_2);
        result[ (($signed(col_answer_2_3)+4)+($signed(row_answer_2_3)+4)*11+1)*word_length*2-1 -:word_length*2] = $signed(result[ (($signed(col_answer_2_3)+4)+($signed(row_answer_2_3)+4)*11+1)*word_length*2-1 -:word_length*2]) + $signed(answer_2_3);
        result[ (($signed(col_answer_2_4)+4)+($signed(row_answer_2_4)+4)*11+1)*word_length*2-1 -:word_length*2] = $signed(result[ (($signed(col_answer_2_4)+4)+($signed(row_answer_2_4)+4)*11+1)*word_length*2-1 -:word_length*2]) + $signed(answer_2_4);

        result[ (($signed(col_answer_3_1)+4)+($signed(row_answer_3_1)+4)*11+1)*word_length*2-1 -:word_length*2] = $signed(result[ (($signed(col_answer_3_1)+4)+($signed(row_answer_3_1)+4)*11+1)*word_length*2-1 -:word_length*2]) + $signed(answer_3_1);
        result[ (($signed(col_answer_3_2)+4)+($signed(row_answer_3_2)+4)*11+1)*word_length*2-1 -:word_length*2] = $signed(result[ (($signed(col_answer_3_2)+4)+($signed(row_answer_3_2)+4)*11+1)*word_length*2-1 -:word_length*2]) + $signed(answer_3_2);
        result[ (($signed(col_answer_3_3)+4)+($signed(row_answer_3_3)+4)*11+1)*word_length*2-1 -:word_length*2] = $signed(result[ (($signed(col_answer_3_3)+4)+($signed(row_answer_3_3)+4)*11+1)*word_length*2-1 -:word_length*2]) + $signed(answer_3_3);
        result[ (($signed(col_answer_3_4)+4)+($signed(row_answer_3_4)+4)*11+1)*word_length*2-1 -:word_length*2] = $signed(result[ (($signed(col_answer_3_4)+4)+($signed(row_answer_3_4)+4)*11+1)*word_length*2-1 -:word_length*2]) + $signed(answer_3_4);

        result[ (($signed(col_answer_4_1)+4)+($signed(row_answer_4_1)+4)*11+1)*word_length*2-1 -:word_length*2] = $signed(result[ (($signed(col_answer_4_1)+4)+($signed(row_answer_4_1)+4)*11+1)*word_length*2-1 -:word_length*2]) + $signed(answer_4_1);
        result[ (($signed(col_answer_4_2)+4)+($signed(row_answer_4_2)+4)*11+1)*word_length*2-1 -:word_length*2] = $signed(result[ (($signed(col_answer_4_2)+4)+($signed(row_answer_4_2)+4)*11+1)*word_length*2-1 -:word_length*2]) + $signed(answer_4_2);
        result[ (($signed(col_answer_4_3)+4)+($signed(row_answer_4_3)+4)*11+1)*word_length*2-1 -:word_length*2] = $signed(result[ (($signed(col_answer_4_3)+4)+($signed(row_answer_4_3)+4)*11+1)*word_length*2-1 -:word_length*2]) + $signed(answer_4_3);
        result[ (($signed(col_answer_4_4)+4)+($signed(row_answer_4_4)+4)*11+1)*word_length*2-1 -:word_length*2] = $signed(result[ (($signed(col_answer_4_4)+4)+($signed(row_answer_4_4)+4)*11+1)*word_length*2-1 -:word_length*2]) + $signed(answer_4_4);

    end
    //result[11*(data_out_rows[col_length-1:0]+4)+(data_out_cols[col_length-1:0]+4)+1 -:word_length] <= data_out[word_length-1:0] + result[11*(data_out_rows[col_length-1:0]+4)+(data_out_cols[col_length-1:0]+4)+1 -:word_length];
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
    .data_out_rows(data_out_rows),
    .out_valid(out_valid)
);







endmodule