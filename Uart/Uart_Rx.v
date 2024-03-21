`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/24 11:09:27
// Design Name: 
// Module Name: Uart_Rx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Uart_Rx#(
    parameter                          P_UART_CLK         =  250_000_000 , //输入时钟频率
    parameter                          P_UART_BAUDRATE    =  9600        , //波特率
    parameter                          P_UART_DATA_WIDTH  =  8           , //数据位宽
    parameter                          P_UART_STOP_WIDTH  =  1           , //停止位位宽  
    parameter                          P_UART_CHECK       =  0             //0:无校验，1：奇校验 2：偶校验  
)(
    input                              i_clk          ,
    input                              i_rst          ,
    input                              i_uart_rx      ,

    output [P_UART_DATA_WIDTH - 1 : 0] o_usr_rx_data  ,
    output                             o_usr_rx_valid 
    );
/******************************function***************************/

/******************************parameter**************************/

/******************************port*******************************/

/******************************machine****************************/

/******************************reg********************************/
reg [P_UART_DATA_WIDTH - 1 : 0] ro_usr_rx_data  ;
reg                             ro_usr_rx_valid ;
reg [1:0]                       r_uart_rx       ;
reg [15:0]                      r_cnt           ;
reg                             r_rx_check      ;
/******************************wire*******************************/

/******************************component**************************/

/******************************assign*****************************/
assign o_usr_rx_data      =     ro_usr_rx_data  ;
assign o_usr_rx_valid     =     ro_usr_rx_valid ;
/******************************always*****************************/
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_uart_rx <= 2'b11;
    else
        r_uart_rx <= {r_uart_rx[0],i_uart_rx};//r_uart_rx[1]就是打俩拍的结果
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_cnt <= 'd0;
    else if(r_cnt == 2 + P_UART_DATA_WIDTH + P_UART_STOP_WIDTH - 2 && P_UART_CHECK == 0)
        r_cnt <= 'd0;
    else if(r_cnt == 2 + P_UART_DATA_WIDTH + P_UART_STOP_WIDTH - 1 && P_UART_CHECK > 0)
        r_cnt <= 'd0;
    else if(i_uart_rx == 0 || r_cnt > 0)
        r_cnt <= r_cnt + 1;
    else
        r_cnt <= r_cnt;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_usr_rx_data <= 'd0;
    else if(r_cnt >= 1 && r_cnt <= P_UART_DATA_WIDTH)
        ro_usr_rx_data <= {i_uart_rx,ro_usr_rx_data[P_UART_DATA_WIDTH-1:1]};//先发低位
        // ro_usr_rx_data <= {ro_usr_rx_data[P_UART_DATA_WIDTH-2:0],r_uart_rx[1]};//先发高位
    else
        ro_usr_rx_data <= ro_usr_rx_data;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_usr_rx_valid <= 'd0;
    else if(r_cnt == P_UART_DATA_WIDTH && P_UART_CHECK == 0)
        ro_usr_rx_valid <= 1'd1;
    else if(r_cnt == P_UART_DATA_WIDTH + 1 && P_UART_CHECK == 1 && i_uart_rx == ~r_rx_check)
        ro_usr_rx_valid <= 1'd1; 
    else if(r_cnt == P_UART_DATA_WIDTH + 1 && P_UART_CHECK == 2 && i_uart_rx == r_rx_check)
        ro_usr_rx_valid <= 1'd1;
    else
        ro_usr_rx_valid <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_rx_check <= 'd0;
    else if(r_cnt >= 1 && r_cnt <= P_UART_DATA_WIDTH)
        r_rx_check <= r_rx_check ^ i_uart_rx;//异或结果为1说明1个数为奇数
    else
        r_rx_check <= 'd0;
end

endmodule
