`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/07 21:57:38
// Design Name: 
// Module Name: sim_uart_dma_tb
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


module sim_uart_dma_tb();
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
wire            w_uart_rx           ;        
wire            w_uart_tx           ; 

wire            w_u1_clk            ;
wire            w_u1_rst            ;
wire            w_u0_clk            ;
wire            w_u0_rst            ;

reg     [7 : 0] r_u1_tx_data        ;
reg             r_u1_tx_valid       ;
wire            w_u1_tx_ready       ;

wire    [7 : 0] w_usr_rx_data       ;
wire            w_usr_rx_valid      ;

wire    [7 : 0] w_uart_DMA_rlen     ;
wire    [7 : 0] w_uart_DMA_rdata    ;
wire            w_uart_DMA_rlast    ;
wire            w_uart_DMA_rvalid   ;

reg     [7 : 0] r_uart_DMA_tdata    ;
reg             r_uart_DMA_tlast    ;
reg             r_uart_DMA_tvalid   ;
wire            w_uart_DMA_tready   ;

wire    [7 : 0] w_usr_tx_data       ;     
wire            w_usr_tx_valid      ;     
wire            w_usr_tx_ready      ;   

wire    [7 : 0] w_post_data         ;
wire    [7 : 0] w_post_len          ;
wire            w_post_last         ;
wire            w_post_valid        ;

Data_Mclk_buf Data_Mclk_buf_u0(
    .i_pre_clk              (w_u0_clk           ),
    .i_pre_rst              (w_u0_rst           ),
    .i_pre_data             (w_uart_DMA_rdata   ),
    .i_pre_len              (w_uart_DMA_rlen    ),
    .i_pre_last             (w_uart_DMA_rlast   ),
    .i_pre_valid            (w_uart_DMA_rvalid  ),

    .i_post_clk             (clk                ),
    .i_post_rst             (rst                ),
    .o_post_data            (w_post_data        ),
    .o_post_len             (w_post_len         ),
    .o_post_last            (w_post_last        ),
    .o_post_valid           (w_post_valid       ) 
);

Uart_DMA Uart_DMA_U0(
    .i_clk                  (w_u0_clk           ),
    .i_rst                  (w_u0_rst           ),

    .o_usr_tx_data          (w_usr_tx_data      ),
    .o_usr_tx_valid         (w_usr_tx_valid     ),
    .i_usr_tx_ready         (w_usr_tx_ready     ),

    .i_usr_rx_data          (w_usr_rx_data      ),
    .i_usr_rx_valid         (w_usr_rx_valid     ),
    //dma send data 
    .i_uart_DMA_tdata       (r_uart_DMA_tdata   ),
    .i_uart_DMA_tlast       (r_uart_DMA_tlast   ),
    .i_uart_DMA_tvalid      (r_uart_DMA_tvalid  ), 
    .o_uart_DMA_tready      (w_uart_DMA_tready  ), 
    //dma recieve data  
    .o_uart_DMA_rlen        (w_uart_DMA_rlen    ),
    .o_uart_DMA_rdata       (w_uart_DMA_rdata   ),
    .o_uart_DMA_rlast       (w_uart_DMA_rlast   ),
    .o_uart_DMA_rvalid      (w_uart_DMA_rvalid  ) 
    );

Uart_Drive#(
    .P_UART_CLK             (50_000_000         ), 
    .P_UART_BAUDRATE        (9600               ), 
    .P_UART_DATA_WIDTH      (8                  ), 
    .P_UART_STOP_WIDTH      (1                  ), 
    .P_UART_CHECK           (0                  )  
)Uart_Drive_u0(     
    .i_clk                  (clk                ),
    .i_rst                  (rst                ),

    .i_uart_rx              (w_uart_tx          ),
    .o_uart_tx              (w_uart_rx          ),

    .i_usr_tx_data          (w_usr_tx_data      ),
    .i_usr_tx_valid         (w_usr_tx_valid     ),
    .o_usr_tx_ready         (w_usr_tx_ready     ),

    .o_usr_rx_data          (w_usr_rx_data      ),
    .o_usr_rx_valid         (w_usr_rx_valid     ),

    .o_user_clk             (w_u0_clk           ),
    .o_user_rst             (w_u0_rst           ) 
    );

Uart_Drive#(
    .P_UART_CLK             (50_000_000         ), 
    .P_UART_BAUDRATE        (9600               ), 
    .P_UART_DATA_WIDTH      (8                  ),  
    .P_UART_STOP_WIDTH      (1                  ), 
    .P_UART_CHECK           (0                  )  
)Uart_Drive_u1( 
    .i_clk                  (clk                ),
    .i_rst                  (rst                ),

    .i_uart_rx              (w_uart_rx          ),
    .o_uart_tx              (w_uart_tx          ),

    .i_usr_tx_data          (r_u1_tx_data       ),
    .i_usr_tx_valid         (r_u1_tx_valid      ),
    .o_usr_tx_ready         (w_u1_tx_ready      ),

    .o_usr_rx_data          (),
    .o_usr_rx_valid         (),

    .o_user_clk             (w_u1_clk           ),
    .o_user_rst             (w_u1_rst           ) 
    );

initial begin
    r_u1_tx_data  = 0;
    r_u1_tx_valid = 0;
    r_uart_DMA_tdata  = 'd0;
    r_uart_DMA_tlast  = 'd0;
    r_uart_DMA_tvalid = 'd0;
    wait(!w_u1_rst);
    repeat(10) @(posedge w_u1_clk);
    u1_send_data();
    u1_send_data();
    u1_send_data();
    u1_send_data();
    u1_send_data();
    uart_dma_send();
end

task u1_send_data();
begin:u1_send
    integer i;
    r_u1_tx_data  = 0;
    r_u1_tx_valid = 0;
    @(posedge w_u1_clk);
    // for(i=0; i<10; i=i+1)begin
    //     wait(w_u1_tx_ready);
    //     @(posedge w_u1_clk);
    //     r_u1_tx_data  = i;
    //     r_u1_tx_valid = 1;
    //     @(posedge w_u1_clk);
    //     r_u1_tx_data  = i;
    //     r_u1_tx_valid = 0;
    //     @(posedge w_u1_clk);
    // end
//前导码
wait(w_u1_tx_ready);
@(posedge w_u1_clk);
r_u1_tx_data  = 8'h55;
r_u1_tx_valid = 1;
@(posedge w_u1_clk);
r_u1_tx_data  = 0;
r_u1_tx_valid = 0;
@(posedge w_u1_clk);
//指令
wait(w_u1_tx_ready);
@(posedge w_u1_clk);
r_u1_tx_data  = 8'h01;
r_u1_tx_valid = 1;
@(posedge w_u1_clk);
r_u1_tx_data  = 0;
r_u1_tx_valid = 0;
@(posedge w_u1_clk);
//长度
wait(w_u1_tx_ready);
@(posedge w_u1_clk);
r_u1_tx_data  = 8'h01;
r_u1_tx_valid = 1;
@(posedge w_u1_clk);
r_u1_tx_data  = 0;
r_u1_tx_valid = 0;
@(posedge w_u1_clk);
//数据
wait(w_u1_tx_ready);
@(posedge w_u1_clk);
r_u1_tx_data  = 8'h66;
r_u1_tx_valid = 1;
@(posedge w_u1_clk);
r_u1_tx_data  = 0;
r_u1_tx_valid = 0;
@(posedge w_u1_clk);

    //@(posedge w_u1_clk);
    r_u1_tx_data  = 0;
    r_u1_tx_valid = 0;    
end
endtask


task uart_dma_send();
begin:uart_dma_send
integer i;
    r_uart_DMA_tdata  <= 'd0;
    r_uart_DMA_tlast  <= 'd0;
    r_uart_DMA_tvalid <= 'd0;
    @(posedge w_u0_clk);
    // for(i=0; i<5; i=i+1)begin
    //     // wait(w_uart_DMA_tready);
    //     r_uart_DMA_tdata  <= i;
    //     r_uart_DMA_tlast  <= i == 4;
    //     r_uart_DMA_tvalid <= 'd1;         
    //     @(posedge w_u0_clk);
    // end
    r_uart_DMA_tdata  <= 8'h55;
    r_uart_DMA_tvalid <= 'd1;         
    @(posedge w_u0_clk);
    r_uart_DMA_tdata  <= 8'h01;
    r_uart_DMA_tvalid <= 'd1;         
    @(posedge w_u0_clk);
    r_uart_DMA_tdata  <= 8'h01;
    r_uart_DMA_tvalid <= 'd1;         
    @(posedge w_u0_clk);
    r_uart_DMA_tdata  <= 8'h77;
    r_uart_DMA_tvalid <= 'd1; 
    r_uart_DMA_tlast  <= 'd1;        
    @(posedge w_u0_clk);

    r_uart_DMA_tdata  <= 'd0;
    r_uart_DMA_tlast  <= 'd0;
    r_uart_DMA_tvalid <= 'd0;
    @(posedge w_u0_clk);
end
endtask


endmodule
