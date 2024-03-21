`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/10 15:29:00
// Design Name: 
// Module Name: Data_Mclk_buf
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


module Data_Mclk_buf(
    input           i_pre_clk       ,
    input           i_pre_rst       ,
    input   [7 :0]  i_pre_data      ,
    input   [7 :0]  i_pre_len       ,
    input           i_pre_last      ,
    input           i_pre_valid     ,

    input           i_post_clk      ,
    input           i_post_rst      ,
    output  [7 :0]  o_post_data     ,
    output  [7 :0]  o_post_len      ,
    output          o_post_last     ,
    output          o_post_valid          
);
/******************************function***************************/

/******************************parameter**************************/

/******************************port*******************************/

/******************************machine****************************/

/******************************reg********************************/
reg  [7 :0]     ri_pre_data         ;
reg  [7 :0]     ri_pre_len          ;
reg             ri_pre_last         ;
reg             ri_pre_valid        ;
reg  [7 :0]     ro_post_data        ;
reg  [7 :0]     ro_post_len         ;
reg             ro_post_last        ;
reg             ro_post_valid       ;

reg             r_fifo_data_rden    ;
reg             r_fifo_len_rden     ;
reg             r_fifo_data_rden_1d ;
reg             r_fifo_len_rden_1d  ;
reg             r_run               ;
reg  [7 :0]     r_post_cnt          ;

/******************************wire*******************************/
wire [7 :0]     w_fifo_data_rdata   ;
wire            w_fifo_data_full    ;
wire            w_fifo_data_empty   ;
wire [7 :0]     w_fifo_len_rdata    ;
wire            w_fifo_len_full     ;
wire            w_fifo_len_empty    ;

/******************************component**************************/
//data
async_FIFO async_FIFO_u0 (
  .wr_clk       (i_pre_clk          ),  // input wire wr_clk
  .wr_rst       (i_pre_rst          ),  // input wire wr_rst
  .rd_clk       (i_post_clk         ),  // input wire rd_clk
  .rd_rst       (i_post_rst         ),  // input wire rd_rst
  .din          (ri_pre_data        ),  // input wire [7 : 0] din
  .wr_en        (ri_pre_valid       ),  // input wire wr_en
  .rd_en        (r_fifo_data_rden   ),  // input wire rd_en
  .dout         (w_fifo_data_rdata  ),  // output wire [7 : 0] dout
  .full         (w_fifo_data_full   ),  // output wire full
  .empty        (w_fifo_data_empty  )   // output wire empty
);
//data length
async_FIFO async_FIFO_u1 (
  .wr_clk       (i_pre_clk          ),  // input wire wr_clk
  .wr_rst       (i_pre_rst          ),  // input wire wr_rst
  .rd_clk       (i_post_clk         ),  // input wire rd_clk
  .rd_rst       (i_post_rst         ),  // input wire rd_rst
  .din          (ri_pre_len         ),  // input wire [7 : 0] din
  .wr_en        (ri_pre_last        ),  // input wire wr_en
  .rd_en        (r_fifo_len_rden    ),  // input wire rd_en
  .dout         (w_fifo_len_rdata   ),  // output wire [7 : 0] dout
  .full         (w_fifo_len_full    ),  // output wire full
  .empty        (w_fifo_len_empty   )   // output wire empty
);
/******************************assign*****************************/
assign  o_post_data     =   ro_post_data    ;
assign  o_post_len      =   ro_post_len     ;
assign  o_post_last     =   ro_post_last    ;
assign  o_post_valid    =   ro_post_valid   ;
/******************************always*****************************/
always @(posedge i_pre_clk or posedge i_pre_rst)begin
    if(i_pre_rst)begin
        ri_pre_data  <= 'd0;
        ri_pre_len   <= 'd0;
        ri_pre_last  <= 'd0;
        ri_pre_valid <= 'd0;
    end
    else begin
        ri_pre_data  <= i_pre_data ; 
        ri_pre_len   <= i_pre_len  ;
        ri_pre_last  <= i_pre_last ; 
        ri_pre_valid <= i_pre_valid; 
    end
end
//因为1个数据包只对应一个len，所以last要等多byte数据包传输完成才能再使能FIFO取下一个len数据
always @(posedge i_post_clk or posedge i_post_rst)begin
    if(i_post_rst)
        r_run <= 'd0;
    else if(ro_post_last)
        r_run <= 'd0;
    else if(r_fifo_len_rden)
        r_run <= 'd1;
    else
        r_run <= r_run;
end
// fifo len
always @(posedge i_post_clk or posedge i_post_rst)begin
    if(i_post_rst)
        r_fifo_len_rden <= 'd0;
    else if(r_fifo_len_rden)
        r_fifo_len_rden <= 'd0;
    else if(!w_fifo_len_empty && !r_run)
        r_fifo_len_rden <= 'd1;
    else
        r_fifo_len_rden <= 'd0;
end

always @(posedge i_post_clk or posedge i_post_rst)begin
    if(i_post_rst)
        r_fifo_len_rden_1d <= 'd0;
    else
        r_fifo_len_rden_1d <= r_fifo_len_rden;
end

always @(posedge i_post_clk or posedge i_post_rst)begin
    if(i_post_rst)
        ro_post_len <= 'd0;
    else if(r_fifo_len_rden_1d)
        ro_post_len <= w_fifo_len_rdata;
    else
        ro_post_len <= ro_post_len;
end 
//fifo data
always @(posedge i_post_clk or posedge i_post_rst)begin
    if(i_post_rst)
        r_fifo_data_rden <= 'd0;
    else if(r_post_cnt == ro_post_len - 1)
        r_fifo_data_rden <= 'd0;
    else if(r_fifo_len_rden_1d)
        r_fifo_data_rden <= 'd1;
    else
        r_fifo_data_rden <= r_fifo_data_rden;
end

always @(posedge i_post_clk or posedge i_post_rst)begin
    if(i_post_rst)
        r_fifo_data_rden_1d <= 'd0;
    else
        r_fifo_data_rden_1d <= r_fifo_data_rden;
end

always @(posedge i_post_clk or posedge i_post_rst)begin
    if(i_post_rst)
        ro_post_valid <= 'd0;
    else if(ro_post_last)
        ro_post_valid <= 'd0;
    else if(r_fifo_data_rden_1d)
        ro_post_valid <= 'd1;
    else
        ro_post_valid <= ro_post_valid;
end

always @(posedge i_post_clk or posedge i_post_rst)begin
    if(i_post_rst)
        ro_post_data <= 'd0;
    else if(r_fifo_data_rden_1d)
        ro_post_data <= w_fifo_data_rdata;
    else
        ro_post_data <= 'd0;
end

always @(posedge i_post_clk or posedge i_post_rst)begin
    if(i_post_rst)
        r_post_cnt <= 'd0;
    else if(r_post_cnt == ro_post_len - 1)
        r_post_cnt <= 'd0;
    else if(r_fifo_data_rden)
        r_post_cnt <= r_post_cnt + 1;
    else
        r_post_cnt <= r_post_cnt;
end

always @(posedge i_post_clk or posedge i_post_rst)begin
    if(i_post_rst)
        ro_post_last <= 'd0;
    else if(!r_fifo_data_rden && r_fifo_data_rden_1d)//FIFO读延时为1周期 无需减1
        ro_post_last <= 'd1;
    else
        ro_post_last <= 'd0;
end

// always @(posedge i_post_clk or posedge i_post_rst)begin
//     if(i_post_rst)

//     else if()

//     else if()

//     else
    
// end
// always @(posedge i_post_clk or posedge i_post_rst)begin
//     if(i_post_rst)

//     else if()

//     else if()

//     else
    
// end
endmodule
