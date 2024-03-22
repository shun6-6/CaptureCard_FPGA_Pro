`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/11 21:19:09
// Design Name: 
// Module Name: AD7606_module
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


module AD7606_module(
    input           i_clk           ,
    input           i_rst           ,

    input  [7 :0]   i_cmd_adc_data  ,
    input  [7 :0]   i_cmd_adc_len   ,
    input           i_cmd_adc_last  ,
    input           i_cmd_adc_valid ,

    input           i_external_trig ,
    input           i_system_run    ,
    input  [7 :0]   i_adc_chnnel    ,
    input  [23:0]   i_adc_speed     ,
    input           i_adc_start     ,
    input           i_adc_trig      ,

    output          o_ad_range      ,
    output [2 :0]   o_ad_osc        ,
    output          o_ad_reset      ,
    output          o_ad_convstA    ,
    output          o_ad_convstB    ,
    output          o_ad_cs         ,
    output          o_ad_rd         ,
    input           i_ad_busy       ,
    input           i_ad_firstdata  ,
    input  [15:0]   i_ad_data       ,

    output [7 :0]   o_adc_data      ,
    output [7 :0]   o_adc_len       ,
    output          o_adc_last      ,
    output          o_adc_valid     
);

wire [7 :0]     w_cap_chnnel_num    ;
wire            w_cap_enable        ;
wire [23:0]     w_cap_speed         ;
wire            w_cap_trigger       ;
wire            w_cap_seek          ;

wire [15:0]     w_user_data_1       ;
wire            w_user_valid_1      ;
wire [15:0]     w_user_data_2       ;
wire            w_user_valid_2      ;
wire [15:0]     w_user_data_3       ;
wire            w_user_valid_3      ;
wire [15:0]     w_user_data_4       ;
wire            w_user_valid_4      ;
wire [15:0]     w_user_data_5       ;
wire            w_user_valid_5      ;
wire [15:0]     w_user_data_6       ;
wire            w_user_valid_6      ;
wire [15:0]     w_user_data_7       ;
wire            w_user_valid_7      ;
wire [15:0]     w_user_data_8       ;
wire            w_user_valid_8      ;

AD7606_ctrl AD7606_ctrl_u0(
    .i_clk                  (i_clk              ),
    .i_rst                  (i_rst              ),
 
    .i_cmd_adc_data         (i_cmd_adc_data     ),
    .i_cmd_adc_len          (i_cmd_adc_len      ),
    .i_cmd_adc_last         (i_cmd_adc_last     ),
    .i_cmd_adc_valid        (i_cmd_adc_valid    ),

    .i_system_run           (i_system_run       ),
    .i_adc_chnnel           (i_adc_chnnel       ),
    .i_adc_speed            (i_adc_speed        ),
    .i_adc_start            (i_adc_start        ),
    .i_adc_trig             (i_adc_trig         ),
 
    .o_cap_chnnel_num       (w_cap_chnnel_num   ),
    .o_cap_enable           (w_cap_enable       ),
    .o_cap_speed            (w_cap_speed        ),
    .o_cap_trigger          (w_cap_trigger      ),
    .o_cap_seek             (w_cap_seek         )
    );

AD7606_DATA_pkt AD7606_DATA_pkt_u0(
    .i_clk                  (i_clk              ),
    .i_rst                  (i_rst | ~i_system_run),
 
    .i_user_data_1          (w_user_data_1      ),
    .i_user_valid_1         (1     ),
    .i_user_data_2          (w_user_data_2      ),
    .i_user_valid_2         (w_user_valid_2     ),
    .i_user_data_3          (w_user_data_3      ),
    .i_user_valid_3         (w_user_valid_3     ),
    .i_user_data_4          (w_user_data_4      ),
    .i_user_valid_4         (w_user_valid_4     ),
    .i_user_data_5          (w_user_data_5      ),
    .i_user_valid_5         (w_user_valid_5     ),
    .i_user_data_6          (w_user_data_6      ),
    .i_user_valid_6         (w_user_valid_6     ),
    .i_user_data_7          (w_user_data_7      ),
    .i_user_valid_7         (w_user_valid_7     ),
    .i_user_data_8          (w_user_data_8      ),
    .i_user_valid_8         (w_user_valid_8     ),
 
    .i_cap_chnnel_num       (w_cap_chnnel_num),
    .i_cap_seek             (w_cap_seek         ),

    .o_adc_data             (o_adc_data         ),
    .o_adc_len              (o_adc_len          ),
    .o_adc_last             (o_adc_last         ),
    .o_adc_valid            (o_adc_valid        ) 
);

AD7606_drive#(
    .P_RANGE                (0                  )
)AD7606_drive_u0(
    .i_clk                  (i_clk              ),//50MHz 1 cycle = 20ns
    .i_rst                  (i_rst | ~i_system_run),
    /*------user interface------*/
    .i_user_ctrl            (w_cap_enable       ),
    .i_cap_speed            (w_cap_speed        ),
    .o_user_chnl            (),
    .o_user_data_1          (w_user_data_1      ),
    .o_user_valid_1         (w_user_valid_1     ),
    .o_user_data_2          (w_user_data_2      ),
    .o_user_valid_2         (w_user_valid_2     ),
    .o_user_data_3          (w_user_data_3      ),
    .o_user_valid_3         (w_user_valid_3     ),
    .o_user_data_4          (w_user_data_4      ),
    .o_user_valid_4         (w_user_valid_4     ),
    .o_user_data_5          (w_user_data_5      ),
    .o_user_valid_5         (w_user_valid_5     ),
    .o_user_data_6          (w_user_data_6      ),
    .o_user_valid_6         (w_user_valid_6     ),
    .o_user_data_7          (w_user_data_7      ),
    .o_user_valid_7         (w_user_valid_7     ),
    .o_user_data_8          (w_user_data_8      ),
    .o_user_valid_8         (w_user_valid_8     ),
    /*------AD7606 interface------*/
    .o_ad_psb_sel           (                   ),
    .o_ad_stby              (                   ),
    .o_ad_range             (o_ad_range         ),
    .o_ad_osc               (o_ad_osc           ),
    .o_ad_reset             (o_ad_reset         ),
    .o_ad_convstA           (o_ad_convstA       ),
    .o_ad_convstB           (o_ad_convstB       ),
    .o_ad_cs                (o_ad_cs            ),
    .o_ad_rd                (o_ad_rd            ),
    .i_ad_busy              (i_ad_busy          ),
    .i_ad_firstdata         (i_ad_firstdata     ),
    .i_ad_data              (i_ad_data          )
    );
endmodule
