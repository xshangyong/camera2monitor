

module vga_control_module
(
    CLK, RSTn,
	 Ready_Sig, Column_Addr_Sig, Row_Addr_Sig,
	 Red_Sig, Green_Sig, Blue_Sig,
	 ps2_data_i,
	 rom_addr_o,display_data,
	 is_pic
);


	 input CLK;
	 input RSTn;
	 input Ready_Sig;
	 input [10:0]	Column_Addr_Sig;
	 input [10:0]	Row_Addr_Sig;
	 input [7:0] 	ps2_data_i;
	 input [2:0]	display_data;
	 output [15:0]	rom_addr_o;
	 output Red_Sig;
	 output Green_Sig;
	 output Blue_Sig;
	 output is_pic;
	 
	 
	 reg[15:0] posx = 400;
	 reg[15:0] posy = 400;
	 wire[15:0]  rom_addr_r;
	 reg[5:0]  rom_col_addr_r = 0;
	 parameter length = 50;
	 /**********************************/
	 reg isRectangle;
	//   resolution 1440*900   frame_rate 60Hz
//	   clk_fre = 84.960MHz
parameter H_SYN 		= 32;
parameter H_BKPORCH 	= 80;
parameter H_DATA 		= 1440;
parameter H_FTPORCH		= 48;
parameter H_TOTAL    	= 1600;


parameter V_SYN 		= 6;
parameter V_BKPORCH 	= 17;
parameter V_DATA 		= 900;
parameter V_FTPORCH		= 3;
parameter V_TOTAL    	= 926 ;


//	 assign is_pic = (Row_Addr_Sig < 256) &&  (Column_Addr_Sig < 256);
	 
	 
	 always @ ( posedge CLK or negedge RSTn )begin
		if( !RSTn )begin
			posx <= 0;
			posy <= 0;
		end
		
	    else if(ps2_data_i == 'h75)begin
			if(posx <= 20)
				posx <= 0;
			else
				posx <= posx - 20;
		 end
		 
		else if(ps2_data_i == 'h72)begin
			if(posx >= 816)
				posx <= 836;
			else
				posx <= posx + 20;
		end
		
		else if(ps2_data_i == 'h6b)begin
			if(posy <= 20)
				posy <= 0;
			else
				posy <= posy - 20;
		end
		else if(ps2_data_i == 'h74)begin
			if(posy >= 1356)
				posy <= 1376;
			else
				posy <= posy + 20;
		end
	 end
	 
	 
	 
	 
	 always @ ( posedge CLK or negedge RSTn )
	     if( !RSTn )
		      isRectangle <= 1'b0;
		  else if( (Column_Addr_Sig >= posy) && (Column_Addr_Sig <= (posy + length))
					&& (Row_Addr_Sig >= posx) && (Row_Addr_Sig <= (posx + length)) )
			isRectangle <= 1'b1;
		  else
			isRectangle <= 1'b0;
		
// 			pika display

		
	assign is_pic = Row_Addr_Sig <= 256 ?
					Row_Addr_Sig >= 1 ?
					Column_Addr_Sig <= 256 ?
					Column_Addr_Sig <= 256 ? 1 : 0 : 0 : 0 : 0;
					
	assign rom_addr_r = Row_Addr_Sig < 256 ?
					Column_Addr_Sig < 256 ? Row_Addr_Sig*256 + Column_Addr_Sig : 0 : 0; 				

	 
	 always @ ( posedge CLK or negedge RSTn )
	 if( !RSTn )
		  rom_col_addr_r <= 5'b0;
	  else if( Ready_Sig && Column_Addr_Sig - posy< 64 )
			rom_col_addr_r <= Column_Addr_Sig[5:0] ;

	/************************************/
     assign rom_addr_o = rom_addr_r[15:0];			
	 assign Red_Sig   = Ready_Sig && display_data[2] && is_pic ? 1'b1 : 1'b0;
	 assign Green_Sig = Ready_Sig && display_data[1] && is_pic ? 1'b1 : 1'b0;
	 assign Blue_Sig  = Ready_Sig && display_data[0] && is_pic ? 1'b1 : 1'b0;
	 
	/***********************************/
	 

endmodule
