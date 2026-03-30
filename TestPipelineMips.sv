`timescale 1ns/1ps

module TestPipelineMips();
    logic clk, reset;
    logic [31:0] pc, instruction, alu_result, read_data, write_data;
    
    PipelineMips dut (
        .clk(clk),
        .reset(reset),
        .pc(pc),
        .instruction_ex(instruction),
        .alu_result_mem(alu_result),
        .read_data_mem(read_data),
        .write_data_mem(write_data)
    );
    
    always begin
        clk = 1'b0; #8;
        clk = 1'b1; #8;
    end
    
    initial begin
        reset = 1'b1;
        #1;
        reset = 1'b0;
		  
		  #100000;
        $stop;
    end
endmodule
