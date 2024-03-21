`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/24 11:09:27
// Design Name: 
// Module Name: Uart_Drive
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


module Uart_Drive#(
    parameter                          P_UART_CLK         =  250_000_000 , //输入时钟频率
    parameter                          P_UART_BAUDRATE    =  9600        , //波特率
    parameter                          P_UART_DATA_WIDTH  =  8           , //数据位宽
    parameter                          P_UART_STOP_WIDTH  =  1           , //停止位位宽
    parameter                          P_UART_CHECK       =  0             //0:无校验，1：奇校验 2：偶校验
)(
    input                              i_clk          ,
    input                              i_rst          ,
                             
    input                              i_uart_rx      ,
    output                             o_uart_tx      ,

    input  [P_UART_DATA_WIDTH - 1 : 0] i_usr_tx_data  ,
    input                              i_usr_tx_valid ,
    output                             o_usr_tx_ready ,

    output [P_UART_DATA_WIDTH - 1 : 0] o_usr_rx_data  ,
    output                             o_usr_rx_valid ,

    output                             o_user_clk     ,
    output                             o_user_rst      
    );

localparam  P_CLK_DIV_NUM = P_UART_CLK / P_UART_BAUDRATE ;//上电只计算一次，VIVADO不会生成除法器电路，因为俩参数都是固定值，提前就算好

wire                             w_baud_clk         ;
wire                             w_baud_rst         ;
wire                             w_uart_rx_clk      ;
wire [P_UART_DATA_WIDTH - 1 : 0] w_usr_rx_data      ;
wire                             w_usr_rx_valid     ;

reg                              r_uart_rx_rst      ;
reg  [2:0]                       r_uart_overvalue   ;
reg  [2:0]                       r_uart_overvalue_1d;
reg                              r_rx_overlock      ;
reg                              r_usr_rx_valid_1d  ;
reg  [P_UART_DATA_WIDTH - 1 : 0] r_usr_rx_data_1    ;
reg  [P_UART_DATA_WIDTH - 1 : 0] r_usr_rx_data_2    ;
reg                              r_usr_rx_valid_1   ;
reg                              r_usr_rx_valid_2   ;

assign  o_user_clk      = w_baud_clk        ;
assign  o_user_rst      = w_baud_rst        ;
assign  o_usr_rx_data   = r_usr_rx_data_2   ;
assign  o_usr_rx_valid  = r_usr_rx_valid_2  ;
 
CLK_DIV_module#(
    .P_CLK_DIV_CNT   (P_CLK_DIV_NUM) //MAX = 65535
)CLK_DIV_module_tx
(
    .i_clk           (i_clk),
    .i_rst           (i_rst),
    .o_clk_div       (w_baud_clk)
    );

CLK_DIV_module#(
    .P_CLK_DIV_CNT   (P_CLK_DIV_NUM) //MAX = 65535
)CLK_DIV_module_rx
(
    .i_clk           (i_clk),
    .i_rst           (r_uart_rx_rst),
    .o_clk_div       (w_uart_rx_clk)
    );

rst_gen_module#(
    .P_RST_CYCLE     (1)
)rst_gen_module_u
(
    .i_clk           (w_baud_clk),
    .o_rst           (w_baud_rst)
    );  

Uart_Tx#(
    .P_UART_CLK         (P_UART_CLK       ), //输入时钟频率
    .P_UART_BAUDRATE    (P_UART_BAUDRATE  ), //波特率
    .P_UART_DATA_WIDTH  (P_UART_DATA_WIDTH), //数据位宽
    .P_UART_STOP_WIDTH  (P_UART_STOP_WIDTH), //停止位位宽
    .P_UART_CHECK       (P_UART_CHECK     )
)Uart_Tx_u
(
    .i_clk              (w_baud_clk),
    .i_rst              (w_baud_rst),
    .o_uart_tx          (o_uart_tx     ),
    .i_usr_tx_data      (i_usr_tx_data ),
    .i_usr_tx_valid     (i_usr_tx_valid),
    .o_usr_tx_ready     (o_usr_tx_ready)
    );

Uart_Rx#(
    .P_UART_CLK         (P_UART_CLK       ), //输入时钟频率
    .P_UART_BAUDRATE    (P_UART_BAUDRATE  ), //波特率
    .P_UART_DATA_WIDTH  (P_UART_DATA_WIDTH), //数据位宽
    .P_UART_STOP_WIDTH  (P_UART_STOP_WIDTH), //停止位位宽
    .P_UART_CHECK       (P_UART_CHECK     ) 
)Uart_Rx_u
(
    .i_clk              (w_uart_rx_clk),
    .i_rst              (w_baud_rst),
    .i_uart_rx          (i_uart_rx     ),
    .o_usr_rx_data      (w_usr_rx_data ),
    .o_usr_rx_valid     (w_usr_rx_valid)
    );

always@(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_uart_rx_rst <= 1'd1;
    else if(!w_usr_rx_valid && r_usr_rx_valid_1d)
        r_uart_rx_rst <= 1'd1;
    else if(r_rx_overlock)
        r_uart_rx_rst <= 1'd0;
    else
        r_uart_rx_rst <= r_uart_rx_rst;
end

always@(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_uart_overvalue <= 'd0;
    else if(!r_rx_overlock)
        r_uart_overvalue <= {r_uart_overvalue[1:0] , i_uart_rx};
    else
        r_uart_overvalue <=  3'b111;
end

always@(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_uart_overvalue_1d <= 'd0;
    else
        r_uart_overvalue_1d <= r_uart_overvalue;
end

always@(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_rx_overlock <= 'd0;
    else if(!w_usr_rx_valid && r_usr_rx_valid_1d)
        r_rx_overlock <= 'd0;
    else if(r_uart_overvalue == 3'b000 && r_uart_overvalue_1d != 3'b000)
        r_rx_overlock <= 1'b1;
    else
        r_rx_overlock <= r_rx_overlock;
end

always@(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_usr_rx_valid_1d <= 'd0;
    else
        r_usr_rx_valid_1d <= w_usr_rx_valid;
end

always@(posedge w_baud_clk or posedge w_baud_rst)begin
    if(w_baud_rst)begin
        r_usr_rx_data_1  <= 'd0;
        r_usr_rx_data_2  <= 'd0;
        r_usr_rx_valid_1 <= 'd0;
        r_usr_rx_valid_2 <= 'd0;
    end
    else begin
        r_usr_rx_data_1  <= w_usr_rx_data;
        r_usr_rx_data_2  <= r_usr_rx_data_1;
        r_usr_rx_valid_1 <= w_usr_rx_valid;
        r_usr_rx_valid_2 <= r_usr_rx_valid_1;
    end
end

endmodule
