	component sys_reset_in is
		port (
			in_reset  : in  std_logic := 'X'; -- reset
			out_reset : out std_logic         -- reset
		);
	end component sys_reset_in;

	u0 : component sys_reset_in
		port map (
			in_reset  => CONNECTED_TO_in_reset,  --  in_reset.reset
			out_reset => CONNECTED_TO_out_reset  -- out_reset.reset
		);

