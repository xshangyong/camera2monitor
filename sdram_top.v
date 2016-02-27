module sdram_top
(
	clk,
	rst_n,
	sdram_data,
	sdram_addr,
	sdram_clk,
	sdram_ba,
	sdram_ncas,
	sdram_clke,
	sdram_nwe,
	sdram_ncs,
	sdram_dqm,
	sdram_nras,
	wr_sdram_req,
	wr_sdram_ack,
	wr_sdram_add,
	wr_sdram_data,
	rd_sdram_req,
	rd_sdram_ack,
	rd_sdram_add,
	rd_sdram_data,
	work_st,
	cnt_work
);

	input clk;
	input rst_n;
	// sdram port
	inout[15:0] 	sdram_data;
	output[12:0]	sdram_addr;
	output	 		sdram_clk;
	output[1:0]		sdram_ba;
	output	 		sdram_ncas;
	output	 		sdram_clke;
	output	 		sdram_nwe;
	output	 		sdram_ncs;
	output[1:0]		sdram_dqm;
	output			sdram_nras;
	output[4:0]		work_st;
	// enable
	input 			wr_sdram_req;
	output 			wr_sdram_ack;
	input[23:0]		wr_sdram_add;
	input[15:0]		wr_sdram_data;
	input 			rd_sdram_req;
	output 			rd_sdram_ack;
	input[23:0]		rd_sdram_add;
	input[15:0]		rd_sdram_data;
	output[15:0]	cnt_work;
	wire[4:0]		init_st;
	wire			sdram_ini_done;
	wire[2:0]		sys_state;
	assign sdram_clk = ~clk;
	 
	sdram_ctrl inst_sdctrl
	(
		.clk			(clk		),
		.rst_n			(rst_n		),
		.init_st 		(init_st 	),
		.work_st		(work_st	),
		.wr_sdram_req	(wr_sdram_req),
		.wr_sdram_ack	(wr_sdram_ack),
		.rd_sdram_req	(rd_sdram_req),
		.rd_sdram_ack	(rd_sdram_ack),
		.cnt_work		(cnt_work),
		.sys_state		(sys_state)
	);
	
	sdram_cmd inst_sdcmd
	(
		.clk			(clk	),  // use 133MHz clk
		.rst_n			(rst_n		),
		.sdram_addr		(sdram_addr	),
		.sdram_ba		(sdram_ba	),
		.sdram_ncas		(sdram_ncas	),
		.sdram_clke		(sdram_clke	),
		.sdram_nwe		(sdram_nwe	),
		.sdram_ncs		(sdram_ncs	),
		.sdram_dqm		(sdram_dqm	),
		.sdram_nras 	(sdram_nras ),
		.init_st 		(init_st 	),
		.work_st		(work_st),
		.wr_sdram_add	(wr_sdram_add),
		.rd_sdram_add	(rd_sdram_add),
		.cnt_work		(cnt_work),
		.wr_sdram_req	(wr_sdram_req),
		.rd_sdram_req	(rd_sdram_req),
		.sys_state		(sys_state)
	);
	
	sdram_wrdata inst_sddata
	(
		.clk			(clk	),  // use 133MHz clk
		.rst_n			(rst_n	),
		.work_st		(work_st),
		.cnt_work		(cnt_work),
		.wr_sdram_data	(wr_sdram_data),
		.sdram_data		(sdram_data)
	);
endmodule
