# STAGE_4_4: Case语句检查审查报告

⚠️ **部分审查：仅审查 STAGE_4_4（Case语句检查）**

## 审查范围

本次审查针对 `example/c906/ifu/rtl/*.v`，检查Case语句使用规范（检查项28）。

---

## 检查项28 审查结果

### 检查项28: Case语句检查 [R]
**检查方法**: 是否使用casex语句

**审查结果**: ✅ 通过

**说明**:
- 审查所有Case语句，未发现使用 `casex` 的情况
- 所有Case语句均使用标准的 `case` 或 `casez`
- Case语句均包含 default 分支

**证据1**: aq_ifu_bht.v 中的状态机Case语句
```verilog
// 使用标准case
case(bht_inv_cur_st[1:0])
  BHT_INV_IDLE:
  begin
    if(cp0_ifu_bht_inv)
      bht_inv_nxt_st[1:0] = BHT_INV_WRTE;
    else
      bht_inv_nxt_st[1:0] = BHT_INV_IDLE;
  end
  ...
  default:
  begin
    bht_inv_nxt_st[1:0] = BHT_INV_IDLE;
  end
endcase
```

**证据2**: aq_ifu_btb.v 中的数据选择Case语句
```verilog
// 使用标准case
case(btb_entry_hit_flop[15:0])
  16'b0000000000000001: btb_hit_tgt[BTB_ADDR_WIDTH-1:0] = btb_entry_tgt_0[BTB_ADDR_WIDTH-1:0];
  16'b0000000000000010: btb_hit_tgt[BTB_ADDR_WIDTH-1:0] = btb_entry_tgt_1[BTB_ADDR_WIDTH-1:0];
  ...
  default: btb_hit_tgt[BTB_ADDR_WIDTH-1:0] = {BTB_ADDR_WIDTH{1'bx}};
endcase
```

**证据3**: aq_ifu_icache.v 中的状态机Case语句
```verilog
// 使用标准case
case(ref_cur_st[2:0])
  IDLE:
  begin
    if(icache_miss_req)
      ref_nxt_st[2:0] = REQ;
    else
      ref_nxt_st[2:0] = IDLE;
  end
  ...
  default:
  begin
    ref_nxt_st[2:0] = IDLE;
  end
endcase
```

**证据4**: aq_ifu_ibuf.v 中的数据选择Case语句
```verilog
// 使用标准case
case(pop0[ENTRY_NUM-1:0])
  6'b0001:
  begin
    pop0_vld          = entry0_vld;
    pop0_inst[15:0]   = entry0_inst[15:0];
    ...
  end
  ...
  default:
  begin
    pop0_vld          = 1'bx;
    pop0_inst[15:0]   = 16'bx;
    ...
  end
endcase
```

---

## 总体评估

### 通过情况
- ✅ 通过: 1项
- ❌ 未通过: 0项
- ⚠️ 警告: 0项

### 主要优点
1. 未使用 `casex` 语句，符合规范要求
2. 所有Case语句均包含 default 分支
3. Case语句用于状态机和数据选择，逻辑清晰

### 设计特点
- Case语句主要用于状态机设计（状态转换逻辑）
- Case语句也用于数据选择逻辑（如one-hot译码选择）
- Case语句风格统一，均使用parameter定义的状态名或常数作为分支条件

### 建议
代码在Case语句使用方面完全符合规范要求。

---

**审查完成时间**: 2026-02-11