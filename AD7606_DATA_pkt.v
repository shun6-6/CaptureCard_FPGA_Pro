`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/10 15:29:00
// Design Name: 
// Module Name: AD7606_DATA_pkt
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


module AD7606_DATA_pkt(
    input               i_clk               ,
    input               i_rst               ,

    input  [15:0]       i_user_data_1       ,
    input               i_user_valid_1      ,
    input  [15:0]       i_user_data_2       ,
    input               i_user_valid_2      ,
    input  [15:0]       i_user_data_3       ,
    input               i_user_valid_3      ,
    input  [15:0]       i_user_data_4       ,
    input               i_user_valid_4      ,
    input  [15:0]       i_user_data_5       ,
    input               i_user_valid_5      ,
    input  [15:0]       i_user_data_6       ,
    input               i_user_valid_6      ,
    input  [15:0]       i_user_data_7       ,
    input               i_user_valid_7      ,
    input  [15:0]       i_user_data_8       ,
    input               i_user_valid_8      ,

    input  [7 :0]       i_cap_chnnel_num    ,
    input               i_cap_seek          ,

    output [7 :0]       o_adc_data          ,
    output [7 :0]       o_adc_len           ,
    output              o_adc_last          ,
    output              o_adc_valid          
);
/******************************function***************************/

/******************************parameter**************************/

/******************************port*******************************/

/******************************machine****************************/

/******************************reg********************************/
reg  [15:0]         ri_user_data_1      ;
reg                 ri_user_valid_1     ;
reg  [15:0]         ri_user_data_2      ;
reg                 ri_user_valid_2     ;
reg  [15:0]         ri_user_data_3      ;
reg                 ri_user_valid_3     ;
reg  [15:0]         ri_user_data_4      ;
reg                 ri_user_valid_4     ;
reg  [15:0]         ri_user_data_5      ;
reg                 ri_user_valid_5     ;
reg  [15:0]         ri_user_data_6      ;
reg                 ri_user_valid_6     ;
reg  [15:0]         ri_user_data_7      ;
reg                 ri_user_valid_7     ;
reg  [15:0]         ri_user_data_8      ;
reg                 ri_user_valid_8     ;
reg  [7 :0]         ri_cap_chnnel_num   ;
reg                 ri_cap_seek         ;
reg  [7 :0]         ro_adc_data         ;
reg  [7 :0]         ro_adc_len          ;
reg                 ro_adc_last         ;
reg                 ro_adc_valid        ;

reg  [7 :0]         r_cnt               ;
reg  [7 :0]         r_ad_pre_data       ;
reg                 r_ad_pre_valid      ;
reg                 r_valid_end         ;
reg                 r_fifo_rden         ;
reg                 r_fifo_rden_1d      ;
reg  [7 :0]         r_send_cnt          ;
/******************************wire*******************************/
wire [7 :0]         w_fifo_rd_data      ;
wire                w_fifo_full         ;
wire                w_fifo_empty        ;
/******************************component**************************/
//因为数据组包的时候前三个byte无需等待ADC的返回数据，后面的需要等待。所以数据不连续，需要FIFO先存后读
FIFO_8x1024 AD7606_data_pkt(
  .clk          (i_clk              ), 
  .srst         (i_rst              ), 
  .din          (r_ad_pre_data      ), 
  .wr_en        (r_ad_pre_valid     ), 
  .rd_en        (r_fifo_rden        ), 
  .dout         (w_fifo_rd_data     ), 
  .full         (), 
  .empty        (w_fifo_empty       ), 
  .wr_rst_busy  (), 
  .rd_rst_busy  ()  
);
/******************************assign*****************************/
assign  o_adc_data  =   ro_adc_data     ;
assign  o_adc_len   =   ro_adc_len      ;
assign  o_adc_last  =   ro_adc_last     ;
assign  o_adc_valid =   ro_adc_valid    ;
/******************************always*****************************/
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        ri_user_data_1    <= 'd0;
        ri_user_valid_1   <= 'd0;
        ri_user_data_2    <= 'd0;
        ri_user_valid_2   <= 'd0;
        ri_user_data_3    <= 'd0;
        ri_user_valid_3   <= 'd0;
        ri_user_data_4    <= 'd0;
        ri_user_valid_4   <= 'd0;
        ri_user_data_5    <= 'd0;
        ri_user_valid_5   <= 'd0;
        ri_user_data_6    <= 'd0;
        ri_user_valid_6   <= 'd0;
        ri_user_data_7    <= 'd0;
        ri_user_valid_7   <= 'd0;
        ri_user_data_8    <= 'd0;
        ri_user_valid_8   <= 'd0;
        ri_cap_chnnel_num <= 'd0;
        ri_cap_seek       <= 'd0;           
    end
    else begin
        ri_user_data_1    <= i_user_data_1   ;
        ri_user_valid_1   <= i_user_valid_1  ;
        ri_user_data_2    <= i_user_data_2   ;
        ri_user_valid_2   <= i_user_valid_2  ;
        ri_user_data_3    <= i_user_data_3   ;
        ri_user_valid_3   <= i_user_valid_3  ;
        ri_user_data_4    <= i_user_data_4   ;
        ri_user_valid_4   <= i_user_valid_4  ;
        ri_user_data_5    <= i_user_data_5   ;
        ri_user_valid_5   <= i_user_valid_5  ;
        ri_user_data_6    <= i_user_data_6   ;
        ri_user_valid_6   <= i_user_valid_6  ;
        ri_user_data_7    <= i_user_data_7   ;
        ri_user_valid_7   <= i_user_valid_7  ;
        ri_user_data_8    <= i_user_data_8   ;
        ri_user_valid_8   <= i_user_valid_8  ;
        ri_cap_chnnel_num <= i_cap_chnnel_num;
        ri_cap_seek       <= i_cap_seek      ;         
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_ad_pre_data <= 'd0;
    else begin
        case (r_cnt)
            0    : r_ad_pre_data <= 8'h55;                                                  //前导码
            1    : r_ad_pre_data <= 'd5;                                                    //指令编号
            2    : r_ad_pre_data <= ri_cap_chnnel_num+ri_cap_chnnel_num+ri_cap_chnnel_num;  //负载长度
            3    : r_ad_pre_data <=              1      ;
            4    : r_ad_pre_data <= ri_user_data_1[15:8];
            5    : r_ad_pre_data <= ri_user_data_1[7 :0];
            6    : r_ad_pre_data <=              2      ;
            7    : r_ad_pre_data <= ri_user_data_2[15:8];
            8    : r_ad_pre_data <= ri_user_data_2[7 :0];
            9    : r_ad_pre_data <=              3      ;
            10   : r_ad_pre_data <= ri_user_data_3[15:8];
            11   : r_ad_pre_data <= ri_user_data_3[7 :0];
            12   : r_ad_pre_data <=              4      ;
            13   : r_ad_pre_data <= ri_user_data_4[15:8];
            14   : r_ad_pre_data <= ri_user_data_4[7 :0];
            15   : r_ad_pre_data <=              5      ;
            16   : r_ad_pre_data <= ri_user_data_5[15:8];
            17   : r_ad_pre_data <= ri_user_data_5[7 :0];
            18   : r_ad_pre_data <=              6      ;
            19   : r_ad_pre_data <= ri_user_data_6[15:8];
            20   : r_ad_pre_data <= ri_user_data_6[7 :0];
            21   : r_ad_pre_data <=              7      ;
            22   : r_ad_pre_data <= ri_user_data_7[15:8];
            23   : r_ad_pre_data <= ri_user_data_7[7 :0];
            24   : r_ad_pre_data <=              8      ;
            25   : r_ad_pre_data <= ri_user_data_8[15:8];
            26   : r_ad_pre_data <= ri_user_data_8[7 :0];
        endcase
    end
end
//seek查询信号到来开始计数，计算到目标通道数对应的数值后清0，期间需要等待第一个通道有效信号。
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_cnt <= 'd0;
    else if(r_cnt == 2 + ri_cap_chnnel_num+ri_cap_chnnel_num+ri_cap_chnnel_num)
        r_cnt <= 'd0;
    else if(r_cnt > 4)
        r_cnt <= r_cnt + 1;
    else if(r_cnt == 4 && ri_user_valid_1)
        r_cnt <= r_cnt + 1;
    else if(ri_cap_seek || r_cnt < 4)
        r_cnt <= r_cnt + 1;
    else
        r_cnt <= r_cnt;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_ad_pre_valid <= 'd0;
    else if((r_cnt == 4 && !ri_user_valid_1) || r_valid_end)
        r_ad_pre_valid <= 'd0;
    else if(ri_cap_seek || ri_user_valid_1)
        r_ad_pre_valid <= 'd1;
    else
        r_ad_pre_valid <= r_ad_pre_valid;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_valid_end <= 'd0;
    else if(r_cnt == 2 + ri_cap_chnnel_num+ri_cap_chnnel_num+ri_cap_chnnel_num)
        r_valid_end <= 'd1;
    else
        r_valid_end <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_fifo_rden <= 'd0;
    else if(w_fifo_empty)
        r_fifo_rden <= 'd0;
    else if(r_valid_end)
        r_fifo_rden <= 'd1;
    else
        r_fifo_rden <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_fifo_rden_1d <= 'd0;
    else
        r_fifo_rden_1d <= r_fifo_rden;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        ro_adc_data  <= 'd0;
        ro_adc_len   <= 'd0;
        ro_adc_valid <= 'd0;        
    end
    else if(r_fifo_rden_1d)begin
        ro_adc_data  <= w_fifo_rd_data;
        ro_adc_len   <= 2 + ri_cap_chnnel_num+ri_cap_chnnel_num+ri_cap_chnnel_num + 1;
        ro_adc_valid <= 'd1;         
    end
    else begin
        ro_adc_data  <= 'd0;
        ro_adc_len   <= 'd0;
        ro_adc_valid <= 'd0;         
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_adc_last <= 'd0;
    else if(r_send_cnt == 2 + ri_cap_chnnel_num+ri_cap_chnnel_num+ri_cap_chnnel_num + 1 - 2)
        ro_adc_last <= 1;
    else
        ro_adc_last <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_send_cnt <= 'd0;
    else if(r_send_cnt == 2 + ri_cap_chnnel_num+ri_cap_chnnel_num+ri_cap_chnnel_num + 1 - 2)
        r_send_cnt <= 'd0;
    else if(ro_adc_valid)
        r_send_cnt <= r_send_cnt + 'd1;
    else
        r_send_cnt <= r_send_cnt;
end

endmodule
