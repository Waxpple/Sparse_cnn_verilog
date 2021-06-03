module Line_buffer_2x2#(
    parameter dataColNum = 28,
    parameter wordlength = 16,
    parameter col_length = 5
)(
    input clk,
    input irst_n,
    input in_valid,
    input [wordlength-1:0] data_in,
    output [wordlength-1:0] pixels_0,
    output [wordlength-1:0] pixels_1,
    output wire out_valid
);
reg [(dataColNum*wordlength)-1 :0] line_0,next_line_0,line_1,next_line_1;
//28+1
reg [9:0] counter,next_counter;

assign out_valid = (counter >= (dataColNum*1+1) &&  counter <=dataColNum*dataColNum)?1'd1:1'd0;

assign pixels_0 = line_0[wordlength-1:0];
assign pixels_1 = line_1[wordlength-1:0];

// Line Buffer
always @(*) begin
    next_line_0 = line_0;
    next_line_1 = line_1;
    next_counter = counter + 'd1;
end

always @(posedge clk or negedge irst_n) begin
    if(!irst_n)begin
        line_0 <= 'd0;
        line_1 <= 'd0;
        counter <= 'd0;
    end
    else begin
        if(in_valid)begin
            line_0 <= (line_0 << wordlength) + data_in;
            line_1 <= (line_1 << wordlength) + line_0[(dataColNum*wordlength)-1 -: wordlength];
            counter <= next_counter;
        end
        else begin
            line_0 <= 'd0;
            line_1 <= 'd0;
            counter <= 'd0;
        end
    end
end
endmodule