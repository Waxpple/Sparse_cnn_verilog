module PE_top
#(
  parameter col_length = 8,
  parameter wordlength = 16,
  parameter kernelSize = 5,    
  parameter dataRowNum = 28,
  parameter wordLength = 8, // used for data and col_length
  parameter doublewordLength = 16 // used for utils number 
)
(
  input         clk,
  input         rst,
  input         in_valid,
  input   [doublewordLength-1:0] feacture_valid_num,
  input   [dataRowNum*dataRowNum*wordLength-1:0] feacture_value,
  input   [dataRowNum*dataRowNum*wordLength-1:0] feacture_cols,
  input   [dataRowNum*dataRowNum*wordLength-1:0] feacture_rows,
  input   [doublewordLength-1:0] weight_valid_num,
  input   [kernelSize*kernelSize*wordLength-1:0] weight_value,
  input   [kernelSize*kernelSize*wordLength-1:0] weight_cols,
  input   [kernelSize*kernelSize*wordLength-1:0] weight_rows,
  
  output  out_valid,
  output  [(dataRowNum-kernelSize + 1)*(dataRowNum-kernelSize + 1)*wordLength-1:0] data_out
  
);

// TODO
wire [doublewordLength-1:0] curr_pixel,curr_weight;
wire signed [col_length*1 -1:0] weight_in_cols,weight_in_rows;
wire signed [col_length*4 -1:0]data_in_cols,data_in_rows;
wire signed [wordlength*1 -1:0] weight_in;
wire signed [wordlength*4 -1:0] data_in;

// assign weight_in_cols = weight_cols[(curr_weight+1)*col_length-1 -:col_length];
// assign weight_in_rows = weight_rows[(curr_weight+1)*col_length-1 -:col_length];
// assign weight_in = weight_value[(curr_weight+1)*wordLength-1 -:wordLength];


// assign data_in_cols = feacture_cols[(curr_pixel+1)*4*col_length-1 -:col_length*4];
// assign data_in_rows = feacture_rows[(curr_pixel+1)*4*col_length-1 -:col_length*4];
// assign data_in = feacture_value[(curr_pixel+1)*4*wordLength-1 -:wordLength*4];

assign weight_in_cols = weight_cols[(curr_weight)*col_length-1 -:col_length];
assign weight_in_rows = weight_rows[(curr_weight)*col_length-1 -:col_length];
assign weight_in = weight_value[(curr_weight)*wordLength-1 -:wordLength];


assign data_in_cols = feacture_cols[(curr_pixel)*4*col_length-1 -:col_length*4];
assign data_in_rows = feacture_rows[(curr_pixel)*4*col_length-1 -:col_length*4];
assign data_in = feacture_value[(curr_pixel)*4*wordLength-1 -:wordLength*4];



PE #(
.col_length(col_length),
.wordlength(wordlength),
.kernel_size(kernelSize),
.doublewordLength(doublewordLength)
) u1 (
.clk(clk),
.irst_n(irst_n),
.in_valid(in_valid),
.pixels(feacture_valid_num),
.in_channel(),
.weight_cols(weight_in_cols),
.weight_rows(weight_in_rows),
.weight(weight_in),
.data_in_cols(data_in_cols),
.data_in_rows(data_in_rows),
.data_in(data_in),
.out_channel(),
.data_out(data_out),
.data_out_cols(),
.data_out_rows(),
.out_valid(out_valid),
.curr_pixel(curr_pixel),
.curr_weight(curr_weight)
);








endmodule