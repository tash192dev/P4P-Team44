	component sys is
		port (
			clock_in_in_clk_clk : in std_logic := 'X'; -- clk
			reset_reset         : in std_logic := 'X'  -- reset
		);
	end component sys;

	u0 : component sys
		port map (
			clock_in_in_clk_clk => CONNECTED_TO_clock_in_in_clk_clk, -- clock_in_in_clk.clk
			reset_reset         => CONNECTED_TO_reset_reset          --           reset.reset
		);

