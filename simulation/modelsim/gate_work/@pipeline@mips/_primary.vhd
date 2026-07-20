library verilog;
use verilog.vl_types.all;
entity PipelineMips is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        mem_write       : out    vl_logic;
        pc              : out    vl_logic_vector(31 downto 0);
        instruction_ex  : out    vl_logic_vector(31 downto 0);
        alu_result_mem  : out    vl_logic_vector(31 downto 0);
        read_data_mem   : out    vl_logic_vector(31 downto 0);
        write_data_mem  : out    vl_logic_vector(31 downto 0);
        alu_result_ex   : out    vl_logic_vector(31 downto 0)
    );
end PipelineMips;
