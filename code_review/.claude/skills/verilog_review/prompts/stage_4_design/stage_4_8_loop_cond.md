# 阶段 4.8：循环与条件检查

## 审查范围信息

**当前审查类别:** {{REVIEW_CATEGORY}}
**是否完整审查:** {{IS_FULL_REVIEW}}
**本次审查检查项:** 第 40-42 项（共3项）
**规范总检查项:** 45项

% if {{REVIEW_CATEGORY}} != "all":
**⚠️ 注意:** 本次为**部分审查**，仅审查循环与条件相关内容。
% endif

---

## 输出路径说明

**{OUTPUT} 占位符计算规则：**
- 输出目录 = 目标文件所在目录 + "/output/"
- 例如：若目标文件为 `example/IntegerDivider/IntegerDivider.v`
- 则输出目录为 `example/IntegerDivider/output/`

## 任务描述

对Verilog文件的循环语句和条件分支进行检查。

## 检查项目

### 第 40 项：循环语句检查
**规则级别**: [R]
**检查方法**: 循环语句过程中是否存在对index的修改
**参考值**: 否

### 第 41 项：for语句检查
**规则级别**: [S]
**检查方法**: for循环条件范围是否出现变量
**参考值**: 否

### 第 42 项：Case语句检查
**规则级别**: [S]
**检查方法**: Case分支条件是否存在变量
**参考值**: 否

## 循环和条件规范

1. **循环语句**:
   - 禁止在循环中修改循环变量
   - for循环范围应为常量表达式

2. **Case分支**:
   - 分支条件应为常量
   - 避免动态分支条件

## 输出格式

### 报告文件: `{OUTPUT}/reports/stage_4_design/stage_4_8_loop_cond.md`

```markdown
# 阶段 4.8：循环与条件检查报告

## 文件信息
- 审查文件：{file_list}
- 审查时间：{timestamp}
- 规范版本：Verilog_RTL_Coding_Standards-v1.4.3

## 检查项目统计
- 总检查项：3
- 通过：{passed}
- 未通过：{failed}
- 警告：{warnings}

## 详细检查结果

{对每个检查项给出详细结果}

## 循环语句分析
- for循环数量：{count}
- while循环数量：{count}
- repeat循环数量：{count}
- forever循环数量：{count}
- 问题汇总：{issues}

## Case语句分析
- case语句数量：{count}
- 分支条件类型分析：{analysis}

## 阶段总结

{summary}

---

## 整体审查总结

### 审查完成情况
- 审查阶段：STAGE_4_8（最后阶段）
- 总检查项：42
- 完成检查项：42
- 通过：{total_passed}
- 未通过：{total_failed}
- 警告：{total_warnings}
- 通过率：{rate}%

### 各阶段统计
- STAGE_1 (文件头): {passed1}/{total1}
- STAGE_2 (命名规则): {passed2}/{total2}
- STAGE_3 (排版规则): {passed3}/{total3}
- STAGE_4.1 (模拟时钟): {passed4_1}/{total4_1}
- STAGE_4.2 (状态复位): {passed4_2}/{total4_2}
- STAGE_4.3 (变量赋值): {passed4_3}/{total4_3}
- STAGE_4.4 (Case语句): {passed4_4}/{total4_4}
- STAGE_4.5 (时钟设计): {passed4_5}/{total4_5}
- STAGE_4.6 (逻辑运算): {passed4_6}/{total4_6}
- STAGE_4.7 (变量声明): {passed4_7}/{total4_7}
- STAGE_4.8 (循环条件): {passed4_8}/{total4_8}

### 主要问题汇总
{列出所有未通过项}

### 改进建议
{给出整体改进建议}

### 审查结论
{overall_conclusion}
```

## 更新文件

1. 更新 `{OUTPUT}/checklist_filled.md` 第40-42项
2. 更新 `{OUTPUT}/review_progress.json` - 设置 current_stage 为 "COMPLETED"
3. 生成 `{OUTPUT}/final_summary.md`
