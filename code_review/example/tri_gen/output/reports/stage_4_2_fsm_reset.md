# STAGE_4_2: 状态机与复位设计审查报告

**审查文件:** `/home/icyangyang/tools/code_review/example/tri_gen/tri_gen.v`
**审查类别:** 状态机与复位设计 (STAGE_4_2)
**审查规范:** Verilog_RTL_Coding_Standards-v1.4.3

---

### #16 状态机检查 [S]

- **检查方法:** 状态机状态是否使用localparam来定义，状态机采用两段式写法
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第10条、第7条
- **期望值:** 是，使用localparam定义状态，采用两段式写法
- **实际值:** 否

#### 检查结果: ❌ 未通过

#### 说明:

状态机存在以下问题：

1. **状态直接使用数字而非localparam定义**
   - 当前代码使用数字 0, 1, 2, 3 表示状态
   - 应使用 `localparam` 定义符号常量
   - 状态命名应使用 `ST_` 前缀（规范第7条第3款）

2. **状态机未采用两段式写法**
   - 规范第7条要求状态机采用两段式写法
   - 第一段：时序逻辑得到cur_state
   - 第二段：组合逻辑得到nxt_state和状态机输出
   - 当前代码将状态跳转和输出逻辑混在一个always块中

3. **缺少default条件**
   - 规范第7条第2款要求状态机有默认状态
   - 虽然代码注释说明"2bite四个状态满了"，但按照规范仍应提供default条件防止死锁

#### 当前代码:

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

#### 建议修改:

根据公司 Verilog RTL Coding Standards (v1.4.3) 第7条状态机设计规范，状态机应采用**两段式写法**：

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

        default: nxt_state = ST_RISING; // 默认状态，防止死锁（规范第7条第2款）
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

### #17 寄存器复位方式检查 [S]

- **检查方法:** 寄存器是否采用异步复位
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第10条
- **期望值:** 是
- **实际值:** 是

#### 检查结果: ✅ 通过

#### 说明:

always块使用异步复位：`always@(posedge clk or negedge res)`

符合规范要求。

---

### #18 寄存器复位值检查 [S]

- **检查方法:** 寄存器的复位值是否是常量
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第10条
- **期望值:** 是
- **实际值:** 是

#### 检查结果: ✅ 通过

#### 说明:

所有寄存器的复位值都是常量：
- `state <= 0`
- `d_out <= 0`
- `con <= 0`

符合规范要求。

---

### #19 多变量寄存器复位检查 [S]

- **检查方法:** 多变量在一个时序always块时，是否所有的变量都被复位
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第10条
- **期望值:** 是
- **实际值:** 是

#### 检查结果: ✅ 通过

#### 说明:

复位时所有寄存器变量都被复位：
```verilog
if(~res) begin
    state<=0;
    d_out<=0;
    con<=0;
end
```

符合规范要求。

---

### #20 复位信号逻辑检查 [R]

- **检查方法:** 是否存在同步复位和异步复位信号的组合逻辑
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第10条
- **期望值:** 否
- **实际值:** 否

#### 检查结果: ✅ 通过

#### 说明:

复位信号直接使用 `res`，没有经过组合逻辑。

符合规范要求。

---

### #21 复位信号使用前检查 [S]

- **检查方法:** 复位信号跨时钟域时，是否先做同步再使用
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第10条
- **期望值:** 是
- **实际值:** N/A

#### 检查结果: ⚠️ 不适用

#### 说明:

复位信号不跨时钟域。模块只有一个时钟域 `clk`。

---

### #22 复位信号数量检查 [R]

- **检查方法:** 一个always块中复位信号是否超过1个
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第10条
- **期望值:** 否
- **实际值:** 否

#### 检查结果: ✅ 通过

#### 说明:

always块中只有一个复位信号 `res`。

符合规范要求。

---

### #23 组合逻辑复位检查 [R]

- **检查方法:** 组合逻辑是否存在复位
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第10条
- **期望值:** 否
- **实际值:** N/A

#### 检查结果: ⚠️ 不适用

#### 说明:

该文件中没有组合逻辑always块（建议采用两段式写法后会有组合逻辑块）。

---

### #24 复位条件写法检查 [S]

- **检查方法:** 是否存在复位if条件后再使用if而不是else if
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第10条
- **期望值:** 否
- **实际值:** 否

#### 检查结果: ✅ 通过

#### 说明:

复位条件后使用 `else begin`，写法正确：
```verilog
if(~res) begin
    ...
end
else begin
    case(state)
        ...
    endcase
end
```

符合规范要求。

---

## 阶段总结

- **检查项总数:** 9
- **通过数:** 7
- **未通过数:** 1 (Suggestion #16)
- **不适用数:** 2 (#21, #23)

**关键问题:**
1. ❌ 状态机未使用localparam定义状态，应使用ST_前缀
2. ❌ 状态机未采用两段式写法（时序+组合）
3. ❌ 缺少default条件防止状态机死锁
4. ⚠️ 信号命名优化建议（con→hold_cnt，state→cur_state）

**符合规范的项:**
1. ✅ 使用异步复位
2. ✅ 寄存器复位值为常量
3. ✅ 所有寄存器都被复位
4. ✅ 复位信号无组合逻辑
5. ✅ 只有一个复位信号
6. ✅ 复位条件使用else而非else if

---

## 修复优先级

| 优先级 | 问题 | 建议 |
|--------|------|------|
| P1 | 状态机设计 | 采用两段式写法，使用localparam和ST_前缀 |
| P1 | 缺少default | 添加default分支防止死锁 |
| P2 | 信号命名 | con→hold_cnt，state→cur_state/nxt_state |

---

**审查完成时间:** 2024年
**审查工具:** Verilog RTL Code Review Skill v1.1.0
**⚠️ 部分审查：仅审查 [状态机与复位设计 (STAGE_4_2)]**