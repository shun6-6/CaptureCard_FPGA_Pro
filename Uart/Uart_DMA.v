`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/31 21:39:42
// Design Name: 
// Module Name: Uart_DMA
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


module Uart_DMA(
    input           i_clk               ,
    input           i_rst               ,

    output [7 : 0]  o_usr_tx_data       ,
    output          o_usr_tx_valid      ,
    input           i_usr_tx_ready      ,

    input  [7 : 0]  i_usr_rx_data       ,
    input           i_usr_rx_valid      ,
    //dma send data
    input  [7 : 0]  i_uart_DMA_tdata    ,
    input           i_uart_DMA_tlast    ,
    input           i_uart_DMA_tvalid   , 
    output          o_uart_DMA_tready   , 
    //dma recieve data
    output [7 : 0]  o_uart_DMA_rlen     ,
    output [7 : 0]  o_uart_DMA_rdata    ,
    output          o_uart_DMA_rlast    ,
    output          o_uart_DMA_rvalid    
    );
/******************************function***************************/

/******************************parameter**************************/

/******************************port*******************************/

/******************************machine****************************/

/******************************reg********************************/
reg  [7 :0]     ro_usr_tx_data      ;
reg             ro_usr_tx_valid     ;
reg             ri_usr_tx_ready     ;
reg  [7 :0]     ri_usr_rx_data      ;
reg             ri_usr_rx_valid     ;
reg  [7 :0]     ro_uart_DMA_rdata   ;
reg             ro_uart_DMA_rlast   ;
reg             ro_uart_DMA_rvalid  ;
reg             ro_uart_DMA_tready  ;
reg  [7 :0]     ro_uart_DMA_rlen    ;

reg  [7 :0]     r_recv_cnt          ; 
reg  [7 :0]     r_recv_len          ;
reg             r_recv_end          ;
reg  [7 :0]     r_recv_end_len      ;
reg             r_send_trigger      ;

reg             r_rx_fifo_rden      ;
reg             r_rx_fifo_rden_1d   ;
reg  [7 :0]     r_rx_fifo_send_cnt  ;

// reg             r_send_run          ;
// reg  [7 :0]     r_send_len          ;
// reg  [7 :0]     r_send_cnt          ;
reg  [7 :0]     r_uart_send_cnt     ;
// reg             r_uart_tx_active    ;

reg             r_tx_fifo_rden      ;
reg             r_tx_fifo_rden_1d   ;
/******************************wire*******************************/
wire [7 :0]     w_rx_fifo_rdata     ;
wire            w_rx_fifo_full      ;
wire            w_rx_fifo_empty     ;
wire            w_send_active       ;

wire [7 :0]     w_tx_fifo_rdata     ;
wire            w_tx_fifo_full      ;
wire            w_tx_fifo_empty     ;
wire            w_uart_tx_active    ;
/******************************component**************************/
FIFO_8x1024 UART_DMA_FIFO_rx (
  .clk          (i_clk              ), 
  .srst         (i_rst              ), 
  .din          (i_usr_rx_data      ), 
  .wr_en        (i_usr_rx_valid     ), 
  .rd_en        (r_rx_fifo_rden     ), 
  .dout         (w_rx_fifo_rdata    ), 
  .full         (w_rx_fifo_full     ), 
  .empty        (w_rx_fifo_empty    ), 
  .wr_rst_busy  (), 
  .rd_rst_busy  ()  
);

FIFO_8x1024 UART_DMA_FIFO_tx (
  .clk          (i_clk              ), 
  .srst         (i_rst              ), 
  .din          (i_uart_DMA_tdata   ), 
  .wr_en        (w_send_active      ), 
  .rd_en        (r_tx_fifo_rden     ), 
  .dout         (w_tx_fifo_rdata    ), 
  .full         (w_tx_fifo_full     ), 
  .empty        (w_tx_fifo_empty    ), 
  .wr_rst_busy  (), 
  .rd_rst_busy  ()  
);
/******************************assign*****************************/
assign  o_usr_tx_data       =   ro_usr_tx_data      ;
assign  o_usr_tx_valid      =   ro_usr_tx_valid     ;
assign  o_uart_DMA_rdata    =   ro_uart_DMA_rdata   ;
assign  o_uart_DMA_rlast    =   ro_uart_DMA_rlast   ;
assign  o_uart_DMA_rvalid   =   ro_uart_DMA_rvalid  ;
assign  o_uart_DMA_rlen     =   ro_uart_DMA_rlen    ;
assign  o_uart_DMA_tready   =   !w_tx_fifo_full     ;
assign  w_send_active       =   i_uart_DMA_tvalid & o_uart_DMA_tready;
assign  w_uart_tx_active    =   o_usr_tx_valid & i_usr_tx_ready;
/******************************always*****************************/
/*--------recieve data--------*/
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        ri_usr_rx_data  <= 'd0;
        ri_usr_rx_valid <= 'd0;
    end
    else begin
        ri_usr_rx_data  <= i_usr_rx_data ;
        ri_usr_rx_valid <= i_usr_rx_valid;
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_recv_cnt <= 'd0;
    else if(r_recv_cnt == 3 + r_recv_len - 1 && ri_usr_rx_valid)
        r_recv_cnt <= 'd0;
    else if(ri_usr_rx_valid && ri_usr_rx_data == 8'h55)
        r_recv_cnt <= r_recv_cnt + 1;
    else if(r_recv_cnt > 0 && ri_usr_rx_valid)
        r_recv_cnt <= r_recv_cnt + 1;
    else
        r_recv_cnt <= r_recv_cnt;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_recv_len <= 8'd255;
    else if(r_recv_cnt == 3 + r_recv_len - 1 && ri_usr_rx_valid)
        r_recv_len <= 8'd255;
    else if(ri_usr_rx_valid && r_recv_cnt == 2)
        r_recv_len <= ri_usr_rx_data;
    else
        r_recv_len <= r_recv_len;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_recv_end <= 'd0;
    else if(r_send_trigger)
        r_recv_end <= 'd0;
    else if(r_recv_cnt == 3 + r_recv_len - 1 && ri_usr_rx_valid)
        r_recv_end <= 'd1;
    else
        r_recv_end <= r_recv_end;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_recv_end_len <= 'd0;
    else if(r_recv_cnt == 3 + r_recv_len - 1 && ri_usr_rx_valid)
        r_recv_end_len <= r_recv_len;
    else
        r_recv_end_len <= r_recv_end_len;
end
//如果在第一个数据还没有传输完情况下又来了俩个以上的数据，此时会有bug应该
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_send_trigger <= 'd0;
    else if(r_send_trigger)
        r_send_trigger <= 'd0;
    // else if(!r_rx_fifo_rden && r_recv_end)
    else if(!ro_uart_DMA_rvalid && r_recv_end)
        r_send_trigger <= 'd1;
    else
        r_send_trigger <= r_send_trigger;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_rx_fifo_rden <= 'd0;
    else if(r_rx_fifo_send_cnt == 3 + r_recv_end_len - 1)
        r_rx_fifo_rden <= 'd0;
    else if(r_send_trigger)
        r_rx_fifo_rden <= 'd1;
    else
        r_rx_fifo_rden <= r_rx_fifo_rden;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_rx_fifo_rden_1d <= 'd0;
    else
        r_rx_fifo_rden_1d <= r_rx_fifo_rden;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_rx_fifo_send_cnt <= 'd0;
    else if(r_rx_fifo_send_cnt == 3 + r_recv_end_len - 1)
        r_rx_fifo_send_cnt <= 'd0;
    else if(r_rx_fifo_rden)
        r_rx_fifo_send_cnt <= r_rx_fifo_send_cnt + 'd1;
    else
        r_rx_fifo_send_cnt <= r_rx_fifo_send_cnt;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_uart_DMA_rdata <= 'd0;
    else if(r_rx_fifo_rden_1d)
        ro_uart_DMA_rdata <= w_rx_fifo_rdata;
    else
        ro_uart_DMA_rdata <= ro_uart_DMA_rdata;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_uart_DMA_rvalid <= 'd0;
    else if(r_rx_fifo_rden_1d)
        ro_uart_DMA_rvalid <= 'd1;
    else
        ro_uart_DMA_rvalid <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_uart_DMA_rlast <= 'd0;
    //else if(r_rx_fifo_send_cnt == r_recv_end_len - 2)
    else if(!r_rx_fifo_rden && r_rx_fifo_rden_1d)
        ro_uart_DMA_rlast <= 'd1;
    else
        ro_uart_DMA_rlast <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_uart_DMA_rlen <= 'd0;
    else if(r_rx_fifo_rden_1d)
        ro_uart_DMA_rlen <= 3 + r_recv_end_len;
    else
        ro_uart_DMA_rlen <= 'd0;
end

/*--------send data--------*/
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_tx_fifo_rden <= 'd0;
    else if(r_tx_fifo_rden)
        r_tx_fifo_rden <= 'd0;
    else if(i_usr_tx_ready && !w_tx_fifo_empty && r_uart_send_cnt == 0)
        r_tx_fifo_rden <= 'd1;
    else
        r_tx_fifo_rden <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_tx_fifo_rden_1d <= 'd0;
    else
        r_tx_fifo_rden_1d <= r_tx_fifo_rden;
end
//数据真正输出会有3周期延迟，需要一个计数器来是的FIFO使能信号正常工作
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_uart_send_cnt <= 'd0;
    else if(r_uart_send_cnt == 3)
        r_uart_send_cnt <= 'd0;
    else if(r_tx_fifo_rden || r_uart_send_cnt > 0)
        r_uart_send_cnt <= r_uart_send_cnt + 'd1;
    else
        r_uart_send_cnt <= r_uart_send_cnt;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_usr_tx_valid <= 'd0;
    else if(r_tx_fifo_rden_1d)
        ro_usr_tx_valid <= 'd1;
    else
        ro_usr_tx_valid <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_usr_tx_data <= 'd0;
    else if(r_tx_fifo_rden_1d)
        ro_usr_tx_data <= w_tx_fifo_rdata;
    else
        ro_usr_tx_data <= 'd0;
end


endmodule
