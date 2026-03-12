# 阶段 3：排版规则审查

## 审查范围信息

**当前审查类别:** {{REVIEW_CATEGORY}}
**是否完整审查:** {{IS_FULL_REVIEW}}
**本次审查检查项:** 第 13 项
**规范总检查项:** 45项

% if {{REVIEW_CATEGORY}} != "all":
**⚠️ 注意:** 本次为**部分审查**，仅审查排版规则相关内容。
% endif

---

## 输出路径说明

**{OUTPUT} 占位符计算规则：**
- 输出目录 = 目标文件所在目录 + "/output/"
- 例如：若目标文件为 `example/IntegerDivider/IntegerDivider.v`
- 则输出目录为 `example/IntegerDivider/output/`

## 任务描述

对Verilog文件的代码排版和格式进行检查，确保符合规范要求。

## 检查项目

### 第 13 项：排版缩进方式检查

**规则级别**: [S] Suggestion - 推荐遵守

**检查方法**: 是否用Space（空格）而非 Tab来进行缩进

**参考值**: 是

**规范引用**: Verilog_RTL_Coding_Standards-v1.4.3.md 第8条

## 排版规范要点

1. **缩进方式**: 使用空格缩进，推荐 4 个空格，禁止使用 Tab
2. **每行字符数**: 最多 120 个字符
3. **注释风格**: 优先使用 `//` 而非 `/* */`
4. **赋值风格**:
   - 时序逻辑使用非阻塞赋值 (`<=`)
   - 组合逻辑使用阻塞赋值 (`=`)

## 检查步骤

1. 读取目标Verilog文件
2. 检查是否包含Tab字符（\t）
3. 检查每行字符数是否超过120
4. 检查注释风格偏好
5. 检查赋值语句使用是否正确
6. 记录检查结果

## 输出格式

### 报告文件: `{OUTPUT}/reports/stage_3_format.md`

```markdown
# 阶段 3：排版规则审查报告

## 文件信息
- 审查文件：{file_list}
- 审查时间：{timestamp}
- 规范版本：Verilog_RTL_Coding_Standards-v1.4.3

## 检查项目统计
- 总检查项：1
- 通过：{passed}
- 未通过：{failed}
- 警告：{warnings}
- 通过率：{rate}%

## 详细检查结果

### 第 13 项：排版缩进方式检查

#### 缩进方式检查
- **状态**: ✅ 通过 / ❌ 未通过
- **检查结果**:
  - 使用空格缩进: {line_count} 行
  - 使用Tab缩进: {line_count} 行 ❌
  - 混合使用: {line_count} 行 ⚠️
- **问题位置**: Line {line_numbers}
- **问题描述**: {详细说明}
- **修复建议**: 将Tab替换为4个空格

#### 行长度检查
- **超过120字符的行**: {count}
- **问题位置**: Line {line_numbers}
- **最长行**: {length} 字符 (Line {line_number})

#### 注释风格检查
- **使用 // 注释**: {count}
- **使用 /* */ 注释**: {count}
- **建议**: 优先使用 // 风格

#### 赋值风格检查
- **时序逻辑使用 <=**: {count}
- **组合逻辑使用 =**: {count}
- **潜在问题**: {count}

## 阶段总结

{summary}
```

## 更新文件

1. 更新 `{OUTPUT}/checklist_filled.md` 第13项
2. 更新 `{OUTPUT}/review_progress.json`
