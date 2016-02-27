//  Title：ps2
//  2015-06-14 by Segment
//  PS2.v  
//  PS2 接口模块
//		输入:ps2_clk_i ps2_data_i为PS2的时钟和数据
//  	输出:  ps2_data_o为输出码字   ps2_break_o表示断码或者通码  ps2_done_o表示数据有效
//		输出信号有效期只有一个clk_i周期， 01为断码   10为通码
//		2015.6.14 注:调试通过，仅协议正确时有效，无防错处理。错误协议可能导致无法正常工作


module ps2(clk_i,rst_i,ps2_clk_i,ps2_data_i,ps2_data_o,ps2_break_o,ps2_done_o);
	input			clk_i;
	input			rst_i;
	input			ps2_clk_i;
	input 			ps2_data_i;
	output[15:0]	ps2_data_o;
	output[1:0] 	ps2_break_o;
	output			ps2_done_o;
	
	reg 			ps2_clk_d1,ps2_clk_d2;
	reg[5:0]		st_ps2 = 0;
	reg[5:0]    st_dat = 0;
	reg[7:0]		ps2_data_r = 0;
	reg			ps2_done_r = 0;
	reg[15:0]	double_data_r;
	reg[1:0] 	ma_br_r;
	reg			data_done_r;
	wire			ps2_clk_down;
	parameter   BREAK = 2'b01;
	parameter   MAKE =  2'b10;
	
assign ps2_clk_down = ~ps2_clk_d1 & ps2_clk_d2;
assign ps2_data_o   = double_data_r;
assign ps2_break_o      = ma_br_r;
assign ps2_done_o   = data_done_r;



always@(posedge clk_i or negedge rst_i) begin
	if(!rst_i)begin
		ps2_clk_d1 <= 0;
		ps2_clk_d2 <= 0;
	end
	
	else begin		
		ps2_clk_d1 <= ps2_clk_i;
		ps2_clk_d2 <= ps2_clk_d1;
	end	
end

//always@(posedge clk_i or negedge rst_i) begin
//	if(!rst_i)begin
//		ps2_data_use <= 0;
//		ps2_data_tmp <= 0;
//	end
//	
//	else if(ps2_done_r == 1) begin
//		
//		if(ps2_data_r == 'hf0) begin
//			ps2_data_use <= ps2_data_tmp;
//		end
//		else if(ps2_data_r != 'he0)begin
//			ps2_data_tmp <= ps2_data_r;
//			ps2_data_use <= 0;
//		end
//	end
//	else begin
//		ps2_data_use <= 0;
//	end
//end

always@(posedge clk_i or negedge rst_i) begin
	if(!rst_i)begin
		double_data_r <= 0;
		ma_br_r 	     <= 0;
		data_done_r   <= 0;
		st_dat	     <= 0;
	end
	
	else begin
		case(st_dat)
		0: begin		// idle:  wait for f0 e0 xx
			if(ps2_data_r == 8'hf0 && ps2_done_r == 1) begin
				st_dat <= 1;
			end
			
			else if(ps2_data_r == 8'he0 && ps2_done_r == 1) begin
				st_dat <=  2;
			end
			
			else if(ps2_done_r == 1) begin
				ma_br_r <= MAKE;
				data_done_r <= 1;
				double_data_r[15:8] <= 8'h0;
				double_data_r[7:0] <= ps2_data_r[7:0];
				st_dat <= 0;		
			end
			
			else begin
				double_data_r <= 0;
				ma_br_r 	     <= 0;
				data_done_r   <= 0;
				st_dat	     <= 0;
			end
		end
		
		1: begin			// single break
			if(ps2_done_r == 1) begin
				ma_br_r <= BREAK;
				data_done_r <= 1;
				double_data_r[15:8] <= 8'h0;
				double_data_r[7:0] <= ps2_data_r[7:0];
				st_dat <= 0;
			end
		end
		
		2: begin			//  double dat 
			if(ps2_data_r == 8'hf0 && ps2_done_r == 1) begin
				st_dat <= 3;			
			end
			
			else if(ps2_done_r == 1) begin
				ma_br_r <= MAKE;
				data_done_r <= 1;
				double_data_r[15:8] <= 8'he0;
				double_data_r[7:0] <= ps2_data_r[7:0];
				st_dat <= 0;				
			end
		end
		
		3: begin      //   double break
			if(ps2_done_r == 1) begin
				ma_br_r <= BREAK;
				data_done_r <= 1;
				double_data_r[15:8] <= 8'he0;
				double_data_r[7:0] <= ps2_data_r[7:0];
				st_dat <= 0;			
			end
		end
	   endcase
	end
end

	
always@(posedge clk_i or negedge rst_i) begin
	if(!rst_i)begin
		st_ps2 <= 0;
		ps2_data_r <= 0;
		ps2_done_r <= 0;
	end
	
	else begin
		case(st_ps2) 
			0: begin
				ps2_data_r <= 0;
				ps2_done_r <= 0;
				if(ps2_clk_down) begin
					st_ps2 <= st_ps2 + 1;
				end
			end
			
			1,2,3,4,5,6,7,8: begin
				if(ps2_clk_down) begin
					ps2_data_r[st_ps2 - 1] <= ps2_data_i;
					st_ps2 <= st_ps2 + 1;

				end
			end
			
			9: begin
				if(ps2_clk_down) begin
					st_ps2 <= st_ps2 + 1;
				end				
			end
			
			10: begin
				if(ps2_clk_down) begin
					st_ps2 <= 0;
					ps2_done_r <= 1;
				end				
			end
			
			
//			11 : begin
//				if(ps2_data_r == 8'he0)begin
//					st_ps2 <= 23;
//				end
//				else if(ps2_data_r == 8'hf0)begin
//					st_ps2 <= 12;
//				end
//				
//				else begin
//					st_ps2 <= 23;
//				end
//			end

			
//			ingore this			
//			12,13,14,15,16,17,18,19,20,21,22 : begin
//				if(ps2_clk_down) begin
//					st_ps2 <= st_ps2 + 1;
//				end					
//			end
//			
//			23 : begin
//				st_ps2 <= st_ps2 + 1;
//				ps2_done_r <= 1;
//			end
//			
//			24 : begin
//				st_ps2 <= 0;
//				ps2_done_r <= 0;
//			end
		endcase	
	end		
end		
				
	
	
	
	
	
endmodule















