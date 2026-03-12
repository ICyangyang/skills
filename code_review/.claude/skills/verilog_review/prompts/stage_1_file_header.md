# 阶段 1：文件头审查

## 审查范围信息

**当前审查类别:** {{REVIEW_CATEGORY}}
**是否完整审查:** {{IS_FULL_REVIEW}}
**本次审查检查项:** 第 1 项
**规范总检查项:** 45项

% if {{REVIEW_CATEGORY}} != "all":
**⚠️ 注意:** 本次为**部分审查**，仅审查文件头相关内容。
% endif

---

## 输出路径说明

**{OUTPUT} 占位符计算规则：**
- 输出目录 = 目标文件所在目录 + "/output/"
- 例如：若目标文件为 `example/IntegerDivider/IntegerDivider.v`
- 则输出目录为 `example/IntegerDivider/output/`

## 任务描述

对Verilog文件的文件头进行检查，确保符合规范要求。

## 检查项目

### 第 1 项：文件头内容检查

**规则级别**: [R] Rule - 必须遵守

**检查方法**: 文件头中是否包含文件名、作者、其创建时间与概要描述

**参考值**: 是

**规范引用**: Verilog_RTL_Coding_Standards-v1.4.3.md 第5条

## 标准文件头格式

```verilog
//--------------------------------------------------------------
// (C) COPYRIGHT 2020-2023 Sophgo Technologies Inc.
// ALL RIGHTS RESERVED
//
// Filename : <file_name>.v
// Author   : <author_name> (name@sophgo.com)
// Created  : <time>
// Description:
//   1) ...
//   2) ...
//
// History :
//   YYYY.MM.DD, <author>, initial version
//--------------------------------------------------------------
```

## 检查步骤

1. 读取目标Verilog文件
2. 定位文件头位置（文件开头的注释块）
3. 检查是否包含以下必需字段：
   - Filename: 文件名
   - Author: 作者（包含邮箱）
   - Created: 创建时间
   - Description: 功能描述
4. 检查文件头格式是否符合规范
5. 记录检查结果

## 输出格式

### 报告文件: `{OUTPUT}/reports/stage_1_file_header.md`

```markdown
# 阶段 1：文件头审查报告

## 文件信息
- 审查文件：{file_list}
- 审查时间：{timestamp}
- 规范版本：Verilog_RTL_Coding_Standards-v1.4.3

## 检查项目统计
- 总检查项：1
- 通过：{passed}
- 未通过：{failed}
- 通过率：{rate}%

## 详细检查结果

### 第 1 项：文件头内容检查
- **状态**: ✅ 通过 / ❌ 未通过
- **规则级别**: [R]
- **检查方法**: 文件头中是否包含文件名、作者、其创建时间与概要描述
- **代码位置**: Line {line_numbers}
- **检查结果**:
  - Filename字段: ✅ / ❌
  - Author字段: ✅ / ❌
  - Created字段: ✅ / ❌
  - Description字段: ✅ / ❌
- **问题原因**: {如有问题，详细说明}
- **规范引用**: Verilog_RTL_Coding_Standards-v1.4.3.md 第5条
- **修复建议**: {如有问题，给出代码示例}

## 阶段总结

{summary}
```

## 更新文件

1. **更新 `{OUTPUT}/checklist_filled.md`**

   在表格中填写第1项检查结果：

   ```markdown
   | 文件头 | 1 | 文件头内容检查 | 文件头中是否包含文件名、作者、其创建时间与概要描述<br>参考值：是 | **通过** / **未通过** - {详细说明} | {date} |
   ```

2. **更新 `{OUTPUT}/review_progress.json`**

   ```json
   {
     "current_stage": "STAGE_2",
     "completed_stages": ["STAGE_1"],
     "statistics": {
       "total_checks": 45,
       "completed_checks": 1,
       "passed": {passed_count},
       "failed": {failed_count},
       "warnings": 0
     }
   }
   ```
