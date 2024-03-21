`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/30 19:40:02
// Design Name: 
// Module Name: CaptureCard_Top
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


module CaptureCard_Top(
    input           i_clk           ,
    /*--------UART interface--------*/
    input           i_uart_rx       ,
    output          o_uart_tx       ,
    /*--------AD7606 interface--------*/
    output          o_ad_range      ,
    output  [2 :0]  o_ad_osc        ,
    output          o_ad_reset      ,
    output          o_ad_convstA    ,
    output          o_ad_convstB    ,
    output          o_ad_cs         ,
    output          o_ad_rd         ,
    input           i_ad_busy       ,
    input           i_ad_firstdata  ,
    input   [15:0]  i_ad_data       ,
    input           i_external_trig ,
    /*--------EEPROM interface--------*/
    output          o_iic_scl       ,
    inout           io_iic_sda      ,
    /*--------FLASH interface--------*/
    input           clk             ,
    output          o_spi_cs        ,
    output          o_spi_clk       ,
    output          o_spi_mosi      ,
    input           i_spi_miso      

    );

wire            w_clk_50MHz         ;
wire            w_clk_5MHz          ;
wire            w_clk_50MHz_rst     ;
wire            w_clk_5MHz_rst      ;
wire            w_pll_locked        ;
wire            w_clk_125khz        ;
wire            w_clk_125khz_rst    ;

wire [7 :0]     w_uart_tx_data      ;
wire            w_uart_tx_valid     ;
wire            w_uart_tx_ready     ;
wire [7 :0]     w_uart_rx_data      ;
wire            w_uart_rx_valid     ;
wire            w_uart_clk          ;
wire            w_uart_rst          ;

wire [7 : 0]    w_uart_DMA_rlen     ;
wire [7 : 0]    w_uart_DMA_rdata    ;
wire            w_uart_DMA_rlast    ;
wire            w_uart_DMA_rvalid   ;

wire [7 :0]     w_pre_cmd_data      ;
wire [7 :0]     w_pre_cmd_len       ;
wire            w_pre_cmd_last      ;
wire            w_pre_cmd_valid     ;
wire [7 :0]     w_post_cmd_data     ;
wire [7 :0]     w_post_cmd_len      ;
wire            w_post_cmd_last     ;
wire            w_post_cmd_valid    ;

wire [7 :0]     w_cmd_adc_data      ;
wire [7 :0]     w_cmd_adc_len       ;
wire            w_cmd_adc_last      ;
wire            w_cmd_adc_valid     ;
wire [7 :0]     w_cmd_flash_data    ;
wire [7 :0]     w_cmd_flash_len     ;
wire            w_cmd_flash_last    ;
wire            w_cmd_flash_valid   ;
wire [7 :0]     w_cmd_ctrl_data     ;
wire [7 :0]     w_cmd_ctrl_len      ;
wire            w_cmd_ctrl_last     ;
wire            w_cmd_ctrl_valid    ;

wire [7 :0]     w_adc_data          ;
wire [7 :0]     w_adc_len           ;
wire            w_adc_last          ;
wire            w_adc_valid         ;

wire            w_system_run        ;
wire [7 :0]     w_adc_chnnel        ;
wire [23:0]     w_adc_speed         ;
wire            w_adc_start         ;
wire            w_adc_trig          ;
wire            w_flash_start       ;
wire [15:0]     w_flash_num         ;

system_clk system_clk_u0
(
    .clk_out1               (w_clk_50MHz        ),    
    .clk_out2               (w_clk_5MHz         ),     
    .locked                 (w_pll_locked       ),       
    .clk_in1                (i_clk              )     
);
//产生EEPROM时钟 125Khz
CLK_DIV_module#(
    .P_CLK_DIV_CNT          (40) //MAX = 65535
)CLK_DIV_module_U(
    .i_clk                  (w_clk_50MHz        ),
    .i_rst                  (~w_pll_locked      ),
    .o_clk_div              (w_clk_125khz       )
    );

rst_gen_module#(
    .P_RST_CYCLE            (10)  
)rst_gen_module_50MHz(     
    .i_clk                  (w_clk_50MHz        ),
    .o_rst                  (w_clk_50MHz_rst    )
    ); 

rst_gen_module#(
    .P_RST_CYCLE            (10)  
)rst_gen_module_5MHz(     
    .i_clk                  (w_clk_5MHz         ),
    .o_rst                  (w_clk_5MHz_rst     )
    ); 

rst_gen_module#(
    .P_RST_CYCLE            (10)  
)rst_gen_module_125khz(     
    .i_clk                  (w_clk_125khz       ),
    .o_rst                  (w_clk_125khz_rst   )
    ); 

Uart_Drive#(
    .P_UART_CLK             (50_000_000         ), 
    .P_UART_BAUDRATE        (115200             ), 
    .P_UART_DATA_WIDTH      (8                  ), 
    .P_UART_STOP_WIDTH      (1                  ), 
    .P_UART_CHECK           (0                  )  
)Uart_Drive_u0(
    .i_clk                  (w_clk_50MHz        ),
    .i_rst                  (w_clk_50MHz_rst    ),
    .i_uart_rx              (i_uart_rx          ),
    .o_uart_tx              (o_uart_tx          ),

    .i_usr_tx_data          (w_uart_tx_data     ),
    .i_usr_tx_valid         (w_uart_tx_valid    ),
    .o_usr_tx_ready         (w_uart_tx_ready    ),
    .o_usr_rx_data          (w_uart_rx_data     ),
    .o_usr_rx_valid         (w_uart_rx_valid    ),

    .o_user_clk             (w_uart_clk         ),
    .o_user_rst             (w_uart_rst         ) 
    );

Uart_DMA Uart_DMA_u0(
    .i_clk                  (w_uart_clk         ),
    .i_rst                  (w_uart_rst         ),
    
    .o_usr_tx_data          (w_uart_tx_data     ),
    .o_usr_tx_valid         (w_uart_tx_valid    ),
    .i_usr_tx_ready         (w_uart_tx_ready    ),
    .i_usr_rx_data          (w_uart_rx_data     ),
    .i_usr_rx_valid         (w_uart_rx_valid    ),
    //dma send data 
    .i_uart_DMA_tdata       (w_adc_data         ),
    .i_uart_DMA_tlast       (w_adc_last         ),
    .i_uart_DMA_tvalid      (w_adc_valid        ), 
    .o_uart_DMA_tready      (), 
    //dma recieve data  
    .o_uart_DMA_rlen        (w_uart_DMA_rlen    ),
    .o_uart_DMA_rdata       (w_uart_DMA_rdata   ),
    .o_uart_DMA_rlast       (w_uart_DMA_rlast   ),
    .o_uart_DMA_rvalid      (w_uart_DMA_rvalid  )
);
//跨时钟域处理 uart DMA数据跨到系统参数管理模块
Data_Mclk_buf Data_Mclk_buf_uart2bus_mux(
    .i_pre_clk              (w_uart_clk         ),
    .i_pre_rst              (w_uart_rst         ),
    .i_pre_data             (w_uart_DMA_rlen    ),
    .i_pre_len              (w_uart_DMA_rdata   ),
    .i_pre_last             (w_uart_DMA_rlast   ),
    .i_pre_valid            (w_uart_DMA_rvalid  ),

    .i_post_clk             (w_uart_clk         ),
    .i_post_rst             (w_uart_rst         ),
    .o_post_data            (w_post_cmd_data    ),
    .o_post_len             (w_post_cmd_len     ),
    .o_post_last            (w_post_cmd_last    ),
    .o_post_valid           (w_post_cmd_valid   ) 
);
//总线分流器
BUS_MUX BUS_MUX_u0(
    .i_clk                  (w_uart_clk         ),
    .i_rst                  (w_uart_rst         ),

    .i_cmd_data             (w_post_cmd_data    ),
    .i_cmd_len              (w_post_cmd_len     ),
    .i_cmd_last             (w_post_cmd_last    ),
    .i_cmd_valid            (w_post_cmd_valid   ), 

    .o_adc_data             (w_cmd_adc_data     ),
    .o_adc_len              (w_cmd_adc_len      ),
    .o_adc_last             (w_cmd_adc_last     ),
    .o_adc_valid            (w_cmd_adc_valid    ),

    .o_flash_data           (w_cmd_flash_data   ),
    .o_flash_len            (w_cmd_flash_len    ),
    .o_flash_last           (w_cmd_flash_last   ),
    .o_flash_valid          (w_cmd_flash_valid  ),

    .o_ctrl_data            (w_cmd_ctrl_data    ),
    .o_ctrl_len             (w_cmd_ctrl_len     ),
    .o_ctrl_last            (w_cmd_ctrl_last    ),
    .o_ctrl_valid           (w_cmd_ctrl_valid   ) 
);

//系统参数管理
Parameter_ctrl Parameter_ctrl_u0(
    .i_clk                  (w_clk_125khz       ),
    .i_rst                  (w_clk_125khz_rst   ),

    .i_pre_cmd_data         (),
    .i_pre_cmd_len          (),
    .i_pre_cmd_last         (),
    .i_pre_cmd_valid        (),
        
    .o_post_cmd_data        (),
    .o_post_cmd_len         (),
    .o_post_cmd_last        (),
    .o_post_cmd_valid       (),

    .o_system_run           (w_system_run       ),
    .o_adc_chnnel           (w_adc_chnnel       ),
    .o_adc_speed            (w_adc_speed        ),
    .o_adc_start            (w_adc_start        ),
    .o_adc_trig             (w_adc_trig         ),
    .o_flash_start          (w_flash_start      ),
    .o_flash_num            (w_flash_num        ),

    .o_iic_scl              (o_iic_scl          ),
    .io_iic_sda             (io_iic_sda         ) 
);

AD7606_module AD7606_module_u0(
    .i_clk                  (w_clk_50MHz        ),
    .i_rst                  (w_clk_50MHz_rst    ),

    .i_cmd_adc_data         (w_cmd_adc_data     ),
    .i_cmd_adc_len          (w_cmd_adc_len      ),
    .i_cmd_adc_last         (w_cmd_adc_last     ),
    .i_cmd_adc_valid        (w_cmd_adc_valid    ),

    .i_external_trig        (i_external_trig    ),
    .i_system_run           (w_system_run       ),
    .i_adc_chnnel           (w_adc_chnnel       ),
    .i_adc_speed            (w_adc_speed        ),
    .i_adc_start            (w_adc_start        ),
    .i_adc_trig             (w_adc_trig         ),

    .o_ad_range             (o_ad_range         ),
    .o_ad_osc               (o_ad_osc           ),
    .o_ad_reset             (o_ad_reset         ),
    .o_ad_convstA           (o_ad_convstA       ),
    .o_ad_convstB           (o_ad_convstB       ),
    .o_ad_cs                (o_ad_cs            ),
    .o_ad_rd                (o_ad_rd            ),
    .i_ad_busy              (i_ad_busy          ),
    .i_ad_firstdata         (i_ad_firstdata     ),
    .i_ad_data              (i_ad_data          ),

    .o_adc_data             (w_adc_data         ),
    .o_adc_len              (w_adc_len          ),
    .o_adc_last             (w_adc_last         ),
    .o_adc_valid            (w_adc_valid        ) 
);


// Flash_drive#(
//     .P_DATA_WIDTH           (8 )  ,
//     .P_SPI_CPOL             (0 )  ,
//     .P_SPI_CPHL             (0 )  ,
//     .P_READ_DWIDTH          (8 )  ,
//     .P_OP_LEN               (32)   
// )Flash_drive_u0(
//     .i_clk                  (w_clk_5MHz         ),
//     .i_rst                  (w_clk_5MHz_rst     ),
//     /*--------user single--------*/ 
//     .i_operation_type       () ,
//     .i_operation_addr       () ,
//     .i_operation_byte_num   () ,
//     .i_operation_valid      () ,
//     .o_operation_ready      () ,
//     .i_write_data           () ,
//     .i_write_sop            () ,
//     .i_write_eop            () ,
//     .i_write_valid          () ,
//     .o_read_data            () ,
//     .o_read_sop             () ,
//     .o_read_eop             () ,
//     .o_read_valid           () ,   
//     /*--------spi single--------*/
//     .o_spi_cs               (o_spi_cs           ),
//     .o_spi_clk              (o_spi_clk          ),
//     .o_spi_mosi             (o_spi_mosi         ),
//     .i_spi_miso             (i_spi_miso         )
//);
endmodule
