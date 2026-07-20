module ALU(
	 input logic alu_src,
	 input logic [2:0] alu_control,
    input logic [31:0] alu_a, alu_b, sign_ext_imm,
    output logic [31:0] alu_result,
    output logic zero);
	 
	 logic [31:0] src_b, imm_modified;
    
    // Выбор второго операнда (register или immediate)
    assign src_b = alu_src ? sign_ext_imm : alu_b;
	 
	 // Для ori: нулевое расширение immediate
    assign imm_modified = (alu_control == 3'b101) ? {16'b0, sign_ext_imm[15:0]} : sign_ext_imm;
	
    always_comb begin
        case (alu_control)
				3'b000: alu_result = $signed(alu_b) >>> alu_a[4:0]; // SRA
				3'b001: alu_result = alu_a | imm_modified; //OR
				3'b010: alu_result = alu_a + src_b;      // ADD
            3'b011: alu_result = ~(alu_a | src_b);   // NOR (для bne)
				3'b101: alu_result = {sign_ext_imm[15:0], 16'b0}; // lui
				3'b110: alu_result = alu_a - src_b;      // SUB
				3'b111: begin                				  // SLT
                if ($signed(alu_a) < $signed(src_b))
                    alu_result = 32'b1;
                else
                    alu_result = 32'b0;
            end
            default: alu_result = alu_a + src_b;
        endcase
        
        // Для bne: branch & ~zero
        zero = (alu_result == 32'b0);
    end
	 
endmodule
