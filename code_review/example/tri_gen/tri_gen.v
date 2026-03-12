module tri_gen(
			clk,
			res,
			d_out
			);
input		clk,res;
output[8:0]	d_out;
 
reg[1:0]	state;
reg[8:0]	d_out;
reg[7:0]	con;
 
always@(posedge clk or negedge res)
if(~res) begin
		state<=0;d_out<=0;con<=0;
end 
else begin 
	case(state)
	0://上升
	begin
		d_out<=d_out+1;
		if(d_out==299) begin
			state<=1;
		end 
	end 
	1://平顶；
	begin
		if(con==200) begin
		state<=2;
		con<=0;
		end 
		else begin
		con<=con+1;
		end 
	end 
	2://下降；
	begin 
		d_out<=d_out-1;
		if(d_out==1) begin
			state<=3;
		end 
	end
	3://平顶，不需要default了，2bite四个状态满了
	begin
		if(con==200) begin
		state<=0;
		con<=0;
		end 
		else begin
		con<=con+1;
		end 
	end 
	endcase
end 
 
endmodule
