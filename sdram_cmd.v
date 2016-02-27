module sdram_cmd
(
	clk,
	rst_n,
	sdram_addr,
	sdram_ba,
	sdram_ncas,
	sdram_clke,
	sdram_nwe,
	sdram_ncs,
	sdram_dqm,
	sdram_nras,
	init_st,
	work_st,
	wr_sdram_add,
	rd_sdram_add,
	cnt_work,
	wr_sdram_req,
	rd_sdram_req,
	sys_state
);


	parameter	CMD_RST		= 5'b01111;		//5'd15;
	parameter	CMD_MRS		= 5'b10000;		//5'd16;
	parameter	CMD_ACT		= 5'b10011;		//5'd19;
	parameter	CMD_WR		= 5'b10100;		//5'd20;
	parameter	CMD_RD		= 5'b10101;		//5'd20;
	parameter	CMD_BSTOP	= 5'b10110;		//5'd22;
	parameter	CMD_NOP	 	= 5'b10111;		//5'd23;
	parameter	CMD_CHG	 	= 5'b10010;		//5'd18;
	parameter	CMD_REF	 	= 5'b10001;		//5'd17;
	                        
	parameter 	I_200us		= 5'd0;
	parameter 	I_pre 		= 5'd1;
	parameter 	I_wait_pre	= 5'd2;
	parameter 	I_refresh1 	= 5'd3;
	parameter 	I_refresh2 	= 5'd4;
	parameter 	I_refresh3 	= 5'd5;
	parameter 	I_refresh4 	= 5'd6;
	parameter 	I_refresh5 	= 5'd7;
	parameter 	I_refresh6 	= 5'd8;
	parameter 	I_refresh7 	= 5'd9;
	parameter 	I_refresh8 	= 5'd10;
	parameter 	I_wait_re1 	= 5'd11;
	parameter 	I_wait_re2 	= 5'd12;
	parameter 	I_wait_re3 	= 5'd13;
	parameter 	I_wait_re4 	= 5'd14;
	parameter 	I_wait_re5 	= 5'd15;
	parameter 	I_wait_re6 	= 5'd16;
	parameter 	I_wait_re7 	= 5'd17;
	parameter 	I_wait_re8 	= 5'd18;
	parameter 	I_mrs 		= 5'd19;
	parameter	I_wati_mrs	= 5'd20;
	parameter 	I_done 		= 5'd21;
	
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
	
	
//	`include "sdram_para.v"
	input 			clk;
	input 			rst_n;
	input[4:0]		init_st;
	input[4:0] 		work_st;
	input[23:0]		wr_sdram_add;
	input[23:0]		rd_sdram_add;
	input[15:0]		cnt_work;
	input			wr_sdram_req;
	input           rd_sdram_req;
	input[2:0]		sys_state;
	output[12:0]	sdram_addr;
	output[1:0]		sdram_ba;
	output	 		sdram_ncas;
	output	 		sdram_clke;
	output	 		sdram_nwe;
	output	 		sdram_ncs;
	output[1:0]		sdram_dqm;
	output			sdram_nras;


	reg[4:0]		cmd_r = CMD_NOP;
	reg[12:0]		sdram_addr_r;
	reg[1:0]		sdram_ba_r = 2'b11;	
