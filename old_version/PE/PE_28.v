`include "PE_UNIT.v"
module PE
#(
    parameter col_length = 8,
    parameter word_length = 8,
    parameter double_word_length = 16,
    parameter kernel_size = 5,
    parameter image_size = 28
)
(
  input         clk,
  input         rst,
  input         in_valid,
  input   [double_word_length-1:0] in_channel,
  input   [double_word_length-1:0] feature_valid_num,
  input   [image_size*image_size*word_length-1:0] feature_value,
  input   [image_size*image_size*col_length-1:0] feature_cols,
  input   [image_size*image_size*col_length-1:0] feature_rows,
  input   [double_word_length-1:0] weight_valid_num,
  input   [28*word_length-1:0] weight_value,
  input   [28*col_length-1:0] weight_cols,
  input   [28*col_length-1:0] weight_rows,
  
  output  out_valid,
  output signed [word_length*2*16 -1:0]data_out,
  output signed [col_length*16 -1:0]data_out_cols,
  output signed [col_length*16 -1:0]data_out_rows
  
);

// TODO
wire [double_word_length-1:0] curr_pixel,curr_weight;
wire signed [col_length*1 -1:0] weight_in_cols,weight_in_rows;
wire signed [col_length*4 -1:0]data_in_cols,data_in_rows;
wire signed [word_length*1 -1:0] weight_in;
wire signed [word_length*4 -1:0] data_in;

assign weight_in_cols = (curr_weight<weight_valid_num || curr_pixel < feature_valid_num)?weight_cols[(curr_weight+1)*col_length-1 -:col_length]:'d0;
assign weight_in_rows = (curr_weight<weight_valid_num || curr_pixel < feature_valid_num)?weight_rows[(curr_weight+1)*col_length-1 -:col_length]:'d0;
assign weight_in = (curr_weight<weight_valid_num || curr_pixel < feature_valid_num)?weight_value[(curr_weight+1)*word_length-1 -:word_length]:'d0;


assign data_in_cols = (curr_weight<weight_valid_num || curr_pixel < feature_valid_num)?feature_cols[(curr_pixel+1)*4*col_length-1 -:col_length*4]:'d0;
assign data_in_rows = (curr_weight<weight_valid_num || curr_pixel < feature_valid_num)?feature_rows[(curr_pixel+1)*4*col_length-1 -:col_length*4]:'d0;
assign data_in = (curr_weight<weight_valid_num || curr_pixel < feature_valid_num)?feature_value[(curr_pixel+1)*4*word_length-1 -:word_length*4]:'d0;




PE_UNIT_NEW_2 #(
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
    .feature_valid_num(feature_valid_num), 
    .feature_value(data_in), 
    .feature_cols(data_in_cols),
    .feature_rows(data_in_rows), 
    .weight_valid_num(weight_valid_num),
    .weight_value(weight_in), 
    .weight_cols(weight_in_cols),
    .weight_rows(weight_in_rows), 
    .out_valid(out_valid), 
    .data_out(data_out),
    .data_out_cols(data_out_cols),
    .data_out_rows(data_out_rows),
    .curr_pixel(curr_pixel),
    .curr_weight(curr_weight)
);



endmodule