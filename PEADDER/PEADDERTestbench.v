`include "PEADDER.v"
`timescale 1ns/10ps

`define CYCLE 10
`define ENDCYCLE  40000

`define PEADDER_INPUT_VALUES_PATTERN     "../../GoldenPattern/PEADDER/peadder_values_pattern32.dat"
`define PEADDER_INPUT_COLS_PATTERN     "../../GoldenPattern/PEADDER/peadder_cols_pattern32.dat"
`define PEADDER_INPUT_ROWS_PATTERN     "../../GoldenPattern/PEADDER/peadder_rows_pattern32.dat"
`define PEADDER_OUTPUT_PATTERN     "../../GoldenPattern/PEADDER/peadder_output_pattern5x5.dat"
`define WORD_LENGTH 8
`define IMAGE_SIZE 28
`define KERNEL_SIZE 5
`define PE_INPUT_feature_VALID_NUMBER  111
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
parameter col_length = `WORD_LENGTH;
parameter double_word_length = 2*`WORD_LENGTH;
parameter input_size = 32;
parameter output_size = 25;
parameter PE_output_size = 16;

reg [double_word_length-1:0] peadder_input_values_pat_mem [0:input_size-1];
reg [word_length-1:0] peadder_input_cols_pat_mem [0:input_size-1];
reg [word_length-1:0] peadder_input_rows_pat_mem [0:input_size-1];
reg [double_word_length-1:0] peadder_output_pat_mem [0:output_size-1];
reg [output_size*double_word_length-1:0] data_out_r, next_data_out_r;
reg [2:0] counter, next_counter;
reg in_valid_r, next_in_valid_r;
reg out_valid_r, next_out_valid_r;

wire signed [double_word_length*PE_output_size -1:0]data_in;
wire signed [col_length*PE_output_size -1:0]data_in_cols;
wire signed [col_length*PE_output_size -1:0]data_in_rows;
wire [output_size*double_word_length-1:0] data_out_wire;
wire out_valid_wire;

genvar i;
// Bind 2d input_feature_value to 1d array
generate
  for (i=0; i<PE_output_size; i=i+1) begin
    assign data_in[double_word_length*i+double_word_length-1:double_word_length*i] = peadder_input_values_pat_mem[i];
  end 
endgenerate

// Bind 2d input_feature_cols to 1d array
generate
  for (i=0; i<PE_output_size; i=i+1) begin
    assign data_in_cols[word_length*i+word_length-1:word_length*i] = peadder_input_cols_pat_mem[i];
  end 
endgenerate

// Bind 2d input_feature_cols to 1d array
generate
  for (i=0; i<PE_output_size; i=i+1) begin
    assign data_in_rows[word_length*i+word_length-1:word_length*i] = peadder_input_rows_pat_mem[i];
  end 
endgenerate

PEADDER adder( 
  .clk(clk),
  .rst(rst),
  .in_valid(in_valid_r),
  .data_in(data_in),
  .data_in_cols(data_in_cols),
  .data_in_rows(data_in_rows),
  
  .out_valid(out_valid_wire),
  .data_out(data_out_wire)
);

always #(`CYCLE/2) clk = ~clk;

initial begin
   `ifdef SDFSYN
     $sdf_annotate("PEADDER_syn.sdf", DUT);
   `endif
   `ifdef SDFAPR
     $sdf_annotate("PEADDER_APR.sdf", DUT);
   `endif	 	 
   `ifdef FSDB
     $fsdbDumpfile("PEADDER.fsdb");
	 $fsdbDumpvars();
   `endif
  //  `ifdef VCD
     $dumpfile("PEADDEr.vcd");
	 $dumpvars();
  //  `endif
end

initial begin
	$readmemb(`PEADDER_INPUT_VALUES_PATTERN , peadder_input_values_pat_mem);
	$readmemb(`PEADDER_INPUT_COLS_PATTERN, peadder_input_cols_pat_mem);
	$readmemb(`PEADDER_INPUT_ROWS_PATTERN, peadder_input_rows_pat_mem);
	$readmemb(`PEADDER_OUTPUT_PATTERN , peadder_output_pat_mem);
end

//rst initialization
initial begin
   rst = 0;
   next_in_valid_r = 0;
   #(`CYCLE/2*3);
   rst = 1;
   #(`CYCLE/2);
   rst = 0;
   next_in_valid_r = 1;
end

always @(*) begin
  next_data_out_r = data_out_wire; 
  next_out_valid_r = out_valid_wire;
  next_counter = counter + 1;

  if(counter > 1) next_in_valid_r = 0;
  else next_in_valid_r = 1;
end

integer value_golden_idx = 0;
integer value_error_num = 0;
genvar w;
generate
 for(w=0; w<output_size;w=w+1) begin
  always @(*) begin
    if((counter == 4) && !out_valid_wire) begin
      if(data_out_r[double_word_length*w+double_word_length-1:double_word_length*w] !== peadder_output_pat_mem[w]) begin
        value_error_num = value_error_num+1; 
      end
      $display("index: %d, out: %h, pat: %h", w, data_out_r[double_word_length*w+double_word_length-1:double_word_length*w], peadder_output_pat_mem[w]); 
      value_golden_idx = value_golden_idx + 1;
    end
  end
 end 
endgenerate


always @(posedge clk or posedge rst) begin
  if(rst) begin
    data_out_r <= 0;
    counter <= 0;
    in_valid_r <= 0;
    out_valid_r <= 0;
  end
  else begin
    data_out_r <= next_data_out_r;
    counter <= next_counter;
    in_valid_r <= next_in_valid_r;
    out_valid_r <= next_out_valid_r;
  end
end 

always @(*) begin
  if(value_golden_idx == output_size ) begin
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
