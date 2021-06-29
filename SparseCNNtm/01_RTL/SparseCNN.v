`include "CSR.v"
`include "PE.v"
`include "PE_UNIT.v"
`include "PEADDER.v"

module SparseCNN#(
  parameter input_size = 28,
  parameter kernel_size = 5,
  parameter word_length = 8, // used for data
  parameter col_length = 8,
  parameter double_word_length = 16, // used for utils number,
  parameter output_size = 24,
  parameter PE_output_size = 16,
  parameter PE_weight_row_size = 28
)(clk, tclk, rst, feature_in_valid, in_feature, pe_input_weight_value, pe_input_weight_rows, pe_input_weight_cols, weight_valid_num, out_valid, out_feature);

  input         clk;
  input         tclk;
  input         rst;
  
  input         feature_in_valid;
  input   [word_length-1:0] in_feature;
  input [224-1:0] pe_input_weight_value;
  input [224-1 :0] pe_input_weight_rows;
  input [224-1 :0] pe_input_weight_cols;
  input [double_word_length-1:0] weight_valid_num;
  
  output       out_valid;
  output  [output_size*output_size*double_word_length-1:0] out_feature;

  wire [double_word_length-1:0] channel;
  assign channel = 1;
  wire csr_feature_done;
  wire [double_word_length-1:0] csr_feature_valid_num;
  wire [input_size*input_size*word_length -1:0] csr_feature_value_output;
  wire [input_size*input_size*col_length -1:0] csr_feature_col_output, csr_feature_row_output;

  wire signed [double_word_length*PE_output_size -1:0] pe_data_out;
  wire signed [col_length*PE_output_size -1:0] pe_data_out_cols;
  wire signed [col_length*PE_output_size -1:0] pe_data_out_rows;
  wire pe_out_valid;

  // PEAdder output
  wire [output_size*output_size*double_word_length-1:0] peadder_data_out_wire;
  wire peadder_out_valid_wire;

  // Output
  reg [output_size*output_size*double_word_length-1:0] data_out_r, next_data_out_r;
  reg out_valid_r, next_out_valid_r;

  assign out_valid = out_valid_r;
  assign out_feature = data_out_r;

  CSR #(
    .image_size(input_size),
    .col_length(col_length),
    .word_length(word_length),
    .double_word_length(double_word_length) 
  ) feature_csr (
  .clk(clk),
  .rst(rst),
  .in_valid(feature_in_valid),
  .data_in(in_feature),
  .out_valid(csr_feature_done),
  .valid_num_out(csr_feature_valid_num),
  .data_out(csr_feature_value_output),
  .data_out_cols(csr_feature_col_output),
  .data_out_rows(csr_feature_row_output)
  );

  PE #(
    .col_length(col_length),
    .word_length(word_length),
    .double_word_length(double_word_length),
    .kernel_size(kernel_size),
    .image_size(input_size)
  ) pe( 
    .clk(clk),
    .rst(rst),
    .in_channel(channel),
    .in_valid(csr_feature_done),
    .feature_valid_num(csr_feature_valid_num),
    .feature_value(csr_feature_value_output),
    .feature_cols(csr_feature_col_output),
    .feature_rows(csr_feature_row_output),
    .weight_valid_num(weight_valid_num),
    .weight_value(pe_input_weight_value),
    .weight_cols(pe_input_weight_rows),
    .weight_rows(pe_input_weight_cols),
    .out_valid(pe_out_valid),
    .data_out(pe_data_out),
    .data_out_cols(pe_data_out_cols),
    .data_out_rows(pe_data_out_rows),
    .out_channel(channel)
  );


  PEADDER #(
    .col_length(col_length),
    .word_length(word_length),
    .double_word_length(double_word_length),
    .PE_output_size(PE_output_size),
    .output_col_size(output_size),
    .output_size(output_size*output_size)
  ) peadder(
    .clk(clk),
    .tclk(tclk),
    .rst(rst),
    .in_valid(pe_out_valid),
    .data_in(pe_data_out),
    .data_in_cols(pe_data_out_cols),
    .data_in_rows(pe_data_out_rows),
    
    .out_valid(peadder_out_valid_wire),
    .data_out(peadder_data_out_wire)
  );

always @(negedge peadder_out_valid_wire) begin
  if(csr_feature_done) next_out_valid_r = 1;
  else next_out_valid_r = out_valid_r; 
end

always @(*) begin
  if (peadder_out_valid_wire) next_data_out_r = peadder_data_out_wire;
  else next_data_out_r = data_out_r;
end

always @(posedge clk or posedge rst) begin
  if(rst) begin
    out_valid_r <= 0;
    data_out_r <= 0;
  end
  else begin
    out_valid_r <= next_out_valid_r;
    data_out_r <= next_data_out_r;
  end
end

endmodule
