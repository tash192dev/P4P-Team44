module sys_nvmm_0 #(
		parameter N = 4
	) (
		input  wire [31:0] NVMM_alu_result, // NVMM.alu_result
		input  wire        NVMM_clk,        //     .clk
		input  wire [31:0] NVMM_ctrl,       //     .ctrl
		input  wire [31:0] NVMM_data0,      //     .data0
		input  wire [31:0] NVMM_data1,      //     .data1
		output wire        NVMM_done,       //     .done
		input  wire        NVMM_enable,     //     .enable
		input  wire        NVMM_reset,      //     .reset
		output wire [31:0] NVMM_result      //     .result
	);
endmodule

