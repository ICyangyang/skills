module sigma_16p (
                data_in,
                syn_in,
                clk,
                res,
                data_out,
                syn_out
);

input[7:0]      data_in;    //采样信号
input           syn_in;     //采样时钟
input           clk;
input           res;
output          syn_out;    //累加结果同步脉冲
output[11:0]    data_out;   //累加结果输出


reg             syn_in_n1;  //syn_in反向延时
wire            syn_pulse;  //采样时钟上升沿识别脉冲

assign          syn_pulse = syn_in & syn_in_n1;
reg[3:0]        con_syn;    //采样时钟循环计数器
wire[7:0]       comp_8;     //补码
wire[11:0]      d_12;       //升位结果
assign          comp_8=data_in[7]?{data_in[7],~data_in[6:0]+1}:data_in;     //补码运算，二选一
assign          d_12={comp_8[7],comp_8[7],comp_8[7],comp_8[7],comp_8};//升位
reg [11:0]      sigma;  //累加计算
reg [11:0]      data_out; 
reg             syn_out;

always @(posedge clk or negedge res) begin
    if (~res) begin
        syn_in_n1<=0;
        con_syn<=4'b1111;
        sigma<=0;
        data_out<=0;
        syn_out<=0;
    end
    else begin
        syn_in_n1<=~syn_in;
        if (syn_pulse) begin
            con_syn<=con_syn+1;
        end

        if (syn_pulse) begin
            if (con_syn==15) begin
                data_out<=sigma;
                sigma<=d_12;
                syn_out<=1;
            end
            else begin
                sigma<=sigma+d_12;
            end
            
        end

        else begin
            syn_out<=0;
        end

    end
end

endmodule      
