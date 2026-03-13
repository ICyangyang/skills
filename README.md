# OpenClaw Verilog Skills

本仓库包含用于 OpenClaw 的 Verilog 相关技能。

## 技能列表

### code_review
Verilog RTL 代码审查工具，基于 Verilog_RTL_Coding_Standards-v1.4.3 规范进行代码审查。

### code-modify
Verilog 代码自动修改工具，根据 verilog_review 生成的审查报告自动修复代码问题。

## 使用方法

```bash
# 将技能复制到你的 OpenClaw 工作区 skills 目录
cp -r code_review /path/to/workspace/skills/
cp -r code-modify /path/to/workspace/skills/
```

## 环境要求

- OpenClaw
- verilog_review skill（code-modify 依赖此项）

## 许可证

MIT License
