# 状态机与复位设计审查总结报告

**审查文件:** `/home/icyangyang/tools/code_review/example/tri_gen/tri_gen.v`
**审查日期:** 2024年
**审查规范:** Verilog_RTL_Coding_Standards-v1.4.3
**审查类别:** 状态机与复位设计 (STAGE_4_2)
**⚠️ 部分审查：仅审查 [状态机与复位设计 (STAGE_4_2)]**

---

## 一、审查概览

| 指标 | 数值 |
|------|------|
| 总检查项数 | 9 (检查项 #16-24) |
| 适用检查项数 | 7 |
| Rule (必须) 未通过数 | 0 |
| Suggestion (推荐) 未通过数 | 1 |
| 不适用项数 | 2 |

---

## 二、检查项结果

| 序号 | 检查项 | 级别 | 结果 | 说明 |
|------|--------|------|------|------|
| 16 | 状态机检查 | S | ❌ 未通过 | 状态未用localparam定义，未采用两段式写法 |
| 17 | 寄存器复位方式检查 | S | ✅ 通过 | 使用异步复位 |
| 18 | 寄存器复位值检查 | S | ✅ 通过 | 复位值为常量 |
| 19 | 多变量寄存器复位检查 | S | ✅ 通过 | 所有寄存器都被复位 |
| 20 | 复位信号逻辑检查 | R | ✅ 通过 | 复位信号无组合逻辑 |
| 21 | 复位信号使用前检查 | S | ⚠️ 不适用 | 复位信号不跨时钟域 |
| 22 | 复位信号数量检查 | R | ✅ 通过 | 只有一个复位信号 |
| 23 | 组合逻辑复位检查 | R | ⚠️ 不适用 | 当前无组合逻辑always块 |
| 24 | 复位条件写法检查 | S | ✅ 通过 | 使用else begin写法正确 |

---

## 三、关键问题分析

### ❌ 检查项 #16 - 状态机检查 [S]

**问题描述:**

状态机存在以下三个主要问题：

1. **状态定义不符合规范**
   - 当前使用数字 0, 1, 2, 3 表示状态
   - 规范要求使用 `localparam` 定义符号常量
   - 状态命名应使用 `ST_` 前缀（规范第7条第3款）

2. **未采用两段式写法**
   - 规范第7条要求状态机采用两段式写法
   - 第一段：时序逻辑得到 `cur_state`
   - 第二段：组合逻辑得到 `nxt_state` 和状态机输出
   - 当前代码将状态跳转和输出逻辑混在一个always块中

3. **缺少default条件**
   - 规范第7条第2款要求状态机有默认状态
   - 虽然代码注释说明"2bite四个状态满了"，但按照规范仍应提供default条件防止死锁

**当前代码:**

```verilog
always@(posedge clk or negedge res)
if(~res) begin
    state<=0;d_out<=0;con<=0;
end
else begin
    case(state)
        0://上升
        begin
            d_out<=d_out+1;
            if(d_out==299) begin
                state<=1;
            end
        end
        1://平顶；
        begin
            if(con==200) begin
                state<=2;
                con<=0;
            end
            else begin
                con<=con+1;
            end
        end
        2://下降；
        begin
            d_out<=d_out-1;
            if(d_out==1) begin
                state<=3;
            end
        end
        3://平顶，不需要default了，2bite四个状态满了
        begin
            if(con==200) begin
                state<=0;
                con<=0;
            end
            else begin
                con<=con+1;
            end
        end
    endcase
end
```

**建议修复:**

```verilog
// 状态定义 (使用 ST_ 前缀，符合规范第7条第3款)
localparam ST_RISING  = 2'b00;
localparam ST_TOP     = 2'b01;
localparam ST_FALLING = 2'b10;
localparam ST_BOTTOM  = 2'b11;

// 状态寄存器和输出寄存器
reg [1:0] cur_state;
reg [1:0] nxt_state;
reg [8:0] d_out;
reg [7:0] hold_cnt;

// 第一段：时序逻辑 - 状态寄存器
always @(posedge clk or negedge res) begin
    if(~res) begin
        cur_state <= ST_RISING;
        d_out     <= 9'd0;
        hold_cnt  <= 8'd0;
    end
    else begin
        cur_state <= nxt_state;
        d_out     <= d_out_nxt;
        hold_cnt  <= hold_cnt_nxt;
    end
end

// 第二段：组合逻辑 - 下一状态和输出逻辑
always @(*) begin
    // 默认值：保持当前状态
    nxt_state    = cur_state;
    d_out_nxt    = d_out;
    hold_cnt_nxt = hold_cnt;

    case(cur_state)
        ST_RISING: begin // 上升阶段
            d_out_nxt = d_out + 9'd1;
            if(d_out == 9'd299) begin
                nxt_state = ST_TOP;
            end
        end

        ST_TOP: begin // 平顶阶段
            if(hold_cnt == 8'd200) begin
                nxt_state    = ST_FALLING;
                hold_cnt_nxt = 8'd0;
            end
            else begin
                hold_cnt_nxt = hold_cnt + 8'd1;
            end
        end

        ST_FALLING: begin // 下降阶段
            d_out_nxt = d_out - 9'd1;
            if(d_out == 9'd1) begin
                nxt_state = ST_BOTTOM;
            end
        end

        ST_BOTTOM: begin // 平底阶段
            if(hold_cnt == 8'd200) begin
                nxt_state    = ST_RISING;
                hold_cnt_nxt = 8'd0;
            end
            else begin
                hold_cnt_nxt = hold_cnt + 8'd1;
            end
        end

        default: nxt_state = ST_RISING; // 默认状态，防止死锁
    endcase
end
```

**符合规范要点：**
- ✅ 使用两段式写法（第一段时序，第二段组合）
- ✅ 状态命名使用 ST_ 前缀（ST_RISING、ST_TOP、ST_FALLING、ST_BOTTOM）
- ✅ 使用 localparam 定义状态常量
- ✅ 组合逻辑块使用 `always @(*)`
- ✅ nxt_state 初始化为 cur_state（默认保持当前状态）
- ✅ 必须有 default 条件防止状态机死锁
- ✅ 输出逻辑在组合逻辑块中计算，使用 _nxt 后缀表示下一周期的值
- ✅ 使用 `hold_cnt` 代替 `con`，符合标准命名缩写（规范表1）

---

## 四、优秀实践

该代码在以下方面符合规范要求：

1. ✅ **使用异步复位:** always块使用异步复位 `always@(posedge clk or negedge res)`
2. ✅ **所有变量都被复位:** 复位时 state、d_out、con 都被正确复位
3. ✅ **复位值为常量:** 所有寄存器的复位值都是常量 0
4. ✅ **复位信号无组合逻辑:** 复位信号直接使用，无组合逻辑
5. ✅ **只有一个复位信号:** always块中只有一个复位信号 res
6. ✅ **复位条件写法正确:** 复位条件后使用 `else begin`

---

## 五、修复优先级

| 优先级 | 问题 | 检查项 | 建议操作 |
|--------|------|--------|----------|
| P1 | 状态机设计不符合规范 | #16 | 采用两段式写法，使用localparam和ST_前缀 |
| P1 | 缺少default条件 | #16 | 添加default分支防止死锁 |
| P2 | 信号命名优化 | #16 | con→hold_cnt，state→cur_state/nxt_state |

---

## 六、总体评价

### 代码质量评分（状态机与复位设计部分）

| 维度 | 评分 | 说明 |
|------|------|------|
| 规范符合度 | ⭐⭐⭐⭐☆ | 7/8 适用项通过 |
| 状态机设计 | ⭐⭐☆☆☆ | 未采用两段式写法，状态未用localparam定义 |
| 复位设计 | ⭐⭐⭐⭐⭐ | 完全符合规范要求 |

### 综合评价

`tri_gen.v` 是一个三角波发生器模块，本次仅审查了状态机与复位设计部分。

**优点:**
- 异步复位实现正确
- 所有寄存器复位完整
- 复位信号处理规范

**需要改进:**
- **高优先级:** 采用两段式状态机写法，符合规范第7条要求
- **高优先级:** 使用 `localparam` 定义状态常量，状态命名使用 ST_ 前缀
- **高优先级:** 添加 default 条件防止状态机死锁
- **中优先级:** 优化信号命名（con→hold_cnt，state→cur_state/nxt_state）

**总结:** 该代码在复位设计方面表现良好，完全符合规范要求。但在状态机设计方面存在不符合规范的问题，需要采用两段式写法并使用规范的命名方式。修复后代码可读性和可维护性将显著提升。

---

## 七、规范参考

本次审查基于以下规范条款：

- **第10条:** 复位处理规范
  - 寄存器采用异步复位
  - 复位值为常量
  - 多变量在时序always块时都要复位
  - 复位信号无组合逻辑
  - 一个always块中复位信号不超过1个
  - 复位条件后使用else而非else if

- **第7条:** 状态机设计规范
  - 状态机采用两段式写法
  - 要求状态机有默认状态（default条件）
  - 状态命名使用 ST_ 前缀
  - 状态命名使用 localparam

---

## 八、输出文件

本次审查生成的文件位于 `example/tri_gen/output/` 目录：

```
output/
├── review_progress.json      # 审查进度
├── reports/
│   └── stage_4_2_fsm_reset.md  # 状态机与复位设计详细报告
└── final_summary_fsm_reset.md   # 本总结报告
```

---

## 九、参考文档

- 规范文档: `Verilog_RTL_Coding_Standards-v1.4.3/Verilog_RTL_Coding_Standards-v1.4.3.md`
  - 第7条：状态机设计规范
  - 第10条：复位处理规范
- 检查清单: `Verilog_RTL_Coding_Standards-v1.4.3/checklist.md`
- 工作流配置: `.claude/skills/verilog_review/workflow.yaml`
- 规则数据库: `.claude/skills/verilog_review/rules/verilog_standards.json`

---

**审查完成时间:** 2024年
**审查工具:** Verilog RTL Code Review Skill v1.1.0
**⚠️ 部分审查：仅审查 [状态机与复位设计 (STAGE_4_2)]**