//						CLKE,CS,RAS,CAS,WE
	assign sdram_addr 	= sdram_addr_r;
	assign sdram_ba 	= sdram_ba_r;
	assign sdram_dqm    = 2'b00;
	assign {sdram_clke,sdram_ncs,sdram_nras,sdram_ncas,sdram_nwe} = cmd_r;
	
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			cmd_r			<= CMD_RST;
			sdram_addr_r 	<= 13'hfff;
			sdram_ba_r		<= 2'b11;
		end
		else begin
			case(init_st)
			I_200us: begin
				cmd_r <= CMD_NOP;
				sdram_addr_r 	<= 13'hfff;
				sdram_ba_r		<= 2'b11;
			end
			I_pre: begin
				cmd_r <= CMD_CHG;  
				sdram_addr_r[10] <= 1'b1;		// all bank  a[10] = 1'b1
			end
			I_wait_pre: begin
				cmd_r <= CMD_NOP;
				sdram_addr_r 	<= 13'hfff;
				sdram_ba_r		<= 2'b11;				
			end
			I_refresh1,I_refresh2,I_refresh3,I_refresh4,I_refresh5,
			I_refresh6,I_refresh7,I_refresh8: begin
				cmd_r <= CMD_REF;
			end
			I_wait_re1,I_wait_re2,I_wait_re3,I_wait_re4,I_wait_re5,
			I_wait_re6,I_wait_re7,I_wait_re8: begin
				cmd_r <= CMD_NOP;
				sdram_addr_r 	<= 13'hfff;
				sdram_ba_r		<= 2'b11;				
			end
			I_mrs: begin
				cmd_r <= CMD_MRS;
				sdram_ba_r		<= 2'b00;				
				sdram_addr_r 	<= {3'b0,
									1'b0, 	//A9 	:	burst read and write
									2'b0,
									3'b011, //A6A5A4: 	CAS latency = 3
									1'b0,   //A3	:	Sequential
									3'b111 	//A2A1A0:	burst length = full page
									};
			end
			I_wati_mrs: begin
				cmd_r <= CMD_NOP;
				sdram_addr_r 	<= 13'hfff;
				sdram_ba_r		<= 2'b11;				
			end
			// row addr:wr_sdram_add[21:9], column addr:wr_sdram_add[8:0]
			I_done: begin
				case(work_st)
					W_IDLE : begin
						cmd_r <= CMD_NOP;
						sdram_addr_r 	<= 13'hfff;
						sdram_ba_r		<= 2'b11;				
					end
					W_ACTIVE : begin
						cmd_r <= CMD_ACT;
						if(sys_state == 1) begin
							sdram_addr_r <= rd_sdram_add[21:9];
							sdram_ba_r   <= rd_sdram_add[23:22];	
						end
						else if(sys_state == 2) begin
							sdram_addr_r <= wr_sdram_add[21:9];
							sdram_ba_r   <= wr_sdram_add[23:22];	
						end
					end
					W_REF : begin
						cmd_r <= CMD_REF;
						sdram_addr_r 	<= 13'hfff;
						sdram_ba_r		<= 2'b11;				
					end
					W_WRITE : begin
						if(cnt_work == 0)begin
							cmd_r <= CMD_WR;
							sdram_addr_r 	<= 0;
							sdram_ba_r		<= wr_sdram_add[23:22];
						end
						else begin
							cmd_r <= CMD_NOP;
							sdram_addr_r 	<= 13'hfff; 
							sdram_ba_r		<= 2'b11;
						end
					end
					W_READ : begin
						if(cnt_work == 0)begin
							cmd_r <= CMD_RD;
							sdram_addr_r 	<= 0;
							sdram_ba_r		<= wr_sdram_add[23:22];
						end 
						else begin
							cmd_r <= CMD_NOP;
							sdram_addr_r 	<= 13'hfff; 
							sdram_ba_r		<= 2'b11;
						end
					end
					W_RDDAT : begin
						if(cnt_work == 509)begin
							cmd_r <= CMD_BSTOP;
							sdram_addr_r 	<= 0;
							sdram_ba_r		<= wr_sdram_add[23:22];
						end
						else begin
							cmd_r <= CMD_NOP;
							sdram_addr_r 	<= 13'hfff; 
							sdram_ba_r		<= 2'b11;
						end
					end
					W_PRECH : begin
						cmd_r <= CMD_CHG;
						sdram_addr_r 	<= 13'hfff; // A10=1 -> all banks
						sdram_ba_r		<= 2'b11;
					end
					W_CHGACT : begin
						cmd_r <= CMD_CHG;
						sdram_addr_r 	<= 13'hfff; // A10=1 -> all banks
						sdram_ba_r		<= 2'b11;
					end
					W_BSTOP : begin
						cmd_r <= CMD_BSTOP;
						sdram_addr_r 	<= 13'hfff; // A10=1 -> all banks
						sdram_ba_r		<= 2'b11;
					end
					W_TRCD,W_RC,W_TRP,W_TRPACT,W_CL: begin
						cmd_r <= CMD_NOP;
						sdram_addr_r 	<= 13'hfff;
						sdram_ba_r		<= 2'b11;				
					end
				endcase
			end
			endcase
		end
	end
endmodule
