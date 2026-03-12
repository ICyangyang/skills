# STAGE_4: 电路设计规范审查报告

**审查文件:** `/home/icyangyang/tools/code_review/example/tri_gen/tri_gen.v`

---

## STAGE_4_1: 模拟与时钟设计审查

### #14 模拟信号连接检查 [S]

- **检查方法:** 模拟信号连接中间是否插入buffer
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第9条
- **期望值:** 否
- **实际值:** N/A

#### 检查结果: ⚠️ 不适用

#### 说明:

该文件中不涉及模拟信号。

---

### #15 跨时钟域调用IP检查 [S]

- **检查方法:** 跨时钟域设计是否都是用common IP
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第9条
- **期望值:** 是
- **实际值:** N/A

#### 检查结果: ⚠️ 不适用

#### 说明:

该文件中只有一个时钟域，不涉及跨时钟域设计。

---

## STAGE_4_2: 状态机与复位设计审查

### #16 状态机检查 [S]

- **检查方法:** 状态机状态是否使用localparam来定义
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第10条
- **期望值:** 是
- **实际值:** 否

#### 检查结果: ❌ 未通过

#### 说明:

状态机状态直接使用数字 0, 1, 2, 3，而没有使用 `localparam` 定义有意义的符号常量。

#### 当前代码:

```verilog
case(state)
    0://上升
    ...
    1://平顶；
    ...
    2://下降；
    ...
    3://平顶，不需要default了，2bite四个状态满了
    ...
endcase
```

#### 建议修改:

根据公司 Verilog RTL Coding Standards (v1.4.3) 第7条状态机设计规范，状态机应采用**两段式写法**：

```verilog
// 状态定义 (使用 ST_ 前缀，符合规范第7条)
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

---

### #17 寄存器复位方式检查 [S]

- **检查方法:** 寄存器是否采用异步复位
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第10条
- **期望值:** 是
- **实际值:** 是

#### 检查结果: ✅ 通过

#### 说明:

always块使用异步复位：`always@(posedge clk or negedge res)`

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

---

### #20 复位信号逻辑检查 [R]

- **检查方法:** 是否存在同步复位和异步复位信号的组合逻辑
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第10条
- **期望值:** 否
- **实际值:** 否

#### 检查结果: ✅ 通过

#### 说明:

复位信号直接使用 `res`，没有经过组合逻辑。

---

### #21 复位信号使用前检查 [S]

- **检查方法:** 复位信号跨时钟域时，是否先做同步再使用
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第10条
- **期望值:** 是
- **实际值:** N/A

#### 检查结果: ⚠️ 不适用

#### 说明:

复位信号不跨时钟域。

---

### #22 复位信号数量检查 [R]

- **检查方法:** 一个always块中复位信号是否超过1个
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第10条
- **期望值:** 否
- **实际值:** 否

#### 检查结果: ✅ 通过

#### 说明:

always块中只有一个复位信号 `res`。

---

### #23 组合逻辑复位检查 [R]

- **检查方法:** 组合逻辑是否存在复位
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第10条
- **期望值:** 否
- **实际值:** N/A

#### 检查结果: ⚠️ 不适用

#### 说明:

该文件中没有组合逻辑always块。

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

---

## STAGE_4_3: 变量与赋值检查

### #25 变量声明检查 [S]

- **检查方法:** 信号声明时是否存在赋值
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第11条
- **期望值:** 否
- **实际值:** N/A

#### 检查结果: ⚠️ 不适用

#### 说明:

信号声明时没有赋值。

---

### #26 变量声明冲突性检查 [S]

- **检查方法:** 局部变量名和全局变量名是否发生冲突
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第11条
- **期望值:** 否
- **实际值:** N/A

#### 检查结果: ⚠️ 不适用

#### 说明:

没有局部变量。

---

### #27 变量赋值检查 [R]

- **检查方法:** 赋值语句中是否使用"X"或是"Z"
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第11条
- **期望值:** 否
- **实际值:** 否

#### 检查结果: ✅ 通过

#### 说明:

所有赋值语句未使用 X 或 Z。

---

## STAGE_4_4: Case与语句检查

### #28 Case语句检查 [R]

- **检查方法:** 是否使用casex语句
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第12条
- **期望值:** 否
- **实际值:** 否

#### 检查结果: ✅ 通过

#### 说明:

使用的是 `case` 语句，没有使用 `casex`。

---

## STAGE_4_5: 时钟设计检查

### #29 时钟来源检查 [R]

- **检查方法:** 时钟是否来源于模块内部组合逻辑
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第13条
- **期望值:** 否
- **实际值:** 否

#### 检查结果: ✅ 通过

#### 说明:

时钟 `clk` 是模块输入端口，不来源于内部组合逻辑。

---

### #30 时钟用途检查 [R]

- **检查方法:** 时钟是否被当做数据用于赋值
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第13条
- **期望值:** 否
- **实际值:** 否

#### 检查结果: ✅ 通过

#### 说明:

时钟 `clk` 仅用于时序触发，未用作数据赋值。

---

### #31 时钟通路检查 [S]

- **检查方法:** 时钟通路上的cell是否为clock专用cell
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第13条
- **期望值:** 是
- **实际值:** N/A

#### 检查结果: ⚠️ 不适用

#### 说明:

RTL级别代码无法确定使用的cell类型，需要在综合后网表级别检查。

---

## STAGE_4_6: 逻辑运算检查

### #32 逻辑运算表达式检查 [R]

- **检查方法:** 是否存在使用"?"作为常量匹配
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第14条
- **期望值:** 否
- **实际值:** N/A

#### 检查结果: ⚠️ 不适用

#### 说明:

该文件中没有使用三元运算符 `?` 作为常量匹配。

---

### #33 逻辑运算表达式检查 [S]

- **检查方法:** 是否存在位宽不匹配的变量间进行逻辑运算
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第14条
- **期望值:** 否
- **实际值:** 是

#### 检查结果: ⚠️ 警告

#### 说明:

存在位宽不匹配的运算：
- `d_out == 299` - `d_out` 是 9位，299 隐式转换为 9位
- `d_out == 1` - `d_out` 是 9位，1 隐式转换为 9位
- `con == 200` - `con` 是 8位，200 隐式转换为 8位

建议显式指定位宽：
```verilog
d_out == 9'd299
d_out == 9'd1
con == 8'd200
```

---

### #34 算术运算表达式检查 [S]

- **检查方法:** 是否存在有符号变量和无符号变量间进行多目运算
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第14条
- **期望值:** 否
- **实际值:** N/A

#### 检查结果: ⚠️ 不适用

#### 说明:

所有变量都是无符号类型，没有有符号变量。

---

### #35 条件检查 [S]

- **检查方法:** 条件语句是否存在永远不能满足的条件分支
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第14条
- **期望值:** 否
- **实际值:** 否

#### 检查结果: ✅ 通过

#### 说明:

所有条件分支都是可达的。

---

### #36 逻辑运算表达式检查 [R]

- **检查方法:** 逻辑比较操作中是否使用"X"或"Z"
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第14条
- **期望值:** 否
- **实际值:** N/A

#### 检查结果: ⚠️ 不适用

#### 说明:

没有使用 X 或 Z 进行比较。

---

### #37 条件检查 [S]

- **检查方法:** 条件语句中条件是否使用算术表达式
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第14条
- **期望值:** 否
- **实际值:** 是

#### 检查结果: ❌ 未通过

#### 说明:

case 语句中使用了算术表达式（数值常量）作为分支条件：
```verilog
case(state)
    0://上升
    1://平顶；
    2://下降；
    3://平顶，不需要default了，2bite四个状态满了
