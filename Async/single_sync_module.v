`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/28 19:29:10
// Design Name: 
// Module Name: single_sync_module
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


module single_sync_module#(
    parameter   P_CLK_FRQ_A = 50_000_000,
    parameter   P_CLK_FRQ_B = 50_000_000
)(
    input       i_clk_a     ,
    input       i_rst_a     ,
    input       i_single_a  ,

    input       i_clk_b     ,
    input       i_rst_b     ,
    output      o_single_b  
    );
localparam  P_CNT_END_B = P_CLK_FRQ_A >= P_CLK_FRQ_B ? 2 : (P_CLK_FRQ_B/P_CLK_FRQ_A) + 1;
/*--------clk_a--------*/
reg         r_trans_a       ;
reg         r_ack_a1        ;
reg         r_ack_a2        ;
/*--------clk_b--------*/
reg         r_single_b      ;
reg         r_single_b1     ;
reg         r_single_b2     ;
reg         r_ack_b         ;  
reg  [7:0]  r_cnt_b         ;

wire        w_single_b_pos  ;

assign      o_single_b      = r_single_b                ;
assign      w_single_b_pos  = r_single_b1 & !r_single_b2;

/*--------clk_a--------*/
always @(posedge i_clk_a or posedge i_rst_a) begin
    if(i_rst_a)
        r_trans_a <= 'd0;
    else if(r_ack_a2)
        r_trans_a <= 'd0;
    else if(i_single_a)
        r_trans_a <= 1;
    else
        r_trans_a <= r_trans_a;
end

always @(posedge i_clk_a or posedge i_rst_a) begin
    if(i_rst_a)begin
        r_ack_a1 <= 'd0;
        r_ack_a2 <= 'd0;
    end
    else begin
        r_ack_a1 <= r_ack_b;
        r_ack_a2 <= r_ack_a1;        
    end
end

/*--------clk_b--------*/
always @(posedge i_clk_b or posedge i_rst_b) begin
    if(i_rst_b)begin
        r_single_b1 <= 'd0;
        r_single_b2 <= 'd0;
    end
    else if(r_trans_a)begin
        r_single_b1 <= 'd1;
        r_single_b2 <= r_single_b1;        
    end
    else begin
        r_single_b1 <= r_trans_a;
        r_single_b2 <= r_single_b1;
    end
end

always @(posedge i_clk_b or posedge i_rst_b) begin
    if(i_rst_a)
        r_single_b <= 'd0;
    else if(w_single_b_pos)
        r_single_b <= 1;
    else
        r_single_b <= 'd0;
end

always @(posedge i_clk_b or posedge i_rst_b) begin
    if(i_rst_a)
        r_ack_b <= 'd0;
    else if(r_cnt_b == P_CNT_END_B - 1)
        r_ack_b <= 'd0;
    else if(w_single_b_pos)
        r_ack_b <= 1;
    else
        r_ack_b <= r_ack_b;
end

always @(posedge i_clk_b or posedge i_rst_b) begin
    if(i_rst_a)
        r_cnt_b <= 'd0;
    else if(r_cnt_b == P_CNT_END_B - 1)
        r_cnt_b <= 'd0;
    else if(r_ack_b)
        r_cnt_b <= r_cnt_b + 1;
    else
        r_cnt_b <= 'd0;
end

endmodule
