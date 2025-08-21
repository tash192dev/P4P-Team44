-- nvmm.vhd


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity nvmm is
	generic(
		-- N = K^2

		-- Sys Array size 
		N : integer := 25;
		-- Kernel Size

		K : integer := 5
	);
	port (
		NVMM_alu_result : in  std_logic_vector(31 downto 0) := (others => '0'); -- NVMM.alu_result
		NVMM_clk        : in  std_logic                     := '0';             --     .clk
		NVMM_ctrl       : in  std_logic_vector(31 downto 0) := (others => '0'); --     .ctrl
		NVMM_data0      : in  std_logic_vector(31 downto 0) := (others => '0'); --     .data0
		NVMM_data1      : in  std_logic_vector(31 downto 0) := (others => '0'); --     .data1
		NVMM_done       : out std_logic;                                        --     .done
		NVMM_enable     : in  std_logic                     := '0';             --     .enable
		NVMM_reset      : in  std_logic                     := '0';             --     .reset
		NVMM_result     : out std_logic_vector(31 downto 0)                     --     .result
	);
end entity nvmm;




architecture rtl of nvmm is

	-- Systolic array interface signals
	signal SysIn : std_logic_vector((N*8)-1 downto 0) := (others => '0');
	signal SysOut : std_logic_vector((N*8)-1 downto 0) := (others => '0');
	signal SysBias : std_logic_vector((N*8)-1 downto 0) := (others => '0');
	signal SysKernel : std_logic_vector((N*8)-1 downto 0) := (others => '0');
	signal SysWeightMove : std_logic;
	signal Stride : integer range 0 to 255 := 0;

	-- NIOS V interface signals
	signal Func7 : std_logic_vector(6 downto 0);
	signal Func3 : std_logic_vector(2 downto 0);
	signal Enable : std_logic := '0';
	signal CycleCount : integer range 0 to 255 := 0;

begin

	-- Potentially add 1 cycle of delays
	-- Renaming for readability
	Func7 <= NVMM_ctrl(31 downto 25);
	Func3 <= NVMM_ctrl(14 downto 12); 


	process(NVMM_clk, NVMM_reset)
		variable F3IDX : integer range 255 to 0; 
	begin
		if rising_edge(NVMM_clk) then
			if Enable or NVMM_enable then
				Enable <= '1';
				CycleCount <= CycleCount + 1;

				case(Func7(6 downto 4)) is
					-- CONV IN
					when "000" =>
						Case(Func3) is
							-- LSB
							when "000" => 	
								SysIn(31 downto 0) <= NVMM_data0;
								SysIn(63 downto 32) <= NVMM_data1;
							when "001" =>
								SysIn(95 downto 64) <= NVMM_data0;
								SysIn(127 downto 96) <= NVMM_data1;
							when "010" =>
								SysIn(159 downto 128) <= NVMM_data0;
								SysIn(191 downto 160) <= NVMM_data1;
							-- MSB
							when "011" =>
								SysIn(199 downto 192) <= NVMM_data0(7 downto 0);
							-- Not used for our test sizing will be added later
							when others =>
								NULL;
						end case;

						Enable <= '0';
						NVMM_done <= '1';
						CycleCount <= 0;
						NVMM_result <= (others => '0');


					-- CONV OUT
					when "001" =>
						-- Hardcoded for K = 5 N = 25
						F3IDX := to_integer(Unsigned(Func3)) * 32;
						
						if F3IDX >= 192 then
							NVMM_Result <= X"000000" & SysOut(199 downto 192); 
						else
							NVMM_Result <= SysOut(F3IDX + 31 downto F3IDX);
						end if;
						Enable <= '0';
						NVMM_done <= '1';
						CycleCount <= 0;


					-- Kernel SET
					when "010" => 
						-- Hardcoded for K = 5 N = 25
						Case(Func3) is
							-- LSB
							when "000" => 	
								SysKernel(31 downto 0) <= NVMM_data0;
								SysKernel(63 downto 32) <= NVMM_data1;
							when "001" =>
								SysKernel(95 downto 64) <= NVMM_data0;
								SysKernel(127 downto 96) <= NVMM_data1;
							when "010" =>
								SysKernel(159 downto 128) <= NVMM_data0;
								SysKernel(191 downto 160) <= NVMM_data1;
							-- MSB
							when "011" =>
								SysKernel(199 downto 192) <= NVMM_data0(7 downto 0);
								SysWeightMove <= '1';
							-- Not used for our test sizing will be added later
							when others =>
								NULL;
						end case;
						Enable <= '0';
						NVMM_done <= '1';
						CycleCount <= 0;
						NVMM_result <= (others => '0');



					-- BIAS SET
					when "011" => 
						-- Hardcoded for K = 5 N = 25
						Case(Func3) is
							-- LSB
							when "000" => 	
								SysBias(31 downto 0) <= NVMM_data0;
								SysBias(63 downto 32) <= NVMM_data1;
							when "001" =>
								SysBias(95 downto 64) <= NVMM_data0;
								SysBias(127 downto 96) <= NVMM_data1;
							when "010" =>
								SysBias(159 downto 128) <= NVMM_data0;
								SysBias(191 downto 160) <= NVMM_data1;
							when "011" =>
								SysBias(199 downto 192) <= NVMM_data0(7 downto 0);
							-- Not used for our test sizing will be added later
							when others =>
								NULL;
						end case;
						Enable <= '0';
						NVMM_done <= '1';
						CycleCount <= 0;
						NVMM_result <= (others => '0');

					-- SYS DELAY
					when "100" =>
						if CycleCount >= 25 then
							Enable <= '0';
							NVMM_done <= '1';
							CycleCount <= 0;
							NVMM_result <= X"00000019";
						end if;

					-- Others
					when others =>
							Enable <= '0';
							NVMM_done <= '1';
							CycleCount <= 0;
							NVMM_result <= (others => '0');

				end case;

			else
				CycleCount <= 0;
				SysWeightMove <= '0';
				
				NVMM_done <= '0';
			end if;
		end if;
	end process;
end architecture rtl; -- of nvmm
