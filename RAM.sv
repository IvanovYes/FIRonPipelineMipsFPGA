module RAM(
    input logic clk, reset, mem_write,
    input logic [31:0] address, write_data,
    output logic [31:0] read_data);
	 
    // Память данных: 128 слов по 32 бита
    logic [31:0] memory [0:127];
    
    // Чтение (асинхронное)
    assign read_data = memory[address[8:2]];
    
    // Запись(синхронная)
    always_ff @(posedge clk or posedge reset) 
	 begin
	 if (reset) begin
		  for (int i = 0; i < 128; i = i + 1) begin
				memory[i] = 32'b0;  // Задание нулевых значений памяти при сбросе (эмуляция энергозависимости памяти)
		  end
		  $readmemh("data_test.dat", memory);
	 end
	 else if (mem_write) begin
        memory[address[8:2]] <= write_data;
    end
	 end
	 
endmodule
