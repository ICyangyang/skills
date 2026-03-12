# Verilog Skills for OpenClaw

This repository contains Verilog-related skills for OpenClaw.

## Skills

### code_review
Verilog RTL 代码审查工具，基于 Verilog_RTL_Coding_Standards-v1.4.3 规范进行代码审查。

### code-modify
Verilog 代码自动修改工具，根据 verilog_review 生成的审查报告自动修复代码问题。

## Usage

```bash
# Copy skills to your OpenClaw workspace skills directory
cp -r code_review /path/to/workspace/skills/
cp -r code-modify /path/to/workspace/skills/
```

## Requirements

- OpenClaw
- verilog_review skill (required for code-modify)

## License

MIT License