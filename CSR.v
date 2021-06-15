module CSR
#(
    parameter dataRowNum = 28,
    parameter wordLength = 8, // used for data
    parameter doublewordLength = 16 // used for utils number 
)(
  input         clk,
  input         rst,
  input         in_valid,
  input   [dataRowNum*dataRowNum*wordLength-1:0] data_in,
  
  output  reg      out_valid,
  output reg  [doublewordLength-1:0] valid_num,
  output reg  [dataRowNum*dataRowNum*wordLength-1:0] data_out,
  output reg [dataRowNum*dataRowNum*wordLength-1:0] cols,
  output reg [dataRowNum*dataRowNum*wordLength-1:0] rows
);
 
  reg [1:0]state, next_state;
  reg [wordLength-1:0]row_count, next_row_count, col_count, next_col_count; 
  reg [dataRowNum*dataRowNum*wordLength-1:0] data_in_r, next_data_in_r; 
  reg  [doublewordLength-1:0] valid_num_r, next_valid_num_r;
  reg  [dataRowNum*dataRowNum*wordLength-1:0] data_out_r, next_data_out_r, cols_r, next_cols_r, rows_r, next_rows_r, temp_data, temp_cols, temp_rows;
  reg out_valid_r, next_out_valid_r;

  reg signed [wordLength-1:0] current_data;
  
  parameter IDLE = 2'd0;
  parameter EXEC = 2'd1;
  parameter OUTPUT = 2'd2;

  always@(*)begin
    case (state)
    IDLE:begin
      if(in_valid)next_state = EXEC;	
      else        next_state = state;	   
    end
    EXEC:begin
      if (row_count == (dataRowNum-1) && col_count == (dataRowNum-1)) begin
        next_state = OUTPUT;
      end
      else begin
        next_state = state;	   
      end
    end
    OUTPUT:begin
      next_state = IDLE;	   
    end
    default:begin
      next_state = state;	
    end
	endcase
  end

  always@(*)begin
    out_valid = out_valid_r;
    data_out = data_out_r;
    cols = cols_r;
    rows = rows_r;
    valid_num = valid_num_r;


    next_data_in_r = data_in_r;
    next_valid_num_r = valid_num_r;
    next_data_out_r = data_out_r;
    next_cols_r = cols_r;
    next_rows_r = rows_r;
    current_data = 0;
    temp_data = 0;
    temp_cols = 0;
    temp_rows = 0;
    next_col_count = col_count;
    next_row_count = row_count;
    next_out_valid_r = out_valid_r;

    case(state)
    IDLE: begin
      if(in_valid) begin
        next_data_in_r = data_in;
      end
      else begin
       next_data_in_r = 0;
       next_data_out_r = 0;
       next_cols_r = 0;
       next_rows_r = 0;
       next_out_valid_r = 0;
      end
    end
    EXEC: begin
      current_data = data_in_r >> (row_count*dataRowNum + col_count)*wordLength;
      if (current_data > 0) begin
        next_valid_num_r = valid_num_r + 1;
        temp_data = current_data;
        next_data_out_r = data_out_r + (temp_data << valid_num_r*wordLength);
        temp_cols = col_count;
        next_cols_r = cols_r + (temp_cols << valid_num_r*wordLength);
        temp_rows = row_count;
        next_rows_r = rows_r + (temp_rows << valid_num_r*wordLength);
      end
      else begin
        next_valid_num_r = valid_num_r;
      end

      if (col_count == (dataRowNum-1)) begin
        next_col_count = 0;
        next_row_count = row_count+1;
      end 
      else begin
        next_col_count = col_count+1;
        next_row_count = row_count;
      end
    end
    OUTPUT: begin
      next_out_valid_r = 1;
    end
	  default:begin
       next_data_in_r = data_in_r;
    end
	  endcase
  end
  
  always@(posedge clk or posedge rst)begin
    if(rst)begin
      data_in_r <= 0; 
      state    <= 0;
      row_count <= 0;
      col_count <= 0;

      data_out_r <= 0; 
      cols_r <= 0;
      rows_r <= 0;

      out_valid_r <= 0;
      valid_num_r <= 0;
    end 
    else begin
      data_in_r <= next_data_in_r;
      state    <= next_state;	
      row_count <= next_row_count;
      col_count <= next_col_count;

      data_out_r <= next_data_out_r; 
      cols_r <= next_cols_r;
      rows_r <= next_rows_r;

      out_valid_r <= next_out_valid_r;
      valid_num_r <= next_valid_num_r;
    end    
  end
endmodule
