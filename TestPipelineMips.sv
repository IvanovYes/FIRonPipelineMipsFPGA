`timescale 1ns/1ps

module TestPipelineMips();
    logic clk, reset, mem_write;
    logic [31:0] pc, instruction, alu_result, alu_result_ex, read_data, write_data, signal_source, signal_out;
	 logic [31:0] buffer_source [63:0];
	 logic [31:0] buffer_out [63:0];
    
    PipelineMips dut (
        .clk(clk),
        .reset(reset),
        .pc(pc),
        .instruction_ex(instruction),
        .alu_result_mem(alu_result),
		  .alu_result_ex(alu_result_ex),
        .read_data_mem(read_data),
        .write_data_mem(write_data),
		  .mem_write(mem_write)
    );
	 
    always begin
        clk = 1'b0; #8;
		  if ((mem_write == 1) && (alu_result >= 32'b000000000000000100000100)) begin
		  $display("SMA_result = %d", $signed(write_data), "	alu_result = %d", alu_result);
		  end
        clk = 1'b1; #8;
    end
	
    logic [31:0] i, j, k, alu_ex;
	 int n;
	 logic [31:0] memory [0:127];
	 logic isAllCounts;
	
	 always @(posedge clk) begin
		  //if (instruction == 32'h21b8001c) begin
		  //alu_ex <= alu_result_ex;
		  //end
		  //if (alu_ex == alu_result) begin
		  //buffer_source[k] <= read_data;
		  //k <= k + 1;
		  //end
        if ((mem_write == 1) && (alu_result >= 32'b000000000000000100000100)) begin
		  buffer_out[i] <= write_data;
		  i <= i + 1;
        end
		  if ((mem_write == 1) && (alu_result >= 504)) begin
		  isAllCounts <= 1;
		  end
    end
	 
	 always @(posedge clk) begin
        if (isAllCounts) begin
		  signal_source <= memory[n];
		  signal_out <= buffer_out[j];
		  j <= j + 1;
		  n <= n + 1;
        end
    end
	 
    initial begin
		  $readmemh("C:/altera/13.1/PipelineMips/data_test.dat", memory);
		  i = 0;
		  j = 0;
		  k = 0;
		  n = 7;
		  alu_ex = 0;
		  isAllCounts = 0;
		  
        reset = 1'b1;
        #1;
        reset = 1'b0;
		
		  #300000;
        $stop;
    end
endmodule
