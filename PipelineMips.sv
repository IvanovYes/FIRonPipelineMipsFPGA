module PipelineMips (
    input logic clk, reset,
	 output wire mem_write,
    output wire [31:0] pc, instruction_ex, alu_result_mem, read_data_mem, write_data_mem, alu_result_ex);
	 
    // Стадия извлечения инструкции IF
	 logic [31:0] pc_plus_4_if, instruction_if, jump_target;
    logic [31:0] pc_branch_mem;
    logic pc_src_mem;
    logic jump_id;
	 
    ProgrammCounter pc_unit(
        .clk(clk),
        .reset(reset),
        .jump(jump_id),
        .pc_src(pc_src_mem),
        .jump_target(jump_target),
        .pc_branch(pc_branch_mem),
        .pc_current(pc),
        .pc_next(pc_plus_4_if)
    );
    
    ROM instruction_memory(.address(pc), .read_data(instruction_if));
    
	 logic [63:0] if_id_reg; 
	 
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            if_id_reg <= 64'b0;
        end else begin
            if_id_reg[63:32] <= pc_plus_4_if;
            if_id_reg[31:0]  <= instruction_if;
        end
    end
    
    // Стадия декодирования инструкции ID
	 logic [31:0] read_data1_id, read_data2_id;
    logic reg_write_id, mem_to_reg_id, mem_write_id;
    logic alu_src_id, reg_dst_id, branch_id;
    logic [2:0] alu_control_id;
	 
    ControlUnit controller(
        .opcode(if_id_reg[31:26]),  
        .funct(if_id_reg[5:0]),     
        .reg_write(reg_write_id),
        .mem_to_reg(mem_to_reg_id),
        .mem_write(mem_write_id),
        .alu_src(alu_src_id),
        .reg_dst(reg_dst_id),
        .jump(jump_id),
        .branch(branch_id),
        .alu_control(alu_control_id)
    );
    
    RegFile registers_unit(
        .clk(clk),
        .reg_write(mem_wb_reg[25]),  
        .instruction(if_id_reg[31:0]),
        .write_reg(mem_wb_reg[37:33]),  
        .wd3(wb_result),
        .read_data1(read_data1_id),
        .read_data2(read_data2_id)
    );
    
    assign jump_target = {if_id_reg[63:60], if_id_reg[25:0], 2'b00};
	 
    logic [159:0] id_ex_reg;
	 
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            id_ex_reg <= 160'b0;
        end else begin
            // Данные
            id_ex_reg[159:128] <= if_id_reg[63:32];  // pc_plus_4_id
            id_ex_reg[127:96]  <= read_data1_id;     // read_data1_id
            id_ex_reg[95:64]   <= read_data2_id;     // read_data2_id
            id_ex_reg[63:32]   <= if_id_reg[31:0];   // instruction_id
            
            // Сигналы управления
            id_ex_reg[31:29]   <= alu_control_id;    
            id_ex_reg[28]      <= reg_dst_id;        
            id_ex_reg[27]      <= alu_src_id;        
            id_ex_reg[26]      <= mem_write_id;      
            id_ex_reg[25]      <= mem_to_reg_id;     
            id_ex_reg[24]      <= reg_write_id;      
            id_ex_reg[23]      <= branch_id;         
            id_ex_reg[22]      <= jump_id;           
        end
    end
    
    // Стадия выполнения инструкции EX
    logic [31:0] read_data1_ex, read_data2_ex, pc_branch_ex;
    logic [4:0] write_reg_ex;
    logic zero_ex;
    logic [31:0] sign_ext_imm;
    wire [31:0] wb_result;
    wire [31:0] pc_plus_4_ex      = id_ex_reg[159:128];
    assign read_data1_ex     = id_ex_reg[127:96];
    assign read_data2_ex     = id_ex_reg[95:64];
	 assign instruction_ex = id_ex_reg[63:32];
    wire [2:0]  alu_control_ex = id_ex_reg[31:29];
    wire        reg_dst_ex     = id_ex_reg[28];
    wire        alu_src_ex     = id_ex_reg[27];
    wire        mem_write_ex   = id_ex_reg[26];
    wire        mem_to_reg_ex  = id_ex_reg[25];
    wire        reg_write_ex   = id_ex_reg[24];
    wire        branch_ex      = id_ex_reg[23];
    wire        jump_ex        = id_ex_reg[22];
    
    // Мультиплексор для выбора регистра приемника
    assign write_reg_ex = reg_dst_ex ? 
                         instruction_ex[15:11] : // R-type: rd
                         instruction_ex[20:16];  // I-type: rt
    
    assign sign_ext_imm = {{16{instruction_ex[15]}}, instruction_ex[15:0]};
    
    ALU alu_unit(
        .alu_a(read_data1_ex),
        .alu_b(read_data2_ex),
        .alu_control(alu_control_ex),
        .alu_src(alu_src_ex),
        .sign_ext_imm(sign_ext_imm),
        .alu_result(alu_result_ex),
        .zero(zero_ex)
    );
    
    assign pc_branch_ex = pc_plus_4_ex + {sign_ext_imm[29:0], 2'b00};
    
	 logic [168:0] ex_mem_reg;
	 
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            ex_mem_reg <= 169'b0;
        end else begin
            // Данные
            ex_mem_reg[168:137] <= alu_result_ex;    
            ex_mem_reg[136:105] <= read_data2_ex;    
            ex_mem_reg[104:100] <= write_reg_ex;     
            ex_mem_reg[99:68]   <= pc_branch_ex;     
            ex_mem_reg[67:36]   <= read_data1_ex;    
            ex_mem_reg[35]      <= zero_ex;          
            
            // Сигналы управления
            ex_mem_reg[34:32]   <= alu_control_ex; 
            ex_mem_reg[31]      <= reg_dst_ex;     
            ex_mem_reg[30]      <= alu_src_ex;     
            ex_mem_reg[29]      <= mem_write_ex;   
            ex_mem_reg[28]      <= mem_to_reg_ex;  
            ex_mem_reg[27]      <= reg_write_ex;   
            ex_mem_reg[26]      <= branch_ex;      
            ex_mem_reg[25]      <= jump_ex;        
        end
    end
    
    // Стадия чтения/записи в память MEM
	 assign alu_result_mem = ex_mem_reg[168:137];
	 assign write_data_mem = ex_mem_reg[136:105];
    wire [4:0]  write_reg_mem  = ex_mem_reg[104:100];
    wire [31:0] pc_branch_ex_reg  = ex_mem_reg[99:68];
    wire [31:0] read_data1_ex_reg = ex_mem_reg[67:36];
    wire        zero_ex_reg       = ex_mem_reg[35];
    wire        branch_ex_reg     = ex_mem_reg[26];
    
    assign pc_src_mem = branch_ex_reg & ~zero_ex_reg;
    assign pc_branch_mem = pc_branch_ex_reg;
    
    RAM data_mem(
        .clk(clk),
        .reset(reset),
        .mem_write(ex_mem_reg[29]),
        .address(alu_result_mem),
        .write_data(write_data_mem),
        .read_data(read_data_mem)
    );
    
    logic [101:0] mem_wb_reg; // Вектор регистра MEM/WB
	 
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_wb_reg <= 102'b0;
        end else begin
            // Данные
            mem_wb_reg[101:70]  <= alu_result_mem;  
            mem_wb_reg[69:38]   <= read_data_mem;      
            mem_wb_reg[37:33]   <= write_reg_mem;   
            
            // Сигналы управления
            mem_wb_reg[32:30]   <= ex_mem_reg[34:32];  // alu_control_wb
            mem_wb_reg[29]      <= ex_mem_reg[31];     // reg_dst_wb
            mem_wb_reg[28]      <= ex_mem_reg[30];     // alu_src_wb
            mem_wb_reg[27]      <= ex_mem_reg[29];     // mem_write_wb
            mem_wb_reg[26]      <= ex_mem_reg[28];     // mem_to_reg_wb
            mem_wb_reg[25]      <= ex_mem_reg[27];     // reg_write_wb
            mem_wb_reg[24]      <= ex_mem_reg[26];     // branch_wb
            mem_wb_reg[23]      <= ex_mem_reg[25];     // jump_wb
        end
    end
    
    // Стадия обратной записи в регистровый файл WB
	 (* preserve *) reg [31:0] wb_result_comb;
	 always @(*) begin
		 case (mem_wb_reg[26])
			 1'b0: wb_result_comb = mem_wb_reg[101:70];
			 1'b1: wb_result_comb = mem_wb_reg[69:38];
          default: wb_result_comb = 32'b0;
		 endcase
	 end
	 assign wb_result = wb_result_comb;
	 assign mem_write = ex_mem_reg[29];
endmodule
