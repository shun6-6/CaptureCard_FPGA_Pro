`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/10 15:29:00
// Design Name: 
// Module Name: Parameter_crtl
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
//使用eeprom实现将上位传递的参数进行一个掉电保存

module Parameter_ctrl(
    input           i_clk               ,
    input           i_rst               ,

    input  [7 :0]   i_pre_cmd_data      ,
    input  [7 :0]   i_pre_cmd_len       ,
    input           i_pre_cmd_last      ,
    input           i_pre_cmd_valid     ,
    
    output [7 :0]   o_post_cmd_data     ,
    output [7 :0]   o_post_cmd_len      ,
    output          o_post_cmd_last     ,
    output          o_post_cmd_valid    ,

    output          o_system_run        ,
    output [7 :0]   o_adc_chnnel        ,
    output [23:0]   o_adc_speed         ,
    output          o_adc_start         ,
    output          o_adc_trig          ,
    output          o_flash_start       ,
    output [15:0]   o_flash_num         ,

    output          o_iic_scl           ,
    inout           io_iic_sda           
);

localparam      P_EEPROM_ADDR = 3'b011  ;

//eeprom_drive interface
wire [2 :0]     w_eeprom_addr           ;
wire [15:0]     w_user_operation_addr   ;
wire [1 :0]     w_user_operation_type   ;
wire [7 :0]     w_user_operation_len    ;
wire            w_user_operation_valid  ;
wire            w_user_operation_ready  ;
wire [7 :0]     w_user_write_date       ;
wire            w_user_write_valid      ;
wire            w_user_write_sop        ;
wire            w_user_write_eop        ;
wire [7 :0]     w_user_read_date        ;
wire            w_user_read_valid       ;

eeprom_drive eeprom_drive_u0(
    .i_clk                   (i_clk                 ),
    .i_rst                   (i_rst                 ),
    /*----user interface----*/
    .i_eeprom_addr           (w_eeprom_addr         ),
    .i_user_operation_addr   (w_user_operation_addr ),
    .i_user_operation_type   (w_user_operation_type ),
    .i_user_operation_len    (w_user_operation_len  ),
    .i_user_operation_valid  (w_user_operation_valid),
    .o_user_operation_ready  (w_user_operation_ready),
    .i_user_write_date       (w_user_write_date     ),
    .i_user_write_valid      (w_user_write_valid    ),
    .i_user_write_sop        (w_user_write_sop      ),
    .i_user_write_eop        (w_user_write_eop      ),

    .o_user_read_date        (w_user_read_date      ),
    .o_user_read_valid       (w_user_read_valid     ),
    /*----IIC interface----*/
    .o_iic_scl               (o_iic_scl             ),//IIC时钟线
    .io_iic_sda              (io_iic_sda            )//IIC双向数据线
    );

parameter_ram parameter_ram_u0(
    .i_clk                   (i_clk                 ),
    .i_rst                   (i_rst                 ),

    .i_pre_cmd_data          (i_pre_cmd_data        ),
    .i_pre_cmd_len           (i_pre_cmd_len         ),
    .i_pre_cmd_last          (i_pre_cmd_last        ),
    .i_pre_cmd_valid         (i_pre_cmd_valid       ),

    .o_post_cmd_data        (o_post_cmd_data      ),
    .o_post_cmd_len         (o_post_cmd_len       ),
    .o_post_cmd_last        (o_post_cmd_last      ),
    .o_post_cmd_valid       (o_post_cmd_valid     ),

    .o_system_run            (o_system_run          ),
    .o_adc_chnnel            (o_adc_chnnel          ),
    .o_adc_speed             (o_adc_speed           ),
    .o_adc_start             (o_adc_start           ),
    .o_adc_trig              (o_adc_trig            ),
    .o_flash_start           (o_flash_start         ),
    .o_flash_num             (o_flash_num           ),
    /*----eeprom interface----*/
    .o_eeprom_addr           (w_eeprom_addr         ),
    .o_user_operation_addr   (w_user_operation_addr ),
    .o_user_operation_type   (w_user_operation_type ),
    .o_user_operation_len    (w_user_operation_len  ),
    .o_user_operation_valid  (w_user_operation_valid),
    .i_user_operation_ready  (w_user_operation_ready),
    .o_user_write_date       (w_user_write_date     ),
    .o_user_write_valid      (w_user_write_valid    ),
    .o_user_write_sop        (w_user_write_sop      ),
    .o_user_write_eop        (w_user_write_eop      ),
    .i_user_read_date        (w_user_read_date      ),
    .i_user_read_valid       (w_user_read_valid     ) 
);

endmodule
