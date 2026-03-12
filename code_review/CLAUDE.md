# CLAUDE.md

本文件为 Claude Code (claude.ai/code) 在此仓库中工作时提供指导。

## 仓库概述

本仓库包含 Verilog RTL 代码规范 (v1.4.3) 文档和代码审查工具，用于 IC 逻辑设计和代码审查。文档建立了 Verilog HDL 开发的代码风格指南、命名规范和设计实践。

## 仓库结构

```
code_review/
├── Verilog_RTL_Coding_Standards-v1.4.3/    # 规范文档目录
│   ├── Verilog_RTL_Coding_Standards-v1.4.3.md    # 主规范文档（中文）
│   ├── Verilog_RTL_Coding_Standards-v1.4.3.html  # HTML 网页浏览版本
│   ├── checklist.md                              # 代码审查检查清单（45项）
│   ├── Verilog RTL代码规范-v1.4.3.docx         # 中文 Word 文档版本
│   ├── history.log                               # 文档修订历史
│   └── image-*.png                               # 规范中引用的图表
├── .claude/
│   └── skills/
│       └── verilog_review/                       # Verilog 代码审查 Skill (v1.1.0)
│           ├── skill.json                        # Skill 配置（支持 category 参数）
│           ├── workflow.yaml                     # 工作流配置（支持条件执行）
│           ├── prompts/                          # 审查阶段模板
│           ├── rules/                            # 规则数据库
│           ├── README.md                         # Skill 使用文档
│           └── SKILL.md                          # Skill 说明文档
├── example/                                      # 示例代码目录
│   ├── uart_tx/                                  # UART 发送模块示例
│   ├── audio_fir/                                # 音频 FIR 滤波器示例
│   └── IntegerDivider/                           # 整数除法器示例
└── Makefile                                      # 构建和清理工具
```

## 主要规范分类

规范文档分为三个主要章节：

1. **第一章 总则**
   - 目的、适用范围和术语定义
   - 规则分级：[规则] (Rule/R) = 必须遵守，[建议] (Suggestion/S) = 推荐遵守

2. **第二章 代码规范**
   - 文件头要求（文件名、作者、创建日期、描述）
   - 模块、信号、宏和参数的命名规范
   - 模块定义和例化规则
   - 注释和排版指南

3. **第二章 电路设计规范**
   - 时序和组合逻辑设计规则
   - 复位处理实践
   - 跨时钟域指南
   - 状态机设计模式
   - 锁存器使用限制

## 代码审查检查清单

`checklist.md` 文件包含 45 个审查项目，按类别组织：
- 文件头
- 信号及模块命名规则
- 排版规则
- 电路设计规范

每个项目包含检查方法和预期参考值。

## 常用规范摘要

### 命名规范
- 信号：小写字母加下划线（如 `xx2yy_din`、`clk`、`rst_n`）
- 宏定义：全大写
- 参数：全大写
- 多位总线使用降序 `[N-1:0]`
- 打拍寄存器使用 `_r` 后缀；上一周期信号使用 `_d` 后缀
- 低电平有效信号使用 `_n` 后缀

### 文件头
每个 Verilog 文件必须包含：
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

### 模块例化规则
- 使用命名端口映射（`.port(signal)`），禁止位置映射
- 例化端口中不得进行逻辑运算
- 所有端口必须显式列出（未使用的输出用空括号表示）
- 模块实例使用 `u_`、`u0_`、`u1_` 等前缀
- 单独硬化的 IP 模块不应接收参数

### 代码格式
- 使用空格缩进（而非制表符），推荐 4 个空格
- 每行最多 120 个字符
- 多行注释优先使用 `//` 而非 `/* */`
- 时序逻辑使用非阻塞赋值 (`<=`)
- 组合逻辑使用阻塞赋值 (`=`)

## Verilog 代码审查 Skill

本仓库集成了 Verilog RTL 代码自动审查工具，基于 Verilog_RTL_Coding_Standards-v1.4.3 规范对代码进行分阶段审查。

### 使用方法

```bash
# 完整审查（默认，45项检查）
"请对 example/uart_tx/*.v 进行 Verilog 代码审查"
"调用 verilog_review skill，对 example/IntegerDivider/IntegerDivider.v 进行审查"

# 指定类别审查（v1.1.0 新功能）
"对 example/uart_tx/*.v 进行电路设计规范审查"
"只检查命名规则"
"审查时钟设计相关规范"
"只检查状态机和复位部分"

# 继续中断的审查
"继续对 example/uart_tx/*.v 的审查"
```

### 支持的审查类别

