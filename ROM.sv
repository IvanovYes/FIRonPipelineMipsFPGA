module ROM(input logic [31:0] address, 
			  output logic [31:0] read_data);

logic [31:0] memory[0:63];

// Постоянная инициализация (эмуляция энергонезависисти памяти)
initial begin
	$readmemh("instruction_test.dat", memory);
end

assign read_data = memory[address[7:2]];
endmodule
