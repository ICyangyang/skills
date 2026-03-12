# 阶段 4.7：变量声明检查

## 审查范围信息

**当前审查类别:** {{REVIEW_CATEGORY}}
**是否完整审查:** {{IS_FULL_REVIEW}}
**本次审查检查项:** 第 38-39 项（共2项）
**规范总检查项:** 45项

% if {{REVIEW_CATEGORY}} != "all":
**⚠️ 注意:** 本次为**部分审查**，仅审查变量声明相关内容。
% endif

---

## 输出路径说明

**{OUTPUT} 占位符计算规则：**
- 输出目录 = 目标文件所在目录 + "/output/"
- 例如：若目标文件为 `example/IntegerDivider/IntegerDivider.v`
- 则输出目录为 `example/IntegerDivider/output/`

## 任务描述

对Verilog文件的变量声明格式进行检查。

## 检查项目

### 第 38 项：变量声明检查
**规则级别**: [S]
**检查方法**: 一行是否存在多个变量的赋值表达式
**参考值**: 否

### 第 39 项：变量声明检查
**规则级别**: [S]
**检查方法**: 变量声明是否进行赋值
**参考值**: 否

## 变量声明规范

```verilog
// 推荐：每个变量单独声明
reg [7:0] data_reg;
reg [15:0] addr_reg;
wire valid;

// 避免：一行多变量
reg [7:0] data_reg, addr_reg;  // 不推荐

// 避免：声明时赋值
reg [7:0] data_reg = 8'h00;  // 不推荐
```

## 输出格式

### 报告文件: `{OUTPUT}/reports/stage_4_design/stage_4_7_var_decl.md`
