#************************************************************
# THIS IS A WIZARD-GENERATED FILE.                           
#
# Version 11.0 Build 208 07/03/2011 Service Pack 1 SJ Full Version
#
#************************************************************

# Copyright (C) 1991-2011 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.



# Clock constraints

create_clock -name "clk_in" -period 20.000ns [get_ports {CLK}]
create_clock -name "clk_100" -period 10.000ns [get_ports {clk_100m:inst_100m|altpll:altpll_component|clk[0]}]
create_clock -name "clk_133" -period 7.000ns [get_ports {pll_133:inst_133m|altpll:altpll_component|clk[0]}]


# Automatically constrain PLL and other generated clocks
derive_pll_clocks -create_base_clocks

# Automatically calculate clock uncertainty to jitter and other effects.
derive_clock_uncertainty

# tsu/th constraints

# tco constraints

# tpd constraints

