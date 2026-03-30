module ControlUnit (
    input logic [5:0] opcode, funct,
    output logic reg_write, mem_to_reg, mem_write, alu_src, reg_dst, jump, branch,
    output logic [2:0] alu_control);

    logic [1:0] alu_op;
	 
	 always_comb begin
		  reg_dst   = 1'b0;
        alu_src   = 1'b0;
        mem_to_reg = 1'b0;
        reg_write = 1'b0;
        mem_write = 1'b0;
        branch    = 1'b0;
        alu_op    = 2'b00; // R-type
        jump      = 1'b0;
        case (opcode)
            6'b000000: begin // R-type (add, slt)
                reg_dst   = 1'b1;
                alu_src   = 1'b0;
                reg_write = 1'b1;
                alu_op    = 2'b10; // R-type
            end
            6'b100011: begin // lw
                alu_src   = 1'b1;
                mem_to_reg = 1'b1;
                reg_write = 1'b1;
                alu_op    = 2'b00; // add
            end
            6'b101011: begin // sw
                alu_src   = 1'b1;
                mem_write = 1'b1;
                alu_op    = 2'b00; // add
            end
            6'b001000: begin // addi
                alu_src   = 1'b1;
                reg_write = 1'b1;
                alu_op    = 2'b00; // add
            end
            6'b000101: begin // bne
                branch    = 1'b1;
                alu_op    = 2'b01; // sub
            end
            6'b000010: begin // j
                jump      = 1'b1;
            end
				6'b001111: begin // lui
					 reg_dst = 1'b0;
                alu_src   = 1'b1;
                mem_to_reg = 1'b0;
                reg_write = 1'b1;
                alu_op    = 2'b11;
				end
			   6'b001101: begin // ori
					 reg_dst = 1'b0;
                alu_src   = 1'b1;
                mem_to_reg = 1'b0;
                reg_write = 1'b1;
                alu_op    = 2'b11;
				end
        endcase
    end
	 
	always_comb begin
        case (alu_op)
            2'b00: alu_control = 3'b010; // ADD для lw/sw/addi
            2'b01: alu_control = 3'b110; // SUB для bne
            2'b10: begin                 // R-type: add, slt
                case (funct)
                    6'b100000: alu_control = 3'b010; // add
                    6'b101010: alu_control = 3'b111; // slt
						  default:   alu_control = 3'b000;
                endcase
				end
				2'b11: begin                 
                case (opcode)
                    6'b001111: alu_control = 3'b101; // lui
                    6'b001101: alu_control = 3'b001; // ori
						  default:   alu_control = 3'b000;
                endcase
            end
            default: alu_control = 3'b000;
        endcase
    end
	 
endmodule
