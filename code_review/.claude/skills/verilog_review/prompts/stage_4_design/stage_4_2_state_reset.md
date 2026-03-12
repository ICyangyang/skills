# 阶段 4.2：状态机与复位设计审查

## 审查范围信息

**当前审查类别:** {{REVIEW_CATEGORY}}
**是否完整审查:** {{IS_FULL_REVIEW}}
**本次审查检查项:** 第 16-24 项 + 第 43-45 项（共12项）
**规范总检查项:** 45项

% if {{REVIEW_CATEGORY}} != "all":
**⚠️ 注意:** 本次为**部分审查**，仅审查状态机与复位设计相关内容。
% endif

---

## 输出路径说明

**{OUTPUT} 占位符计算规则：**
- 输出目录 = 目标文件所在目录 + "/output/"
- 例如：若目标文件为 `example/IntegerDivider/IntegerDivider.v`
- 则输出目录为 `example/IntegerDivider/output/`

## 任务描述

对Verilog文件的状态机设计和复位处理进行全面检查。

## 检查项目

### 状态机设计检查

#### 第 16 项：状态机状态定义检查
**规则级别**: [R] 必须遵守
**检查方法**: 状态机状态是否使用localparam来定义（而非parameter，防止被外部例化修改）
**参考值**: 是
**规范引用**: Verilog_RTL_Coding_Standards-v1.4.3.md 第7条

#### 第 43 项：状态机命名检查
**规则级别**: [S] 推荐遵守
**检查方法**: 状态机状态命名是否使用ST_前缀
**参考值**: 是
**规范引用**: Verilog_RTL_Coding_Standards-v1.4.3.md 第7条

#### 第 44 项：状态机结构检查
**规则级别**: [R] 必须遵守
**检查方法**: 状态机是否采用两段式写法（一个时序always块用于状态寄存，一个组合always块用于次态逻辑和输出）
**参考值**: 是
**规范引用**: Verilog_RTL_Coding_Standards-v1.4.3.md 第7条

#### 第 45 项：状态机默认状态检查
**规则级别**: [R] 必须遵守
**检查方法**: 状态机case语句中是否有default分支指定默认状态
**参考值**: 是
**规范引用**: Verilog_RTL_Coding_Standards-v1.4.3.md 第7条

### 复位设计检查

#### 第 17 项：寄存器复位方式检查
**规则级别**: [S]
**检查方法**: 寄存器是否采用异步复位
**参考值**: 是

#### 第 18 项：寄存器复位值检查
**规则级别**: [S]
**检查方法**: 寄存器的复位值是否是常量
**参考值**: 是

#### 第 19 项：多变量寄存器复位检查
**规则级别**: [S]
**检查方法**: 多变量在一个时序always块时，是否所有的变量都被复位
**参考值**: 是

#### 第 20 项：复位信号逻辑检查
**规则级别**: [R]
**检查方法**: 是否存在同步复位和异步复位信号的组合逻辑
**参考值**: 否

#### 第 21 项：复位信号使用前检查
**规则级别**: [S]
**检查方法**: 复位信号跨时钟域时，是否先做同步再使用
**参考值**: 是

#### 第 22 项：复位信号数量检查
**规则级别**: [R]
**检查方法**: 一个always块中复位信号是否超过1个
**参考值**: 否

#### 第 23 项：组合逻辑复位检查
**规则级别**: [R]
**检查方法**: 组合逻辑是否存在复位
**参考值**: 否

#### 第 24 项：复位条件写法检查
**规则级别**: [S]
**检查方法**: 是否存在复位if条件后再使用if而不是else if
**参考值**: 否

## 状态机设计规范

### 规范要求（第7条）

1. **两段式写法**: 状态机采用两段式写法，将状态机描述分成两个always块：
   - 一个为时序逻辑，得到cur_state
   - 一个为组合逻辑，得到nxt_state和状态机输出

2. **默认状态**: 必须使用default条件为状态机指定一个默认状态，防止状态机进入死锁状态

3. **状态命名与编码要求**:
   - 状态命名使用ST_前缀
   - 在FSM输出逻辑较多时，状态编码建议使用独热码
   - 状态命名使用localparam，而非parameter（防止被外部例化时修改）
   - 状态名只在两段式的always块中出现

4. **状态数限制**: 建议状态数控制在40个以内 [S]

### 规范状态机模板
```verilog
// 状态定义 - 使用localparam和ST_前缀
localparam ST_IDLE    = 3'b001;
localparam ST_PROCESS = 3'b010;
localparam ST_END     = 3'b100;

// 状态寄存器
reg [2:0] cur_state;
reg [2:0] nxt_state;
reg       process_en;

// 时序always块 - 状态寄存
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        cur_state <= ST_IDLE;  // 使用默认状态
    else
        cur_state <= nxt_state;
end

// 组合always块 - 次态逻辑和输出
always @(*) begin
    nxt_state = cur_state;  // 默认保持当前状态
    process_en = 1'b0;
    case(cur_state)
        ST_IDLE: begin
            if(start)
                nxt_state = ST_PROCESS;
            else
                nxt_state = ST_IDLE;
        end
        ST_PROCESS: begin
            nxt_state = ST_END;
            process_en = 1'b1;
        end
        ST_END: begin
            nxt_state = ST_IDLE;
        end
        default: nxt_state = ST_IDLE;  // 必须有default
    endcase
end
```

