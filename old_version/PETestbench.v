`include "PE.v"
`timescale 1ns/10ps

`define CYCLE 10
`define ENDCYCLE  40000

`define PE_INPUT_FEACTURE_VALUE_PATTERN     "../../GoldenPattern/PE/pe_input_feacture_value_pattern28x28.dat"
`define PE_INPUT_FEACTURE_COLS_PATTERN     "../../GoldenPattern/PE/pe_input_feacture_cols_pattern28x28.dat"
`define PE_INPUT_FEACTURE_ROWS_PATTERN     "../../GoldenPattern/PE/pe_input_feacture_rows_pattern28x28.dat"
`define PE_INPUT_WEIGHT_VALUE_PATTERN     "../../GoldenPattern/PE/pe_input_weight_value_pattern5x5.dat"
`define PE_INPUT_WEIGHT_COLS_PATTERN     "../../GoldenPattern/PE/pe_input_weight_cols_pattern5x5.dat"
`define PE_INPUT_WEIGHT_ROWS_PATTERN     "../../GoldenPattern/PE/pe_input_weight_rows_pattern5x5.dat"
`define PE_OUTPUT_PATTERN     "../../GoldenPattern/PE/pe_output_pattern24x24.dat"
`define WORD_LENGTH 8
`define IMAGE_SIZE 28
`define KERNEL_SIZE 5
`define PE_INPUT_FEACTURE_VALID_NUMBER  111
`define PE_INPUT_WEIGHT_VALID_NUMBER  25

// color definition
`define YEL "%c[0;33m",27
`define BLK "%c[0;m",27

module PETestBench();

// TODO: module, reg, wire, clock, rst initialization...
reg clk = 0;
reg rst;
reg in_valid;

parameter word_length = `WORD_LENGTH;
parameter double_word_length = 2*`WORD_LENGTH;
parameter image_size = `IMAGE_SIZE;
parameter kernel_size = `KERNEL_SIZE;
parameter input_feacture_valid_num = `PE_INPUT_FEACTURE_VALID_NUMBER;
parameter input_weight_valid_num = `PE_INPUT_WEIGHT_VALID_NUMBER;

reg [word_length-1:0] pe_input_feature_value_pat_mem [0:image_size*image_size-1];
reg [word_length-1:0] pe_input_feacture_cols_pat_mem [0:image_size*image_size-1];
reg [word_length-1:0] pe_input_feacture_rows_pat_mem [0:image_size*image_size-1];
reg [word_length-1:0] pe_input_weight_value_pat_mem [0:kernel_size*kernel_size-1];
reg [word_length-1:0] pe_input_weight_cols_pat_mem [0:kernel_size*kernel_size-1];
reg [word_length-1:0] pe_input_weight_rows_pat_mem [0:kernel_size*kernel_size-1];
reg [word_length-1:0] pe_output_pat_mem [0:(image_size-kernel_size+1)*(image_size-kernel_size+1)-1];

wire [double_word_length-1:0] input_feacture_valid_num_w = input_feacture_valid_num; 
wire [double_word_length-1:0] input_weight_valid_num_w = input_weight_valid_num; 
wire [image_size*image_size*word_length-1:0] pe_input_feature_value;
wire [image_size*image_size*word_length-1:0] pe_input_feacture_cols;
wire [image_size*image_size*word_length-1:0] pe_input_feacture_rows;
wire [kernel_size*kernel_size*word_length-1:0] pe_input_weight_value;
wire [kernel_size*kernel_size*word_length-1:0] pe_input_weight_cols;
wire [kernel_size*kernel_size*word_length-1:0] pe_input_weight_rows;
wire [(image_size-kernel_size+1)*(image_size-kernel_size+1)*word_length-1:0] out_feacture;
wire out_valid;

genvar i;
// Bind 2d input_feacture_value to 1d array
generate
  for (i=0; i<image_size*image_size; i=i+1) begin
    assign pe_input_feature_value[word_length*i+word_length-1:word_length*i] = pe_input_feature_value_pat_mem[i];
  end 
endgenerate

// Bind 2d input_feacture_cols to 1d array
generate
  for (i=0; i<image_size*image_size; i=i+1) begin
    assign pe_input_feacture_cols[word_length*i+word_length-1:word_length*i] = pe_input_feacture_cols_pat_mem[i];
  end 
endgenerate

