module row_scan_module 
(
	clk_i,
	rst_i,
	p1pps, 
	smg_1_i,
	smg_2_i,
	smg_3_i,
	smg_4_i,
	smg_5_i,
	smg_6_i,
	row_o,
	column_o
);

input 		clk_i;
input 		rst_i;
input 		p1pps;
input[7:0]	smg_1_i;
input[7:0]	smg_2_i;
input[7:0]	smg_3_i;
input[7:0]	smg_4_i;
input[7:0]	smg_5_i;
input[7:0]	smg_6_i;
output[7:0]	row_o;
output[5:0] column_o;

reg[7:0]	row_scan_r = 0;
reg[5:0]	column_scan_r = 0;
reg[3:0]	row_ind = 0;

assign row_o = row_scan_r;
assign column_o = column_scan_r;


always@(posedge clk_i or negedge rst_i) begin
	if(!rst_i)begin
		row_ind <= 0;
	end
	
	else if(p1pps == 1)begin
		if(row_ind == 5)begin
			row_ind <= 0;
		end
		
		else begin
			row_ind <= row_ind + 1;
		end
	end
end

always@(posedge clk_i or negedge rst_i) begin
	if(!rst_i)begin
		row_scan_r <= 0;
		column_scan_r <= 0;
	end

	else begin
		case(row_ind)
			0	:	begin
				row_scan_r 	<= smg_1_i;
				column_scan_r <= 'b111110;
			end
			1	:	begin
				row_scan_r 	<= smg_2_i;
				column_scan_r <= 'b111101;
			end
			2	:	begin
				row_scan_r <= smg_3_i;
				column_scan_r <= 'b111011;
			end
			3	:	begin
				row_scan_r <= smg_4_i;
				column_scan_r <= 'b110111;
			end
			4	:	begin
				row_scan_r <= smg_5_i;
				column_scan_r <= 'b101111;
			end	
			5	:	begin
				row_scan_r <= smg_6_i;
				column_scan_r <= 'b011111;
			end
		endcase
	end
		
end

endmodule











