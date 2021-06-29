module PEADDER
#(
    parameter col_length = 8,
    parameter word_length = 8,
    parameter double_word_length = 16,
    parameter PE_output_size = 16,
    parameter output_col_size = 5,
    parameter output_size = 25
)
(
  input clk,
  input tclk,
  input rst,
  input in_valid,
  input signed [double_word_length*PE_output_size -1:0]data_in,
  input signed [col_length*PE_output_size -1:0]data_in_cols,
  input signed [col_length*PE_output_size -1:0]data_in_rows,
  
  output out_valid,
  output [(output_size)*double_word_length-1:0] data_out
);

reg signed [double_word_length*PE_output_size -1:0] data_in_r, next_data_in_r;
reg [(output_size)*double_word_length-1:0] data_out_r, next_data_out_r;
reg out_valid_r, next_out_valid_r;
reg [3:0] counter, next_counter;

reg [output_size*double_word_length-1:0] temp_out_feature [PE_output_size-1:0];
reg [double_word_length-1:0] current_data;
reg [double_word_length-1:0] position;
reg [col_length-1:0] col, row;

assign out_valid = out_valid_r;
assign data_out = data_out_r;

always @(*) begin
  col = data_in_cols >> counter*col_length;
  row = data_in_rows >> counter*col_length;
  position = col + row*output_col_size;
  next_out_valid_r = in_valid; 
  if(in_valid) begin
    if($signed(col) < output_col_size & $signed(col) >= 0 & $signed(row) < output_col_size & $signed(row) >= 0) begin
      current_data = data_out_r[position*double_word_length+:double_word_length] + data_in[counter*double_word_length+:double_word_length];
    end
    
    else current_data = data_out_r[counter*double_word_length+:double_word_length];
    next_counter = counter + 1;
  end
  else begin
    current_data = data_out_r[counter*double_word_length+:double_word_length];
    next_counter = 0;
  end
end

always @(posedge tclk or posedge rst) begin
  if(rst) begin
    counter <= 0;
    data_out_r <= 0;
  end
  else begin
    counter <= next_counter;
    data_out_r[(position)*double_word_length+:double_word_length] <= current_data;
  end
end

always @(posedge clk or posedge rst) begin
  if(rst) begin
    out_valid_r <= 0;
  end
  else begin
    out_valid_r <= next_out_valid_r;
  end
end

endmodule
