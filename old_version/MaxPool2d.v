module MaxPool2d#(
    parameter dataColNum = 28,
    parameter wordlength = 16,
    parameter col_length = 5
)(
    input clk,
    input irst_n,
    input in_valid,
    input signed [wordlength-1:0] pixels_0,
    input signed [wordlength-1:0] pixels_1,
    output signed  [wordlength-1:0] data_out,
    output reg out_valid
);
reg signed [wordlength-1:0] max,next_max;
reg counter,next_counter;
assign data_out = max;


always @(*) begin
    next_max = max;
    next_counter = counter;
end

always @(posedge clk or negedge irst_n) begin
    if(!irst_n)begin
        max <= {1'b1,{(wordlength-1){1'b0}}};
        counter <= 'd0;
        out_valid <= 'd0;
    end
    else begin
        if (in_valid)begin
            if (counter ==0)begin
                if (pixels_0 > pixels_1) max <= pixels_0;
                else max <= pixels_1;
                out_valid <= 'd0;
            end
            else begin
                if (max <pixels_0) max <= pixels_0;
                else if (max < pixels_1) max <= pixels_1;
                else max <= next_max;
                out_valid <= 'd1;
            end
            counter <= next_counter + 1'b1;    
        end
    end
    
end
endmodule