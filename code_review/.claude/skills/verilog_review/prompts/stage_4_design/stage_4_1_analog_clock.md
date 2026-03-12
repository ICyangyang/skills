# 阶段 4.1：模拟与时钟设计审查

## 审查范围信息

**当前审查类别:** {{REVIEW_CATEGORY}}
**是否完整审查:** {{IS_FULL_REVIEW}}
**本次审查检查项:** 第 14-15 项（共2项）
**规范总检查项:** 45项

% if {{REVIEW_CATEGORY}} != "all":
**⚠️ 注意:** 本次为**部分审查**，仅审查模拟与时钟设计相关内容。
% endif

---

## 输出路径说明

**{OUTPUT} 占位符计算规则：**
- 输出目录 = 目标文件所在目录 + "/output/"
- 例如：若目标文件为 `example/IntegerDivider/IntegerDivider.v`
- 则输出目录为 `example/IntegerDivider/output/`

## 任务描述

对Verilog文件的模拟信号处理和跨时钟域设计进行检查。

## 检查项目

### 第 14 项：模拟信号连接检查

**规则级别**: [S]

**检查方法**: 模拟信号连接中间是否插入buffer

**参考值**: 否

### 第 15 项：跨时钟域调用IP检查

**规则级别**: [S]

**检查方法**: 跨时钟域设计是否都是用common IP

**参考值**: 是

## 检查要点

1. **模拟信号处理**:
   - 模拟信号直接连接可能影响信号完整性
   - 中间插入buffer可能影响信号质量

2. **跨时钟域设计**:
   - 跨时钟域信号必须使用同步器
   - 推荐使用经过验证的common IP
   - 检查是否有手动实现的跨时钟域处理

## 输出格式

### 报告文件: `{OUTPUT}/reports/stage_4_design/stage_4_1_analog_clock.md`

```markdown
# 阶段 4.1：模拟与时钟设计审查报告

## 文件信息
- 审查文件：{file_list}
- 审查时间：{timestamp}
- 规范版本：Verilog_RTL_Coding_Standards-v1.4.3

## 检查项目统计
- 总检查项：2
- 通过：{passed}
- 未通过：{failed}
- 警告：{warnings}

## 详细检查结果

### 第 14 项：模拟信号连接检查
- **状态**: ✅ 通过 / ❌ 未通过
- **代码位置**: {location}
- **问题描述**: {description}

### 第 15 项：跨时钟域调用IP检查
- **状态**: ✅ 通过 / ❌ 未通过
- **代码位置**: {location}
- **问题描述**: {description}

## 阶段总结

{summary}
```
