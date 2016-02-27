module sdram_ctrl
(
	clk,
	rst_n,
	init_st,
	work_st,
	wr_sdram_req,
	wr_sdram_ack,
	rd_sdram_req,
	rd_sdram_ack,
	cnt_work,
	sys_state
);
	
	parameter	CMD_RST		= 5'b01111;
	parameter	CMD_MRS		= 5'b10000;
	parameter	CMD_ACT		= 5'b10011;
	parameter	CMD_WR		= 5'b10100;
	parameter	CMD_BSTOP	= 5'b10110;
	parameter	CMD_NOP	 	= 5'b10111;
	parameter	CMD_CHG	 	= 5'b10010;
	parameter	CMD_REF	 	= 5'b10001;
	
	parameter	cnt_200us	= 2666;  // 26666clk = 200us
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
	parameter	W_BSTOP		= 4'd11;	//burst stop
	parameter	W_CHGACT	= 4'd12;	//precharge before act
	parameter	W_TRPACT	= 4'd13;	//precharge before act

	input 		clk;
	input 		rst_n;
	input		wr_sdram_req;
	input 		rd_sdram_req;
	output reg	wr_sdram_ack;
	output reg	rd_sdram_ack;
	output reg[4:0]		init_st = I_200us;
	output reg[4:0]		work_st = W_IDLE;	
	output reg[15:0]	cnt_work;
	output reg[2:0]		sys_state = 0;
	reg[15:0]	cnt_init;
	reg			pre_charge_done;
	reg			init_cnt_rst = 0;
	reg			work_cnt_rst = 0;
	reg[4:0]	nxt_ist = I_200us;
	reg[4:0]	nxt_wst = W_IDLE;
	reg[9:0]	ref_cnt = 0;
	reg			ref_req = 0;
	wire		ref_ack;
	
	assign ref_ack = (work_st == W_REF);		// SDRAM自刷新应答信号

