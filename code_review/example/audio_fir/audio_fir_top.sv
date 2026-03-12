module audio_fir_top();

/*verilator public_flat_rw_on*/
  parameter   DIN_WIDTH                 = 16, 
  parameter   DOUT_WIDTH                = 16,
  parameter   STAGE                     = 18;
  
  logic signed [DIN_WIDTH-1:0]     din;
  logic                            din_vld;
  logic signed [DOUT_WIDTH-1:0]    dout;
  logic                            dout_vld;
  logic                            init_done;
  logic                            start;
  logic                            enable;
  logic             [4:0]         cnt;
  logic signed      [19:0]        coef;
  logic signed      [DIN_WIDTH-1:0]     mac_a;
  logic signed      [19:0]        mac_b;
  logic signed      [19:0]        mac_c;
  logic signed      [19:0]        mac_sum;
  logic signed      [15:0]        mac_out;
  logic                            clk;
  logic                            rstn;
/*verilator public_off*/


 audio_fir #(
    .DIN_WIDTH(DIN_WIDTH),
    .DOUT_WIDTH(DOUT_WIDTH),
    .STAGE(STAGE)
 ) audio_fir(
    .din(din),
    .din_vld(din_vld),
    .dout(dout),
    .dout_vld(dout_vld),
    .init_done(init_done),
    .start(start),
    .enable(enable),
    .cnt(cnt),
    .coef(coef),
    .mac_a(mac_a),
    .mac_b(mac_b),
    .mac_c(mac_c),
    .mac_sum(mac_sum),
    .mac_out(mac_out),
    .clk(clk),
    .rstn(rstn)
 );


  export "DPI-C" function get_dinxxnU6B7Nbz0H;
  export "DPI-C" function set_dinxxnU6B7Nbz0H;
  export "DPI-C" function get_din_vldxxnU6B7Nbz0H;
  export "DPI-C" function set_din_vldxxnU6B7Nbz0H;
  export "DPI-C" function get_doutxxnU6B7Nbz0H;
  export "DPI-C" function get_dout_vldxxnU6B7Nbz0H;
  export "DPI-C" function get_init_donexxnU6B7Nbz0H;
  export "DPI-C" function get_startxxnU6B7Nbz0H;
  export "DPI-C" function set_startxxnU6B7Nbz0H;
  export "DPI-C" function get_enablexxnU6B7Nbz0H;
  export "DPI-C" function set_enablexxnU6B7Nbz0H;
  export "DPI-C" function get_cntxxnU6B7Nbz0H;
  export "DPI-C" function set_cntxxnU6B7Nbz0H;
  export "DPI-C" function get_coefxxnU6B7Nbz0H;
  export "DPI-C" function set_coefxxnU6B7Nbz0H;
  export "DPI-C" function get_mac_axxnU6B7Nbz0H;
  export "DPI-C" function get_mac_bxxnU6B7Nbz0H;
  export "DPI-C" function get_mac_cxxnU6B7Nbz0H;
  export "DPI-C" function get_mac_sumxxnU6B7Nbz0H;
  export "DPI-C" function set_mac_sumxxnU6B7Nbz0H;
  export "DPI-C" function get_mac_outxxnU6B7Nbz0H;
  export "DPI-C" function set_mac_outxxnU6B7Nbz0H;
  export "DPI-C" function get_clkxxnU6B7Nbz0H;
  export "DPI-C" function set_clkxxnU6B7Nbz0H;
  export "DPI-C" function get_rstnxxnU6B7Nbz0H;
  export "DPI-C" function set_rstnxxnU6B7Nbz0H;


  function void get_dinxxnU6B7Nbz0H;
    output logic signed [15:0] value;
    value=din;
  endfunction

  function void set_dinxxnU6B7Nbz0H;
    input logic signed [15:0] value;
    din=value;
  endfunction

  function void get_din_vldxxnU6B7Nbz0H;
    output logic  value;
    value=din_vld;
  endfunction

  function void set_din_vldxxnU6B7Nbz0H;
    input logic  value;
    din_vld=value;
  endfunction

  function void get_doutxxnU6B7Nbz0H;
    output logic signed [15:0] value;
    value=dout;
  endfunction

  function void get_dout_vldxxnU6B7Nbz0H;
    output logic  value;
    value=dout_vld;
  endfunction

  function void get_init_donexxnU6B7Nbz0H;
    output logic  value;
    value=init_done;
  endfunction

  function void get_startxxnU6B7Nbz0H;
    output logic  value;
    value=start;
  endfunction

  function void set_startxxnU6B7Nbz0H;
    input logic  value;
    start=value;
  endfunction

  function void get_enablexxnU6B7Nbz0H;
    output logic  value;
    value=enable;
  endfunction

  function void set_enablexxnU6B7Nbz0H;
    input logic  value;
    enable=value;
  endfunction

  function void get_cntxxnU6B7Nbz0H;
    output logic [4:0] value;
    value=cnt;
  endfunction

  function void set_cntxxnU6B7Nbz0H;
    input logic [4:0] value;
    cnt=value;
  endfunction

  function void get_coefxxnU6B7Nbz0H;
    output logic signed [19:0] value;
    value=coef;
  endfunction

  function void set_coefxxnU6B7Nbz0H;
    input logic signed [19:0] value;
    coef=value;
  endfunction

  function void get_mac_axxnU6B7Nbz0H;
    output logic signed [15:0] value;
    value=mac_a;
  endfunction

  function void get_mac_bxxnU6B7Nbz0H;
    output logic signed [19:0] value;
    value=mac_b;
  endfunction

  function void get_mac_cxxnU6B7Nbz0H;
    output logic signed [19:0] value;
    value=mac_c;
  endfunction

  function void get_mac_sumxxnU6B7Nbz0H;
    output logic signed [19:0] value;
    value=mac_sum;
  endfunction

  function void set_mac_sumxxnU6B7Nbz0H;
    input logic signed [19:0] value;
    mac_sum=value;
  endfunction

  function void get_mac_outxxnU6B7Nbz0H;
    output logic signed [15:0] value;
    value=mac_out;
  endfunction

  function void set_mac_outxxnU6B7Nbz0H;
    input logic signed [15:0] value;
    mac_out=value;
  endfunction

  function void get_clkxxnU6B7Nbz0H;
    output logic  value;
    value=clk;
  endfunction

  function void set_clkxxnU6B7Nbz0H;
    input logic  value;
    clk=value;
  endfunction

  function void get_rstnxxnU6B7Nbz0H;
    output logic  value;
    value=rstn;
  endfunction

  function void set_rstnxxnU6B7Nbz0H;
    input logic  value;
    rstn=value;
  endfunction



  initial begin
    $dumpfile("output/audio_fir/audio_fir.fst");
    $dumpvars(0, audio_fir_top);
  end

  export "DPI-C" function finish_nU6B7Nbz0H;
  function void finish_nU6B7Nbz0H;
    $finish;
  endfunction


endmodule
