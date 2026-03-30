module ProgrammCounter (
    input logic clk, reset, jump, pc_src,
    input logic [31:0] jump_target, pc_branch,
    output logic [31:0] pc_current, pc_next);
    
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            pc_current <= 32'b0;
        else  
            pc_current <= pc_next;
    end
    
    always_comb begin
		if (jump)
			pc_next = jump_target;
		else if (pc_src)
			pc_next = pc_branch;
		else
			pc_next = pc_current + 4;
	 end
	 
endmodule
