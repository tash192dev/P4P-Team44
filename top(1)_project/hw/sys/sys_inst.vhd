	component sys is
		port (
			reset_reset : in std_logic := 'X'  -- reset
		);
	end component sys;

	u0 : component sys
		port map (
			reset_reset => CONNECTED_TO_reset_reset  -- reset.reset
		);

