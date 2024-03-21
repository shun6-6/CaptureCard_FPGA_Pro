项目说明:
多通道同步采集卡系统需支持8通道ADC同步采集，采样速率不低于200K。在此系统中可由上位机控制8通道采集状态，并可实时显示每个通道采集模拟量数值以及数值曲线。在上位机控制界面中，可设置采集卡触发模式（如自触发、外部触发）因此采集板卡上应有触发IO。在8路同步采集与触发模式功能的基础上，还要支持系统配置管理、系统交互、波形存储与回放、上电自检功能等等。在采样数据处理上应支持滤波与降采样。
模块说明：
1. CaptureCard_Top：顶层模块，产生相应时钟以及复位，提供设计与外界接口，包括UART、FLASH、EEPROM、AD7606。
2. Uart_Drive：UART驱动模块，与上位机进行数据交互。
3. Uart_DMA：将Uart_Drive按字节接收到的数据进行组帧处理，变为与其他模块交互的控制数据流，反方向上，将其他模块发送的数据流转化为按字节发送的形式。

![image](/picture/data_format.png#pic_center) 
