`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/10 15:29:00
// Design Name: 
// Module Name: BUS_MUX
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


module BUS_MUX(
    input           i_clk           ,
    input           i_rst           ,

    input   [7 :0]  i_cmd_data      ,
    input   [7 :0]  i_cmd_len       ,
    input           i_cmd_last      ,
    input           i_cmd_valid     ,  

    output  [7 :0]  o_adc_data      ,
    output  [7 :0]  o_adc_len       ,
    output          o_adc_last      ,
    output          o_adc_valid     ,

    output  [7 :0]  o_flash_data    ,
    output  [7 :0]  o_flash_len     ,
    output          o_flash_last    ,
    output          o_flash_valid   ,

    output  [7 :0]  o_ctrl_data     ,
    output  [7 :0]  o_ctrl_len      ,
    output          o_ctrl_last     ,
    output          o_ctrl_valid    
);
/******************************function***************************/

/******************************parameter**************************/

/******************************port*******************************/

/******************************machine****************************/

/******************************reg********************************/
reg  [7 :0]     ri_cmd_data     ;
reg  [7 :0]     ri_cmd_len      ;
reg             ri_cmd_last     ;
reg             ri_cmd_valid    ;
reg  [7 :0]     ri_cmd_data_1d  ;
reg  [7 :0]     ri_cmd_len_1d   ;
reg             ri_cmd_last_1d  ;
reg             ri_cmd_valid_1d ;
reg  [7 :0]     ri_cmd_data_2d  ;
reg  [7 :0]     ri_cmd_len_2d   ;
reg             ri_cmd_last_2d  ;
reg             ri_cmd_valid_2d ;
reg  [7 :0]     ro_adc_data     ;
reg  [7 :0]     ro_adc_len      ;
reg             ro_adc_last     ;
reg             ro_adc_valid    ;
reg  [7 :0]     ro_flash_data   ;
reg  [7 :0]     ro_flash_len    ;
reg             ro_flash_last   ;
reg             ro_flash_valid  ;
reg  [7 :0]     ro_ctrl_data    ;
reg  [7 :0]     ro_ctrl_len     ;
reg             ro_ctrl_last    ;
reg             ro_ctrl_valid   ;

reg  [7 :0]     r_cmd_cnt       ;
reg  [2 :0]     r_header        ;
/******************************wire*******************************/

/******************************component**************************/

/******************************assign*****************************/
assign  o_adc_data      =   ro_adc_data     ;
assign  o_adc_len       =   ro_adc_len      ;
assign  o_adc_last      =   ro_adc_last     ;
assign  o_adc_valid     =   ro_adc_valid    ;
assign  o_flash_data    =   ro_flash_data   ;
assign  o_flash_len     =   ro_flash_len    ;
assign  o_flash_last    =   ro_flash_last   ;
assign  o_flash_valid   =   ro_flash_valid  ;
assign  o_ctrl_data     =   ro_ctrl_data    ;
assign  o_ctrl_len      =   ro_ctrl_len     ;
assign  o_ctrl_last     =   ro_ctrl_last    ;
assign  o_ctrl_valid    =   ro_ctrl_valid   ;
/******************************always*****************************/
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst) begin
        ri_cmd_data     <= 'd0;
        ri_cmd_len      <= 'd0;
        ri_cmd_last     <= 'd0;
        ri_cmd_valid    <= 'd0;
        ri_cmd_data_1d  <= 'd0;
        ri_cmd_len_1d   <= 'd0;
        ri_cmd_last_1d  <= 'd0;
        ri_cmd_valid_1d <= 'd0;
        ri_cmd_data_2d  <= 'd0;
        ri_cmd_len_2d   <= 'd0;
        ri_cmd_last_2d  <= 'd0;
    end
    else begin
        ri_cmd_data     <= i_cmd_data       ;
        ri_cmd_len      <= i_cmd_len        ;
        ri_cmd_last     <= i_cmd_last       ;
        ri_cmd_valid    <= i_cmd_valid      ; 
        ri_cmd_data_1d  <= ri_cmd_data      ;
        ri_cmd_len_1d   <= ri_cmd_len       ;
        ri_cmd_last_1d  <= ri_cmd_last      ;
        ri_cmd_valid_1d <= ri_cmd_valid     ; 
        ri_cmd_data_2d  <= ri_cmd_data_1d   ;
        ri_cmd_len_2d   <= ri_cmd_len_1d    ;
        ri_cmd_last_2d  <= ri_cmd_last_1d   ;  
        ri_cmd_valid_2d <= ri_cmd_valid_1d  ; 
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_cmd_cnt <= 'd0;
    else if(ri_cmd_valid)
        r_cmd_cnt <= r_cmd_cnt + 'd1;
    else
        r_cmd_cnt <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        ro_adc_data  <= 'd0;
        ro_adc_len   <= 'd0;
        ro_adc_last  <= 'd0;
        ro_adc_valid <= 'd0;
    end
    else if(r_header == 1) begin
        ro_adc_data  <= ri_cmd_data_2d ;
        ro_adc_len   <= ri_cmd_len_2d  ;
        ro_adc_last  <= ri_cmd_last_2d ;
        ro_adc_valid <= ri_cmd_valid_2d;        
    end
    else begin
        ro_adc_data  <= 'd0;
        ro_adc_len   <= 'd0;
        ro_adc_last  <= 'd0;
        ro_adc_valid <= 'd0;        
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        ro_flash_data  <= 'd0;
        ro_flash_len   <= 'd0;
        ro_flash_last  <= 'd0;
        ro_flash_valid <= 'd0;
    end
    else if(r_header == 2) begin
        ro_flash_data  <= ri_cmd_data_2d ;
        ro_flash_len   <= ri_cmd_len_2d  ;
        ro_flash_last  <= ri_cmd_last_2d ;
        ro_flash_valid <= ri_cmd_valid_2d;        
    end
    else begin
        ro_flash_data  <= 'd0;
        ro_flash_len   <= 'd0;
        ro_flash_last  <= 'd0;
        ro_flash_valid <= 'd0;
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        ro_ctrl_data  <= 'd0;
        ro_ctrl_len   <= 'd0;
        ro_ctrl_last  <= 'd0;
        ro_ctrl_valid <= 'd0;
    end
    else if(r_header == 3) begin
        ro_ctrl_data  <= ri_cmd_data_2d ;
        ro_ctrl_len   <= ri_cmd_len_2d  ;
        ro_ctrl_last  <= ri_cmd_last_2d ;
        ro_ctrl_valid <= ri_cmd_valid_2d;        
    end
    else begin
        ro_ctrl_data  <= 'd0;
        ro_ctrl_len   <= 'd0;
        ro_ctrl_last  <= 'd0;
        ro_ctrl_valid <= 'd0;        
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_header <= 'd0;
    else if(ro_ctrl_last || ro_flash_last || ro_adc_last)
        r_header <= 'd0;
    else if(r_cmd_cnt == 1 && ri_cmd_data >= 1 && ri_cmd_data <= 5)
        r_header <= 'd1;
    else if(r_cmd_cnt == 1 && ri_cmd_data >= 6 && ri_cmd_data <= 8)
        r_header <= 'd2;
    else if(r_cmd_cnt == 1 && ri_cmd_data > 8)
        r_header <= 'd3;        
    else
        r_header <= r_header;
end


endmodule
