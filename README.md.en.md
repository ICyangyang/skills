# OpenClaw Verilog Skills

This repository contains Verilog-related skills for OpenClaw.

## Skills List

### code_review
Verilog RTL code review tool, based on the Verilog_RTL_Coding_Standards-v1.4.3 specification.

### code-modify
Verilog code auto-modification tool, automatically fixes code issues based on verilog_review reports.

## Usage

```bash
# Copy skills to your OpenClaw workspace skills directory
cp -r code_review /path/to/workspace/skills/
cp -r code-modify /path/to/workspace/skills/
```

## Requirements

- OpenClaw
- verilog_review skill (code-modify depends on this)

## License

MIT License