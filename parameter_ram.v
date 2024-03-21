`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/16 20:29:45
// Design Name: 
// Module Name: parameter_ram
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


module parameter_ram(
    input           i_clk                   ,
    input           i_rst                   ,

    input  [7 :0]   i_pre_cmd_data          ,
    input  [7 :0]   i_pre_cmd_len           ,
    input           i_pre_cmd_last          ,
    input           i_pre_cmd_valid         ,

    output [7 :0]   o_post_cmd_data         ,
    output [7 :0]   o_post_cmd_len          ,
    output          o_post_cmd_last         ,
    output          o_post_cmd_valid        ,

    output          o_system_run            ,
    output [7 :0]   o_adc_chnnel            ,
    output [23:0]   o_adc_speed             ,
    output          o_adc_start             ,
    output          o_adc_trig              ,
    output          o_flash_start           ,
    output [15:0]   o_flash_num             ,

    /*----eeprom interface----*/
    output [2 :0]   o_eeprom_addr           ,
    output [15:0]   o_user_operation_addr   ,
    output [1 :0]   o_user_operation_type   ,
    output [7 :0]   o_user_operation_len    ,
    output          o_user_operation_valid  ,
    input           i_user_operation_ready  ,
    output [7 :0]   o_user_write_date       ,
    output          o_user_write_valid      ,
    output          o_user_write_sop        ,
    output          o_user_write_eop        ,
    input  [7 :0]   i_user_read_date        ,
    input           i_user_read_valid        

    );
/******************************function***************************/

/******************************parameter**************************/
localparam      P_EEPROM_ADDR = 3'b011;
/******************************port*******************************/

/******************************machine****************************/

/******************************reg********************************/
reg  [7 :0]     ri_pre_cmd_data         ;
reg  [7 :0]     ri_pre_cmd_len          ;
reg             ri_pre_cmd_last         ;
reg             ri_pre_cmd_valid        ;
reg  [7 :0]     ro_post_cmd_data       ;
reg  [7 :0]     ro_post_cmd_len        ;
reg             ro_post_cmd_last       ;
reg             ro_post_cmd_valid      ;
reg             ro_system_run           ;
reg  [7 :0]     ro_adc_chnnel           ;
reg  [23:0]     ro_adc_speed            ;
reg             ro_adc_start            ;
reg             ro_adc_trig             ;
reg             ro_flash_start          ;
reg  [15:0]     ro_flash_num            ;
/*----eeprom interface----*/
// reg  [2 :0]     ro_eeprom_addr          ;
reg  [15:0]     ro_user_operation_addr  ;
reg  [1 :0]     ro_user_operation_type  ;
reg  [7 :0]     ro_user_operation_len   ;
reg             ro_user_operation_valid ;

reg  [7 :0]     ro_user_write_date      ;
reg             ro_user_write_valid     ;
reg             ro_user_write_sop       ;
reg             ro_user_write_eop       ;

reg  [7 :0]     ri_user_read_date       ;
reg             ri_user_read_valid      ;
reg             ri_user_read_valid_1d   ;

reg  [15:0]     r_cnt                   ;
reg             r_cmd_header            ;
reg  [7 :0]     r_cmd_type              ;
reg  [7 :0]     r_cmd_len               ;
reg  [7 :0]     r_cmd_data              ;
reg             r_cmd_data_valid        ;
reg             r_cmd_data_valid_1d     ;
//ram single
reg             r_ram_ena               ;
reg             r_ram_wea               ;
reg  [6 :0]     r_ram_addra             ;
reg  [7 :0]     r_ram_dina              ;
reg             r_ram_enb               ;
reg             r_ram_web               ;
reg  [6 :0]     r_ram_addrb             ;
reg  [7 :0]     r_ram_dinb              ;

reg             r_eeprom_commit         ;
reg  [15:0]     r_eeprom_write_cnt      ;
reg  [1 :0]     r_eeprom_run_ctrl       ;
reg  [7 :0]     r_pkt_cnt               ;
/******************************wire*******************************/
wire            w_op_user_active        ;
wire [7 :0]     w_ram_douta             ;
wire [7 :0]     w_ram_doutb             ;
wire            w_ram_init_end          ;
/******************************component**************************/
// BRAM8x128 para_ram (
//   .clka     (i_clk      ),
//   .ena      (r_ram_ena   ),//使能
//   .wea      (r_ram_wea  ),//写使能
//   .addra    (r_ram_addra ),//读写地址
//   .dina     (r_ram_dina  ),//写数据
//   .douta    (w_ram_douta ) //读数据
// );
BRAM8x128 para_ram (
  .clka     (i_clk      ),  
  .ena      (r_ram_ena  ),  
  .wea      (r_ram_wea  ),  
  .addra    (r_ram_addra),  
  .dina     (r_ram_dina ),  
  .douta    (w_ram_douta),  

  .clkb     (i_clk      ),  
  .enb      (r_ram_enb  ),             
  .web      (r_ram_web  ),             
  .addrb    (r_ram_addrb),             
  .dinb     (r_ram_dinb ),             
  .doutb    (w_ram_doutb)             
);
/******************************assign*****************************/
assign  o_post_cmd_data         =   ro_post_cmd_data       ;
assign  o_post_cmd_len          =   ro_post_cmd_len        ;
assign  o_post_cmd_last         =   ro_post_cmd_last       ;
assign  o_post_cmd_valid        =   ro_post_cmd_valid      ;
assign  o_system_run            =   ro_system_run           ;
assign  o_adc_chnnel            =   ro_adc_chnnel           ;
assign  o_adc_speed             =   ro_adc_speed            ;
assign  o_adc_start             =   ro_adc_start            ;
assign  o_adc_trig              =   ro_adc_trig             ;
assign  o_flash_start           =   ro_flash_start          ;
assign  o_flash_num             =   ro_flash_num            ;

assign  o_eeprom_addr           =   P_EEPROM_ADDR           ;//device addr
assign  o_user_operation_addr   =   ro_user_operation_addr  ;
assign  o_user_operation_type   =   ro_user_operation_type  ;
assign  o_user_operation_len    =   ro_user_operation_len   ;
assign  o_user_operation_valid  =   ro_user_operation_valid ;
assign  o_user_write_date       =   ro_user_write_date      ;
assign  o_user_write_valid      =   ro_user_write_valid     ;
assign  o_user_write_sop        =   ro_user_write_sop       ;
assign  o_user_write_eop        =   ro_user_write_eop       ;

assign  w_op_user_active        =   i_user_operation_ready & o_user_operation_valid;
assign  w_ram_init_end          =   !ri_user_read_valid & ri_user_read_valid_1d;
/******************************always*****************************/
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        ri_pre_cmd_data    <= 'd0;
        ri_pre_cmd_len     <= 'd0;
        ri_pre_cmd_last    <= 'd0;
        ri_pre_cmd_valid   <= 'd0;
        ri_user_read_date  <= 'd0;
        ri_user_read_valid <= 'd0;
        ri_user_read_valid_1d <= 'd0;
    end 
    else begin
        ri_pre_cmd_data    <= i_pre_cmd_data   ;
        ri_pre_cmd_len     <= i_pre_cmd_len    ;
        ri_pre_cmd_last    <= i_pre_cmd_last   ;
        ri_pre_cmd_valid   <= i_pre_cmd_valid  ;      
        ri_user_read_date  <= i_user_read_date ;
        ri_user_read_valid <= i_user_read_valid;
        ri_user_read_valid_1d <=  ri_user_read_valid;         
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        ro_post_cmd_data  <= 'd0;
        ro_post_cmd_len   <= 'd0;
        ro_post_cmd_last  <= 'd0;
        ro_post_cmd_valid <= 'd0;
    end 
    else begin
        ro_post_cmd_data  <= ri_pre_cmd_data ;
        ro_post_cmd_len   <= ri_pre_cmd_len  ;
        ro_post_cmd_last  <= ri_pre_cmd_last ;
        ro_post_cmd_valid <= ri_pre_cmd_valid;        
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_cnt <= 'd0;
    else if(ri_pre_cmd_valid)
        r_cnt <= r_cnt + 'd1;
    else
        r_cnt <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_cmd_header <= 'd0;
    else if(r_cnt == 0 && ri_pre_cmd_valid && ri_pre_cmd_data == 8'h55)
        r_cmd_header <= 'd1;
    else if(r_cnt == 0 && !ri_pre_cmd_valid && ri_pre_cmd_data != 8'h55) 
        r_cmd_header <= 'd0;
    else
        r_cmd_header <= r_cmd_header;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_cmd_type <= 'd0;
    else if(r_cnt == 1 && ri_pre_cmd_valid)
        r_cmd_type <= ri_pre_cmd_data;
    else
        r_cmd_type <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_cmd_len <= 'd0;
    else if(r_cnt == 2 && ri_pre_cmd_valid)
        r_cmd_len <= ri_pre_cmd_data;
    else
        r_cmd_len <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_cmd_data_valid <= 'd0;
    else if(ri_pre_cmd_last)
        r_cmd_data_valid <= 'd0;
    else if(r_cnt == 2 && ri_pre_cmd_valid && r_cmd_header && r_cmd_type <= 9) 
        r_cmd_data_valid <= 'd1;
    else
        r_cmd_data_valid <= r_cmd_data_valid;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_cmd_data_valid_1d <= 'd0;
    else
        r_cmd_data_valid_1d <= r_cmd_data_valid;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_cmd_data <= 'd0;
    else if(r_cmd_data_valid)
        r_cmd_data <= ri_pre_cmd_data;   
    else
        r_cmd_data <= 'd0;
end
//ram
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_ram_ena <= 'd0;   
    else if(r_eeprom_write_cnt == 9 - 1 || (!r_cmd_data_valid & r_cmd_data_valid_1d))
        r_ram_ena <= 'd0;
    else if(w_op_user_active)//读ram数据写入eeprom
        r_ram_ena <= 'd1;
    else if(r_cmd_data_valid)//将uart dma传入的控制数据写入ram
        r_ram_ena <= 'd1;
    else
        r_ram_ena <= r_ram_ena;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_ram_wea <= 'd0;
    else
        r_ram_wea <= r_cmd_data_valid;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_ram_addra <= 'd0;
    else if(r_eeprom_commit)
        r_ram_addra <= 'd0;
    else if(r_ram_ena && (w_op_user_active ||ro_user_write_valid))//读取ram数据写入eeprom
        r_ram_addra <= r_ram_addra + 'd1;
    else if(r_cnt == 2)//将uart传入指令写入ram
        case (r_cmd_type)
            1       : r_ram_addra <= 'd0;
            2       : r_ram_addra <= 'd1;
            3       : r_ram_addra <= 'd4;
            4       : r_ram_addra <= 'd5;
            6       : r_ram_addra <= 'd6;
            7       : r_ram_addra <= 'd7;
            default : r_ram_addra <= 'd0;
        endcase
    else if(r_ram_wea) 
        r_ram_addra <= r_ram_addra + 1;
    else
        r_ram_addra <= r_ram_addra;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_ram_dina <= 'd0;   
    else
        r_ram_dina <= r_cmd_data;
end
//收到上传eeprom指令信号，将控制信息存到eeprom里
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_eeprom_commit <= 'd0;
    else if(r_cnt == 1 && ri_pre_cmd_valid && r_cmd_type == 9)
        r_eeprom_commit <= 'd1;
    else
        r_eeprom_commit <= 'd0;
end
//将指令存入eeprom
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        ro_user_operation_addr  <= 'd0;
        ro_user_operation_type  <= 'd0;
        ro_user_operation_len   <= 'd0;
        ro_user_operation_valid <= 'd0;        
    end
    else if(w_op_user_active)begin
        ro_user_operation_addr  <= 'd0;
        ro_user_operation_type  <= 'd0;
        ro_user_operation_len   <= 'd0;
        ro_user_operation_valid <= 'd0;        
    end
    else if(r_eeprom_commit) begin
        ro_user_operation_addr  <= 'd0;
        ro_user_operation_type  <= 'd1;
        ro_user_operation_len   <= 'd9;//只存9个byte
        ro_user_operation_valid <= 'd1;        
    end
    else if(r_eeprom_run_ctrl == 0) begin
        ro_user_operation_addr  <= 'd0;
        ro_user_operation_type  <= 'd2;
        ro_user_operation_len   <= 'd9;//只存9个byte
        ro_user_operation_valid <= 'd1;        
    end
    else begin
        ro_user_operation_addr  <= ro_user_operation_addr ;
        ro_user_operation_type  <= ro_user_operation_type ;
        ro_user_operation_len   <= ro_user_operation_len  ;
        ro_user_operation_valid <= ro_user_operation_valid;        
    end
end 

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_eeprom_write_cnt <= 'd0;
    else if(r_eeprom_write_cnt == 9)
        r_eeprom_write_cnt <= 'd0;
    else if(w_op_user_active || r_eeprom_write_cnt > 0)
        r_eeprom_write_cnt <= r_eeprom_write_cnt + 1;
    else
        r_eeprom_write_cnt <= r_eeprom_write_cnt;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_user_write_date <= 'd0;
    else
        ro_user_write_date <= w_ram_douta;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_user_write_valid <= 'd0;
    else if(ro_user_write_sop)
        ro_user_write_valid <= 'd0;
    else if(w_op_user_active) 
        ro_user_write_valid <= 'd1;
    else
        ro_user_write_valid <= ro_user_write_valid;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_user_write_sop <= 'd0;
    else if(w_op_user_active)
        ro_user_write_sop <= 'd1;
    else
        ro_user_write_sop <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_user_write_eop <= 'd0;
    else if(r_eeprom_write_cnt == 9 - 1)
        ro_user_write_eop <= 'd1;
    else
        ro_user_write_eop <= 'd0;
end
//上电读ram
// always @(posedge i_clk or posedge i_rst)begin
//     if(i_rst)
//         ro_system_run <= 'd0;
//     else if()
//         ro_system_run <= 'd1;
//     else
//         ro_system_run <= ro_system_run;
// end
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_system_run <= 'd0;
    else if(w_ram_init_end)
        ro_system_run <= 'd1;
    else
        ro_system_run <= ro_system_run;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_eeprom_run_ctrl <= 'd0;
    else if(w_ram_init_end) //表示已经从eeprom当中获取了所有指令并且存放到ram里
        r_eeprom_run_ctrl <= r_eeprom_run_ctrl + 'd1;
    else if(w_op_user_active && r_eeprom_run_ctrl == 0) //
        r_eeprom_run_ctrl <= r_eeprom_run_ctrl + 'd1;
    else
        r_eeprom_run_ctrl <= r_eeprom_run_ctrl;
end
//上电后从eeprom当中获取存入的控制指令存入ram当中
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        r_ram_enb <= 'd0;  
        r_ram_web <= 'd0;
    end
    else if(ri_user_read_valid) begin
        r_ram_enb <= 'd1;  
        r_ram_web <= 'd1;        
    end
    // else if() begin
    //     r_ram_enb <= 'd1;  
    //     r_ram_web <= 'd0;        
    // end
    else begin
        r_ram_enb <= 'd0;  
        r_ram_web <= 'd0;        
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_ram_addrb <= 'd0;
    else if(ri_user_read_valid) 
        r_ram_addrb <= r_ram_addrb + 'd1;
    else
        r_ram_addrb <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_ram_dinb <= 'd0;
    else if(ri_user_read_valid)
        r_ram_dinb <= ri_user_read_date;
    else
        r_ram_dinb <= 'd0;
end

//从ram当中拿到数据
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        ro_adc_chnnel  <= 'd0;
        ro_adc_speed   <= 'd0;
        ro_adc_start   <= 'd0;
        ro_adc_trig    <= 'd0;
        ro_flash_start <= 'd0;
        ro_flash_num   <= 'd0;        
    end
    else begin
        case (r_ram_addrb)
            0   : ro_adc_chnnel         <= ri_user_read_date;   
            1   : ro_adc_speed[7 : 0]   <= ri_user_read_date;
            2   : ro_adc_speed[15: 8]   <= ri_user_read_date;
            3   : ro_adc_speed[23:16]   <= ri_user_read_date;
            4   : ro_adc_start          <= ri_user_read_date;
            5   : ro_adc_trig           <= ri_user_read_date;
            6   : ro_flash_start        <= ri_user_read_date;
            7   : ro_flash_num[7 : 0]   <= ri_user_read_date;
            8   : ro_flash_num[15: 8]   <= ri_user_read_date;
        endcase       
    end

end


endmodule
