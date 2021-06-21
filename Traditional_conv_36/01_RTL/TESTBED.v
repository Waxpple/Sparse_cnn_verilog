`timescale 1ns/10ps

`define CYCLE 10
`define ENDCYCLE  100000

`define conv_INPUT_PATTERN     "E:/VLSI/Sparse_cnn_verilog/Matlab_gen/3636_3232/feature_value_sparsity_100.dat"
`define conv_WEIGHT_PATTERN     "E:/VLSI/Sparse_cnn_verilog/Matlab_gen/3636_3232/kernel_value_sparsity_100.dat"
`define conv_OUTPUT_PATTERN     "E:/VLSI/Sparse_cnn_verilog/Matlab_gen/3636_3232/out_value_sparsity_100.dat"
// `define conv_INPUT_PATTERN     "../../Matlab_gen/feature_value_sparsity_100.dat"
// `define conv_WEIGHT_PATTERN     "../../Matlab_gen/kernel_value_sparsity_100.dat"
// `define conv_OUTPUT_PATTERN     "../../Matlab_gen/out_value_sparsity_100.dat"

`define WORD_LENGTH 8
`define COL_LENGTH 8
`define IMAGE_SIZE 36
`define KERNEL_SIZE 5

// color definition
`define YEL "%c[0;33m",27
`define BLK "%c[0;m",27

module TESTBED();

// TODO: module, reg, wire, clock, rst initialization...
reg clk = 0;
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
parameter bias = 16'b0000000000001110;

reg [word_length-1:0] conv_input_pat_mem [0:image_size*image_size-1];
reg [word_length-1:0] conv_weight_pat_mem [0:kernel_size*kernel_size-1];
reg [double_word_length-1:0] conv_output_pat_mem [0:output_size*output_size-1];
reg [output_size*output_size*double_word_length-1:0] out_feature, next_out_feature;
reg [16:0] clk_counter, next_clk_counter;

reg [word_length-1:0] conv_input_feature_value;
wire [kernel_size*kernel_size*word_length-1:0] conv_input_weight_value;
wire signed [double_word_length*output_size*output_size -1:0]data_out;
wire out_valid;

genvar i;
// Bind 2d input_weight_value to 1d array
generate
  for (i=0; i<kernel_size*kernel_size; i=i+1) begin
    assign conv_input_weight_value[word_length*i+word_length-1:word_length*i] = conv_weight_pat_mem[i];
  end 
endgenerate

conv #(
    .col_length(col_length), 
    .word_length(word_length), 
    .double_word_length(double_word_length), 
    .kernel_size(kernel_size), 
    .image_size(image_size)
) conv_CORE (
    .clk(clk),
    .rst(rst),
    .in_valid(in_valid),
    .weight_value(conv_input_weight_value),
    .data_in(conv_input_feature_value),
    .data_out(data_out),
    .out_valid(out_valid)
);


always #(`CYCLE/2) clk = ~clk;

initial begin
	`ifdef RTL
		$fsdbDumpfile("conv_RTL.fsdb");
		$fsdbDumpvars(0, TESTBED);
	`elsif GATE
		$sdf_annotate("../02_SYN/Netlist/conv_syn.sdf",conv_CORE);

		`ifdef VCD
			$dumpfile("conv_GATE.vcd");
			$dumpvars();
		`elsif FSDB
			$fsdbDumpfile("conv_GATE.fsdb");
			$fsdbDumpvars(0, conv_CORE);
		`endif
	`endif
end

initial begin
	$readmemb(`conv_INPUT_PATTERN , conv_input_pat_mem);
	$readmemb(`conv_WEIGHT_PATTERN , conv_weight_pat_mem);
	$readmemb(`conv_OUTPUT_PATTERN , conv_output_pat_mem);
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
      if((data_out[double_word_length*w+:double_word_length]) !== conv_output_pat_mem[w]) begin
        value_error_num = value_error_num+1; 
        $display("index: %d, out: %b, pat: %b", w, data_out[double_word_length*w+:double_word_length], conv_output_pat_mem[w]); 
      end
      value_golden_idx = value_golden_idx + 1;
     end
   end 
 end 
endgenerate


always @(*) begin
  if (clk_counter < image_size*image_size) conv_input_feature_value = conv_input_pat_mem[clk_counter];
  else conv_input_feature_value = 0;
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
  if(value_golden_idx === (image_size-kernel_size+1)*(image_size-kernel_size+1) ) begin
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
