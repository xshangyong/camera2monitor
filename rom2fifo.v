module rom2fifo
(
	clk_100M_i,
	clk_133M_i,
	rst_100i,
	rst_133i,
	rom_dat_i,
	rdrom_add_o,
	fifo_used_o,
	wr_sdram_data,
	work_st
);
	// 100MHz for write fifo
	// 133MHz for read  fifo 
	input 			clk_100M_i;
	input 			clk_133M_i;
	input			rst_100i;
	input			rst_133i;
	input[2:0]		rom_dat_i;
	input[4:0]		work_st;
	output[15:0]	rdrom_add_o;
	output[10:0]	fifo_used_o;
	output[15:0]	wr_sdram_data;
	wire[10:0]		fifo_used;
	wire				clear_fifo;
	reg				wr_fifo_en = 0;
	reg[7:0]		rom_radd_cnt = 0;
	reg[7:0]		rom_cadd_cnt = 0;
	reg[15:0]		rd_rom_add = 0;
	reg[3:0]		wr_fifo_st = 0;
	reg				wr_fifo_1d = 0;
	wire			rd_fifo;
	parameter 		Clear 	= 2'b00;
	parameter 		Idle 	= 2'b01;
	parameter 		Wr_fifo	= 2'b10; 
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
	
	assign rdrom_add_o = rd_rom_add;
	assign fifo_used_o = fifo_used;
	assign rd_fifo = (work_st == W_WRITE) ? 1 : 0;
	assign wr_sdram_data[15:3] = 0;
	assign clear_fifo = ~rst_100i;
	
	
	desk_fifo inst_dfifo
	(	         
		.aclr	(clear_fifo),  // need clear
		.data	(rom_dat_i),
		.rdclk	(clk_133M_i),
		.rdreq	(rd_fifo),
		.wrclk	(clk_100M_i),
		.wrreq	(wr_fifo_1d),
		.q		(wr_sdram_data[2:0]),
		.rdempty(),
		.rdusedw(),
		.wrfull	(),
		.wrusedw(fifo_used)
	);

//  	wr_fifo state machine 
//	 	fifo_use < 512 ,start write , 1 write state machine write 255 data
	always@(posedge clk_100M_i) begin   
		if(!rst_100i) begin
			wr_fifo_st <= Clear;
		end
		
		else begin
			case (wr_fifo_st)
				Clear : begin
					wr_fifo_st  <= Idle;
				end
				
				Idle : begin
					if(rd_rom_add == 16'hffff) begin
						wr_fifo_st 	<= Idle;
					end
					else if(fifo_used <= 512) begin
						wr_fifo_st  <= Wr_fifo;
					end
					else begin
						wr_fifo_st 	<= Idle;
					end
				end
				
				Wr_fifo : begin
					if(rom_cadd_cnt == 255) begin
						wr_fifo_st <= Idle;
					end
					
					else begin
						wr_fifo_st <= Wr_fifo;
					end
				end
			
			endcase
		end
		
	end
	
//  write data to fifo	
	always@(posedge clk_100M_i) begin  
		if(!rst_100i) begin
			rom_cadd_cnt 	<= 0;
			rom_radd_cnt 	<= 0;
			wr_fifo_en   <= 0;
			rd_rom_add   <= 0;
		end
		
		else begin
			case (wr_fifo_st)
				Clear: begin
					rom_cadd_cnt 	<= 0;
					rom_radd_cnt 	<= 0;
					wr_fifo_en <= 0;
				end
				
				Idle : begin
					rom_cadd_cnt <= 0;
					wr_fifo_en <= 0;
				end
				
				Wr_fifo : begin
					if(rom_cadd_cnt == 255) begin
						if(rom_radd_cnt == 255) begin  
							rom_radd_cnt 	<= 0;
						end
						
						else begin
							rom_radd_cnt 	<= rom_radd_cnt + 1;
						end
						rom_cadd_cnt <= 0;
						wr_fifo_en 	<= 1;
						rd_rom_add <= {rom_radd_cnt,rom_cadd_cnt};
					end
					
					else begin
						rom_cadd_cnt <= rom_cadd_cnt + 1;
						wr_fifo_en 	<= 1;
						rd_rom_add <= {rom_radd_cnt,rom_cadd_cnt};
					end	
				end
			endcase
		end
		
	end
	always@(posedge clk_100M_i) begin  
		if(!rst_100i) begin
			wr_fifo_1d <= 0;
		end
		else begin
			wr_fifo_1d <= wr_fifo_en;
		end
		
	end

endmodule
