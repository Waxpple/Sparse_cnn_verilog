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
  input rst,
  input in_valid,
  input signed [double_word_length*PE_output_size -1:0]data_in,
  input signed [col_length*PE_output_size -1:0]data_in_cols,
  input signed [col_length*PE_output_size -1:0]data_in_rows,
  
  output out_valid,
  output [(output_size)*double_word_length-1:0] data_out
);

reg [(output_size)*double_word_length-1:0] data_out_r, next_data_out_r;
reg out_valid_r, next_out_valid_r;

reg [output_size*double_word_length-1:0] temp_out_feature [PE_output_size-1:0];
reg [double_word_length-1:0] shift_num [PE_output_size-1:0];

assign out_valid = out_valid_r;
assign data_out = data_out_r;

integer i;

genvar j;
generate
 for(j=0; j< PE_output_size;j=j+1) begin
  wire [double_word_length-1:0] current_data;
  assign current_data = data_in[((j+1)*double_word_length - 1):j*double_word_length];
  always @(*) begin
    temp_out_feature[j] = 0;
    shift_num[j] = ((data_in_cols[((j+1)*col_length - 1):j*col_length] + data_in_rows[((j+1)*col_length - 1):j*col_length]*output_col_size));
    if(in_valid==1) begin
      if($signed(data_in_cols[j*col_length+:col_length]) >= 0 & $signed(data_in_cols[j*col_length+:col_length]) < output_col_size & $signed(data_in_rows[j*col_length+:col_length]) >= 0 & $signed(data_in_rows[j*col_length+:col_length]) < output_col_size) begin
        temp_out_feature[j] = (current_data << (shift_num[j] << 4));
      end
    end
  end 
 end 
endgenerate

genvar w;
generate
 for(w=0; w< output_size;w=w+1) begin
   always @(*) begin
     next_data_out_r[(w+1)*double_word_length-1:w*double_word_length] = data_out_r[(w+1)*double_word_length-1:w*double_word_length];
      if(shift_num[0] == w | shift_num[1] == w | shift_num[2] == w | shift_num[3] == w | shift_num[4] == w | shift_num[5] == w | shift_num[6] == w | shift_num[7] == w | shift_num[8] == w | shift_num[9] == w | shift_num[10] == w | shift_num[11] == w | shift_num[12] == w | shift_num[13] == w | shift_num[14] == w | shift_num[15] == w) begin
        next_data_out_r[w*double_word_length+:double_word_length] = data_out_r[w*double_word_length+:double_word_length]+ temp_out_feature[0][w*double_word_length+:double_word_length]+ temp_out_feature[1][w*double_word_length+:double_word_length] + temp_out_feature[2][w*double_word_length+:double_word_length]+ temp_out_feature[3][w*double_word_length+:double_word_length]+ temp_out_feature[4][w*double_word_length+:double_word_length]+ temp_out_feature[5][w*double_word_length+:double_word_length]+ temp_out_feature[6][w*double_word_length+:double_word_length]+ temp_out_feature[7][w*double_word_length+:double_word_length] + temp_out_feature[8][w*double_word_length+:double_word_length] + temp_out_feature[9][w*double_word_length+:double_word_length]+ temp_out_feature[10][w*double_word_length+:double_word_length] + temp_out_feature[11][w*double_word_length+:double_word_length]+ temp_out_feature[12][w*double_word_length+:double_word_length]+ temp_out_feature[13][w*double_word_length+:double_word_length]+ temp_out_feature[14][w*double_word_length+:double_word_length]+ temp_out_feature[15][w*double_word_length+:double_word_length];  
      end
   end
 end 
endgenerate

always @(*) begin
  next_out_valid_r = in_valid; 
end

always @(posedge clk or posedge rst) begin
  if(rst) begin
    data_out_r <= 0;
    out_valid_r <= 0;
  end
  else begin
    data_out_r <= next_data_out_r;
    out_valid_r <= next_out_valid_r;
  end
end

endmodule