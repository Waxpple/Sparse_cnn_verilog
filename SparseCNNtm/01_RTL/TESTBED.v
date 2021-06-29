`timescale 1ns/10ps

`define CYCLE 32
`define ENDCYCLE  100000

`define SparseCNN_INPUT_PATTERN     "../GoldenPattern/SparseCNN/image_pattern28x28.dat"
`define SparseCNN_WEIGHT_PATTERN     "../GoldenPattern/SparseCNN/sparsecnn_weight_pattern5x5.dat"
`define SparseCNN_OUTPUT_PATTERN     "../GoldenPattern/SparseCNN/sparsecnn_output_pattern24x24.dat"
`define WORD_LENGTH 8
`define COL_LENGTH 8
`define IMAGE_SIZE 28
`define KERNEL_SIZE 5

// color definition
`define YEL "%c[0;33m",27
`define BLK "%c[0;m",27

module TESTBED();

// TODO: module, reg, wire, clock, rst initialization...
reg clk = 0;
reg tclk = 0;
reg rst;
reg in_valid;

parameter word_length = `WORD_LENGTH;
parameter col_length = `COL_LENGTH;
parameter double_word_length = 2*`WORD_LENGTH;
parameter image_size = `IMAGE_SIZE;
parameter kernel_size = `KERNEL_SIZE;
parameter output_size = image_size-kernel_size+1;
parameter weight_row_size = 28;
parameter PE_output_size = 16;

reg [224-1:0] pe_input_weight_value ='h08_09_03_02_fd_05_09_09_08_01_ff_ff_03_07_06_f5_fc_fc_02_04_f9_f8_fd_ff_01;
reg [224-1 :0] pe_input_weight_rows='h04_04_04_04_04_03_03_03_03_03_02_02_02_02_02_01_01_01_01_01_00_00_00_00_00;
reg [224-1 :0] pe_input_weight_cols='h04_03_02_01_00_04_03_02_01_00_04_03_02_01_00_04_03_02_01_00_04_03_02_01_00;
reg [double_word_length-1:0] weight_valid_num='d25;

reg [word_length-1:0] sparsecnn_input_pat_mem [0:image_size*image_size-1];
reg [word_length-1:0] sparsecnn_weight_pat_mem [0:kernel_size*kernel_size-1];
reg [double_word_length-1:0] sparsecnn_output_pat_mem [0:output_size*output_size-1];
reg [output_size*output_size*double_word_length-1:0] out_feature, next_out_feature;
reg [16:0] clk_counter, next_clk_counter;

reg [word_length-1:0] sparsecnn_input_feature_value;
reg [word_length-1:0] sparsecnn_input_weight_value;
wire signed [double_word_length*output_size*output_size -1:0]data_out;
wire out_valid;

// genvar i;
// // Bind 2d input_feature_value to 1d array
// generate
//   for (i=0; i<image_size*image_size; i=i+1) begin
//     assign sparsecnn_input_feature_value[word_length*i+word_length-1:word_length*i] = sparsecnn_input_pat_mem[i];
//   end 
// endgenerate

// // Bind 2d input_weight_value to 1d array
// generate
//   for (i=0; i<kernel_size*kernel_size; i=i+1) begin
//     assign sparsecnn_input_weight_value[word_length*i+word_length-1:word_length*i] = sparsecnn_weight_pat_mem[i];
//   end 
// endgenerate

SparseCNN  SPARSECNN_CORE (
  .clk(clk),
  .tclk(tclk),
  .rst(rst),
  .feature_in_valid(in_valid),
  .in_feature(sparsecnn_input_feature_value),
  .pe_input_weight_value(pe_input_weight_value),
  .pe_input_weight_rows(pe_input_weight_cols),
  .pe_input_weight_cols(pe_input_weight_rows),
  .weight_valid_num(weight_valid_num),
  .out_valid(out_valid),
  .out_feature(data_out)
);


always #(`CYCLE/32) tclk = ~tclk;
always #(`CYCLE/2) clk = ~clk;

initial begin
			$dumpfile("SPARSECNN_local.vcd");
			$dumpvars();
	`ifdef RTL
		$fsdbDumpfile("SPARSECNN_RTL.fsdb");
		$fsdbDumpvars(0, TESTBED);
	`elsif GATE
		$sdf_annotate("../02_SYN/Netlist/SPARSECNN_syn.sdf",SPARSECNN_CORE);

		`ifdef VCD
			$dumpfile("SPARSECNN_GATE.vcd");
			$dumpvars();
		`elsif FSDB
			$fsdbDumpfile("SPARSECNN_GATE.fsdb");
			$fsdbDumpvars(0, SPARSECNN_CORE);
		`endif
	`endif
end

initial begin
	$readmemb(`SparseCNN_INPUT_PATTERN , sparsecnn_input_pat_mem);
	$readmemb(`SparseCNN_WEIGHT_PATTERN , sparsecnn_weight_pat_mem);
	$readmemb(`SparseCNN_OUTPUT_PATTERN , sparsecnn_output_pat_mem);
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

integer value_golden_idx = 0;
integer value_error_num = 0;
genvar w;
generate
 for(w=0; w<(image_size-kernel_size+1)*(image_size-kernel_size+1);w=w+1) begin
   always @(posedge out_valid) begin
     if(out_valid) begin
      if((data_out[double_word_length*w+:double_word_length]) !== sparsecnn_output_pat_mem[w]) begin
        value_error_num = value_error_num+1; 
        $display("index: %d, out: %b, pat: %b", w, data_out[double_word_length*w+:double_word_length], sparsecnn_output_pat_mem[w]); 
      end
      value_golden_idx = value_golden_idx + 1;
     end
   end 
 end 
endgenerate

// genvar e;
// generate
//  for(e=0; e<16;e=e+1) begin
//    always @(negedge clk) begin
//      if(pe_out_valid & data_out[double_word_length*e+double_word_length-1:double_word_length*e] != 0) begin
//       $display("Clk: %d Input: index: %d, input: %b, col: %d, row: %d", clk_counter ,e, data_out[double_word_length*e+double_word_length-1:double_word_length*e], data_out_cols[word_length*e+word_length-1:word_length*e], data_out_rows[word_length*e+word_length-1:word_length*e]); 
//      end
//    end 
//  end 
// endgenerate

// genvar q;
// generate
//  for(q=0; q<(image_size-kernel_size+1)*(image_size-kernel_size+1);q=q+1) begin
//    always @(negedge clk) begin
//      if(out_valid_wire & data_out_wire[double_word_length*q+double_word_length-1:double_word_length*q] != 0) begin
//       $display("Clk: %d Output: index: %d, out: %b", clk_counter, q, data_out_wire[double_word_length*q+double_word_length-1:double_word_length*q]); 
//      end
//    end 
//  end 
// endgenerate


always @(*) begin
  if (clk_counter < image_size*image_size) sparsecnn_input_feature_value = sparsecnn_input_pat_mem[clk_counter];
  else sparsecnn_input_feature_value = 0;
  if (clk_counter < kernel_size*kernel_size) sparsecnn_input_weight_value = sparsecnn_weight_pat_mem[clk_counter];
  else sparsecnn_input_weight_value = 0;
end

always @(posedge clk or posedge rst) begin
  if(rst) begin
    clk_counter <= 0;
  end
  else begin
    clk_counter <= clk_counter + 1;
  end
end 

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
  $display("  You can try to modify ENDCYCLE in the testbench.\n");
  $display(" =================== TIME OUT ======================\n");
  $finish;
end

endmodule
