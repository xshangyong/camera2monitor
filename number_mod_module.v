module number_mod_module
(
	clk_i,
	rst_i,
	number_data_i,
	dat_1_o,
	dat_2_o,
	dat_3_o,
	dat_4_o,
	dat_5_o,
	dat_6_o
);

input 		clk_i;
input			rst_i;
input[19:0]	number_data_i;
output[3:0]	dat_1_o;
output[3:0] dat_2_o;
output[3:0] dat_3_o;
output[3:0] dat_4_o;
output[3:0] dat_5_o;
output[3:0] dat_6_o;

			
reg[3:0]  dat_1_r = 0;
reg[3:0]  dat_2_r = 0;
reg[3:0]  dat_3_r = 0;
reg[3:0]  dat_4_r = 0;
reg[3:0]  dat_5_r = 0;
reg[3:0]  dat_6_r = 0;

assign dat_1_o = dat_1_r;
assign dat_2_o = dat_2_r;
assign dat_3_o = dat_3_r;
assign dat_4_o = dat_4_r;
assign dat_5_o = dat_5_r;
assign dat_6_o = dat_6_r;

always@(posedge clk_i or negedge rst_i) begin
	if(!rst_i)begin
		dat_1_r <= 0;
		dat_2_r <= 0;
		dat_3_r <= 0;
		dat_4_r <= 0;
		dat_5_r <= 0;
		dat_6_r <= 0;
	end
	
	else begin
		dat_1_r <= number_data_i%10;
		dat_2_r <= (number_data_i%100)/10;
		dat_3_r <= (number_data_i%1000)/100;
		dat_4_r <= (number_data_i%10000)/1000;
		dat_5_r <= (number_data_i%100000)/10000;
		dat_6_r <= (number_data_i%1000000)/100000;
	end

end
endmodule