	sys_nvmm_0 #(
		.N (INTEGER_VALUE_FOR_N)
	) u0 (
		.NVMM_alu_result (_connected_to_NVMM_alu_result_), //   input,  width = 32, NVMM.alu_result
		.NVMM_clk        (_connected_to_NVMM_clk_),        //   input,   width = 1,     .clk
		.NVMM_ctrl       (_connected_to_NVMM_ctrl_),       //   input,  width = 32,     .ctrl
		.NVMM_data0      (_connected_to_NVMM_data0_),      //   input,  width = 32,     .data0
		.NVMM_data1      (_connected_to_NVMM_data1_),      //   input,  width = 32,     .data1
		.NVMM_done       (_connected_to_NVMM_done_),       //  output,   width = 1,     .done
		.NVMM_enable     (_connected_to_NVMM_enable_),     //   input,   width = 1,     .enable
		.NVMM_reset      (_connected_to_NVMM_reset_),      //   input,   width = 1,     .reset
		.NVMM_result     (_connected_to_NVMM_result_)      //  output,  width = 32,     .result
	);

