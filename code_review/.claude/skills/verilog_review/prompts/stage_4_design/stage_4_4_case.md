# 阶段 4.4：Case与语句检查

## 审查范围信息

**当前审查类别:** {{REVIEW_CATEGORY}}
**是否完整审查:** {{IS_FULL_REVIEW}}
**本次审查检查项:** 第 28 项
**规范总检查项:** 45项

% if {{REVIEW_CATEGORY}} != "all":
**⚠️ 注意:** 本次为**部分审查**，仅审查Case语句相关内容。
% endif

---

## 输出路径说明

**{OUTPUT} 占位符计算规则：**
- 输出目录 = 目标文件所在目录 + "/output/"
- 例如：若目标文件为 `example/IntegerDivider/IntegerDivider.v`
- 则输出目录为 `example/IntegerDivider/output/`

## 任务描述

对Verilog文件的Case语句使用进行检查。

## 检查项目

### 第 28 项：Case语句检查
**规则级别**: [R]
**检查方法**: 是否使用casex语句
**参考值**: 否

## Case语句使用规范

1. **禁止使用casex**: casex会忽略don't care，可能导致不可预期的行为
2. **推荐使用case**: 明确匹配所有位
3. **casez**: 仅在特定场景下使用（处理don't care的高阻态）

## 推荐写法
```verilog
// 推荐使用case
case (state)
    3'b000: next_state = 3'b001;
    3'b001: next_state = 3'b010;
    default: next_state = 3'b000;
endcase

// 禁止使用casex
casex (state)  // ❌ 禁止
    ...
endcase
```

## 输出格式

### 报告文件: `{OUTPUT}/reports/stage_4_design/stage_4_4_case.md`
