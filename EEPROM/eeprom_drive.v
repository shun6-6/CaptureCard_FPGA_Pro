`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/12 16:33:14
// Design Name: 
// Module Name: eeprom_drive
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


module eeprom_drive(
    input           i_clk                   ,
    input           i_rst                   ,
    /*----user interface----*/
    input   [2 :0]  i_eeprom_addr           ,
    input   [15:0]  i_user_operation_addr   ,
    input   [1 :0]  i_user_operation_type   ,
    input   [7 :0]  i_user_operation_len    ,
    input           i_user_operation_valid  ,
    output          o_user_operation_ready  ,

    input   [7 :0]  i_user_write_date       ,
    input           i_user_write_valid      ,
    input           i_user_write_sop        ,
    input           i_user_write_eop        ,

    output  [7 :0]  o_user_read_date        ,
    output          o_user_read_valid       ,
    /*----IIC interface----*/
    output          o_iic_scl               ,//IIC时钟线
    inout           io_iic_sda               //IIC双向数据线
    );

wire    [6 :0]      w_device_addr           ;
wire    [15:0]      w_operation_addr        ;
wire    [7 :0]      w_operation_len         ;
wire    [1 :0]      w_operation_type        ;
wire                w_operation_valid       ;
wire                w_operation_ready       ;    
wire    [7 :0]      w_write_date            ;
wire                w_write_req             ;   
wire    [7 :0]      w_read_date             ;
wire                w_read_valid            ;

eeprom_ctrl eeprom_ctrl_u0(
    .i_clk                      (i_clk                  ),
    .i_rst                      (i_rst                  ),
    /*----user interface----*/
    .i_eeprom_addr              (i_eeprom_addr          ),
    .i_user_operation_addr      (i_user_operation_addr  ),
    .i_user_operation_type      (i_user_operation_type  ),
    .i_user_operation_len       (i_user_operation_len   ),
    .i_user_operation_valid     (i_user_operation_valid ),
    .o_user_operation_ready     (o_user_operation_ready ),
    .i_user_write_date          (i_user_write_date      ),
    .i_user_write_valid         (i_user_write_valid     ),
    .i_user_write_sop           (i_user_write_sop       ),
    .i_user_write_eop           (i_user_write_eop       ),
    .o_user_read_date           (o_user_read_date       ),
    .o_user_read_valid          (o_user_read_valid      ),
    /*----iic drive interface----*/
    .o_device_addr              (w_device_addr          ),
    .o_operation_addr           (w_operation_addr       ),
    .o_operation_len            (w_operation_len        ),
    .o_operation_type           (w_operation_type       ),
    .o_operation_valid          (w_operation_valid      ),
    .i_operation_ready          (w_operation_ready      ),
    .o_write_date               (w_write_date           ),
    .i_write_req                (w_write_req            ),
    .i_read_date                (w_read_date            ),
    .i_read_valid               (w_read_valid           ) 
    );

iic_drive#(
    .P_ADDR_WIDTH               (16)   
)iic_drive_u0(
    .i_clk                      (i_clk                  ),
    .i_rst                      (i_rst                  ),
    /*----user interface----*/
    .i_device_addr              (w_device_addr          ),//用户输入设备地址
    .i_operation_addr           (w_operation_addr       ),//用户输入读写数据地址
    .i_operation_len            (w_operation_len        ),//用户输入读写数据长度
    .i_operation_type           (w_operation_type       ),//用户输入读写类型
    .i_operation_valid          (w_operation_valid      ),//用户输入操作有效信号
    .o_operation_ready          (w_operation_ready      ),//用户输出操作准备信号
    .i_write_date               (w_write_date           ),//用户写入数据
    .o_write_req                (w_write_req            ),//用户写数据请求
    .o_read_date                (w_read_date            ),//输出IIC读到的数据
    .o_read_valid               (w_read_valid           ),//数据有效信号
    /*----IIC interface----*/
    .o_iic_scl                  (o_iic_scl ),//IIC时钟线
    .io_iic_sda                 (io_iic_sda) //IIC双向数据线
    );
endmodule