//	auto refresh counter , refresh req and ack	
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			ref_cnt	<= 0;
		end
	
		else if(ref_cnt >= 'd400)begin    // 133MHz   cnt 1000 
			ref_cnt	<= 0;
		end
		
		else begin
			ref_cnt	<= ref_cnt + 1;	
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			ref_req	<= 0;
		end
	
		else if(ref_cnt == 'd400)begin
			ref_req	<= 1;
		end
		
		else if(ref_ack)begin
			ref_req	<= 0;
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			cnt_init		<= 0;
		end
		else begin
			if(init_cnt_rst) begin
				cnt_init <= 0;
			end
			else begin
				cnt_init <= cnt_init + 1;
			end
		end
	end	
	
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			cnt_work <= 0;
		end
		else begin
			if(work_cnt_rst) begin
				cnt_work <= 0;
			end
			else begin
				cnt_work <= cnt_work + 1;
			end
		end
	end
	
	// 控制初始化计数器复位 组合逻辑
	// generate ack ,respond req, sys_state
	always @(*) begin
		case(init_st)
			I_200us: begin
				init_cnt_rst = cnt_init >= cnt_200us ? 1 : 0;
				rd_sdram_ack = 0;
				wr_sdram_ack = 0;
			end
			
			I_pre: begin
				init_cnt_rst = 0;
			end
			
			I_wait_pre: begin
				init_cnt_rst = cnt_init >= 3 ? 1 : 0;	// precharge time 20ns = 3 sdramclk	
			end
			
			I_refresh1,I_refresh2,I_refresh3,I_refresh4,I_refresh5,
			I_refresh6,I_refresh7,I_refresh8: begin
				init_cnt_rst = 0;
			end
			
			I_wait_re1,I_wait_re2,I_wait_re3,I_wait_re4,I_wait_re5,
			I_wait_re6,I_wait_re7,I_wait_re8: begin
				init_cnt_rst = cnt_init >= 8 ? 1 : 0;   // refresh cycle tRC = 60ns = 9 sdramclk	
			end
			
			I_mrs: begin
				init_cnt_rst = 0;
			end
			
			I_wati_mrs: begin
				init_cnt_rst = cnt_init >= 2 ? 1 : 0;  
			end
			
			I_done: begin
				init_cnt_rst = 0;
				case(work_st)
					W_IDLE : begin
						work_cnt_rst = 1;
						sys_state	 = 0;
						rd_sdram_ack = 0;
						wr_sdram_ack = 0;
					end
					W_REF : begin
						work_cnt_rst = 0;
					end
					W_ACTIVE : begin
						work_cnt_rst = 0;
						if(wr_sdram_req == 1 )begin
							sys_state = 2;
						end
						else if(rd_sdram_req == 1 )begin
							sys_state = 1;
						end
						else begin
							sys_state = 0;
						end
					end
					W_RC : begin
						work_cnt_rst = cnt_work >= 8 ? 1 : 0; // refresh cycle tRC = 63ns = 9 sdramclk	
					end
					W_TRCD: begin
						work_cnt_rst = cnt_work >= 2 ? 1 : 0;
					end
					W_WRITE: begin
						work_cnt_rst = cnt_work >= 511 ? 1 : 0;
						if(cnt_work == 510) begin
							wr_sdram_ack = 1;
						end
						else begin
							wr_sdram_ack = 0;
						end
					end
					W_READ : begin
						work_cnt_rst = 0;
					end					
					W_CL : begin
						work_cnt_rst = cnt_work >= 3? 1 : 0;   // cal latency = 3
					end					
					W_RDDAT : begin
						work_cnt_rst = cnt_work >= 511? 1 : 0;
						if(cnt_work == 510) begin
							rd_sdram_ack = 1;
						end
						else begin
							rd_sdram_ack = 0;
						end
					end
					W_BSTOP : begin
						work_cnt_rst = cnt_work >= 1? 1 : 0;   // cal latency = 3
					end
					
					W_TRP,W_TRPACT: begin
						work_cnt_rst = cnt_work >= 2 ? 1 : 0;
					end
					default: begin
						work_cnt_rst = 1;
						wr_sdram_ack = 0;
						rd_sdram_ack = 0;
						
					end
				endcase
			end
		endcase
	end
	
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			init_st <= I_200us;
			work_st <= W_IDLE;
			
		end
		else begin
			init_st <= nxt_ist;
			work_st <= nxt_wst;
			
		end
	end
	
	// 状态机跳转控制
	always @(*)begin   //comb
		case(init_st)
			I_200us: begin
				nxt_ist = cnt_init >= cnt_200us ? I_pre: I_200us;
			end
			
			I_pre: begin
				nxt_ist = I_wait_pre;  // 1 clk
			end
			
			I_wait_pre: begin
				nxt_ist = cnt_init >= 3? I_refresh1: I_wait_pre;
			end
			
			I_refresh1: begin
				nxt_ist = I_wait_re1;
			end
			
			I_wait_re1: begin
				nxt_ist = cnt_init >= 8? I_refresh2: I_wait_re1;// 若一共需�个周期，I_refresh1已经占用一个周期，此处只需�个周�			end
			end
			
			I_refresh2: begin
				nxt_ist = I_wait_re2;
			end
			
			I_wait_re2: begin
				nxt_ist = cnt_init >= 8? I_refresh3: I_wait_re2;
			end
			
			I_refresh3: begin
				nxt_ist = I_wait_re3;
			end
			
			I_wait_re3: begin
				nxt_ist = cnt_init >= 8? I_refresh4: I_wait_re3;
			end
			
			I_refresh4: begin
				nxt_ist = I_wait_re4;
			end
			
			I_wait_re4: begin
				nxt_ist = cnt_init >= 8? I_refresh5: I_wait_re4;
			end
			
			I_refresh5: begin
				nxt_ist = I_wait_re5;
			end
			
			I_wait_re5: begin
				nxt_ist = cnt_init >= 8? I_refresh6: I_wait_re5;
			end

			I_refresh6: begin
				nxt_ist = I_wait_re6;
			end
			
			I_wait_re6: begin
				nxt_ist = cnt_init >= 8? I_refresh7: I_wait_re6;
			end
				
			I_refresh7: begin
				nxt_ist = I_wait_re7;
			end
			
			I_wait_re7: begin
				nxt_ist = cnt_init >= 8? I_refresh8: I_wait_re7;
			end
			
			I_refresh8: begin
				nxt_ist = I_wait_re8;
			end
			
			I_wait_re8: begin
				nxt_ist = cnt_init >= 8? I_mrs: I_wait_re8;
			end
				
			I_mrs : begin
				nxt_ist = I_wati_mrs;
			end
			
			I_wati_mrs : begin
				nxt_ist = cnt_init >= 2? I_done: I_wati_mrs;
			end
			
			I_done: begin
				nxt_ist = I_done;
				case(work_st)
					W_IDLE : begin
						if(ref_req) begin // auto refresh
							nxt_wst = W_PRECH; 
						end
						
						else if(wr_sdram_req) begin //  write 
							nxt_wst = W_CHGACT;
						end

						else if(rd_sdram_req) begin //  read
							nxt_wst = W_CHGACT;
						end
						
						else  begin
							nxt_wst = W_IDLE;
						end
					end
					W_REF : begin
						nxt_wst = W_RC; 
					end
					W_RC : begin
						nxt_wst = cnt_work >= 8? W_IDLE: W_RC;
					end
					W_ACTIVE: begin
						nxt_wst = W_TRCD;
					end
					W_TRCD: begin
						if(cnt_work >= 2) begin
							if(sys_state == 1) begin
								nxt_wst = W_READ;
							end
							else if(sys_state == 2) begin
								nxt_wst = W_WRITE;
							end
							else begin
								nxt_wst = W_IDLE;
							end
						end
						else begin
							nxt_wst = W_TRCD;
						end
					end
					W_WRITE : begin
						nxt_wst = cnt_work >= 511? W_BSTOP : W_WRITE;		
					end
					W_READ : begin
						nxt_wst = W_CL;
					end
					W_CL : begin
						nxt_wst = cnt_work >= 3? W_RDDAT : W_CL;
					end
					W_RDDAT : begin
						nxt_wst = cnt_work >= 511? W_PRECH : W_RDDAT;
					end
					W_BSTOP : begin
						nxt_wst = cnt_work >= 1? W_PRECH : W_BSTOP; // exchange
					end
					W_PRECH : begin
						nxt_wst = W_TRP;		
					end
					W_TRP : begin
						nxt_wst = cnt_work >= 2? W_REF: W_TRP;
					end
					W_CHGACT : begin
						nxt_wst = W_TRPACT;		
					end
					W_TRPACT : begin
						nxt_wst = cnt_work >= 2? W_ACTIVE: W_TRPACT;		
					end
					default: begin
						nxt_wst = W_IDLE;
					end
				endcase
			end
			
			default: begin
				nxt_ist = I_200us;
			end
		endcase
	end
	
endmodule
