# STAGE_4_8: 循环与条件检查审查报告

⚠️ **部分审查：仅审查 STAGE_4_8（循环与条件检查）**

## 审查范围

本次审查针对 `example/c906/ifu/rtl/*.v`，检查循环与条件规范（检查项40-42）。

---

## 检查项40-42 审查结果

### 检查项40: 循环语句检查 [R]
**检查方法**: 循环语句过程中是否存在对index的修改

**审查结果**: ✅ 通过

**说明**:
- 审查代码中未发现 for 循环语句
- 所有计数器/索引更新均在 always 块中使用时序逻辑实现
- 不存在循环体中修改循环变量的问题

**证据**: 使用时序逻辑实现的计数器
```verilog
// aq_ifu_bht.v - 使用时序逻辑而非for循环
always @ (posedge bht_inv_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    bht_inv_cnt[IDX_WIDTH-1:0] <= {IDX_WIDTH{1'b0}};
  else if(bht_inv_wr)
    bht_inv_cnt[IDX_WIDTH-1:0] <= bht_inv_cnt[IDX_WIDTH-1:0] + 1'b1;
  else
    bht_inv_cnt[IDX_WIDTH-1:0] <= bht_inv_cnt[IDX_WIDTH-1:0];
end
```

---

### 检查项41: for语句检查 [S]
**检查方法**: for循环条件范围是否出现变量

**审查结果**: ✅ 通过

**说明**:
- 代码中未使用 for 循环
- 所有数组访问使用固定索引或基于信号的索引

**证据**: 使用固定索引或信号索引
```verilog
// 固定索引访问
assign bht_sel_way[7:0] = 8'b1 << bht_vghr[2:0];
assign bht_sel_result[1] = |(bht_sel_way[7:0] & bht_dout_ff[15:8]);
assign bht_sel_result[0] = |(bht_sel_way[7:0] & bht_dout_ff[7:0]);

// 基于信号的索引
assign bht_mem_idx[2:0] = {bht_vghr[1:0], bht_pred_taken};

// 生成多个实例，使用后缀而非循环
aq_ifu_btb_entry x_aq_ifu_btb_entry0 (...);
aq_ifu_btb_entry x_aq_ifu_btb_entry1 (...);
...
aq_ifu_btb_entry x_aq_ifu_btb_entry15 (...);
```

---

### 检查项42: Case语句检查 [S]
**检查方法**: Case分支条件是否存在变量

**审查结果**: ✅ 通过

**说明**:
- 所有 Case 分支条件均使用常量或 parameter
- 未在 Case 分支条件中使用变量

**证据1**: Case分支使用parameter
```verilog
// aq_ifu_bht.v - 使用parameter定义的状态
case(bht_inv_cur_st[1:0])
  BHT_INV_IDLE:
  begin
    if(cp0_ifu_bht_inv)
      bht_inv_nxt_st[1:0] = BHT_INV_WRTE;
    else
      bht_inv_nxt_st[1:0] = BHT_INV_IDLE;
  end
  BHT_INV_WRTE:
  ...
  default:
  begin
    bht_inv_nxt_st[1:0] = BHT_INV_IDLE;
  end
endcase
```

**证据2**: Case分支使用常数
```verilog
// aq_ifu_btb.v - 使用常数作为分支条件
case(btb_entry_hit_flop[15:0])
  16'b0000000000000001: btb_hit_tgt[BTB_ADDR_WIDTH-1:0] = btb_entry_tgt_0[BTB_ADDR_WIDTH-1:0];
  16'b0000000000000010: btb_hit_tgt[BTB_ADDR_WIDTH-1:0] = btb_entry_tgt_1[BTB_ADDR_WIDTH-1:0];
  ...
  default: btb_hit_tgt[BTB_ADDR_WIDTH-1:0] = {BTB_ADDR_WIDTH{1'bx}};
endcase
```

**证据3**: Case分支使用parameter
```verilog
// aq_ifu_icache.v - 使用parameter定义的状态
case(ref_cur_st[2:0])
  IDLE:
  begin
    if(icache_miss_req)
      ref_nxt_st[2:0] = REQ;
    else
      ref_nxt_st[2:0] = IDLE;
  end
  REQ:
  begin
    if (biu_icache_grant)
      ref_nxt_st[2:0] = INIT;
    else
      ref_nxt_st[2:0] = REQ;
  end
  ...
  default:
  begin
    ref_nxt_st[2:0] = IDLE;
  end
endcase
```

---

## 总体评估

### 通过情况
- ✅ 通过: 3项
- ❌ 未通过: 0项
- ⚠️ 警告: 0项

### 主要优点
1. 不使用 for 循环，使用时序逻辑实现计数器
2. Case 分支条件均使用常量或 parameter
3. 数组访问使用固定索引或信号索引

### 设计特点
- IFU 模块采用展开式实例化（如16个BTB entry），而非使用循环
- 这种设计方式虽然代码行数较多，但可读性强，便于调试
- 所有的计数器、状态机均使用标准的 always 时序逻辑实现

### 建议
代码在循环与条件方面完全符合规范要求。

---

**审查完成时间**: 2026-02-11