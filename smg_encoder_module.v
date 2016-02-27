module smg_encoder_module
(
	clk_i,
	rst_i,
	dat_i,
	smg_o
);

input 		clk_i;
input			rst_i;
input[3:0]	dat_i;
output[7:0]	smg_o;	


parameter SMG_0  = 8'b1100_0000;
parameter SMG_1  = 8'b1111_1001;    
parameter SMG_2  = 8'b1010_0100;    
parameter SMG_3  = 8'b1011_0000;    
parameter SMG_4  = 8'b1001_1001;    
parameter SMG_5  = 8'b1001_0010;    
parameter SMG_6  = 8'b1000_0010;    
parameter SMG_7  = 8'b1111_1000;    
parameter SMG_8  = 8'b1000_0000;    
parameter SMG_9  = 8'b1001_0000;    
                 
reg[7:0] smg_r = 0;

assign smg_o = smg_r[7:0];


always@(posedge clk_i or negedge rst_i)
begin
	if(!rst_i)begin
		smg_r <= 0;
	end
	
	else begin
		case(dat_i)
			4'd0	:	smg_r <= SMG_0;
			4'd1	:	smg_r <= SMG_1;
			4'd2	:	smg_r <= SMG_2;
			4'd3	:	smg_r <= SMG_3;
			4'd4	:	smg_r <= SMG_4;
			4'd5	:	smg_r <= SMG_5;
			4'd6	:	smg_r <= SMG_6;
			4'd7	:	smg_r <= SMG_7;
			4'd8	:	smg_r <= SMG_8;
			4'd9	:	smg_r <= SMG_9;
		endcase
	end
end
endmodule
