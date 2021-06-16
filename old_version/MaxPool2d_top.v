`timescale 1ns/1ns
module line_buffer_top();
parameter dataColNum = 28;
parameter col_length= 5;
parameter wordlength = 16;

reg clk;
reg irst_n;
reg signed [wordlength-1:0] data_in;
reg in_valid;

wire out_valid;
wire signed [wordlength-1:0] pixels_0,pixels_1;


//iter
integer i,j,k;

initial begin
    #0      irst_n = 1;
            clk = 1;
    #10     irst_n = 0;
    #10     irst_n = 1;
    #100    in_valid = 1;
            for (i=0;i<1024;i=i+1)begin
                data_in[wordlength-1:0] = $random;
                #10;
            end
    #1000;
    
end




always #5 clk = ~clk;


Line_buffer_2x2 #(
.col_length(col_length),
.wordlength(wordlength),
.dataColNum(dataColNum)
) u1 (
.clk(clk),
.irst_n(irst_n),
.in_valid(in_valid),
.data_in(data_in),
.pixels_0(pixels_0),
.pixels_1(pixels_1),
.out_valid(out_valid)
);


MaxPool2d #(
.col_length(col_length),
.wordlength(wordlength),
.dataColNum(dataColNum)
) u2 (
.clk(clk),
.irst_n(irst_n),
.in_valid(out_valid),
.pixels_0(pixels_0),
.pixels_1(pixels_1),
.data_out(),
.out_valid()
);


endmodule
