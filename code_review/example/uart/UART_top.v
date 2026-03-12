module UART_top(
				clk,
				res,
				RX,
				TX
				);
input		clk;
input		res;
input		RX;
output	TX;
 
//在这里例化三个模块
//需要定义RX,TX模块与cmd模块联系的5个中间信号，信号名以cmd为准
//因为这五个信号都是连接信号，定义为wire类型
wire[7:0]				din_pro;
wire						en_din_pro;
wire[7:0]				dout_pro;
wire						en_dout_pro;
wire						rdy;
 
//封装顶层的时候，不管谁是输入，谁是输出，从顶层看都是连线，纯连接wire类型
//做testbench时，会改变模块的输入，所以要定义为reg类型
 
//异名例化
 
//串口数据接收
UART_RXer UART_RXer(
							.clk(clk),
							.res(res),
							.RX(RX),
							.data_out(din_pro),
							.en_data_out(en_din_pro)
							);
 
//串口数据发送
UART_TXer UART_TXer(
							.clk(clk),
							.res(res),
							.data_in(dout_pro),
							.en_data_in(en_dout_pro),
							.TX(TX),
							.rdy(rdy)
								);
//指令处理
cmd_pro cmd_pro(
							.clk(clk),
							.res(res),
							.din_pro(din_pro),
							.en_din_pro(en_din_pro),
							.dout_pro(dout_pro),
							.en_dout_pro(en_dout_pro),
							.rdy(rdy)
							);
endmodule
