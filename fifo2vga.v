module fifo2vga
(
	clk_133M_i	,
	clk_100M	,
	rst_100i	,
	rst_133i ,
	fifo_used_o	,
	sdram_data,
	work_st,
	cnt_work,
	fifo_clear,
	data_vga,
	vga_rdfifo
);

	input 			clk_133M_i;
	input			clk_100M;
	input			rst_100i;
	input			rst_133i;
	input[4:0]		work_st;
	input 			fifo_clear;
	input 			vga_rdfifo;
	input[15:0]		cnt_work;
	inout[15:0] 	sdram_data;
	output[10:0]	fifo_used_o;
	output[15:0]	data_vga;
	parameter	W_IDLE		= 4'd0;		//idle
	parameter	W_ACTIVE	= 4'd1;		//row active 
	parameter	W_TRCD		= 4'd2;		//row active wait time  min=20ns
	parameter	W_REF		= 4'd3;		//auto refresh
	parameter	W_RC		= 4'd4;		//auto refresh wait time min=63ns
	parameter	W_READ		= 4'd5;		//read cmd
	parameter	W_RDDAT		= 4'd6;		//read data
	parameter	W_CL		= 4'd7;		//cas latency
	parameter	W_WRITE		= 4'd8;		//auto write
	parameter	W_PRECH		= 4'd9;		//precharge
	parameter	W_TRP		= 4'd10;	//precharge wait time  min=20ns
	parameter	W_BSTOP		= 4'd11;	//precharge wait time  min=20ns
	parameter	W_CHGACT	= 4'd12;	//precharge before act
	parameter	W_TRPACT	= 4'd13;	//precharge before act
	wire	wr_fifo;
	wire[10:0]	fifo_used;
	assign fifo_used_o = fifo_used;
	assign wr_fifo = (work_st == W_RDDAT) ? 1 : 0;
	assign data_vga[15:3] = 0;
	
	
	
/* 	always @(posedge clk_133M_i or negedge nrst_i) begin
		if(!nrst_i) begin
			wr_fifo <= 0;
		end
		else begin
			wr_fifo <= (work_st == W_RDDAT) ? 1 : 0;
		end
	end */
	
	desk_fifo inst_dfifo2
	(	         
		.aclr	(fifo_clear),
		.data	(sdram_data[2:0]),
		.rdclk	(clk_100M),
		.rdreq	(vga_rdfifo),
		.wrclk	(clk_133M_i),
		.wrreq	(wr_fifo),
		.q		(data_vga[2:0]),
		.rdempty(),
		.rdusedw(),
		.wrfull	(),
		.wrusedw(fifo_used)
	);
	



endmodule