```

虽然状态变量 `state` 是 2 位，但这不符合规范要求。建议使用 `localparam` 定义符号常量（详见检查项 #16）。

---

## STAGE_4_7: 变量声明检查

### #38 变量声明检查 [S]

- **检查方法:** 一行是否存在多个变量的赋值表达式
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第15条
- **期望值:** 否
- **实际值:** 否

#### 检查结果: ✅ 通过

#### 说明:

每行只有一个变量赋值。

---

### #39 变量声明检查 [S]

- **检查方法:** 变量声明是否进行赋值
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第15条
- **期望值:** 否
- **实际值:** 否

#### 检查结果: ✅ 通过

#### 说明:

变量声明时未进行赋值。

---

## STAGE_4_8: 循环与条件检查

### #40 循环语句检查 [R]

- **检查方法:** 循环语句过程中是否存在对index的修改
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第16条
- **期望值:** 否
- **实际值:** N/A

#### 检查结果: ⚠️ 不适用

#### 说明:

该文件中没有循环语句。

---

### #41 for语句检查 [S]

- **检查方法:** for循环条件范围是否出现变量
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第16条
- **期望值:** 否
- **实际值:** N/A

#### 检查结果: ⚠️ 不适用

#### 说明:

该文件中没有 for 循环语句。

---

### #42 Case语句检查 [S]

- **检查方法:** Case分支条件是否存在变量
- **参考:** Verilog_RTL_Coding_Standards-v1.4.3.md 第12条
- **期望值:** 否
- **实际值:** 否

#### 检查结果: ✅ 通过

#### 说明:

case 语句的分支条件使用的是常量数值 0, 1, 2, 3，没有使用变量。

---

## 阶段总结

- **检查项总数:** 29
- **通过数:** 11
- **未通过数:** 2 (Suggestion)
- **警告数:** 1 (Suggestion)
- **不适用数:** 15

**关键问题:**
1. 状态机状态应使用 `localparam` 定义符号常量
2. case 分支条件应使用符号常量而非算术表达式
3. 存在位宽隐式转换的警告