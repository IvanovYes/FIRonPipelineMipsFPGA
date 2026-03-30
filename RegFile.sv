module RegFile (
    input logic clk, reg_write,
	 input logic [4:0] write_reg,
    input logic [31:0] instruction, wd3,
    output logic [31:0] read_data1, read_data2);
	 
	 logic [31:0] registers [0:31];
    
    // Инициализация регистра $zero
    initial begin
		registers[0] = 32'b0;
    end
	 
	 // Асинхронное чтение (при этом регистр $zero всегда возвращает 0)
	 assign read_data1 = (instruction[25:21] == 5'b00000) ? 32'b0 : registers[instruction[25:21]];
	 assign read_data2 = (instruction[20:16] == 5'b00000) ? 32'b0 : registers[instruction[20:16]];

	 // Синхронная запись (при этом регистр $zero всегда возвращает 0)
	 always_ff @(posedge clk) begin
		 if (reg_write && (write_reg != 5'b00000)) begin 
			 registers[write_reg] <= wd3;
		 end
	 end
endmodule
