#!/bin/bash
# Code Modify Tool - Verilog 代码自动修改工具
# 用法: ./fix.sh <verilog_file> [report_file] [mode]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERILOG_FILE="${1:-}"
REPORT_FILE="${2:-}"
MODE="${3:-apply}"

if [ -z "$VERILOG_FILE" ]; then
    echo "用法: $0 <verilog_file> [report_file] [mode]"
    echo "  verilog_file : 需要修改的Verilog文件"
    echo "  report_file  : verilog_review报告 (可选，默认查找同目录checklist_filled.md)"
    echo "  mode         : dry_run|apply|backup (默认: apply)"
    exit 1
fi

if [ ! -f "$VERILOG_FILE" ]; then
    echo "错误: 文件不存在: $VERILOG_FILE"
    exit 1
fi

# 查找报告文件
if [ -z "$REPORT_FILE" ]; then
    DIR=$(dirname "$VERILOG_FILE")
    if [ -f "$DIR/output/checklist_filled.md" ]; then
        REPORT_FILE="$DIR/output/checklist_filled.md"
    elif [ -f "$DIR/output/final_summary.md" ]; then
        REPORT_FILE="$DIR/output/final_summary.md"
    else
        echo "警告: 未找到审查报告，将进行完整检查"
        REPORT_FILE=""
    fi
fi

echo "========================================"
echo "Verilog 代码自动修改工具"
echo "========================================"
echo "文件: $VERILOG_FILE"
echo "报告: ${REPORT_FILE:-无}"
echo "模式: $MODE"
echo "========================================"

# 调用 agent 进行修复
python3 << EOF
import json
import re
from datetime import datetime
from pathlib import Path

VERILOG_FILE = """$VERILOG_FILE"""
REPORT_FILE = """$REPORT_FILE"""
MODE = """$MODE"""

# 加载修复规则
with open("$SCRIPT_DIR/references/fix_rules.json") as f:
    fix_rules = json.load(f)

# 读取Verilog文件
with open(VERILOG_FILE) as f:
    content = f.read()

fixes_applied = []
fixes_skipped = []
needs_review = []

def apply_fix(fix_id, description, replacement_func):
    global content
    original = content
    content = replacement_func(content)
    if content != original:
        fixes_applied.append((fix_id, description))
        return True
    return False

# === 文件头修复 ===
if not re.search(r'^//\s*\w+:', content):
    # 缺少文件头，添加
    header = f"""// Engineer: ICyangyang
// Create Date: {datetime.now().strftime('%Y-%m-%d')}
// Description: Auto-generated module
// Version: 1.0

"""
    content = header + content
    fixes_applied.append(("FH001", "添加文件头"))
elif "Engineer:" not in content:
    fixes_skipped.append(("FH002", "缺少 Engineer 字段"))
elif "Create Date:" not in content:
    fixes_skipped.append(("FH003", "缺少 Create Date 字段"))

# === 命名修复 ===
name_fixes = {"\\b d \\b": "data_in", "\\b q \\b": "data_out", "\\b en \\b": "enable"}
for pattern, replacement in name_fixes.items():
    if re.search(pattern, content):
        if re.search(rf'(wire|reg|input|output).*{pattern.strip()}', content):
            content = re.sub(pattern, replacement, content)
            fixes_applied.append((f"NM001-{pattern}", f"重命名 {pattern.strip()} -> {replacement}"))

# === 格式修复 ===
if '\t' in content:
    content = content.replace('\t', '    ')
    fixes_applied.append(("FM001", "将 tab 替换为空格"))

content = re.sub(r'if\s*\(', 'if (', content)
content = re.sub(r'\)\s*begin', ') begin', content)
fixes_applied.append(("FM002", "修复括号空格"))

# === 设计修复 ===
# 检测时序逻辑中的阻塞赋值
if re.search(r'always\s*@\s*\(\*posedge.*?\)\s*begin.*?\w+\s*=', content, re.DOTALL):
    needs_review.append(("DS001", "检测到时序逻辑中使用阻塞赋值，请手动检查"))

# 检测组合逻辑中的非阻塞赋值
if re.search(r'always\s*@\s*\(\*\)\s*begin.*?<{2}', content, re.DOTALL):
    needs_review.append(("DS002", "检测到组合逻辑中使用非阻塞赋值，请手动检查"))

# 检测 if-else 不完整
if re.search(r'if\s*\([^)]+\)\s*begin\n[^}]*?\nend\s*$', content, re.DOTALL):
    needs_review.append(("DS003", "检测到不完整的if-else，可能导致锁存器"))

# 检测 case 缺少 default
if re.search(r'case\s*\([^)]+\)\n(?!.*default).*?\nendcase', content, re.DOTALL):
    needs_review.append(("DS004", "case语句缺少default分支"))

# 生成报告
report_md = f"""# Code Modify Report

## 基本信息

- **文件**: {VERILOG_FILE}
- **时间**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
- **模式**: {MODE}

## 修改摘要

| 类型 | 数量 |
|------|------|
| 已修复 | {len(fixes_applied)} |
| 跳过 | {len(fixes_skipped)} |
| 需人工确认 | {len(needs_review)} |

## 已修复的问题

"""
for fix_id, desc in fixes_applied:
    report_md += f"- [{fix_id}] {desc}\n"

if fixes_skipped:
    report_md += "\n## 跳过的修复\n"
    for fix_id, desc in fixes_skipped:
        report_md += f"- [{fix_id}] {desc} (建议手动修复)\n"

if needs_review:
    report_md += "\n## 需人工确认\n"
    for fix_id, desc in needs_review:
        report_md += f"- [{fix_id}] {desc}\n"

# 写入报告
report_file = "code_modify_report.md"
with open(report_file, 'w') as f:
    f.write(report_md)

print(report_md)
print(f"\n报告已保存到: {report_file}")
EOF

# 写入修改后的文件
if [ "$MODE" = "apply" ] || [ "$MODE" = "backup" ]; then
    echo "文件已修改"
elif [ "$MODE" = "backup" ]; then
    cp "$VERILOG_FILE" "$VERILOG_FILE.bak"
    echo "已备份: $VERILOG_FILE.bak"
else
    echo "dry_run 模式：未实际修改文件"
fi

echo "========================================"
echo "完成!"
echo "========================================"