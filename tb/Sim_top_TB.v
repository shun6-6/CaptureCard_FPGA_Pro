`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/30 19:41:21
// Design Name: 
// Module Name: Sim_top_TB
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


module Sim_top_TB();
localparam CLK_PERIOD = 20;
reg clk,rst;

always begin
    clk = 0;
    #(CLK_PERIOD/2);
    clk = 1;
    #(CLK_PERIOD/2);
end

initial begin
    rst = 1;
    #100;
    @(posedge clk) rst = 0;
end

wire        i_uart_rx       ;
wire        o_uart_tx       ;

reg  [7 :0] r_usr_tx_data   ;
reg         r_usr_tx_valid  ;
wire        w_usr_tx_ready  ;
wire        w_usr_rx_data   ;
wire        w_usr_rx_valid  ;
wire        w_user_clk      ;
wire        w_user_rst      ;
//采集卡
CaptureCard_Top CaptureCard_Top_0(
    .i_clk                  (clk            ),
    .i_uart_rx              (o_uart_tx      ),
    .o_uart_tx              (i_uart_rx      ),
    .o_ad_range             (),
    .o_ad_osc               (),
    .o_ad_reset             (),
    .o_ad_convstA           (),
    .o_ad_convstB           (),
    .o_ad_cs                (),
    .o_ad_rd                (),
    .i_ad_busy              (),
    .i_ad_firstdata         (),
    .i_ad_data              (),
    .i_external_trig        (),
    .o_iic_scl              (),
    .io_iic_sda             (),
    .o_spi_cs               (),
    .o_spi_clk              (),
    .o_spi_mosi             (),
    .i_spi_miso             () 
);
//上位机
Uart_Drive#(
    .P_UART_CLK             (50_000_000         ), 
    .P_UART_BAUDRATE        (115200               ), 
    .P_UART_DATA_WIDTH      (8                  ), 
    .P_UART_STOP_WIDTH      (1                  ), 
    .P_UART_CHECK           (0                  )  
)Uart_Drive_u0(     
    .i_clk                  (clk                ),
    .i_rst                  (rst                ),
    .i_uart_rx              (i_uart_rx          ),
    .o_uart_tx              (o_uart_tx          ),

    .i_usr_tx_data          (r_usr_tx_data      ),
    .i_usr_tx_valid         (r_usr_tx_valid     ),
    .o_usr_tx_ready         (w_usr_tx_ready     ),
    .o_usr_rx_data          (w_usr_rx_data      ),
    .o_usr_rx_valid         (w_usr_rx_valid     ),
    .o_user_clk             (w_user_clk         ),
    .o_user_rst             (w_user_rst         )
    );

task cmd_send_byte(input [7 :0] Byte);
begin:cmd_send_byte
    wait(w_usr_tx_ready); 
    r_usr_tx_data  <= Byte;
    r_usr_tx_valid <= 'd1;
    @(posedge w_user_clk);
    r_usr_tx_data  <= Byte;
    r_usr_tx_valid <= 'd0;
    @(posedge w_user_clk);
end
endtask

task cmd_read_adc();
begin:cmd_read_adc
    r_usr_tx_data  <= 'd0;
    r_usr_tx_valid <= 'd0;
    @(posedge w_user_clk);
    cmd_send_byte(8'h55);//head
    cmd_send_byte(8'h05);//type
    cmd_send_byte(8'h01);//length
    cmd_send_byte(8'h01);//data
end
endtask

initial begin
    r_usr_tx_data  = 'd0;
    r_usr_tx_valid = 'd0;
    wait(!rst);
    repeat(200)@(posedge w_user_clk);
    cmd_read_adc();
    repeat(200)@(posedge w_user_clk);
    cmd_read_adc();
end

endmodule
