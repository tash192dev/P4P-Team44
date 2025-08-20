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
					when "000" =>
						if CycleCount >= 4 then
							Enable <= '0';
							NVMM_done <= '1';
							CycleCount <= 0;
							NVMM_result <= X"000000FF";
						end if;

					when others =>
							Enable <= '0';
							NVMM_done <= '1';
							CycleCount <= 0;
							NVMM_result <= (others => '0');

				end case;

			else
				CycleCount <= 0;

				
				NVMM_done <= '0';
			end if;
		end if;
	end process;
end architecture rtl; -- of nvmm

