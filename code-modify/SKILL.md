---
name: code-modify
description: |
  Verilog 代码自动修改工具。根据 verilog_review 生成的审查报告自动修复代码问题。

  触发场景：
  - 根据审查报告修复 Verilog 代码中的问题
  - 自动修复文件头、命名规则、格式、电路设计等问题
  - 配合 verilog_review 使用：审查 -> 修复 -> 验证

  触发词：修改、修复、code_modify、自动修复、代码修改
---

# Code Modify

## Overview

自动修复 Verilog 代码的 Skill。读取 `verilog_review` 生成的审查报告 (`checklist_filled.md` 或 `final_summary.md`)，然后根据报告中的问题列表自动修复代码。

## Workflow

```
Verilog 代码 → verilog_review (审查) → 生成报告 → code-modify (自动修复)
```

## 快速开始

**配合 verilog_review 使用：**

```
"修复 shift_reg.v"
"根据 output/checklist_filled.md 修复 uart_tx.v"
"只修复文件头问题"
```

**独立使用：**

```
"修改这个Verilog文件的命名规则"
"修复格式问题"
```

## 使用方法

### 1. 先运行 verilog_review

```bash
"对 shift_reg.v 进行 Verilog 代码审查"
```

### 2. 再运行 code-modify

```bash
"修复 shift_reg.v"
```

### 3. 查看修复报告

修复完成后会生成 `code_modify_report.md`，记录所有修改内容。

## 输入要求

| 来源 | 说明 |
|------|------|
| **Verilog 文件** | 需要修改的 `.v` 文件路径 |
| **审查报告** | `verilog_review` 生成的报告路径（可选，默认查找同目录的 output/checklist_filled.md） |

## 参数选项

| 参数 | 说明 | 默认值 |
|------|------|--------|
| MODE | dry_run/apply/backup | apply |
| CATEGORY | file_header/naming/format/design/all | all |

### 修复模式

- **dry_run**: 试运行，只显示修改建议，不实际修改文件
- **apply**: 应用修复，直接修改文件
- **backup**: 备份原文件（.bak），然后修改

### 修复类别

- **file_header**: 修复文件头问题
- **naming**: 修复命名规则问题
- **format**: 修复排版格式问题
- **design**: 修复电路设计问题
- **all**: 修复所有问题

## 修复范围

| 类别 | 可修复的问题 |
|------|-------------|
| **文件头** | 添加/完善 Engineer、Create Date、Description、Version 字段 |
| **命名规则** | 重命名单字母信号、模块名大小写等 |
| **排版格式** | 缩进、空格、括号间距 |
| **电路设计** | 阻塞/非阻塞赋值、if-else 完整性、case default 等 |

## 输出

| 文件 | 说明 |
|------|------|
| `*.v` | 修改后的 Verilog 文件 |
| `code_modify_report.md` | 修改对比报告 |
| `*.bak` | 备份文件（当 MODE=backup 时） |

## 注意事项

- 修复前会自动备份原文件（当 MODE=backup 时）
- 对于不确定的修改，会在报告中标注 "需要人工确认"
- 建议在版本控制下使用，便于回滚
- 修复后建议重新运行 verilog_review 验证修复效果

## Resources

### scripts/
- `fix.sh` - 快速修复脚本，支持命令行调用

### references/
- `fix_rules.md` - 修复规则详细说明
- `verilog_standards_summary.md` - Verilog 编码规范摘要