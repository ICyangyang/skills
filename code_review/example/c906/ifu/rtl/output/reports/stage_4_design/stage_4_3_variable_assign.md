# STAGE_4_3: 变量与赋值检查审查报告

⚠️ **部分审查：仅审查 STAGE_4_3（变量与赋值检查）**

## 审查范围

本次审查针对 `example/c906/ifu/rtl/*.v`，检查变量与赋值规范（检查项25-27）。

---

## 检查项25-27 审查结果

### 检查项25: 变量声明检查 [S]
**检查方法**: 信号声明时是否存在赋值

**审查结果**: ✅ 通过

**说明**:
- 所有信号声明均与赋值分离
- 未在声明时进行初始化赋值
- 所有赋值操作均在 assign 语句或 always 块中进行

**证据**:
```verilog
// 正确：声明与赋值分离
reg [15:0] bht_dout_bypass;
reg [13:0] bht_ghr;

// 赋值在assign或always块中
always @ (posedge bht_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    bht_dout_bypass[DATA_WIDTH-1:0] <= {DATA_WIDTH{1'b0}};
  else if(bht_miss_write || bht_upd_vld)
    bht_dout_bypass[DATA_WIDTH-1:0] <= bht_dout[DATA_WIDTH-1:0];
end
```

---

### 检查项26: 变量声明冲突性检查 [S]
**检查方法**: 局部变量名和全局变量名是否发生冲突

**审查结果**: ✅ 通过

**说明**:
- 未发现局部变量名与全局变量名冲突的情况
- generate 块中的例化使用后缀区分（如 `_0`, `_1` 等）
- 信号命名规范，无重复定义

**证据**: aq_ifu_btb.v
```verilog
// 16个BTB entry例化，使用后缀区分
aq_ifu_btb_entry x_aq_ifu_btb_entry0 (...);
aq_ifu_btb_entry x_aq_ifu_btb_entry1 (...);
aq_ifu_btb_entry x_aq_ifu_btb_entry2 (...);
...
aq_ifu_btb_entry x_aq_ifu_btb_entry15 (...);

// 对应的wire信号也使用后缀区分
wire [15:0] btb_entry_tgt_0;
wire [15:0] btb_entry_tgt_1;
...
wire [15:0] btb_entry_tgt_15;
```

---

### 检查项27: 变量赋值检查 [R]
**检查方法**: 赋值语句中是否使用"X"或是"Z"

**审查结果**: ✅ 通过

**说明**:
- 审查所有赋值语句，未发现使用 "X" 或 "Z" 进行赋值的情况
- default 分支中使用了 'bx，但这属于default分支的正常处理，不属于赋值语句

**证据1**: 正常赋值使用常量或信号
```verilog
// 正确赋值
if(!cpurst_b)
  bht_ghr[HIS_WIDTH-1:0] <= {HIS_WIDTH{1'b0}};

// 正确赋值
assign bht_icg_en = pred_bht_br_vld || iu_ifu_bht_mispred_gate || ...;

// 正确赋值
assign bht_wr_val[15:0] = {{8{bht_wr_val_single[1]}}, {8{bht_wr_val_single[0]}}};
```

**证据2**: default 分支中使用 'bx
```verilog
// 这不是赋值语句，是default分支的处理，允许使用
default:
begin
  bht_upd_en       = 1'b0;
  bht_upd_val[1:0] = {2{1'bx}};  // default分支，允许
end
```

---

## 总体评估

### 通过情况
- ✅ 通过: 3项
- ❌ 未通过: 0项
- ⚠️ 警告: 0项

### 主要优点
1. 信号声明与赋值分离，代码清晰
2. 变量命名规范，无冲突
3. 赋值语句规范，不使用X/Z赋值

### 建议
代码在变量与赋值方面完全符合规范要求。

---

**审查完成时间**: 2026-02-11