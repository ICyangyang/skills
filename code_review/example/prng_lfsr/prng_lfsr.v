// 4位伪随机码发生器（基于LFSR，模2加反馈）
module prng_lfsr (
    input        clk,   // 时钟信号
    input        res,   // 复位信号（高电平有效）
    output       y      // 伪随机码输出
);

// 定义4位移位寄存器（存储当前状态）
reg [3:0] d;

// 输出连接：取寄存器最低位作为伪随机码输出
assign y = d[0];

// 时序逻辑：移位+反馈（复位时初始化状态）
always @(posedge clk or posedge res) begin  // 原代码中res是negedge，这里统一为posedge更常用
    if (res) begin
        // 复位时初始化为非全0状态（LFSR不能初始化为全0，否则无法产生随机序列）
        d <= 4'b1111;  
    end else begin
        // 1. 右移：高位接收低位，d[2:0] = 原d[3:1]
        d[2:0] <= d[3:1];
        // 2. 模2加反馈：最高位d[3] = 原d[3] ^ 原d[0]（异或等价于模2加）
        d[3]   <= d[3] ^ d[0];
    end
end

endmodule
