library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity NVMM_TB is
    port(
        result : out std_logic_vector(31 downto 0);
        done : out std_logic
    );
end entity NVMM_TB;

architecture rtl of NVMM_TB is 
    signal Tclk : std_logic;
    signal Tdata : std_logic_vector(31 downto 0) := (others => '0');
    signal Tctrl : std_logic_vector(31 downto 0) := (others => '0');
    signal Tenable : std_logic;
begin

    NVMM : entity work.nvmm
	generic map (
		N => 4
	)
	port map(
        NVMM_alu_result => X"00000000",
		NVMM_clk        => Tclk,
		NVMM_ctrl       => Tctrl,
		NVMM_data0      => Tdata,
		NVMM_data1      => X"00000000",
		NVMM_done       => done,
		NVMM_enable     => Tenable,
		NVMM_reset      => '0',
		NVMM_result     => result
	);

    TB_INST : process
    begin
        wait for 11 ns;
        -- Initalisations
        Tdata <= X"00000000";
        Tctrl <= X"00000000";
        Tenable <= '0';
        wait for 180 ns;

        -- Bias Input
        Tenable <= '1';
        Tctrl <= X"60000000";
        Tdata <= X"00000000";
        wait for 20 ns;
        Tenable <= '0';
        wait for 180 ns;
        


        -- Kernal Input 1
        Tenable <= '1';
        Tctrl <= X"40000000";
        Tdata <= X"FF01FF01";
        wait for 20 ns;
        Tenable <= '0';
        wait for 180 ns;

        -- Kernal Input 2
        Tenable <= '1';
        Tctrl <= X"40000000";
        Tdata <= X"01FFFF01";
        wait for 20 ns;
        Tenable <= '0';
        wait for 180 ns;

        -- Kernal Input 3
        Tenable <= '1';
        Tctrl <= X"40000000";
        Tdata <= X"FF0101FF";
        wait for 20 ns;
        Tenable <= '0';
        wait for 180 ns;
        
        -- Kernal Input 4
        Tenable <= '1';
        Tctrl <= X"40000000";
        Tdata <= X"01FF01FF";
        wait for 20 ns;
        Tenable <= '0';
        wait for 180 ns;



        -- Data Input Test 1
        Tenable <= '1';
        Tctrl <= X"00000000";
        Tdata <= X"01000008";
        wait for 20 ns;
        Tenable <= '0';
        wait for 180 ns;


        -- Data Input Test 2
        Tenable <= '1';
        Tctrl <= X"00000000";
        Tdata <= X"0008FF0A";
        wait for 20 ns;
        Tenable <= '0';
        wait for 180 ns;


        -- Data Input Test 3
        Tenable <= '1';
        Tctrl <= X"00000000";
        Tdata <= X"FF0A0100";
        wait for 20 ns;
        Tenable <= '0';
        wait for 180 ns;

        -- Data Input Test 4
        Tenable <= '1';
        Tctrl <= X"00000000";
        Tdata <= X"00000809";
        wait for 20 ns;
        Tenable <= '0';
        wait for 180 ns;

        -- Data Input Test 5
        Tenable <= '1';
        Tctrl <= X"00000000";
        Tdata <= X"08090A09";
        wait for 20 ns;
        Tenable <= '0';
        wait for 180 ns;

        -- Data Input Test 6
        Tenable <= '1';
        Tctrl <= X"00000000";
        Tdata <= X"0A0900FF";
        wait for 20 ns;
        Tenable <= '0';
        wait for 180 ns;

        -- Data Input Test 7
        Tenable <= '1';
        Tctrl <= X"00000000";
        Tdata <= X"00FF0901";
        wait for 20 ns;
        Tenable <= '0';
        wait for 180 ns;

        -- Data Input Test 8
        Tenable <= '1';
        Tctrl <= X"00000000";
        Tdata <= X"09010900";
        wait for 20 ns;
        Tenable <= '0';
        wait for 180 ns;

        -- Data Input Test 9
        Tenable <= '1';
        Tctrl <= X"00000000";
        Tdata <= X"0900FF00";
        wait for 20 ns;
        Tenable <= '0';
        wait for 180 ns;

    end process TB_INST;


    TB_CLK : process
    begin
        Tclk <= '0';
        wait for 10 ns;
        Tclk <= '1';
        wait for 10 ns;
    end process TB_CLK;
end architecture;