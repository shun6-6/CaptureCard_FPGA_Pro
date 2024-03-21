`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/06 10:46:13
// Design Name: 
// Module Name: iic_drive
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


module iic_drive#(
    parameter       P_ADDR_WIDTH     = 16   
)(
    input           i_clk               ,
    input           i_rst               ,
    /*----user interface----*/
    input   [6 :0]  i_device_addr       ,//�û������豸��ַ
    input   [15:0]  i_operation_addr    ,//�û������д���ݵ�ַ
    input   [7 :0]  i_operation_len     ,//�û������д���ݳ���
    input   [1 :0]  i_operation_type    ,//�û������д����
    input           i_operation_valid   ,//�û����������Ч�ź�
    output          o_operation_ready   ,//�û��������׼���ź�

    input   [7 :0]  i_write_date        ,//�û�д������
    output          o_write_req         ,//�û�д��������

    output  [7 :0]  o_read_date         ,//���IIC����������
    output          o_read_valid        ,//������Ч�ź�
    /*----IIC interface----*/
    output          o_iic_scl           ,//IICʱ����
    inout           io_iic_sda           //IIC˫��������
    );
/******************************function***************************/

/******************************parameter**************************/
localparam      P_ST_IDLE    = 0    ,//״̬��-����
                P_ST_START   = 1    ,//״̬��-��ʼλ
                P_ST_UADDR   = 2    ,//״̬��-�豸��ַ
                P_ST_DADDR1  = 3    ,//״̬��-���ݵ�ַ��λ
                P_ST_DADDR2  = 4    ,//״̬��-���ݵ�ַ��λ
                P_ST_WRITE   = 5    ,//״̬��-д����
                P_ST_REATART = 6    ,//״̬��-����iic����
                P_ST_READ    = 7    ,//״̬��-������
                P_ST_WATI    = 8    ,//�ȴ�Ӧ����ٷ���ֹͣλ
                P_ST_STOP    = 9    ,//״̬��-ֹͣ
                P_ST_EMPTY   = 10   ;//

localparam      P_W         = 1     ,//д����
                P_R         = 2     ;//������
/******************************port*******************************/

/******************************machine****************************/
reg  [7 :0]     r_st_cur            ;
reg  [7 :0]     r_st_nxt            ;
reg  [15:0]     r_st_cnt            ;
/******************************reg********************************/
reg  [7 :0]     ri_device_addr      ;//����豸��ַ��һλ����Ϊ��Ҫ��һλ��д����
reg  [15:0]     ri_operation_addr   ;
reg  [7 :0]     ri_operation_len    ;
reg  [1 :0]     ri_operation_type   ;

reg             ro_operation_ready  ;
reg  [7 :0]     ri_write_date       ;
reg             ro_write_req        ;//д��������
reg             r_write_valid       ;//д������Ч
reg  [7 :0]     ro_read_date        ;
reg             ro_read_valid       ;
reg  [15:0]     r_wr_cnt            ;//��дbyte������
reg             r_slave_ack         ;//iicӦ��
reg             r_ack_valid         ;//Ӧ����Ч

reg             ro_iic_scl          ;
reg             r_iic_st            ;//iicʱ��״̬
reg             r_iic_sda_ctrl      ;//iic���������̬�ſ���
reg             ro_iic_sda          ;//iic����ͨ�����

reg             r_st_restart        ;
reg             r_ack_lock          ;
reg  [7 :0]     r_read_device_addr  ;       
/******************************wire*******************************/
wire            w_operation_active  ;
wire            w_st_turn           ;//״̬����ת
wire            w_iic_sda           ;//iic����ͨ������
/******************************component**************************/
//��̬�Źٷ�����������ģ��
//��̬��ԭ��ʵ��
// IOBUF IOBUF_u0 (
//    .O   (ro_iic_sda      ),   // 1-bit output: Buffer output
//    .I   (w_iic_sda       ),   // 1-bit input: Buffer input
//    .IO  (io_iic_sda      ),   // 1-bit inout: Buffer inout (connect directly to top-level port)
//    .T   (!r_iic_sda_ctrl )    // 1-bit input: 3-state enable input
// );
/******************************assign*****************************/
assign  o_operation_ready   =   ro_operation_ready  ;
assign  o_write_req         =   ro_write_req        ;
assign  o_read_date         =   ro_read_date        ;
assign  o_read_valid        =   ro_read_valid       ;
assign  o_iic_scl           =   ro_iic_scl          ;
assign  w_operation_active  =   o_operation_ready & i_operation_valid;
assign  w_st_turn           =   r_st_cnt == 8 && r_iic_st;
//��̬�Ŵ���ʵ��
assign  io_iic_sda          =   r_iic_sda_ctrl  ? ro_iic_sda : 1'bz;
assign  w_iic_sda           =   !r_iic_sda_ctrl ? io_iic_sda : 1'b0;
/******************************always*****************************/
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_st_cur <= P_ST_IDLE;
    else
        r_st_cur <= r_st_nxt;
end

always @(*)begin
    case (r_st_cur)
        P_ST_IDLE    : r_st_nxt = w_operation_active ? P_ST_START : P_ST_IDLE;
        P_ST_START   : r_st_nxt = P_ST_UADDR;

        P_ST_UADDR   : r_st_nxt = w_st_turn    ? 
                                  r_st_restart ? P_ST_READ : P_ST_DADDR1
                                : P_ST_UADDR;
 
        P_ST_DADDR1  : r_st_nxt = r_slave_ack    ? P_ST_STOP   :                           
                                  w_st_turn      ? P_ST_DADDR2 : P_ST_DADDR1;
 
        P_ST_DADDR2  : r_st_nxt = w_st_turn && ri_operation_type == P_W ? P_ST_WRITE   :   
                                  w_st_turn && ri_operation_type == P_R ? P_ST_REATART :
                                  P_ST_DADDR2;
 
        P_ST_WRITE   : r_st_nxt = w_st_turn && r_wr_cnt == ri_operation_len - 1          
                                             ? P_ST_WATI   : P_ST_WRITE;

        P_ST_REATART : r_st_nxt = P_ST_STOP;

        // P_ST_READ    : r_st_nxt = w_st_turn && r_wr_cnt == ri_operation_len - 1
        //                                      ? P_ST_WATI   : P_ST_READ;
        P_ST_READ   : r_st_nxt = w_st_turn ? P_ST_WATI   : P_ST_READ;//�������һ��һ��byte

        P_ST_WATI    : r_st_nxt = P_ST_STOP;
        P_ST_STOP    : r_st_nxt = r_st_cnt == 1 ? P_ST_EMPTY : P_ST_STOP;
        P_ST_EMPTY   : r_st_nxt = r_st_restart | r_ack_lock ? P_ST_START : P_ST_IDLE;
        default      : r_st_nxt = P_ST_IDLE;
    endcase
end
//iicӦ���飬1����Ӧ��
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_ack_lock <= 'd0;
    else if(r_ack_valid && !w_iic_sda && r_st_cur == P_ST_DADDR1)
        r_ack_lock <= 'd0;
    else if(r_ack_valid && w_iic_sda && r_st_cur == P_ST_DADDR1)
        r_ack_lock <= 'd1;
    else
        r_ack_lock <= r_ack_lock;
end
//������ʱ����Ҫ�ȼ�д�����ݵ�ַ������������
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_st_restart <= 'd0;
    else if(r_st_cur == P_ST_READ)
        r_st_restart <= 'd0;
    else if(r_st_cur == P_ST_REATART)
        r_st_restart <= 'd1;
    else
        r_st_restart <= r_st_restart;
end
//���������ź�
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_operation_ready <= 'd0;
    else if(w_operation_active)
        ro_operation_ready <= 'd0;
    else if(r_st_cur == P_ST_IDLE)
        ro_operation_ready <= 'd1;
    else
        ro_operation_ready <= ro_operation_ready;
end
//�Ĵ��������
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        ri_device_addr    <= 'd0;
        ri_operation_addr <= 'd0;
        ri_operation_len  <= 'd0;
        ri_operation_type <= 'd0;
    end
    else if(w_operation_active)begin
        ri_device_addr    <= {i_device_addr,1'b0};//���۶�д����һ�ζ�дΪ��Ϊд����Ϊ������ǰҲ��Ҫ��д��ַ
        ri_operation_addr <= i_operation_addr;
        ri_operation_len  <= i_operation_len ;
        ri_operation_type <= i_operation_type;
    end
    else begin
        ri_device_addr    <= ri_device_addr   ;
        ri_operation_addr <= ri_operation_addr;
        ri_operation_len  <= ri_operation_len ;
        ri_operation_type <= ri_operation_type;
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_read_device_addr <= 'd0;
    else if(w_operation_active)
        r_read_device_addr <= {i_device_addr,1'b1};
    else
        r_read_device_addr <= r_read_device_addr;
end
//״̬������
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_st_cnt <= 'd0;
    else if(r_st_cur != r_st_nxt || r_write_valid || ro_read_valid)//ÿ��״̬��ת���д��8bit���ݹ���
        r_st_cnt <= 'd0;
    else if(r_st_cur == P_ST_STOP)
        r_st_cnt <= r_st_cnt + 'd1;
    else if(r_iic_st)
        r_st_cnt <= r_st_cnt + 'd1;
    else    
        r_st_cnt <= r_st_cnt;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_iic_scl <= 'd1;
    else if(r_st_cur >= P_ST_UADDR && r_st_cur <= P_ST_WATI)
        ro_iic_scl <= ~ro_iic_scl;
    else
        ro_iic_scl <= 'd1;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_iic_st <= 'd0;
    else if(r_st_cur >= P_ST_UADDR && r_st_cur <= P_ST_WATI)
        r_iic_st <= ~r_iic_st;
    else
        r_iic_st <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_iic_sda_ctrl <= 'd0;
    else if(r_st_cnt == 8 || r_st_nxt == P_ST_IDLE)
        r_iic_sda_ctrl <= 'd0;
    else if(r_st_cur >= P_ST_START && r_st_cur <= P_ST_WRITE || r_st_cur == P_ST_STOP)
        r_iic_sda_ctrl <= 'd1;
    else    
        r_iic_sda_ctrl <= r_iic_sda_ctrl;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_iic_sda <= 'd1;
    else if(r_st_cur == P_ST_START)
        ro_iic_sda <= 'd0;
    else if(r_st_cur == P_ST_UADDR)
        ro_iic_sda <= r_st_restart ? r_read_device_addr[7 - r_st_cnt] : ri_device_addr[7 - r_st_cnt];
    else if(r_st_cur == P_ST_DADDR1)
        ro_iic_sda <= ri_operation_addr[15 - r_st_cnt];
    else if(r_st_cur == P_ST_DADDR2)
        ro_iic_sda <= ri_operation_addr[7 - r_st_cnt];
    else if(r_st_cur == P_ST_WRITE)
        ro_iic_sda <= ri_write_date[7 - r_st_cnt];
    else if(r_st_cur == P_ST_READ)
        ro_iic_sda <= 'd0;  
    else if(r_st_cur == P_ST_STOP && r_st_cnt == 1)
        ro_iic_sda <= 'd1;
    else    
        ro_iic_sda <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_write_req <= 'd0;
    else if(r_st_cur == P_ST_DADDR2 && ri_operation_type == P_W && r_st_cnt == 7 && r_iic_st)
        ro_write_req <= 1'b1;//дһ������
    else if(r_st_cur >= P_ST_DADDR2 && ri_operation_type == P_W && r_st_cnt == 7 && r_iic_st)
        ro_write_req <= r_wr_cnt < ri_operation_len - 1 ? 'd1 : 1'b0;    
    else    
        ro_write_req <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_write_valid <= 'd0;
    else    
        r_write_valid <= ro_write_req;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ri_write_date <= 'd0;
    else if(r_write_valid)
        ri_write_date <= i_write_date;
    else    
        ri_write_date <= ri_write_date;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_wr_cnt <= 'd0;
    else if(r_st_cur == P_ST_IDLE)
        r_wr_cnt <= 'd0;
    else if((r_st_cur == P_ST_WRITE || r_st_cur == P_ST_READ) && r_write_valid)
        r_wr_cnt <= r_wr_cnt + 1;
    else    
        r_wr_cnt <= r_wr_cnt;
end 

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_read_date <= 'd0;
    else if(r_st_cur == P_ST_READ && r_st_cnt >= 1 && r_st_cnt <= 8 && !r_iic_st)// && r_iic_st
        ro_read_date <= {ro_read_date[6:0],w_iic_sda};    
    else    
        ro_read_date <= ro_read_date;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_read_valid <= 'd0;
    else if(r_st_cur == P_ST_READ && r_st_cnt == 8 && !r_iic_st)// ==7
        ro_read_valid <= 'd1;
    else    
        ro_read_valid <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_slave_ack <= 'd0;
    else if(r_ack_valid)
        r_slave_ack <= w_iic_sda;
    else    
        r_slave_ack <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_ack_valid <= 'd0;
    else    
        r_ack_valid <= w_st_turn;
end

// always @(posedge i_clk or posedge i_rst)begin
//     if(i_rst)
        
//     else if()
        
//     else if()
        
//     else    
        
// end
endmodule
