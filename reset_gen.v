module reset_gen
(
	clk_100,
	clk_133,
	rst_n,
	rst_100,
	rst_133
);

	input 		clk_100;
	input		clk_133;
	input 		rst_n;
	output reg	rst_100;
	output reg	rst_133;
	reg			rst_133a = 1;
	reg			rst_133b = 1;
	reg[32:0]	cnt_rst = 0;
	reg			rst = 0;
	reg[32:0]	cnt_init = 0;
	reg			rst_init = 0; // low valid
	reg			rst_100a = 0;
	reg			rst_100b = 0;
	
	wire		rst_use;
// generate a low valid rst signal per 5s
	reg			rst_freq = 1;
	reg			rst_freq_1p = 1;
	reg[1:0]	rst_mode = 0; // 0 for 3s,1 for 4s,2 for 5s, 4 for 6s;
	reg[31:0]	cnt_10ns = 0; // 100_000_000 for 1s

	
	
	
	always @(posedge clk_100) begin
		if(cnt_init == 32'd100) begin
			cnt_init <= cnt_init;
			rst_init <= 1;
		end
		
		else begin
			cnt_init <= cnt_init + 1;
			rst_init <= 0;
		end
	end	


	always @(posedge clk_100) begin
		if(!rst_n) begin
			if(cnt_rst == 32'd100) begin //10ms
				cnt_rst <= cnt_rst;
				rst <= 0;
			end
			else begin
				cnt_rst <= cnt_rst + 1;
				rst <= 1;
			end
		end
		else begin
			cnt_rst <= 0;
			rst <= 1;
		end
	end



//	always @(posedge clk_100) begin
//		rst_freq_1p <= rst_freq;
//		if(rst_freq && !rst_freq_1p) begin
//			rst_mode <= rst_mode + 1;
//		end
//	end
//	always @(posedge clk_100) begin
//		case(rst_mode)
//			0 : begin
//				if(rst_freq == 1 && cnt_10ns >= 32'd80_000_013) begin
//					rst_freq <= ~rst_freq;
//					cnt_10ns <= 0;
//				end
//				else if(rst_freq == 0 && cnt_10ns >= 32'd40_000_000) begin
//					rst_freq <= ~rst_freq;
//					cnt_10ns <= 0;
//				end
//				else begin
//					cnt_10ns <= cnt_10ns + 1;
//				end
//			end
//			1 : begin
//				if(rst_freq == 1 && cnt_10ns >= 32'd90_000_000) begin
//					rst_freq <= ~rst_freq;
//					cnt_10ns <= 0;
//				end
//				else if(rst_freq == 0 && cnt_10ns >= 32'd40_000_000) begin
//					rst_freq <= ~rst_freq;
//					cnt_10ns <= 0;
//				end
//				else begin
//					cnt_10ns <= cnt_10ns + 1;
//				end		
//			end
//			2 : begin
//				if(rst_freq == 1 && cnt_10ns >= 32'd100_000_000) begin
//					rst_freq <= ~rst_freq;
//					cnt_10ns <= 0;
//				end
//				else if(rst_freq == 0 && cnt_10ns >= 32'd40_000_000) begin
//					rst_freq <= ~rst_freq;
//					cnt_10ns <= 0;
//				end
//				else begin
//					cnt_10ns <= cnt_10ns + 1;
//				end			
//			end
//			3 : begin
//				if(rst_freq == 1 && cnt_10ns >= 32'd110_000_000) begin
//					rst_freq <= ~rst_freq;
//					cnt_10ns <= 0;
//				end
//				else if(rst_freq == 0 && cnt_10ns >= 32'd40_000_000) begin
//					rst_freq <= ~rst_freq;
//					cnt_10ns <= 0;
//				end
//				else begin
//					cnt_10ns <= cnt_10ns + 1;
//				end		
//			end
//		endcase
//	end
	
	
	
	assign rst_use = rst & rst_init;
	
	always @(posedge clk_100) begin
		rst_100b <= rst_use;
		rst_100a <= rst_100b;
		rst_100 <= rst_100a;
	end
	
	
	always @(posedge clk_133) begin
			rst_133a <= rst_use;
			rst_133b <= rst_133a;
			rst_133  <= rst_133b;
		
	end
endmodule
