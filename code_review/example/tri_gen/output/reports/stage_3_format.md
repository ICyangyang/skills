# STAGE 3: 排版规则审查报告

**审查文件**: `example/tri_gen/tri_gen.v`
**审查时间**: 2025-01-26
**审查阶段**: STAGE_3 - 排版规则审查 [检查项13]

---

## 检查项 13: 排版缩进方式检查

**检查方法**: 是否用Space（空格）而非 Tab来进行缩进

**检查结果**: ⚠️ **警告**

**分析**:
经过检查，文件中存在以下排版问题：

### 13.1 缩进问题
代码使用了Tab字符进行缩进（从源文件可观察到制表符模式），应使用空格替代Tab。

### 13.2 缩进层次混乱
```verilog
// 第6行：端口声明缩进不一致
input		clk,res;        // 使用Tab缩进
output[8:0]	d_out;          // 使用Tab缩进

// 第13-16行：always块内if-else缩进不一致
always@(posedge clk or negedge res)
if(~res) begin                // if语句缺少begin-end块的标准缩进
    state<=0;d_out<=0;con<=0; // 多条语句在同一行
end
else begin
    case(state)
    0://上升                  // case分支缩进不规范
    begin
        d_out<=d_out+1;
```

### 13.3 具体位置
| 行号 | 问题 | 建议 |
|------|------|------|
| 1-5 | 模块端口列表缩进使用Tab | 改用4空格缩进 |
| 6-7 | 端口声明缩进不一致 | 统一使用4空格缩进 |
| 9-11 | 寄存器声明使用Tab | 改用4空格缩进 |
| 13-54 | always块内代码缩进混乱 | 使用一致的缩进层次 |

**规范引用**: Verilog_RTL_Coding_Standards-v1.4.3.md 第8条

**修复建议**:
1. 将所有Tab替换为4个空格
2. 统一缩进风格，建议：
   - module声明不缩进
   - 端口声明缩进1级（4空格）
   - always块内的语句缩进2级（8空格）
   - case分支内容缩进3级（12空格）

**示例修复后的代码格式**:
```verilog
module tri_gen (
    input       clk,
    input       res,
    output [8:0] d_out
);

    reg [1:0]   state;
    reg [8:0]   d_out;
    reg [7:0]   con;

    always @(posedge clk or negedge res) begin
        if (~res) begin
            state <= 2'b00;
            d_out <= 9'b0;
            con   <= 8'b0;
        end
        else begin
            case (state)
                2'b00: begin  // 上升
                    d_out <= d_out + 1;
                    if (d_out == 299) begin
                        state <= 2'b01;
                    end
                end
                // ... 其他状态
            endcase
        end
    end

endmodule
```

---

## STAGE 3 审查总结

| 检查项 | 名称 | 级别 | 结果 |
|--------|------|------|------|
| 13 | 排版缩进方式检查 | [S] Suggestion | ⚠️ 警告 |

**通过率**: 0/1 (存在警告)

**主要问题**:
1. 使用Tab而非空格进行缩进
2. 缩进层次不一致
3. 代码格式需要规范化

---

*审查完成，进入 STAGE 4*