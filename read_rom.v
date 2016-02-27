module read_rom
(
	clk_100M_i,
	rst_n_i,
	rd_rom_add_i,
	rom_dat_use_o
);

	input 		clk_100M_i;
	input			rst_n_i;
	input[15:0]	rd_rom_add_i;	
	output[2:0]	rom_dat_use_o;

	desk	desk_inst
	(
		.address(rd_rom_add_i),
		.clock	(clk_100M_i),
		.q		(rom_dat_use_o)
	);

endmodule
