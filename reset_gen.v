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
