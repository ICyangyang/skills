module audio_fir_fifo #(
  parameter                     WIDTH   = 16,
  parameter                     DEPTH   = 32,
  localparam                    DEPTH_W   = $clog2(DEPTH)
) (
  input   [WIDTH-1:0]           din,
  input                         din_vld,

  input   [DEPTH_W-1:0]         sel,
  output  [WIDTH-1:0]           dout,

  input                         clk,
  input                         rstn
);
  
wire  [WIDTH-1:0]       data_lat_temp [DEPTH-1:0];
reg   [WIDTH-1:0]       data_lat      [DEPTH-1:0];
reg   [WIDTH-1:0]       data_sel;

genvar i;
generate
  for (i=0; i<DEPTH; i=i+1) begin: data_fifo
    if (i==0) begin
      assign data_lat_temp[i]  = (din_vld) ? din : data_lat[i];
    end
    else begin
      assign data_lat_temp[i]  = (din_vld) ? data_lat[i-1] : data_lat[i];
    end

    always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
        data_lat[i] <= WIDTH'(0);
      end
      else begin
        data_lat[i] <= data_lat_temp[i];
      end
    end
  end
endgenerate

//genvar j;
generate
always @* begin: g_out
  data_sel = WIDTH'(0);
  for (int j=0; j<DEPTH; j=j+1) begin: g_data_loop
    data_sel |= (sel == j) ? data_lat[j] : WIDTH'(0);
  end
end
endgenerate


assign dout = data_sel;

endmodule
