	component sys_nvmm_0 is
		generic (
			N : integer := 4
		);
		port (
			NVMM_alu_result : in  std_logic_vector(31 downto 0) := (others => 'X'); -- alu_result
			NVMM_clk        : in  std_logic                     := 'X';             -- clk
			NVMM_ctrl       : in  std_logic_vector(31 downto 0) := (others => 'X'); -- ctrl
			NVMM_data0      : in  std_logic_vector(31 downto 0) := (others => 'X'); -- data0
			NVMM_data1      : in  std_logic_vector(31 downto 0) := (others => 'X'); -- data1
			NVMM_done       : out std_logic;                                        -- done
			NVMM_enable     : in  std_logic                     := 'X';             -- enable
			NVMM_reset      : in  std_logic                     := 'X';             -- reset
			NVMM_result     : out std_logic_vector(31 downto 0)                     -- result
		);
	end component sys_nvmm_0;

	u0 : component sys_nvmm_0
		generic map (
			N => INTEGER_VALUE_FOR_N
		)
		port map (
			NVMM_alu_result => CONNECTED_TO_NVMM_alu_result, -- NVMM.alu_result
			NVMM_clk        => CONNECTED_TO_NVMM_clk,        --     .clk
			NVMM_ctrl       => CONNECTED_TO_NVMM_ctrl,       --     .ctrl
			NVMM_data0      => CONNECTED_TO_NVMM_data0,      --     .data0
			NVMM_data1      => CONNECTED_TO_NVMM_data1,      --     .data1
			NVMM_done       => CONNECTED_TO_NVMM_done,       --     .done
			NVMM_enable     => CONNECTED_TO_NVMM_enable,     --     .enable
			NVMM_reset      => CONNECTED_TO_NVMM_reset,      --     .reset
			NVMM_result     => CONNECTED_TO_NVMM_result      --     .result
		);