// Bind 2d input_feacture_rows to 1d array
generate
  for (i=0; i<image_size*image_size; i=i+1) begin
    assign pe_input_feacture_rows[word_length*i+word_length-1:word_length*i] = pe_input_feacture_rows_pat_mem[i];
  end 
endgenerate

// Bind 2d input_weight_values to 1d array
generate
  for (i=0; i<kernel_size*kernel_size; i=i+1) begin
    assign pe_input_weight_value[word_length*i+word_length-1:word_length*i] = pe_input_weight_value_pat_mem[i];
  end 
endgenerate

// Bind 2d input_weight_cols to 1d array
generate
  for (i=0; i<kernel_size*kernel_size; i=i+1) begin
    assign pe_input_weight_cols[word_length*i+word_length-1:word_length*i] = pe_input_weight_cols_pat_mem[i];
  end 
endgenerate

// Bind 2d input_weight_rows to 1d array
generate
  for (i=0; i<kernel_size*kernel_size; i=i+1) begin
    assign pe_input_weight_rows[word_length*i+word_length-1:word_length*i] = pe_input_weight_rows_pat_mem[i];
  end 
endgenerate

PE #(.col_length(word_length), .word_length(word_length), .double_word_length(double_word_length), .kernel_size(kernel_size), .image_size(image_size)) pe( 
  .clk(clk), .rst(rst), .in_valid(in_valid), .feacture_valid_num(input_feacture_valid_num_w), .feacture_value(pe_input_feature_value), .feacture_cols(pe_input_feacture_cols),
   .feacture_rows(pe_input_feacture_rows), .weight_valid_num(input_weight_valid_num_w), .weight_value(pe_input_weight_value), .weight_cols(pe_input_weight_cols),
   .weight_rows(pe_input_weight_rows), .out_valid(out_valid), .data_out(out_feacture)
);

always #(`CYCLE/2) clk = ~clk;

initial begin
   `ifdef SDFSYN
     $sdf_annotate("PE_syn.sdf", DUT);
   `endif
   `ifdef SDFAPR
     $sdf_annotate("PE_APR.sdf", DUT);
   `endif	 	 
   `ifdef FSDB
     $fsdbDumpfile("PE.fsdb");
	 $fsdbDumpvars();
   `endif
  //  `ifdef VCD
     $dumpfile("PE.vcd");
	 $dumpvars();
  //  `endif
end

initial begin
	$readmemb(`PE_INPUT_FEACTURE_VALUE_PATTERN , pe_input_feature_value_pat_mem);
	$readmemh(`PE_INPUT_FEACTURE_COLS_PATTERN, pe_input_feacture_cols_pat_mem);
	$readmemh(`PE_INPUT_FEACTURE_ROWS_PATTERN, pe_input_feacture_rows_pat_mem);
	$readmemb(`PE_INPUT_WEIGHT_VALUE_PATTERN , pe_input_weight_value_pat_mem);
	$readmemh(`PE_INPUT_WEIGHT_COLS_PATTERN, pe_input_weight_cols_pat_mem);
	$readmemh(`PE_INPUT_WEIGHT_ROWS_PATTERN, pe_input_weight_rows_pat_mem);
	$readmemb(`PE_OUTPUT_PATTERN , pe_output_pat_mem);
end

//rst initialization
initial begin
   rst = 0;
   #(`CYCLE/2*3);
   rst = 1;
   #(`CYCLE/2);
   rst = 0;
   in_valid = 1;
end

integer value_error_num = 0;
integer value_golden_idx = 0;
genvar j;
generate
 for(j=0; j<(image_size-kernel_size+1)*(image_size-kernel_size+1);j=j+1) begin
   always @(negedge clk) begin
     if(out_valid===1) begin
       if(out_feacture[word_length*j+word_length-1:word_length*j] !== pe_output_pat_mem[j]) begin
         value_error_num = value_error_num+1; 
       end
       value_golden_idx = value_golden_idx+1; 
     end
   end 
 end 
endgenerate

always @(*) begin
  if(value_golden_idx == (image_size-kernel_size+1)*(image_size-kernel_size+1) ) begin
    $display("Value error number: %d\n", value_error_num); 
    $finish();
  end
end


// Time out
initial begin
  #(`CYCLE*`ENDCYCLE);
  $display(" =================== TIME OUT ======================\n");
  $display("         There are someting wrong in your code...  \n");
  $display("           If you need more simulation time         ");
  $display("  You can try to modify ENDCYCLE in the testfixture.\n");
  $display(" =================== TIME OUT ======================\n");
  $finish;
end

endmodule