| 类别 | 检查项范围 | 关键词示例 |
|------|-----------|-----------|
| `all` (默认) | 1-45 | 全部、完整、所有 |
| `file_header` | 1 | 文件头、header |
| `naming` | 2-12 | 命名、name、信号名 |
| `format` | 13 | 排版、格式、format |
| `design` | 14-45 | 设计、design、电路 |
| `stage_4_1` | 14-15 | 模拟、时钟域 |
| `stage_4_2` | 16-24, 43-45 | 状态机、复位、reset |
| `stage_4_3` | 25-27 | 变量、赋值 |
| `stage_4_4` | 28 | case |
| `stage_4_5` | 29-31 | 时钟、clock |
| `stage_4_6` | 32-37 | 逻辑运算 |
| `stage_4_7` | 38-39 | 变量声明 |
| `stage_4_8` | 40-42 | 循环、条件 |

### 审查阶段

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

### 输出目录

审查完成后，在目标文件所在目录生成 `output/` 目录：

**输出路径规则：**
- 输出目录 = 目标文件所在目录 + "/output/"
- 例如：
  - 目标: `example/uart_tx/*.v` → 输出: `example/uart_tx/output/`
  - 目标: `example/IntegerDivider/*.v` → 输出: `example/IntegerDivider/output/`

```
example/IntegerDivider/
└── output/
    ├── review_progress.json      # 审查进度（支持恢复）
    ├── checklist_filled.md       # 填表版本检查清单
    ├── final_summary.md          # 最终总结报告
    └── reports/                  # 阶段报告目录
        ├── stage_1_file_header.md
        ├── stage_2_naming.md
        ├── stage_3_format.md
        └── stage_4_design/
            └── ...
```

### 检查结果标识

- **✅ 通过**: 符合规范要求
- **❌ 未通过**: 不符合规范要求（必须修复）
- **⚠️ 警告**: 存在潜在问题（建议修复）

### Skill 配置

- **工作流配置**: `.claude/skills/verilog_review/workflow.yaml`
- **规则数据库**: `.claude/skills/verilog_review/rules/verilog_standards.json`（唯一数据源）
- **Prompt 模板**: `.claude/skills/verilog_review/prompts/`
- **Skill 版本**: v1.2.0（单一数据源架构）

### Skill 核心文件架构

Verilog 代码审查 Skill 由四个核心文件组成，采用**单一数据源**架构设计，确保数据一致性：

```
┌─────────────────────────────────────────────────────────────────┐
│                        skill.json                                │
│                      (纯配置文件)                                │
│  • 定义技能基本信息（名称、版本、描述）                            │
│  • 定义阶段名称与 prompt 路径映射                                 │
│  • 引用其他三个文件                                               │
│  • 不包含业务数据（check_ids 已移除）                             │
└──────────────────────┬──────────────────────────────────────────┘
                       │ 引用
         ┌─────────────┼─────────────┐
         │             │             │
         ▼             ▼             ▼
┌─────────────┐ ┌─────────────────────┐ ┌─────────────────────────┐
│ workflow.yaml│ │verilog_standards.json│ │      prompts/*.md      │
│ (纯流程控制) │ │   (唯一数据源)        │ │     (操作指南)         │
├─────────────┤ ├─────────────────────┤ ├─────────────────────────┤
│ • 系统提示   │ │ • rules[] (45条规则) │ │ • 各阶段详细检查步骤    │
│ • 条件执行   │ │ • stage_mapping      │ │ • 规范要点与示例        │
│ • 输出路径   │ │ • category_mapping   │ │ • 输出格式定义          │
│ • 无task列表 │ │ • metadata           │ │ • 检查项说明            │
└─────────────┘ └─────────────────────┘ └─────────────────────────┘
```

#### 各文件职责分工

| 文件 | 类比 | 职责 | 数据流向 |
|------|------|------|----------|
| `skill.json` | 配置文件 | 定义"做什么"、关联资源 | → 引用其他三个文件 |
| `workflow.yaml` | 流程控制器 | 定义"怎么做"、执行条件 | ← 从规则库读取映射 |
| `verilog_standards.json` | **唯一数据源** | 定义"检查什么"、类别映射 | ← 被所有文件引用 |
| `prompts/*.md` | 操作手册 | 定义"具体步骤"、详细指南 | ← 被skill.json引用 |

#### 1. `skill.json` — 纯配置文件

**职责**: 定义技能的基本信息和阶段配置

| 功能 | 说明 |
|------|------|
| 基本信息定义 | 名称、版本、作者、描述 |
| 参数定义 | `category` 参数，支持多种审查类别 |
| 阶段配置 | 定义阶段名称与 prompt 路径（不含 check_ids） |
| 文件引用 | 指向 workflow、rules_db、prompts_dir |

**示例片段**:
```json
"stages": {
  "STAGE_1": {
    "name": "文件头审查",
    "prompt": "prompts/stage_1_file_header.md"
  }
}
```

> ⚠️ **重要变更 (v1.2.0)**: `check_ids` 和 `category_to_stages` 已移至 `verilog_standards.json`，遵循单一数据源原则。

#### 2. `workflow.yaml` — 纯流程控制

