`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/24 11:09:27
// Design Name: 
// Module Name: Uart_Tx
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


module Uart_Tx#(
    parameter                          P_UART_CLK         =  250_000_000 , //输入时钟频率
    parameter                          P_UART_BAUDRATE    =  9600        , //波特率
    parameter                          P_UART_DATA_WIDTH  =  8           , //数据位宽
    parameter                          P_UART_STOP_WIDTH  =  1           , //停止位位宽
    parameter                          P_UART_CHECK       =  0             //0:无校验，1：奇校验 2：偶校验
)(
    input                              i_clk          ,
    input                              i_rst          ,
    output                             o_uart_tx      ,

    input  [P_UART_DATA_WIDTH - 1 : 0] i_usr_tx_data  ,
    input                              i_usr_tx_valid ,
    output                             o_usr_tx_ready 
    );
/******************************function***************************/

/******************************parameter**************************/

/******************************port*******************************/

/******************************machine****************************/

/******************************reg********************************/
reg                             ro_uart_tx      ;
reg                             ro_usr_tx_ready ;
reg [15:0]                      r_cnt           ;
reg [P_UART_DATA_WIDTH - 1 : 0] r_tx_data       ;
reg                             r_tx_check      ;
/******************************wire*******************************/
wire                            w_tx_active     ;
/******************************component**************************/

/******************************assign*****************************/
assign o_uart_tx      = ro_uart_tx                     ;
assign o_usr_tx_ready = ro_usr_tx_ready                ;
assign w_tx_active    = o_usr_tx_ready & i_usr_tx_valid;
/******************************always*****************************/
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_usr_tx_ready <= 1'd1;
    else if(w_tx_active) 
        ro_usr_tx_ready <= 'd0 ;
    else if(r_cnt == 2 + P_UART_DATA_WIDTH + P_UART_STOP_WIDTH - 3 && P_UART_CHECK == 0)
        ro_usr_tx_ready <= 1'd1;
    else if(r_cnt == 2 + P_UART_DATA_WIDTH + P_UART_STOP_WIDTH - 2 && P_UART_CHECK > 0)
        ro_usr_tx_ready <= 1'd1;
    else
        ro_usr_tx_ready <= ro_usr_tx_ready;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_cnt <= 'd0;
    else if(r_cnt == 2 + P_UART_DATA_WIDTH + P_UART_STOP_WIDTH - 2 && P_UART_CHECK == 0) 
        r_cnt <= 'd0;
    else if(r_cnt == 2 + P_UART_DATA_WIDTH + P_UART_STOP_WIDTH - 1 && P_UART_CHECK > 0) 
        r_cnt <= 'd0;
    else if(!ro_usr_tx_ready)
        r_cnt <= r_cnt + 1;
    else
        r_cnt <= r_cnt;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_tx_data <= 'd0;
    else if(w_tx_active) 
        r_tx_data <= i_usr_tx_data;
    else if(!ro_usr_tx_ready)
        r_tx_data <= r_tx_data >> 1;
    else
        r_tx_data <= r_tx_data;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_uart_tx <= 1;
    else if(w_tx_active) 
        ro_uart_tx <= 'd0;
    else if(r_cnt == 3 + P_UART_DATA_WIDTH - 3 && P_UART_CHECK > 0)
        ro_uart_tx <= P_UART_CHECK == 1 ? ~r_tx_check : r_tx_check;
    else if(r_cnt >= 3 + P_UART_DATA_WIDTH - 3 && P_UART_CHECK == 0)
        ro_uart_tx <= 1'd1;
    else if(r_cnt >= 3 + P_UART_DATA_WIDTH - 2 && P_UART_CHECK > 0)
        ro_uart_tx <= 1'd1;
    else if(!ro_usr_tx_ready)
        ro_uart_tx <= r_tx_data[0];
    else
        ro_uart_tx <= 1;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_tx_check <= 'd0;
    else if(r_cnt == 3 + P_UART_DATA_WIDTH - 3)
        r_tx_check <= 'd0;
    else
        r_tx_check <= r_tx_check ^ r_tx_data[0];
end


endmodule
