**项目说明** :
多通道同步采集卡系统需支持8通道ADC同步采集，采样速率不低于200K。在此系统中可由上位机控制8通道采集状态，并可实时显示每个通道采集模拟量数值以及数值曲线。在上位机控制界面中，可设置采集卡触发模式（如自触发、外部触发）因此采集板卡上应有触发IO。在8路同步采集与触发模式功能的基础上，还要支持系统配置管理、系统交互、波形存储与回放、上电自检功能等等。在采样数据处理上应支持滤波与降采样。

![image](/picture/summary.png) 

模块说明：
## 1. CaptureCard_Top
顶层模块，产生相应时钟以及复位，提供设计与外界接口，包括UART、FLASH、EEPROM、AD7606。
## 2. Uart_Drive
UART驱动模块，与上位机进行数据交互。
## 3. Uart_DMA
接收方向上，将Uart_Drive按字节接收到的数据进行组帧处理，变为与其他模块交互的数据报文，发送方向上，将其他模块发送的数据报文转化为按字节发送的形式。
![image](/picture/data_format.png#pic_center) 

**前导码** ：0x55

**指令** ：
+ 8'd1：ADC   配置采样通道数 1B
+ 8'd2：ADC   配置采样率 3B(高位在前)（AD7606最大采样率200K，需要3Byte表示）
+ 8'd3：ADC   配置采样状态（开启、关闭） 1B 0-关闭 1-开启
+ 8'd4：ADC   触发方式 1B 0-自触发 1-外部触发
+ 8'd5：ADC   8通道电压采集结果查询：1B 0-请求 1-回应（后面接数据2B * 8，每个电压数据为16bit）
+ 8'd6：FLASH 波形储存开启 1B 0-关闭 1-开启
+ 8'd7：FLASH 配置波形存储的点数 2B 0~65535
+ 8'd8：FLASH 波形回放开启 1B 0-关闭 1-开启
+ 8'd9：Ctrl  上电自检信息查询 :1B 0-请求 1-回应(后面接数据-1B)

**交互配置信息** ：
+ 配置采样通道数
+ 配置采样率
+ 配置采样状态（开启 关闭）
+ 触发方式（自触发、外部触发）
+ 波形存储开启
+ 配置波形存储点数
+ 波形回放开启
+ 上电自检信息查询

## 4. Data_Mclk_buf
跨时钟域模块，基于异步FIFO设计
## 5. BUS_MUX
总线分流器，将上位机通过UART传输的命令进行分类，分别下发给AD7606、AT23C64、W25Q64等模块
## 6. AD7606_ctrl
解析传递给AD7606的配置信息
## 7. AD7606_DATA_pkt
组包模块，将8通道收集到的数据组成一个数据包的形式
## 8. AD7606_drive
AD7606驱动，控制ADC芯片进行采样
## 9. AD7606_module
例化上述三个AD7606的相关模块
## 10. Parameter_ctrl
参数控制模块，控制配置参数存储以及上电自动配置，包含模块eeprom_drive、parameter_ram
## 11. eeprom_drive
EEPROM驱动模块
## 12. parameter_ram
将UART传输的控制总线信息原封不动传递给总线分流器，同时在本地对其进行解析，将解析出来的所有控制信息存储到本地RAM，一旦收到上位机发送的上传EEPROM指令时，则将RAM当中的数据上传到EEPROM当中，在下一次上电的时候会将EEPROM当中的数据再次读取到RAM当中，同时将EEPROM当中的数据输出到控制端口


