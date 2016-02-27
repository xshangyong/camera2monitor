`timescale 1 ns / 1 ps
module test_top();

	reg 	CLK = 0;
	reg		RSTn,ps2_clk_i,ps2_data_i;

	wire    led_o1     ;	
	wire    led_o2     ;
	wire    led_o3     ;
	wire    VSYNC_Sig  ;
	wire    HSYNC_Sig  ;
	wire    Red_Sig    ;
	wire    Green_Sig  ;
	wire    Blue_Sig   ;
	wire[7:0]    row_o      ;
	wire[5:0]    column_o   ;
	wire[15:0]  sdram_data  ;
	wire[12:0]  sdram_addr  ;
	wire    	sdram_clk	;
	wire[1:0]   sdram_ba	;
	wire    	sdram_ncas  ;
	wire    	sdram_clke  ;
	wire    	sdram_nwe	;
	wire    	sdram_ncs	;
	wire[1:0]   sdram_dqm	;
	wire    	sdram_nras  ;
	
	
	initial begin
		RSTn = 1;
		#5000 RSTn = 0;
		#5000 RSTn = 1;
//		#600000 RSTn = 0;
		#5000 RSTn = 1;
	end
		
		
	always begin
		#10 CLK = ~CLK;
	end
	
	vga_module dut
	(
		.CLK		(CLK		),
		.RSTn		(RSTn		),
		.ps2_clk_i	(ps2_clk_i	),
		.ps2_data_i	(ps2_data_i	),
		.led_o1     (led_o1   	),
		.led_o2     (led_o2   	),
		.led_o3     (led_o3   	),
		.VSYNC_Sig  (VSYNC_Sig	),
		.HSYNC_Sig  (HSYNC_Sig	),
		.Red_Sig    (Red_Sig  	),
		.Green_Sig  (Green_Sig	),
		.Blue_Sig   (Blue_Sig 	),
		.row_o      (row_o    	),
		.column_o   (column_o 	),
		.sdram_data	(sdram_data ),
		.sdram_addr	(sdram_addr	),
		.sdram_clk	(sdram_clk	),
		.sdram_ba	(sdram_ba	),
		.sdram_ncas	(sdram_ncas	),
		.sdram_clke	(sdram_clke	),
		.sdram_nwe	(sdram_nwe	),
		.sdram_ncs	(sdram_ncs	),
		.sdram_dqm	(sdram_dqm	),
		.sdram_nras (sdram_nras	)
	);
	
	sdram inst_sdram
	(
		.Dq		(sdram_data), 
		.Addr	(sdram_addr), 
		.Ba		(sdram_ba), 
		.Clk	(sdram_clk), 
		.Cke	(sdram_clke), 
		.Cs_n	(sdram_ncs), 
		.Ras_n	(sdram_nras), 
		.Cas_n	(sdram_ncas), 
		.We_n	(sdram_nwe), 
		.Dqm	(1'b0)	
	);

endmodule
