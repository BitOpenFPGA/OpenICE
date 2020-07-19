`default_nettype none
//***************************************//
//# @Author: 碎碎思
//# @Date:   2019-04-14 19:54:50
//# @Last Modified by:   zlk
//# @Last Modified time: 2019-04-14 21:36:06
//****************************************//
module Run_LED
(
   	input CLK,
	input RST_n,
	output LED0,
	output LED1,
	output LED2,
	output LED3,
	output LED4,
	output LED5,
	output LED6,
	output LED7 
);   
    
	 
////////////////////////////////////////////	 

	
reg [7:0]LED;


////////////////////////////////////////////
//
//首先定义一个时间计数寄存器counter，每当达到预定的100ms时，
//计数寄存器就清零，否则的话寄存器就加1。
//然后计算计数器计数的最大值。时钟频率为12MHZ，
//也就是周期为1/12M 为83ns，要计数的最大值为T100MS= 100ms/83ns-1 = 120_4818。
//

reg[24:0] counter;
parameter T100MS = 25'd120_4818;

always @ (posedge CLK or negedge RST_n)

if(!RST_n)      //高电平复位

	counter<=25'd0;

else if(counter==T100MS)

	counter<=25'd0;

else

	counter<=counter+1'b1;
////////////////////////////////////////////
always @ (posedge CLK or negedge RST_n)

if(!RST_n)

	LED<=8'b1111_1111;        //初值，最低位led[0]灯亮

else if(counter==T100MS)

	begin

		if(LED==8'b0000_0000)      //当溢出最高位时

			LED<=8'b1111_1111;    //回到复位时的状态

		else

			LED<=LED<<1;     //循环左移一位

	end

assign {LED0,LED1,LED2,LED3,LED4,LED5,LED6,LED7}=LED;

endmodule // Run_LED