**职责**: 定义审查的执行流程和条件逻辑

| 功能 | 说明 |
|------|------|
| 系统提示 | 定义 AI 角色、任务、原则 |
| 条件执行 | `execute_when` 控制哪些类别执行哪些阶段 |
| 输出文件 | 定义每个阶段的输出文件路径 |

**关键特性**:
- **参数解析**: 从用户输入提取 `{{REVIEW_CATEGORY}}`
- **动态执行**: 从规则库读取 category_mapping 决定执行哪些阶段
- **条件语法**: `execute_when: "{{REVIEW_CATEGORY}} in ['all', 'naming']"`

**示例片段**:
```yaml
- name: naming_convention_review
  execute_when: "{{REVIEW_CATEGORY}} in ['all', 'naming', 'stage_2']"
  prompt: "prompts/stage_2_naming.md"
  output_files:
    - "{OUTPUT}/reports/stage_2_naming.md"
```

> ⚠️ **重要变更 (v1.2.0)**: `task` 列表已移除，详细检查步骤统一在 `prompts/*.md` 中定义。

#### 3. `verilog_standards.json` — 唯一数据源

**职责**: 存储所有业务数据，包括规则、阶段映射、类别映射

| 字段 | 说明 |
|------|------|
| rules[] | 45条检查规则（含 stage 字段） |
| stage_mapping | 阶段定义与检查项对应关系 |
| **category_mapping** | 类别到阶段的映射（v1.2.0 新增） |
| metadata | 版本、总数、分类等元信息 |

**示例片段**:
```json
{
  "rules": [
    {
      "id": 16,
      "stage": "STAGE_4_2",
      "check_item": "状态机状态定义检查",
      "regex_pattern": "localparam\\s+(ST_)?[A-Z0-9_]+\\s*="
    }
  ],
  "stage_mapping": {
    "STAGE_4_2": {
      "name": "状态机与复位设计审查",
      "check_ids": [16, 17, 18, 19, 20, 21, 22, 23, 24, 43, 44, 45]
    }
  },
  "category_mapping": {
    "design": ["stage_4_1", "stage_4_2", "stage_4_3", ...]
  }
}
```

> ⚠️ **重要变更 (v1.2.0)**: `category_mapping` 从 `skill.json` 迁移至此，确保阶段-检查项映射只在 `stage_mapping` 中定义一次。

#### 4. `prompts/*.md` — 操作指南

**职责**: 为每个阶段提供详细的审查指导

| 内容 | 说明 |
|------|------|
| 审查范围信息 | 当前审查类别、检查项范围 |
| 检查项目详情 | 每个检查项的级别、方法、参考值 |
| 规范要点 | 正确/错误示例代码 |
| 检查步骤 | 具体执行步骤列表 |
| 输出格式 | 报告文件的标准模板 |

**目录结构**:
```
prompts/
├── stage_1_file_header.md      # 第1阶段：文件头审查
├── stage_2_naming.md           # 第2阶段：命名规则审查
├── stage_3_format.md           # 第3阶段：排版规则审查
└── stage_4_design/
    ├── stage_4_1_analog_clock.md   # 模拟与时钟
    ├── stage_4_2_state_reset.md    # 状态机与复位
    ├── stage_4_3_variable_assign.md
    ├── stage_4_4_case.md
    ├── stage_4_5_clock.md
    ├── stage_4_6_logic_op.md
    ├── stage_4_7_var_decl.md
    └── stage_4_8_loop_cond.md
```

#### 执行流程示例

当用户输入 `"审查状态机设计"` 时：

1. **skill.json** 解析关键词：`"状态机"` → `keywords_mapping` → `stage_4_2`
2. **verilog_standards.json** 提供数据：
   - `category_mapping["stage_4_2"]` → 确定执行阶段
   - `stage_mapping["STAGE_4_2"].check_ids` → 加载检查项 `[16-24, 43-45]`
   - `rules[]` 中 stage="STAGE_4_2" 的规则 → 具体检查内容
3. **workflow.yaml** 控制流程：`execute_when` 条件满足，执行 `state_reset_review`
4. **prompts/stage_4_2_state_reset.md** 提供指南：详细检查步骤和输出格式
5. **生成输出**：在目标目录的 `output/` 下生成审查报告和填写的检查清单

**单一数据源优势**：
- 修改检查项归属只需修改 `verilog_standards.json` 一处
- `rules[].stage` 和 `stage_mapping.check_ids` 保持一致
- 降低维护成本，避免数据不一致问题

## Makefile 工具

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

## 查看规范

- 快速参考：阅读 `Verilog_RTL_Coding_Standards-v1.4.3.md`
- 网页浏览：打开 `Verilog_RTL_Coding_Standards-v1.4.3.html`
- 代码审查：使用 `checklist.md` 作为系统指南
- 详细图表：参考 `image-*.png` 文件
