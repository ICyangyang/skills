module audio_fir
 (
  input      signed [16-1:0]     din,
  input                                 din_vld,

  output reg signed [16-1:0]    dout,
  output reg                            dout_vld,

  output                                init_done,

  input                        start,
  input                                 enable,

  input             [4:0]               cnt,
  input      signed [19:0]              coef,

  output     signed [16-1:0]     mac_a,
  output     signed [19:0]              mac_b,
  output     signed [19:0]              mac_c,
  input      signed [19:0]              mac_sum,
  input      signed [15:0]              mac_out,

  input                                 clk,                    // 24.576MHz = 48K * 512
  input                                 rstn
);

// =============================================================
localparam  S_IDLE      = 1'b0;
localparam  S_FIR       = 1'b1;

// =============================================================
reg                             state_nxt;
reg                             state;

wire                            fir_done;

wire signed [16-1:0]     fir_fifo;

wire signed [19:0]              result_temp;
reg  signed [19:0]              result;

wire signed [16-1:0]    dout_temp;
//reg  signed [16-1:0]    dout;

wire                            dout_vld_temp;
//reg                             dout_vld;

wire        [5-1:0]    init_cnt_temp;
reg         [5-1:0]    init_cnt;
// ============================================================
always @* begin
  case(state)
    S_IDLE: begin
      if (start) begin
        state_nxt = S_FIR;
      end
      else begin
        state_nxt = S_IDLE;
      end
    end

    S_FIR: begin
      if (fir_done) begin
        state_nxt = S_IDLE;
      end
      else begin
        state_nxt = S_FIR;
      end
    end

    default: begin
      state_nxt = S_IDLE;
    end
  endcase
end


always @(posedge clk or negedge rstn) begin
  if (~rstn) begin
    state <= S_IDLE;
  end
  else begin
    state <= state_nxt;
  end
end


assign fir_done = (cnt == 18-1);

assign init_cnt_temp = (enable == 1'b0)    ? 5'(0)            :
                       (init_done == 1'b1) ? init_cnt                  :
                       (din_vld == 1'b1)   ? init_cnt + 5'(1) : init_cnt;


always @(posedge clk or negedge rstn) begin
  if (~rstn) begin
    init_cnt <= 5'(0);
  end
  else begin
        init_cnt <= init_cnt_temp;
  end
end

assign init_done = (init_cnt == 18);

// =============================================================
audio_fir_fifo #(
  .WIDTH                (16             ),
  .DEPTH                (18                    ))
audio_fir1_fifo (
  .din                  (din            ), // input   [WIDTH-1:0]
  .din_vld              (din_vld        ), // input

  .sel                  (cnt            ), // input
  .dout                 (fir_fifo       ), // output  [WIDTH-1:0]

  .clk                  (clk            ), // input
  .rstn                 (rstn           ));// input


assign result_temp = (start) ? 20'b0 : mac_sum;

always @(posedge clk or negedge rstn) begin
  if (~rstn) begin
    result<= 20'b0;
  end
  else begin
    result <= result_temp;
  end
end


assign mac_a = fir_fifo;
assign mac_b = coef;
assign mac_c = result;

assign dout_temp = (state == S_FIR) & fir_done ? mac_out : dout;  // FIXME, remove dout reg?

always @(posedge clk or negedge rstn) begin
  if (~rstn) begin
    dout <= 16'(0);
  end
  else begin
    dout <= dout_temp;
  end
end

assign  dout_vld_temp = (dout_vld == 1'b1)          ? 1'b0 :
                       (state == S_FIR) & fir_done ? 1'b1 : dout_vld;

always @(posedge clk or negedge rstn) begin
  if (~rstn) begin
    dout_vld <= 1'b0;
  end
  else begin
    dout_vld <= dout_vld_temp;
  end
end

endmodule
