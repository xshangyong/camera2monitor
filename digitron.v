//  Lesson1 
//  Title��:��top module
//  2014-06-31 by Segment
//  top.v  

module digitron(clk_i,rst_i,num_i,row_o,column_o);
	input		clk_i;
	input		rst_i;
	input[19:0]	num_i;
	output[7:0]	row_o;
	output[5:0]	column_o;

	
	wire[3:0]  	dat_1_r;
	wire[3:0]  	dat_2_r;
	wire[3:0]  	dat_3_r;
	wire[3:0]  	dat_4_r;
	wire[3:0]  	dat_5_r;
	wire[3:0]  	dat_6_r;
	wire[7:0] 	row_r;
	wire[5:0] 	column_r;
	wire[7:0]  	smg_1_r;
	wire[7:0]  	smg_2_r;
	wire[7:0]  	smg_3_r;
	wire[7:0] 	smg_4_r;
	wire[7:0]  	smg_5_r;
	wire[7:0]  	smg_6_r;	
	reg[31:0] 	cnt = 0;
	reg 		 	p1pps = 0;
	reg[31:0] 	cnt_1s = 0;
//	reg 		 	p1s = 0;
	reg[19:0] 	num = 0;
	reg			rst_1p;
	reg			rst_use;
	
	assign	row_o = row_r;
	assign	column_o = column_r;
	
	
	always@(posedge clk_i or negedge rst_i) begin
		if(!rst_i) begin
			rst_1p <= rst_i;
			rst_use <= rst_i;
		end
		
		else begin
			rst_1p <= rst_i;
			rst_use <= rst_1p;
		end
	end
	number_mod_module inst_num
	(
		.clk_i(clk_i),
		.number_data_i(num_i),
		.rst_i(rst_use),
		.dat_1_o(dat_1_r),
		.dat_2_o(dat_2_r),
		.dat_3_o(dat_3_r),
		.dat_4_o(dat_4_r),
		.dat_5_o(dat_5_r),
		.dat_6_o(dat_6_r)
	);
	
	smg_encoder_module inst_smg1
	(
		.clk_i(clk_i),
		.rst_i(rst_use),
		.dat_i(dat_1_r),
		.smg_o(smg_1_r)
	);

	smg_encoder_module inst_smg2
	(
		.clk_i(clk_i),
		.rst_i(rst_use),
		.dat_i(dat_2_r),
		.smg_o(smg_2_r)
	);
	
	smg_encoder_module inst_smg3
	(
		.clk_i(clk_i),
		.rst_i(rst_use),
		.dat_i(dat_3_r),
		.smg_o(smg_3_r)
	);
	
	smg_encoder_module inst_smg4
	(
		.clk_i(clk_i),
		.rst_i(rst_use),
		.dat_i(dat_4_r),
		.smg_o(smg_4_r)
	);
	
	smg_encoder_module inst_smg5
	(
		.clk_i(clk_i),
		.rst_i(rst_use),
		.dat_i(dat_5_r),
		.smg_o(smg_5_r)
	);
	
	smg_encoder_module inst_smg6
	(
		.clk_i(clk_i),
		.rst_i(rst_use),
		.dat_i(dat_6_r),
		.smg_o(smg_6_r)
	);
	
	row_scan_module inst_rowscan
	(
		.clk_i(clk_i),
		.rst_i(rst_use),
		.p1pps(p1pps), 
		.smg_1_i(smg_1_r),
		.smg_2_i(smg_2_r),
		.smg_3_i(smg_3_r),
		.smg_4_i(smg_4_r),
		.smg_5_i(smg_5_r),
		.smg_6_i(smg_6_r),
		.row_o(row_r),
		.column_o(column_r)
	);
	
	
	
	
	always@(posedge clk_i or negedge rst_use)
	begin
		if(!rst_use) begin
			p1pps <= 0;
		end
		
		else if(cnt == 40000)begin
			p1pps <= 1;
		end
		
		else begin
			p1pps <= 0;
		end
	end
	
	
	always@(posedge clk_i or negedge rst_use)
	begin
		if(!rst_use) begin
			cnt <= 0;
		end
		

		else if(cnt == 40000)begin
			cnt <=0;
		end
		
		else begin
			cnt <= cnt + 1;
		end
	end
	
	always@(posedge clk_i or negedge rst_use)
	begin
		if(!rst_use) begin
			cnt_1s <= 0;
			num <= 0;
		end

		
		else if(cnt_1s == 40000000)begin
				cnt_1s <= 0;
				num <= num + 1;
		end
			
		else begin
			cnt_1s <= cnt_1s + 1;
		end
	end
	
	
endmodule