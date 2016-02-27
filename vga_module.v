// 	Build repository on github
//	https address : https://github.com/xshangyong/camera2monitor.git
//	ssh address   :	git@github.com:xshangyong/camera2monitor.git
//  top module : vga_module 
//	2016.2.28  XuShangyong

module vga_module
(
	CLK, 
	RSTn,
	VSYNC_Sig, 
	HSYNC_Sig,
	Red_Sig, 
	Green_Sig, 
	Blue_Sig,
	ps2_clk_i,
	ps2_data_i,
	row_o,
	column_o,
	led_o1,
	led_o2,
	led_o3,
	sdram_data,
	sdram_addr,
	sdram_clk,
	sdram_ba,
	sdram_ncas,
	sdram_clke,
	sdram_nwe,
	sdram_ncs,
	sdram_dqm,
	sdram_nras
);

	input 	CLK;
	input 	RSTn;		// low valid
	// ps2 
	input 	ps2_clk_i;
	input 	ps2_data_i;
	// led
	output 	led_o1;
	output 	led_o2;
	output 	led_o3;
	// vga
	output reg 	VSYNC_Sig;
	output reg 	HSYNC_Sig;
	output 		Red_Sig;
	output 		Green_Sig;
	output 		Blue_Sig;
	// digitron
	output[7:0]		row_o;
	output[5:0]		column_o;
	// sdram
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


	/*************************************/
	
	wire 			VSYNC_Sig_d1;
	wire 			HSYNC_Sig_d1;
	wire 			clk_100M;
	wire [10:0]		Column_Addr_Sig;
	wire [10:0]		Row_Addr_Sig;
	wire 			Ready_Sig;
	wire [15:0]		rom_addr;
	wire [2:0]		rom_dat;
	wire  [2:0]     rom_dat_use;
	wire[15:0]		rd_rom_add;
	reg				wr_fifo_en = 0;
	wire [2:0]		fifo_dat;
	wire			ps2_done_r;
	wire[1:0]		ps2_break_r;
	wire[15:0]		ps2_data_r;
	wire			is_pic;
	wire[10:0]		fifo_used;
	wire[10:0]		rd_fifo_used;
	wire[4:0]		work_st;
	reg[19:0] 		dat_2dig;
	reg				led_r1 = 0;
	reg				led_r2 = 0;
	reg				led_r3 = 0;
	reg[7:0]		rom_radd_cnt = 0;
	reg[7:0]		rom_cadd_cnt = 0;
	reg[7:0]		rd_rom_radd = 0;
	reg[7:0]		rd_rom_cadd = 0;
	reg				wr_sdram_req=0;
	wire			wr_sdram_ack;
	reg[23:0]		wr_sdram_add=0;
	wire[15:0]		wr_sdram_data;
	
	wire			rst_100o;
	wire			rst_133o;
	
	wire			rst_100;
	wire			rst_133;
	
	reg				rd_sdram_req=0;
	wire			rd_sdram_ack;
	reg[23:0]		rd_sdram_add=0;
	wire[15:0]		rd_sdram_data;
	reg				wr_sdram_finish;
	reg				wr_sdram_finisha;
	reg				wr_sdram_finishb;

	reg[2:0]		st_wrsdram = 0;
	reg[2:0]		st_rdsdram = 0;
	reg[8:0]		wr_sdram_times = 0;
	wire			fifo_clear;
	wire			vsyn_neg;
	wire[15:0]		data_vga;
	wire[15:0]		cnt_work;
	wire			vga_rdfifo;
	parameter 		Clear 	= 2'b00;
	parameter 		Idle 	= 2'b01;
	parameter 		Wr_fifo 	= 2'b10; 
	parameter 		None2 	= 2'b11;

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

	assign led_o1 = led_r1;
	assign led_o2 = led_r2;
	assign led_o3 = led_r3;

	reg			start_wrfifoA = 0;
	reg[19:0]	test_rdsdram = 0;

	clk_100m inst_100m(
	    .inclk0( CLK ),    // input - from top
		.c0( clk_100M )   // to vga
	);

	pll_133 inst_133m(
	    .inclk0( clk_100M ),    // pll100
		.c0( clk_133M )   	// 	to sdram
	);	 	
	 /**************************************/
	reset_gen inst_rst(
		.clk_100	(clk_100M),
		.clk_133    (clk_133M),
		.rst_n      (RSTn),
		.rst_100    (rst_100),
		.rst_133	(rst_133)
	);

	
	sdram_top inst_sdtop
	(
		.clk			(clk_133M	),  // use 133MHz clk
		.rst_n			(rst_133	),
		.sdram_data		(sdram_data	),
		.sdram_addr		(sdram_addr	),
		.sdram_clk		(sdram_clk	),
		.sdram_ba		(sdram_ba	),
		.sdram_ncas		(sdram_ncas	),
		.sdram_clke		(sdram_clke	),
		.sdram_nwe		(sdram_nwe	),
		.sdram_ncs		(sdram_ncs	),
		.sdram_dqm		(sdram_dqm	),
		.sdram_nras 	(sdram_nras ),
		.wr_sdram_req	(wr_sdram_req),
		.wr_sdram_ack	(wr_sdram_ack),
		.wr_sdram_add	(wr_sdram_add),
		.wr_sdram_data  (wr_sdram_data),
		.rd_sdram_req	(rd_sdram_req),
		.rd_sdram_ack	(rd_sdram_ack),
		.rd_sdram_add	(rd_sdram_add),
		.rd_sdram_data  (rd_sdram_data),
		.work_st		(work_st),
		.cnt_work		(cnt_work)
	);

	// read sdram, rd_sdram_req high means read begins,ack high means read finished 
	// start when wr_sdram_finish == 1 && vsync negadge
	reg		wr_en;
	reg 	rd_en;
	always@(posedge clk_133M or negedge rst_133)begin
		if(!rst_133) begin
			rd_en <= 0;
		end
		else if(work_st == W_RDDAT && rd_sdram_add[21:9]==0)begin
			rd_en <= 1;
		end
		else if(work_st == W_RDDAT && rd_sdram_add[21:9]<=200)begin
			rd_en <= 0;
		end
		else begin
			rd_en <= rd_en;
		end
	end
	
	always@(posedge clk_133M or negedge rst_133)begin
		if(!rst_133) begin
			wr_en <= 0;
		end
		else if(work_st == W_WRITE && wr_sdram_add[21:9]==0)begin
			wr_en <= 1;
		end
		else if(work_st == W_WRITE && wr_sdram_add[21:9]<=200)begin
			wr_en <= 0;
		end
		else begin
			wr_en <= wr_en;
		end
	end
	
	always@(posedge clk_133M or negedge rst_133)begin
		if(!rst_133) begin
			test_rdsdram <= 0;
		end
		else if(work_st == W_RDDAT && rd_en==1)begin
			case(cnt_work)
				0 : test_rdsdram[2:0] <= sdram_data[2:0];
				1 :	test_rdsdram[5:3] <= sdram_data[2:0];
				2 :	test_rdsdram[8:6] <= sdram_data[2:0];	
			endcase
		end
		else if(work_st == W_WRITE && wr_en==1)begin
			case(cnt_work)
				1 : test_rdsdram[11:9] <= sdram_data[2:0];
				2 :	test_rdsdram[14:12] <= sdram_data[2:0];
				3 :	test_rdsdram[17:15] <= sdram_data[2:0];	
			endcase
		end
	end

	always@(posedge clk_133M or negedge rst_133)begin
		if(!rst_133) begin
			rd_sdram_req <= 0;
			rd_sdram_add <= 0;
			st_rdsdram   <= 0;
		end
		else begin
			if(VSYNC_Sig_d1 == 0) begin
				st_rdsdram <= 0;
				rd_sdram_add <= 0;
				rd_sdram_req <= 0;
			end
			else begin
				case(st_rdsdram)
					0 : begin
						if(wr_sdram_finishb == 1 &&
							rd_fifo_used <= 512 &&
							rd_sdram_add[21:9] < 128) begin
							st_rdsdram <= 1;
							rd_sdram_req <= 1;
						end
					end	
					1 : begin
						if(rd_sdram_ack == 1) begin
							rd_sdram_add[21:9] <= rd_sdram_add[21:9] + 1'b1;
							rd_sdram_req <= 0;
							st_rdsdram <= 0;
						end
					end
				endcase
			end
		end
	   end
	
	
	always@(posedge clk_133M or negedge rst_133)begin
		if(!rst_133) begin
			wr_sdram_finishb <= 0;
		end
		else if (wr_sdram_add[21:9] >= 127)begin //(wr_sdram_add[21:9] == 127  && VSYNC_Sig == 0 )begin
			wr_sdram_finishb <= 1;
		end
	end
	
	always@(posedge clk_100M or negedge rst_100)begin
		if(!rst_100) begin
			wr_sdram_finisha <= 0;
			wr_sdram_finish <= 0;
		end
		else begin
			wr_sdram_finisha <= wr_sdram_finishb;
			wr_sdram_finish  <= wr_sdram_finisha;
		end
	end

	// write sdram, wr_sdram_req high means write begins,ack high means write finished 
	// start when fifo_used >= 512
	always@(posedge clk_133M or negedge rst_133)begin
		if(!rst_133) begin
			wr_sdram_req   <= 0;
			wr_sdram_add   <= 0;
			wr_sdram_times <= 0;
			st_wrsdram     <= 0;
		end
		else begin
			case(st_wrsdram)
				0 : begin
					if(wr_sdram_times < 128 &&
						fifo_used >= 512) begin
						st_wrsdram <= 1;
						wr_sdram_req <= 1;
					end
				end	
				1 : begin
					if(wr_sdram_ack == 1) begin
						// row addr:wr_sdram_add[21:9], column addr:wr_sdram_add[8:0]
						wr_sdram_add[21:9] <= wr_sdram_add[21:9] + 1'b1;
						wr_sdram_req <= 0;
						st_wrsdram <= 0;
						wr_sdram_times <= wr_sdram_times + 8'b1;
					end
				end
			endcase
		end
	   end

	read_rom	inst_rdrom
	(
		.clk_100M_i		(clk_100M),
		.rst_n_i		(rst_100),
		.rd_rom_add_i	(rd_rom_add),
		.rom_dat_use_o	(rom_dat_use)	
	);
	
	rom2fifo	inst_rom2fifo
	(
		.clk_100M_i		(clk_100M),
		.clk_133M_i		(clk_133M),
		.rst_100i		(rst_100),
		.rst_133i		(rst_133),
		.rom_dat_i		(rom_dat_use),
		.rdrom_add_o	(rd_rom_add),
		.fifo_used_o	(fifo_used),
		.wr_sdram_data	(wr_sdram_data),
		.work_st		(work_st)
	);

	fifo2vga	inst_fifo2vga
	(
		.clk_133M_i		(clk_133M),
		.clk_100M		(clk_100M),
		.rst_100i		(rst_100),
		.rst_133i		(rst_133),
		.fifo_used_o	(rd_fifo_used),
		.sdram_data		(sdram_data),
		.work_st		(work_st),
		.cnt_work		(cnt_work),
		.fifo_clear		(fifo_clear),
		.data_vga		(data_vga),
		.vga_rdfifo		(vga_rdfifo)
	);
	
	
	
	 digitron inst_digi
	(
		.clk_i(CLK),
		.rst_i(rst_100),
		.num_i(test_rdsdram),
		.row_o(row_o),
		.column_o(column_o)
	);
	

	 
	 ps2 inst_ps2
	(
		.clk_i(CLK),
		.rst_i(rst_100),
		.ps2_clk_i(ps2_clk_i),
		.ps2_data_i(ps2_data_i),
		.ps2_data_o(ps2_data_r),
		.ps2_break_o(ps2_break_r),
		.ps2_done_o(ps2_done_r)
	);
	 
	
	 
	 always@(posedge CLK)begin
		if(ps2_done_r == 1) begin
			 dat_2dig <= ps2_data_r[15:8] * 1000 + ps2_data_r[7:0];
	   end
	 end
	 
	 always@(posedge CLK)begin
		if(ps2_done_r == 1) begin
			if(ps2_break_r == 2'b01) begin
				 led_r1 <= 1;
				 led_r2 <= 0;
				 led_r3 <= 0;
			end
			else if(ps2_break_r == 2'b10) begin
				 led_r1 <= 0;
				 led_r2 <= 1;
				 led_r3 <= 0;
		   end
		end
	 end
	 
	 always@(posedge clk_100M)begin
		  VSYNC_Sig<= VSYNC_Sig_d1;
		  HSYNC_Sig<= HSYNC_Sig_d1;
	 end
assign  fifo_clear  = VSYNC_Sig_d1 & ~VSYNC_Sig;  //negadge
assign  vsyn_neg    = VSYNC_Sig_d1 & ~VSYNC_Sig;  //negadge
assign  vga_rdfifo 	= is_pic & Ready_Sig & wr_sdram_finish;
	 
	 
	 
	reg rst_vgasyn,rst_vgasyn1,rst_vgasyn2;
	
	always @(*) begin
		if(!rst_133) begin
			rst_vgasyn = 0;
		end
		else begin
			if(wr_sdram_add[21:9] >= 127) begin
				rst_vgasyn = 1;
			end
		end
	end

	always @ ( posedge clk_100M) begin
		rst_vgasyn1 <= rst_vgasyn;
		rst_vgasyn2 <= rst_vgasyn1;
	end
	
	sync_module inst_sync
	(
		.CLK( clk_100M ),
		.RSTn( rst_vgasyn2  ), //rst_100
		.VSYNC_Sig( VSYNC_Sig_d1 ),   // output - to top
		.HSYNC_Sig( HSYNC_Sig_d1 ),   // output - to top
		.Column_Addr_Sig( Column_Addr_Sig ), // output - to inst_vga_control
		.Row_Addr_Sig( Row_Addr_Sig ),       // output - to inst_vga_control
		.Ready_Sig( Ready_Sig )              // output - to inst_vga_control
	);
	 
	 /******************************************/
	 
	 vga_control_module inst_vga_control
	 (
	      .CLK( clk_100M ),
		  .RSTn( rst_vgasyn2 ), //rst_100
		  .Ready_Sig( Ready_Sig ),             // input - from inst_sync
		  .Column_Addr_Sig( Column_Addr_Sig ), // input - from inst_sync
		  .Row_Addr_Sig( Row_Addr_Sig ),       // input - from inst_sync
		  .Red_Sig( Red_Sig ),      // output - to top
		  .Green_Sig( Green_Sig ),  // output - to top
		  .Blue_Sig( Blue_Sig ),    // output - to top
		  .ps2_data_i( ps2_data_r[7:0] ),
		  .rom_addr_o(rom_addr),
		  .display_data(data_vga[2:0]),
		  .is_pic(is_pic)
	 );


endmodule
