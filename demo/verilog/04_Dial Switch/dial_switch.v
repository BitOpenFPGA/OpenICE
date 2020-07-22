`default_nettype none
//***************************************//
//# @Author: 碎碎思
//# @Date:   2019-04-14 19:54:50
//# @Last Modified by:   zlk
//# @Last Modified time: 2019-04-14 21:36:06
//****************************************//
module dial_switch
(
   	input CLK,
	input RST_n,

	input [7:0] SWICH,

	output LED0,
	output LED1,
	output LED2,
	output LED3,
	output LED4,
	output LED5,
	output LED6,
	output LED7 
);   

wire [7:0]SWICH;
    
	 
////////////////////////////////////////////	 
	

assign {LED7,LED6,LED5,LED4,LED3,LED2,LED1,LED0}=~SWICH;

endmodule //
