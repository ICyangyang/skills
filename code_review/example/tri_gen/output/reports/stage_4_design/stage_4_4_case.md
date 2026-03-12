# STAGE 4.4: Case与语句检查报告

**审查文件**: `example/tri_gen/tri_gen.v`
**审查时间**: 2025-01-26
**审查阶段**: STAGE_4_4 - Case与语句检查 [检查项28]

---

## 检查项 28: Case语句检查

**检查方法**: 是否使用casex语句

**检查结果**: ✅ **通过**

**分析**:
代码中使用的是标准 `case` 语句，而非 `casex` 语句：
```verilog
case(state)
    0://上升
    begin
        ...
    end
    1://平顶；
    begin
        ...
    end
    2://下降；
    begin
        ...
    end
    3://平顶
    begin
        ...
    end
endcase
```

**补充说明**:
- 未使用 `casex` 语句，符合规范要求
- 状态使用了 2位寄存器的全部 4 个状态（0, 1, 2, 3），因此代码注释中说明"不需要default"
- 但从代码健壮性角度，仍建议添加 `default` 分支以处理意外情况

**潜在改进建议**:
虽然不违反规范，但建议添加 `default` 分支以提高代码健壮性：
```verilog
case(state)
    2'b00: begin  // RISE
        ...
    end
    2'b01: begin  // FLAT_TOP
        ...
    end
    2'b10: begin  // FALL
        ...
    end
    2'b11: begin  // FLAT_BOT
        ...
    end
    default: begin
        state <= 2'b00;  // 默认回到初始状态
    end
endcase
```

---

## STAGE 4.4 审查总结

| 检查项 | 名称 | 级别 | 结果 |
|--------|------|------|------|
| 28 | Case语句检查 | [R] Rule | ✅ 通过 |

**通过率**: 1/1 (100%)

**主要发现**:
- ✅ 未使用 `casex` 语句
- ⚠️ 建议添加 `default` 分支以提高代码健壮性（非规范要求）

---

*审查完成，进入 STAGE 4.5*