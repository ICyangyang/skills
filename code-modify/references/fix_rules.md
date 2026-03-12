# Code Modify 修复规则

## 概述

本文档描述 code-modify skill 的修复规则库，每种问题都有对应的修复方式。

## 文件头修复 (file_header)

| ID | 问题 | 修复方式 |
|----|------|----------|
| FH001 | 缺少文件头 | 在文件开头添加完整的文件头 |
| FH002 | 缺少 Engineer | 在第一行注释后添加 Engineer 字段 |
| FH003 | 缺少 Create Date | 在 Engineer 后添加 Create Date |
| FH004 | 缺少 Description | 在 Create Date 后添加 Description |
| FH005 | 缺少 Version | 在 Description 后添加 Version |

**标准文件头格式：**
```verilog
// Engineer: ICyangyang
// Create Date: 2026-03-12
// Description: Module description
// Version: 1.0
```

## 命名规则修复 (naming)

| ID | 问题 | 修复方式 | 示例 |
|----|------|----------|------|
| NM001 | 单字母信号名 | 替换为描述性名称 | d → data_in, q → data_out |
| NM002 | 大小写混用 | 转换为小写下划线 | ModuleName → module_name |

**常见替换规则：**
- `d` → `data_in` 或 `din`
- `q` → `data_out` 或 `dout`
- `in` → `data_in`
- `out` → `data_out`
- `en` → `enable`
- `flag` → `flag_reg`
- `clk` → `clk` (保留)
- `rst` → `rst_n` (低电平有效)

## 排版格式修复 (format)

| ID | 问题 | 修复前 | 修复后 |
|----|------|--------|--------|
| FM001 | Tab 缩进 | `\t` | 4 空格 |
| FM002 | if 括号空格 | `if(` | `if (` |
| FM003 | begin 前空格 | `)begin` | `) begin` |
| FM004 | always @(*) | `always @(*)` | `always @(*)` |

**修复规则：**
- 所有缩进使用 4 空格
- 括号内侧不留空格，外侧留空格
- `begin` 独占一行

## 电路设计修复 (design)

| ID | 问题 | 严重性 | 说明 |
|----|------|--------|------|
| DS001 | 时序逻辑用阻塞赋值 | ❌ 错误 | 必须用 `<=` |
| DS002 | 组合逻辑用非阻塞赋值 | ❌ 错误 | 必须用 `=` |
| DS003 | if-else 不完整 | ⚠️ 警告 | 可能产生锁存器 |
| DS004 | case 无 default | ⚠️ 警告 | 可能产生锁存器 |
| DS005 | 异步复位用高电平 | ⚠️ 建议 | 建议用 `rst_n` 低电平 |

### 时序逻辑示例

```verilog
// 错误 - 使用阻塞赋值
always @(posedge clk) begin
    q = d;  // ❌ 错误
end

// 正确 - 使用非阻塞赋值
always @(posedge clk) begin
    q <= d;  // ✅ 正确
end
```

### 组合逻辑示例

```verilog
// 错误 - 使用非阻塞赋值
always @(*) begin
    q <= d;  // ❌ 错误
end

// 正确 - 使用阻塞赋值
always @(*) begin
    q = d;   // ✅ 正确
end
```

### if-else 完整性

```verilog
// 可能产生锁存器 - 不完整
always @(*) begin
    if (en)
        q = d;  // 没有 else，分支
end

// 正确 - 完整分支
always @(*) begin
    if (en)
        q = d;
    else
        q = q;  // 或默认值
end
```

### case default

```verilog
// 可能产生锁存器
case (state)
    IDLE: next_state = RUN;
    RUN:  next_state = DONE;
endcase

// 正确 - 添加 default
case (state)
    IDLE: next_state = RUN;
    RUN:  next_state = DONE;
    default: next_state = IDLE;
endcase
```

## 修复模式说明

| 模式 | 说明 | 行为 |
|------|------|------|
| dry_run | 试运行 | 只显示修改建议，不修改文件 |
| apply | 应用修复 | 直接修改文件 |
| backup | 备份后修复 | 先备份 `.bak`，再修改 |

## 修复优先级

1. **文件头** - 必须修复，否则代码不规范
2. **命名规则** - 推荐修复，提高可读性
3. **格式** - 推荐修复，保持代码风格一致
4. **设计** - 谨慎修复，可能涉及设计意图

## 注意事项

1. 修复前会自动备份（当 MODE=backup 时）
2. 无法自动修复的问题会标记为 "需要人工确认"
3. 修复后建议重新运行 verilog_review 验证
4. 复杂设计问题需要人工审查