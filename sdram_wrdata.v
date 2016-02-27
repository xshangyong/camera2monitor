module sdram_wrdata
(
	clk,
	rst_n,
	work_st,
	cnt_work,
	wr_sdram_data,
	sdram_data
);

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


	input 			clk;
	input 			rst_n;
	input[4:0] 		work_st;
	input[15:0]		cnt_work;
	input[15:0]		wr_sdram_data;
	inout[15:0]		sdram_data;


	reg				wr_sdram_flag;
	assign sdram_data = wr_sdram_flag ? wr_sdram_data : 16'bzzzz_zzzz_zzzz_zzzz;
	
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			wr_sdram_flag   <= 0;
		end
	
		else if(work_st==W_WRITE)begin   
			wr_sdram_flag	<= 1;
		end
		
		else begin
			wr_sdram_flag   <= 0;
		end
	end
	
	
    
	
endmodule
