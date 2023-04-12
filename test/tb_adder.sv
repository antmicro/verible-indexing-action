`timescale 1ps/1ps

module tb_adder();

logic clk;
logic rst;
logic[7:0] a;
logic[7:0] b;
logic[8:0] q;

adder xdut(
	.clk(clk),
	.rst(rst),
	.a(a),
	.b(b),
	.q(q)
);

initial begin
	clk = '0;
	rst = '0;
end

always
begin
	#(10)
		clk = ~clk;
end

initial
begin: proc_tb
	#(10)
		rst = '1;
	#(34)
		rst = '0;
	#(20)
		a = 8'hAA;
		b = 8'hBB;
	#(20)
		$display("%d added to %d is equal %d",a,b,q);
		$finish();
end


endmodule
