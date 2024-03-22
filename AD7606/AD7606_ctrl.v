`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/10 15:29:00
// Design Name: 
// Module Name: AD7606_ctrl
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


module AD7606_ctrl(
    input           i_clk               ,
    input           i_rst               ,

    input  [7 :0]   i_cmd_adc_data      ,
    input  [7 :0]   i_cmd_adc_len       ,
    input           i_cmd_adc_last      ,
    input           i_cmd_adc_valid     ,

    input           i_system_run        ,
    input  [7 :0]   i_adc_chnnel        ,
    input  [23:0]   i_adc_speed         ,
    input           i_adc_start         ,
    input           i_adc_trig          ,

    output [7 :0]   o_cap_chnnel_num    ,//采样通道数
    output          o_cap_enable        ,//使能
    output [23:0]   o_cap_speed         ,//采样速率
    output          o_cap_trigger       ,//触发方式
    output          o_cap_seek           //查询采样结果

);
/******************************function***************************/

/******************************parameter**************************/

/******************************port*******************************/

/******************************machine****************************/

/******************************reg********************************/
reg  [7 :0]         ri_cmd_adc_data     ;
reg  [7 :0]         ri_cmd_adc_len      ;
reg                 ri_cmd_adc_last     ;
reg                 ri_cmd_adc_valid    ;
reg  [7 :0]         ro_cap_chnnel_num   ;
reg                 ro_cap_enable       ;
reg  [23:0]         ro_cap_speed        ;
reg                 ro_cap_trigger      ;
reg                 ro_cap_seek         ;
reg  [7 :0]         r_cnt               ;
reg  [7 :0]         r_ctrl_type         ;
reg  [7 :0]         r_payload_len       ;

reg                 ri_system_run       ;
reg                 ri_system_run_1d    ;
/******************************wire*******************************/
wire                w_system_run_pos    ;
/******************************component**************************/
assign  w_system_run_pos = ri_system_run & !ri_system_run_1d;
/******************************assign*****************************/
assign  o_cap_chnnel_num    =   ro_cap_chnnel_num   ;
assign  o_cap_enable        =   ro_cap_enable       ;
assign  o_cap_speed         =   ro_cap_speed        ;
assign  o_cap_trigger       =   ro_cap_trigger      ;
assign  o_cap_seek          =   ro_cap_seek         ;
/******************************always*****************************/
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        ri_cmd_adc_data  <= 'd0;
        ri_cmd_adc_len   <= 'd0;
        ri_cmd_adc_last  <= 'd0;
        ri_cmd_adc_valid <= 'd0;        
    end
    else begin
        ri_cmd_adc_data  <= i_cmd_adc_data ;
        ri_cmd_adc_len   <= i_cmd_adc_len  ;
        ri_cmd_adc_last  <= i_cmd_adc_last ;
        ri_cmd_adc_valid <= i_cmd_adc_valid;      
    end
end
//系统运行信号
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        ri_system_run    <= 'd0;
        ri_system_run_1d <= 'd0;    
    end
    else begin
        ri_system_run    <= i_system_run    ;
        ri_system_run_1d <= ri_system_run   ;   
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_cnt <= 'd0;
    else if(ri_cmd_adc_valid)
        r_cnt <= r_cnt + 1;
    else
        r_cnt <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_ctrl_type <= 'd0;
    else if(r_cnt == 1 && ri_cmd_adc_valid)
        r_ctrl_type <= ri_cmd_adc_data;
    else
        r_ctrl_type <= r_ctrl_type;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_payload_len <= 'd0;
    else if(r_cnt == 1 && ri_cmd_adc_valid)
        r_payload_len <= i_cmd_adc_data;
    else
        r_payload_len <= r_payload_len;
end

always @(posedge i_clk or posedge i_rst)begin 
    if(i_rst)
        ro_cap_chnnel_num <= 'd0;
    else if(w_system_run_pos)
        ro_cap_chnnel_num <= i_adc_chnnel;
    else if(r_ctrl_type == 1 && r_cnt == 2 + r_payload_len && ri_cmd_adc_valid)
        ro_cap_chnnel_num <= ri_cmd_adc_data;
    else
        ro_cap_chnnel_num <= ro_cap_chnnel_num;
end
    
always @(posedge i_clk or posedge i_rst)begin 
    if(i_rst)
        ro_cap_speed <= 'd0;
    else if(w_system_run_pos)
        ro_cap_speed <= i_adc_speed;
    else if(r_ctrl_type == 2 && r_cnt > 2 && r_cnt <= 2 + r_payload_len && ri_cmd_adc_valid)
        ro_cap_speed <= {ro_cap_speed[15:0],ri_cmd_adc_data};
    else
        ro_cap_speed <= ro_cap_speed;
end

always @(posedge i_clk or posedge i_rst)begin 
    if(i_rst)
        ro_cap_enable <= 'd0;
    else if(w_system_run_pos)
        ro_cap_enable <= i_adc_start;
    else if(r_ctrl_type == 3 && r_cnt == 2 + r_payload_len && ri_cmd_adc_valid)
        ro_cap_enable <= ri_cmd_adc_data;
    else
        ro_cap_enable <= ro_cap_enable;
end

always @(posedge i_clk or posedge i_rst)begin 
    if(i_rst)
        ro_cap_trigger <= 'd0;
    else if(w_system_run_pos)
        ro_cap_trigger <= i_adc_trig;
    else if(r_ctrl_type == 4 && r_cnt == 2 + r_payload_len && ri_cmd_adc_valid)
        ro_cap_trigger <= ri_cmd_adc_data;
    else
        ro_cap_trigger <= ro_cap_trigger;
end
//主机发送一次查询请求，才查询一次，该信号为脉冲信号，自清除
always @(posedge i_clk or posedge i_rst)begin 
    if(i_rst)
        ro_cap_seek <= 'd0;
    else if(ro_cap_seek)
        ro_cap_seek <= 'd0;
    else if(r_ctrl_type == 5 && r_cnt == 2 + r_payload_len && ri_cmd_adc_valid)
        ro_cap_seek <= 'd1;
    else
        ro_cap_seek <= 'd0;
end

endmodule
