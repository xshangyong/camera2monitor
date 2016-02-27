


module sync_module
(
    CLK, RSTn,
	 VSYNC_Sig, HSYNC_Sig, Ready_Sig,
	 Column_Addr_Sig, Row_Addr_Sig
);

	input CLK;
	input RSTn;
	output VSYNC_Sig;
	output HSYNC_Sig;
	output Ready_Sig;
	output [10:0]Column_Addr_Sig;
	output [10:0]Row_Addr_Sig;
	 
	/********************************/
	 



	 
	reg [10:0]Count_H;
	//   resolution 1440*900   frequence 60Hz
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
	 always @ ( posedge CLK or negedge RSTn )
	     if( !RSTn )
				 Count_H <= 11'd0;
			else if( Count_H == H_TOTAL - 1)
			    Count_H <= 11'd0;
			else 
			    Count_H <= Count_H + 1'b1;
    
	 /********************************/
	 
	 reg [10:0]Count_V;
		 
	always @ ( posedge CLK or negedge RSTn )
	if( !RSTn )
		Count_V <= 11'd0;
	else if( Count_H == H_TOTAL - 1) begin
		Count_V <= Count_V + 1'b1;
		if( Count_V == V_TOTAL - 1) begin
			Count_V <= 11'd0;
		end
	end
	 /********************************/
	 
//	 reg isReady;
	 
/* 	 always @ ( posedge CLK or negedge RSTn )
	     if( !RSTn )
		      isReady <= 1'b0;
        else if( ( Count_H >= H_SYN + H_BKPORCH - 1 && Count_H < H_SYN + H_BKPORCH + H_DATA ) && 
			        ( Count_V >= V_SYN + V_BKPORCH - 1 && Count_V < V_SYN + V_BKPORCH + V_DATA ) )
		      isReady <= 1'b1;
		  else
		      isReady <= 1'b0; */
		    
	 /*********************************/
	 
	 assign VSYNC_Sig = ( Count_V < V_SYN ) ? 1'b0 : 1'b1;
	 assign HSYNC_Sig = ( Count_H < H_SYN ) ? 1'b0 : 1'b1;
	 assign Ready_Sig = (Count_H >= H_SYN + H_BKPORCH)	 ?		
						(Count_H < H_SYN + H_BKPORCH + H_DATA) ? 	
						(Count_V >= V_SYN + V_BKPORCH) ?					
						(Count_V < V_SYN + V_BKPORCH + V_DATA) ? 1 : 0 : 0 : 0 :0;
	                       
	 
	 /********************************/
	 
	 assign Column_Addr_Sig = Ready_Sig ? Count_H - H_SYN - H_BKPORCH + 1: 11'd0;    // Count from 0;
	 assign Row_Addr_Sig = Ready_Sig ? Count_V - V_SYN - V_BKPORCH + 1 : 11'd0; 		 // Count from 0;
	
	 /********************************/
	 
endmodule