## 复位设计规范

### 推荐的复位模板
```verilog
// 异步复位，低电平有效
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // 复位逻辑 - 复位值必须是常量
        state <= ST_IDLE;
        data_reg <= 32'd0;
        cnt_reg <= 8'd0;
    end else begin
        // 正常逻辑
    end
end
```

### 常见错误示例

#### 错误1：使用parameter定义状态
```verilog
// ❌ 错误 - 应使用localparam
parameter ST_IDLE = 3'b001;

// ✅ 正确
localparam ST_IDLE = 3'b001;
```

#### 错误2：状态命名无ST_前缀
```verilog
// ❌ 不推荐
localparam IDLE = 3'b001;

// ✅ 推荐
localparam ST_IDLE = 3'b001;
```

#### 错误3：单段式状态机
```verilog
// ❌ 不推荐 - 单段式写法
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        cur_state <= ST_IDLE;
    end else begin
        case(cur_state)
            ST_IDLE: begin
                if(start) cur_state <= ST_PROCESS;
            end
            // ...
        endcase
    end
end

// ✅ 推荐 - 两段式写法（见上方模板）
```

#### 错误4：缺少default分支
```verilog
// ❌ 错误 - 可能导致死锁
case(cur_state)
    ST_IDLE: nxt_state = ST_PROCESS;
    ST_PROCESS: nxt_state = ST_END;
    // 缺少default
endcase

// ✅ 正确
case(cur_state)
    ST_IDLE: nxt_state = ST_PROCESS;
    ST_PROCESS: nxt_state = ST_END;
    default: nxt_state = ST_IDLE;  // 必须有default
endcase
```

## 输出格式

### 报告文件: `{OUTPUT}/reports/stage_4_design/stage_4_2_state_reset.md`

```markdown
# 阶段 4.2：状态机与复位设计审查报告

## 文件信息
- 审查文件：{file_list}
- 审查时间：{timestamp}
- 规范版本：Verilog_RTL_Coding_Standards-v1.4.3

## 检查项目统计
- 总检查项：12
- 通过：{passed}
- 未通过：{failed}
- 警告：{warnings}

## 状态机检查结果

### 第16项：状态机状态定义检查 [R]
**结果**: ✅通过 / ❌未通过 / ⚠️警告
**分析**: {详细分析}
{如有问题，列出具体位置和修复建议}

### 第43项：状态机命名检查 [S]
**结果**: ✅通过 / ❌未通过 / ⚠️警告
**分析**: {详细分析}

### 第44项：状态机结构检查 [R]
**结果**: ✅通过 / ❌未通过 / ⚠️警告
**分析**: {详细分析}

### 第45项：状态机默认状态检查 [R]
**结果**: ✅通过 / ❌未通过 / ⚠️警告
**分析**: {详细分析}

## 复位检查结果

### 第17项：寄存器复位方式检查 [S]
**结果**: ✅通过 / ❌未通过 / ⚠️警告
**分析**: {详细分析}

### 第18项：寄存器复位值检查 [S]
**结果**: ✅通过 / ❌未通过 / ⚠️警告
**分析**: {详细分析}

### 第19项：多变量寄存器复位检查 [S]
**结果**: ✅通过 / ❌未通过 / ⚠️警告
**分析**: {详细分析}

### 第20项：复位信号逻辑检查 [R]
**结果**: ✅通过 / ❌未通过 / ⚠️警告
**分析**: {详细分析}

### 第21项：复位信号使用前检查 [S]
**结果**: ✅通过 / ❌未通过 / ⚠️警告
**分析**: {详细分析}

### 第22项：复位信号数量检查 [R]
**结果**: ✅通过 / ❌未通过 / ⚠️警告
**分析**: {详细分析}

### 第23项：组合逻辑复位检查 [R]
**结果**: ✅通过 / ❌未通过 / ⚠️警告
**分析**: {详细分析}

### 第24项：复位条件写法检查 [S]
**结果**: ✅通过 / ❌未通过 / ⚠️警告
**分析**: {详细分析}

## 状态机分析汇总
- 发现状态机数量：{count}
- 状态定义方式：{localparam/parameter/其他}
- 状态编码方式：{独热码/二进制/格雷码/其他}
- 结构方式：{两段式/单段式/三段式}
- 是否有default分支：{是/否}

## 复位分析汇总
- 时序always块数量：{count}
- 异步复位：{count}
- 同步复位：{count}
- 无复位：{count}
- 问题汇总：{issues}

## 阶段总结

{summary}
```

## 更新检查清单

更新 `{OUTPUT}/checklist_filled.md`，填充第 16-24 项和第 43-45 项的检查结果。

## 更新进度文件

更新 `{OUTPUT}/review_progress.json`，记录当前阶段完成状态。