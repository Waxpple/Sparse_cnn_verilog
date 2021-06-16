`timescale 1ns/10ps

`define CYCLE 10
`define ENDCYCLE  40000

`define IMAGE_PATTERN     "E:/VLSI/Final/SparseCNN/GoldenPattern/CSR/csr_input_image_pattern28x28.dat"
`define CSR_OUTPUT_VALUE_PATTERN     "E:/VLSI/Final/SparseCNN/GoldenPattern/CSR/csr_output_value_image_pattern28x28.dat"
`define CSR_OUTPUT_COLS_PATTERN     "E:/VLSI/Final/SparseCNN/GoldenPattern/CSR/csr_output_cols_image_pattern28x28.dat"
`define CSR_OUTPUT_ROWS_PATTERN     "E:/VLSI/Final/SparseCNN/GoldenPattern/CSR/csr_output_rows_image_pattern28x28.dat"
`define WORD_LENGTH 8
`define IMAGE_SIZE 28
`define NUM_PATTERN 5
`define NUM_OUT     208
`define COL_LENGTH 8
`define KERNEL_SIZE 5
// color definition
`define YEL "%c[0;33m",27
`define BLK "%c[0;m",27

module CSR_TB_PAT();

// TODO: module, reg, wire, clock, rst initialization...
reg clk = 0;
reg rst;
reg in_valid;
reg [7:0] in_num;
wire busy;
wire out_valid;
wire [7:0] out_num;
wire [1:0] color;
wire [6:0] seg1;
wire [6:0] seg0;

parameter word_length = `WORD_LENGTH;
parameter double_word_length = 2*`WORD_LENGTH;
parameter image_size = `IMAGE_SIZE;
parameter col_length = `COL_LENGTH;
parameter kernel_size = `KERNEL_SIZE;
integer err_cnt;
integer k;
integer p;

wire  [double_word_length-1:0] valid_num;
reg [word_length-1:0] image_pat_mem [0:image_size*image_size-1];
reg [word_length-1:0] csr_output_value_pat_mem [0:image_size*image_size-1];
reg [word_length-1:0] csr_output_cols_pat_mem [0:image_size*image_size-1];
reg [word_length-1:0] csr_output_rows_pat_mem [0:image_size*image_size-1];

reg [word_length-1:0] data_in;

wire [image_size*image_size*word_length-1:0] out_feature;
wire [image_size*image_size*word_length-1:0] out_feature_cols;
wire [image_size*image_size*word_length-1:0] out_feature_rows;




CSR#
(
    .col_length(col_length), 
    .word_length(word_length), 
    .double_word_length(double_word_length), 
    .kernel_size(kernel_size), 
    .image_size(image_size)
)u1
(
    .clk(clk), 
    .rst(rst), 
    .in_valid(in_valid),
    .data_in(data_in),
    .data_out(out_feature),
    .data_out_cols(out_feature_cols),
    .data_out_rows(out_feature_rows),
    .out_valid(out_valid)
);

always #(`CYCLE/2) clk = ~clk;

initial begin
   `ifdef SDFSYN
     $sdf_annotate("CSR_syn.sdf", DUT);
   `endif
   `ifdef SDFAPR
     $sdf_annotate("CSR_APR.sdf", DUT);
   `endif	 	 
   `ifdef FSDB
     $fsdbDumpfile("CSR.fsdb");
	 $fsdbDumpvars();
   `endif
  //  `ifdef VCD
     $dumpfile("CSR.vcd");
	 $dumpvars();
  //  `endif
end

initial begin
	$readmemb(`IMAGE_PATTERN, image_pat_mem);
	$readmemb(`CSR_OUTPUT_VALUE_PATTERN, csr_output_value_pat_mem);
	$readmemh(`CSR_OUTPUT_COLS_PATTERN, csr_output_cols_pat_mem);
	$readmemh(`CSR_OUTPUT_ROWS_PATTERN, csr_output_rows_pat_mem);
end
integer i;
//rst initialization
initial begin
   rst = 0;
   #(`CYCLE/2*3);
   rst = 1;
   #(`CYCLE/2);
   rst = 0;
   in_valid = 1;
   for (i=0;i<(image_size*image_size);i=i+1)begin
        data_in[word_length-1:0] = image_pat_mem[i];
        //data_in[word_length-1:0] = i+1;
        #10;
    end
end

integer value_error_num = 0;
integer value_golden_idx = 0;
genvar j;
generate
 for(j=0; j<image_size*image_size;j=j+1) begin
   always @(negedge clk) begin
     if(out_valid) begin
       if(out_feature[word_length*j+word_length-1:word_length*j] !== csr_output_value_pat_mem[j]) begin
         value_error_num = value_error_num+1; 
       end
       value_golden_idx = value_golden_idx+1; 
     end
   end 
 end 
endgenerate

integer cols_error_num = 0;
integer cols_golden_idx = 0;
generate
 for(j=0; j<image_size*image_size;j=j+1) begin
   always @(negedge clk) begin
     if(out_valid) begin
       if(out_feature_cols[word_length*j+word_length-1:word_length*j] !== csr_output_cols_pat_mem[j]) begin
         cols_error_num = cols_error_num+1;
       end
       cols_golden_idx = cols_golden_idx+1; 
     end
   end 
 end 
endgenerate

integer rows_error_num = 0;
integer rows_golden_idx = 0;
generate
 for(j=0; j<image_size*image_size;j=j+1) begin
   always @(negedge clk) begin
     if(out_valid) begin
       if(out_feature_rows[word_length*j+word_length-1:word_length*j] !== csr_output_rows_pat_mem[j]) begin
         rows_error_num = rows_error_num+1; 
       end
       rows_golden_idx = rows_golden_idx+1; 
     end
   end 
 end 
endgenerate

always @(*) begin
  if(value_golden_idx === image_size*image_size  &  cols_golden_idx === image_size*image_size & rows_golden_idx == image_size*image_size) begin
    $display("Value error number: %d\n", value_error_num); 
    $display("Cols error number: %d\n", cols_error_num); 
    $display("Rows error number: %d\n", rows_error_num); 
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
