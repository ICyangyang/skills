# 阶段 4.2：状态机与复位设计审查报告

## 文件信息
- 审查文件：
  - example/uart/UART_RXer.v
  - example/uart/UART_TXer.v
  - example/uart/cmd_pro.v
  - example/uart/UART_top.v
- 审查时间：2025-02-27
- 规范版本：Verilog_RTL_Coding_Standards-v1.4.3

## 检查项目统计
- 总检查项：12
- 通过：4
- 未通过：8
- 警告：0

## 状态机检查结果

### 第 16 项：状态机状态定义检查 [R]
- **状态**: ❌ 未通过
- **问题位置**:
  - UART_RXer.v: 状态使用数值直接表示（0, 1, 2, ... 10）
  - UART_TXer.v: 状态使用数值直接表示（0, 1, 2, ... 10）
  - cmd_pro.v: 状态使用数值直接表示（0, 1, 2, 3, 4）
- **问题分析**: 未使用 `localparam` 或 `parameter` 定义状态，而是直接使用数字，严重影响可读性和可维护性
- **修复建议**:
```verilog
// 推荐写法
localparam ST_IDLE      = 4'd0;
localparam ST_WAIT_START = 4'd1;
localparam ST_RECV_B0   = 4'd2;
// ...
```

### 第 43 项：状态机命名检查 [S]
- **状态**: ❌ 未通过
- **问题分析**: 状态直接使用数字（0, 1, 2...），未使用 `ST_` 前缀命名

### 第 44 项：状态机结构检查 [R]
- **状态**: ❌ 未通过
- **问题位置**: UART_RXer.v, UART_TXer.v, cmd_pro.v
- **问题分析**: 所有状态机均为**单段式写法**，将状态寄存、次态逻辑和输出逻辑混合在一个时序always块中
- **当前代码结构**:
```verilog
// UART_RXer.v - 单段式状态机（不推荐）
always @(posedge clk or negedge res)
if (~res) begin
    state <= 0;
    // ...
end else begin
    case (state)
        0: begin /* 状态转移和输出 */ end
        1: begin /* 状态转移和输出 */ end
        // ...
    endcase
end
```
- **推荐写法**: 两段式状态机
```verilog
// 时序块 - 状态寄存
always @(posedge clk or negedge res) begin
    if (~res)
        cur_state <= ST_IDLE;
    else
        cur_state <= nxt_state;
end

// 组合块 - 次态逻辑和输出
always @(*) begin
    nxt_state = cur_state;
    // default assignments
    case (cur_state)
        ST_IDLE: begin
            if (condition)
                nxt_state = ST_NEXT;
        end
        // ...
        default: nxt_state = ST_IDLE;
    endcase
end
```

### 第 45 项：状态机默认状态检查 [R]
- **状态**: ✅ 通过
- **问题分析**: 所有状态机case语句均包含 `default` 分支
- **代码位置**:
  - UART_RXer.v Line 170-177
  - UART_TXer.v Line 170-177
  - cmd_pro.v Line 74-78

## 复位检查结果

### 第 17 项：寄存器复位方式检查 [S]
- **状态**: ✅ 通过
- **分析**: 所有寄存器均采用**异步复位**方式
- **代码示例**:
```verilog
always @(posedge clk or negedge res)  // 异步复位
```

### 第 18 项：寄存器复位值检查 [S]
- **状态**: ✅ 通过
- **分析**: 所有寄存器复位值均为常量（0）

### 第 19 项：多变量寄存器复位检查 [S]
- **状态**: ❌ 未通过
- **问题位置**: UART_RXer.v Line 29-32, UART_TXer.v Line 29-32
- **问题分析**: 复位块中存在语法错误，`en_data_out;<=0;` 分号位置错误
- **当前代码**:
```verilog
if(~res)begin
    state<=0;con<=0;con_bits<=0;RX_delay<=0;
    data_out<=0;en_data_out;<=0;  // 错误！
end
```
- **修复**: `en_data_out <= 0;`

### 第 20 项：复位信号逻辑检查 [R]
- **状态**: ✅ 通过
- **分析**: 未发现同步复位和异步复位信号混合使用

### 第 21 项：复位信号使用前检查 [S]
- **状态**: ✅ 通过
- **分析**: 单时钟域设计，复位信号直接使用

### 第 22 项：复位信号数量检查 [R]
- **状态**: ✅ 通过
- **分析**: 每个always块仅使用一个复位信号

### 第 23 项：组合逻辑复位检查 [R]
- **状态**: ✅ 通过
- **分析**: 无组合逻辑复位

### 第 24 项：复位条件写法检查 [S]
- **状态**: ❌ 未通过
- **问题位置**: UART_RXer.v, UART_TXer.v, cmd_pro.v
- **问题分析**: 复位条件使用 `if(~res)` 后直接使用 `else begin`，格式正确，此项实际应通过
- **修正**: ✅ 通过

## 状态机分析汇总

| 模块 | 状态机数量 | 状态定义方式 | 状态编码 | 结构方式 | default分支 |
|------|-----------|-------------|----------|----------|-------------|
| UART_RXer | 1 | 数值字面量 | 二进制 | 单段式 | 有 |
| UART_TXer | 1 | 数值字面量 | 二进制 | 单段式 | 有 |
| cmd_pro | 1 | 数值字面量 | 二进制 | 单段式 | 有 |
| UART_top | 0 | N/A | N/A | N/A | N/A |

## 复位分析汇总

- 时序always块数量：3
- 异步复位：3
- 同步复位：0
- 无复位：0
- 问题汇总：
  1. 复位块存在语法错误（分号位置）
  2. 多变量赋值语句格式需改进

## 阶段总结

状态机设计存在严重问题：
1. **状态定义不规范**：未使用 `localparam` 定义状态，直接使用数字，可读性差
2. **单段式状态机**：不符合规范要求的两段式写法，不利于综合优化和调试
3. **状态命名缺失**：未使用 `ST_` 前缀命名

复位设计基本符合要求，但存在语法错误需要修复。

### 优先修复建议
1. 修复复位块语法错误（Line 31）
2. 使用 `localparam` 定义状态
3. 改写为两段式状态机