`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/12 10:32:14
// Design Name: 
// Module Name: eeprom_ctrl
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


module eeprom_ctrl(
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
    /*----iic drive interface----*/
    output  [6 :0]  o_device_addr           ,
    output  [15:0]  o_operation_addr        ,
    output  [7 :0]  o_operation_len         ,
    output  [1 :0]  o_operation_type        ,
    output          o_operation_valid       ,
    input           i_operation_ready       ,

    output  [7 :0]  o_write_date            ,
    input           i_write_req             ,

    input   [7 :0]  i_read_date             ,
    input           i_read_valid             
    );
/******************************function***************************/

/******************************parameter**************************/
localparam      P_W             = 1     ,//写数据
                P_R             = 2     ;//读数据

localparam      P_ST_IDLE       = 0     ,
                P_ST_WRITE      = 1     ,
                P_ST_WAIT       = 2     ,
                P_ST_READ       = 3     ,
                P_ST_REREAD     = 4     ,
                P_ST_OUT_DATA   = 5     ;
/******************************port*******************************/

/******************************machine****************************/
reg  [7 :0]     r_st_cur                ;
reg  [7 :0]     r_st_nxt                ;
/******************************reg********************************/
/*----user reg----*/
reg             ro_user_operation_ready ;
reg  [7 :0]     ro_user_read_date       ; 
reg             ro_user_read_valid      ; 
reg  [2 :0]     ri_eeprom_addr          ;
reg  [15:0]     ri_user_operation_addr  ;
reg  [1 :0]     ri_user_operation_type  ;
reg  [7 :0]     ri_user_operation_len   ;
reg  [7 :0]     ri_user_write_date      ;
reg             ri_user_write_valid     ;   
reg             ri_user_write_sop       ;
reg             ri_user_write_eop       ;
reg             r_fifo_rden             ;
reg  [7 :0]     r_read_cnt              ;
reg  [15:0]     r_read_addr             ;
reg             ro_user_read_valid_1d   ;
/*----iic drive reg----*/
reg             ri_operation_ready      ;  
reg [7 :0]      ri_read_date            ;
reg             ri_read_valid           ;
reg [6 :0]      ro_device_addr          ;
reg [15:0]      ro_operation_addr       ;
reg [7 :0]      ro_operation_len        ;
reg [1 :0]      ro_operation_type       ;
reg             ro_operation_valid      ;
/******************************wire*******************************/
wire            w_user_active           ;
wire            w_drive_end             ;
wire            w_drive_active          ;
wire [7 :0]     w_fifo_rdata            ;
wire            w_fifo_read_empty       ;
/******************************component**************************/
FIFO_8x1024 fifo_write_u0 (
  .clk          (i_clk              ),
  .srst         (i_rst              ),
  .din          (ri_user_write_date ),
  .wr_en        (ri_user_write_valid),
  .rd_en        (i_write_req        ),
  .dout         (o_write_date       ),
  .full         (                   ),
  .empty        (                   ),
  .wr_rst_busy  (),  
  .rd_rst_busy  ()   
);
FIFO_8x1024 fifo_read_u0 (
  .clk          (i_clk              ),
  .srst         (i_rst              ),
  .din          (ri_read_date       ),
  .wr_en        (ri_read_valid      ),
  .rd_en        (r_fifo_rden        ),
  .dout         (w_fifo_rdata       ),
  .full         (                   ),
  .empty        (w_fifo_read_empty  ),
  .wr_rst_busy  (),  
  .rd_rst_busy  ()   
);
/******************************assign*****************************/
assign  o_user_operation_ready  = ro_user_operation_ready    ;
assign  o_user_read_date        = ro_user_read_date          ;
assign  o_user_read_valid       = ro_user_read_valid_1d      ;
assign  o_device_addr           = ro_device_addr             ;
assign  o_operation_addr        = ro_operation_addr          ;
assign  o_operation_len         = ro_operation_len           ;
assign  o_operation_type        = ro_operation_type          ;
assign  o_operation_valid       = ro_operation_valid         ;
assign  w_user_active           = o_user_operation_ready & i_user_operation_valid;
assign  w_drive_active          = o_operation_valid & i_operation_ready;
assign  w_drive_end             = i_operation_ready & !ri_operation_ready;//iic驱动的准备信号上升沿：即iic drive一次操作结束
/******************************always*****************************/
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_st_cur <= P_ST_IDLE;
    else
        r_st_cur <= r_st_nxt;
end

always @(*)begin
    case (r_st_cur)
        P_ST_IDLE     : r_st_nxt = w_user_active && i_user_operation_type == P_W ? P_ST_WRITE :
                                   w_user_active && i_user_operation_type == P_R ? P_ST_WAIT  :
                                   P_ST_IDLE;
        // P_ST_WRITE    : r_st_nxt = ri_user_write_eop ? P_ST_IDLE : P_ST_WRITE;
        P_ST_WRITE    : r_st_nxt = w_drive_end && ri_user_operation_type == P_W ? P_ST_IDLE : P_ST_WRITE;
        P_ST_WAIT     : r_st_nxt = P_ST_READ;
        P_ST_READ     : r_st_nxt = w_drive_end ? 
                                    r_read_cnt == ri_user_operation_len - 1 ? P_ST_OUT_DATA : P_ST_REREAD
                                    : P_ST_READ;   
        P_ST_REREAD   : r_st_nxt = P_ST_READ; 
        P_ST_OUT_DATA : r_st_nxt = w_fifo_read_empty ? P_ST_IDLE : P_ST_OUT_DATA;
        default       : r_st_nxt = P_ST_IDLE;
    endcase
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst) begin
        ri_eeprom_addr         <= 'd0;
        ri_user_operation_addr <= 'd0;
        ri_user_operation_type <= 'd0;
        ri_user_operation_len  <= 'd0;
    end
    else if(w_user_active)begin
        ri_eeprom_addr         <= i_eeprom_addr;
        ri_user_operation_addr <= i_user_operation_addr;
        ri_user_operation_type <= i_user_operation_type;
        ri_user_operation_len  <= i_user_operation_len;
    end
    else begin
        ri_eeprom_addr         <= ri_eeprom_addr;
        ri_user_operation_addr <= ri_user_operation_addr;
        ri_user_operation_type <= ri_user_operation_type;
        ri_user_operation_len  <= ri_user_operation_len;
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst) begin
        ri_user_write_date  <= 'd0;
        ri_user_write_valid <= 'd0;
    end
    else begin
        ri_user_write_date  <= i_user_write_date ;
        ri_user_write_valid <= i_user_write_valid;
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ri_operation_ready <= 'd0;
    else
        ri_operation_ready <= i_operation_ready;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_user_operation_ready <= 'd1;
    else if(w_user_active)
        ro_user_operation_ready <= 'd0;
    else if(r_st_cur == P_ST_IDLE)
        ro_user_operation_ready <= 'd1;
    // else if(w_drive_end && ri_operation_type == P_W)
    //     ro_user_operation_ready <= 'd1;
    // else if(w_fifo_read_empty && ro_user_read_valid && ri_operation_type == P_R)
    //     ro_user_operation_ready <= 'd1;
    else
        ro_user_operation_ready <= ro_user_operation_ready; 
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst) begin
        ri_read_date      <= 'd0;
        ri_read_valid     <= 'd0;
        ri_user_write_sop <= 'd0;
        ri_user_write_eop <= 'd0;
    end
    else begin
        ri_read_date      <= i_read_date     ;
        ri_read_valid     <= i_read_valid    ;
        ri_user_write_sop <= i_user_write_sop;
        ri_user_write_eop <= i_user_write_eop;
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst) begin
        ro_device_addr     <= 'd0;
        ro_operation_addr  <= 'd0;
        ro_operation_len   <= 'd0;
        ro_operation_type  <= 'd0;
        ro_operation_valid <= 'd0;
    end
    else if(w_drive_active)begin
        ro_device_addr     <= 'd0;
        ro_operation_addr  <= 'd0;
        ro_operation_len   <= 'd0;
        ro_operation_type  <= 'd0;
        ro_operation_valid <= 'd0;
    end
    else if(ri_user_write_eop)begin
        ro_device_addr     <= {4'b1010,ri_eeprom_addr};
        ro_operation_addr  <= ri_user_operation_addr  ;
        ro_operation_len   <= ri_user_operation_len   ;
        ro_operation_type  <= ri_user_operation_type  ;
        ro_operation_valid <= 'd1;
    end
    else if(r_st_nxt == P_ST_READ && r_st_cur != P_ST_READ)begin
        ro_device_addr     <= {4'b1010,ri_eeprom_addr};
        ro_operation_addr  <= r_read_addr  ;
        ro_operation_len   <= 1;
        ro_operation_type  <= ri_user_operation_type  ;
        ro_operation_valid <= 'd1;
    end
    else begin
        ro_device_addr     <= ro_device_addr    ;
        ro_operation_addr  <= ro_operation_addr ;
        ro_operation_len   <= ro_operation_len  ;
        ro_operation_type  <= ro_operation_type ;
        ro_operation_valid <= ro_operation_valid;
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_fifo_rden <= 'd0;
    else if(w_fifo_read_empty)
        r_fifo_rden <= 'd0;
    else if(r_st_nxt == P_ST_OUT_DATA && r_st_cur != P_ST_OUT_DATA)
        r_fifo_rden <= 'd1;
    else
        r_fifo_rden <= r_fifo_rden;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_user_read_date <= 'd0;
    else
        ro_user_read_date <= w_fifo_rdata;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_user_read_valid <= 'd0;
    else if(w_fifo_read_empty)
        ro_user_read_valid <= 'd0;
    else if(r_fifo_rden)
        ro_user_read_valid <= 'd1;
    else
        ro_user_read_valid <= ro_user_read_valid;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_user_read_valid_1d <= 'd0;
    else
        ro_user_read_valid_1d <= ro_user_read_valid;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_read_addr <= 'd0;
    else if(w_user_active)
        r_read_addr <= i_user_operation_addr;
    else if(r_st_cur == P_ST_READ && w_drive_end)
        r_read_addr <= r_read_addr + 1'd1;
    else
        r_read_addr <= r_read_addr;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_read_cnt <= 'd0;
    else if(r_st_cur == P_ST_IDLE)
        r_read_cnt <= 'd0;
    else if(r_st_cur == P_ST_READ && w_drive_end)
        r_read_cnt <= r_read_cnt + 1'd1;
    else
        r_read_cnt <= r_read_cnt;
end

endmodule
