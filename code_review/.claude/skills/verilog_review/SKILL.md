---
name: verilog_review
description: |
  Verilog RTL 代码审查工具 - 基于 Verilog_RTL_Coding_Standards-v1.4.3 规范对 Verilog 代码进行分阶段自动审查。

  触发场景：
  - 审查 Verilog RTL 代码是否符合规范
  - 检查文件头、命名规则、排版规范
  - 检查电路设计规范（时钟、复位、状态机等）
  - 生成代码审查报告和检查清单

  触发词：verilog、审查、代码审查、RTL、checklist、规范、标准
---

# Verilog RTL 代码审查 Skill

## 概述

本 Skill 基于 `Verilog_RTL_Coding_Standards-v1.4.3` 规范，对 Verilog RTL 代码进行分阶段自动审查。通过 45 项检查清单全面评估代码质量。

## 审查阶段

| 阶段 | 名称 | 检查项范围 |
|------|------|------------|
| STAGE_1 | 文件头审查 | 第 1 项 |
| STAGE_2 | 信号及模块命名规则 | 第 2-12 项 |
| STAGE_3 | 排版规则审查 | 第 13 项 |
| STAGE_4_1 | 模拟与时钟设计 | 第 14-15 项 |
| STAGE_4_2 | 状态机与复位设计 | 第 16-24, 43-45 项 |
| STAGE_4_3 | 变量与赋值检查 | 第 25-27 项 |
| STAGE_4_4 | Case与语句检查 | 第 28 项 |
| STAGE_4_5 | 时钟设计检查 | 第 29-31 项 |
| STAGE_4_6 | 逻辑运算检查 | 第 32-37 项 |
| STAGE_4_7 | 变量声明检查 | 第 38-39 项 |
| STAGE_4_8 | 循环与条件检查 | 第 40-42 项 |

## 指定审查类别

### 支持的类别

| 类别参数 | 说明 | 检查项范围 | 关键词示例 |
|---------|------|-----------|-----------|
| `all` (默认) | 完整审查 | 1-45 | 全部、完整、所有 |
| `file_header` | 文件头 | 1 | 文件头、header |
| `naming` | 命名规则 | 2-12 | 命名、name、信号名、模块名 |
| `format` | 排版 | 13 | 排版、格式、format、缩进 |
| `design` | 电路设计 | 14-45 | 设计、design、电路、电路设计 |
| `stage_4_1` | 模拟与时钟 | 14-15 | 模拟、时钟域、跨时钟域 |
| `stage_4_2` | 状态机与复位 | 16-24, 43-45 | 状态机、复位、reset |
| `stage_4_3` | 变量与赋值 | 25-27 | 变量、赋值 |
| `stage_4_4` | Case语句 | 28 | case |
| `stage_4_5` | 时钟设计 | 29-31 | 时钟、clock、clk |
| `stage_4_6` | 逻辑运算 | 32-37 | 逻辑运算、算术运算 |
| `stage_4_7` | 变量声明 | 38-39 | 变量声明 |
| `stage_4_8` | 循环与条件 | 40-42 | 循环、条件 |

### 使用方法

```bash
# 完整审查（默认，向后兼容）
"请对 example/uart_tx/*.v 进行 Verilog 代码审查"
"调用 verilog_review skill，对 example/uart_tx/*.v 进行审查"

# 指定类别审查
"请对 example/uart_tx/*.v 进行电路设计规范审查"
"对 example/uart_tx/*.v 进行命名规则审查"
"只检查文件头"
"审查时钟设计相关规范"

# 自然语言表达
"只检查状态机和复位部分"
"审查时钟设计相关规范"
"检查排版和格式"
```

### 部分审查输出说明

当指定部分审查时：
- 输出文件会标注 "⚠️ 部分审查：仅审查 [类别名称]"
- `checklist_filled.md` 只包含已审查的检查项
- `final_summary.md` 会说明未审查的类别

## 输出结构

审查完成后会在目标文件所在目录生成 `output/` 目录：

**输出路径规则：**
- 输出目录 = 目标文件所在目录 + "/output/"
- 例如：
  - 目标: `example/uart_tx/*.v` → 输出: `example/uart_tx/output/`
  - 目标: `example/IntegerDivider/*.v` → 输出: `example/IntegerDivider/output/`

```
example/uart_tx/
└── output/
    ├── review_progress.json      # 审查进度（支持恢复）
    ├── checklist_filled.md       # 填表版本检查清单
    ├── reports/                  # 阶段报告目录
    │   ├── stage_1_file_header.md
    │   ├── stage_2_naming.md
    │   ├── stage_3_format.md
    │   └── stage_4_design/
    │       └── ...
    └── final_summary.md          # 最终总结报告
```

## 规则级别

- **[R] Rule**: 必须遵守的规则
- **[S] Suggestion**: 推荐遵守的建议

## 检查结果标识

- **✅ 通过**: 符合规范要求
- **❌ 未通过**: 不符合规范要求
- **⚠️ 警告**: 存在潜在问题

## 相关资源

- 规范文档: `Verilog_RTL_Coding_Standards-v1.4.3/Verilog_RTL_Coding_Standards-v1.4.3.md`
- 检查清单: `Verilog_RTL_Coding_Standards-v1.4.3/checklist.md`
- 工作流配置: `.claude/skills/verilog_review/workflow.yaml`
- 规则数据库: `.claude/skills/verilog_review/rules/verilog_standards.json`
- Skill 版本: v1.1.0

## 清理审查输出

项目根目录提供 Makefile 用于快速清理审查输出。

### 使用方法

```bash
# 清除指定项目的 output 目录（.md 和 .json 文件）
make clean uart_tx       # 清除 example/uart_tx/output/
make clean audio_fir     # 清除 example/audio_fir/output/
make clean IntegerDivider # 清除 example/IntegerDivider/output/

# 清除所有项目的 output 目录
make clean

# 清除指定项目的所有文件（包括目录结构）
make clean-all uart_tx

# 显示帮助
make help
```

### 输出路径规则

- 输出目录 = 目标文件所在目录 + "/output/"
- 例如：
  - 目标: `example/uart_tx/*.v` → 输出: `example/uart_tx/output/`
  - 目标: `example/IntegerDivider/*.v` → 输出: `example/IntegerDivider/output/`
