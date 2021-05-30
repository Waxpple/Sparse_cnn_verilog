`timescale 1ns/1ns
module top();

parameter  col_length= 5;
parameter wordlength = 16;

reg clk;
reg irst_n;
reg signed [wordlength*4-1:0] data_in;
reg signed [wordlength-1:0] weight;
reg in_valid;
//iter
integer i,j,k;

initial begin
    #0      irst_n = 1;
            clk = 1;
    #10     irst_n = 0;
    #10     irst_n = 1;
    #100    in_valid = 1;
            for (i=0;i<32;i=i+1)begin
                weight = i+1;
                data_in[wordlength-1:0] = i+1; // + i+2 <<wordlength + i+3 <<wordlength*2 + i+4 <<wordlength*3);
                data_in[wordlength*2-1:wordlength*1] = i+2;
                data_in[wordlength*3-1:wordlength*2] = i+3;
                data_in[wordlength*4-1:wordlength*3] = i+4;
                
                #10;
            end
    #1000;
    
end




always #5 clk = ~clk;


PE #(
.col_length(col_length),
.wordlength(wordlength)
) u1 (
.clk(clk),
.irst_n(irst_n),
.in_valid(in_valid),
.pixels(16'd15),
.in_channel(),
.weight_cols(),
.weight_rows(),
.weight(weight),
.data_in_cols(),
.data_in_rows(),
.data_in(data_in),
.out_channel(),
.data_out(),
.data_out_cols(),
.data_out_rows(),
.out_valid()
);


endmodule
