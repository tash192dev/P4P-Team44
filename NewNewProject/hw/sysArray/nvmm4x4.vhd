-- nvmm.vhd


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity nvmm is
	generic(
		-- Sys Array size 
		N : integer := 4
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

	type Vec32 is array(0 to N-1) of std_logic_vector(31 downto 0);

	-- Systolic array interface signals
	signal SysIn : std_logic_vector((N*8)-1 downto 0) := (others => '0');
	signal SysOut : std_logic_vector((N*32)-1 downto 0) := (others => '0');
	signal SysBias : std_logic_vector((N*8)-1 downto 0) := (others => '0');
	signal SysKernel : std_logic_vector((N*8)-1 downto 0) := (others => '0');
	signal SysWeightMove : std_logic;
	signal Stride : integer range 0 to 255 := 0;

	-- NIOS V interface signals
	signal Func7 : std_logic_vector(6 downto 0);
	signal Func3 : std_logic_vector(2 downto 0);
	signal Enable : std_logic := '0';
	signal CycleCount : integer range 0 to 255 := 0;

	signal Sys_OV : Vec32;

begin

	-- Didn't forget to include this lol
	SYS : entity work.SysArray
	generic map (
		N => 4
	)
	port map(
		Sys_Clk => NVMM_clk,
		Sys_Wm => SysWeightMove,

		Sys_I => SysIn,
		Sys_B => SysBias,
		Sys_W => SysKernel,
		Sys_O => SysOut
	);


	-- Potentially add 1 cycle of delays
	-- Renaming for readability
	Func7 <= NVMM_ctrl(31 downto 25);
	Func3 <= NVMM_ctrl(14 downto 12); 
	

	IO_MAP: for A in 0 to N-1 generate
		Sys_OV(A) <=  SysOut(((A+1)*32)-1 downto A*32);
  	end generate IO_MAP;



	process(NVMM_clk, NVMM_reset)
	begin
		if rising_edge(NVMM_clk) then
			if Enable = '1' or NVMM_enable = '1' then
				Enable <= '1';
				CycleCount <= CycleCount + 1;

				case(Func7(6 downto 4)) is
					-- CONV IN
					when "000" =>
						SysIn <= NVMM_data0;
						Enable <= '0';
						NVMM_done <= '1';
						CycleCount <= 0;
						NVMM_result <= (others => '0');

					-- CONV OUT
					when "001" =>
						Enable <= '0';
						NVMM_done <= '1';
						CycleCount <= 0;
						NVMM_result <= Sys_OV(to_integer(unsigned(Func3)));


					-- Kernel SET
					when "010" => 
						SysWeightMove <= '1';
						SysKernel <= NVMM_data0;

						Enable <= '0';
						NVMM_done <= '1';
						CycleCount <= 0;
						NVMM_result <= (others => '0');


					-- BIAS SET
					when "011" =>
						SysBias <= NVMM_data0;

						Enable <= '0';
						NVMM_done <= '1';
						CycleCount <= 0;
						NVMM_result <= (others => '0');

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

