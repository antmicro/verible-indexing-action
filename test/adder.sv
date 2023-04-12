

module adder(
	input logic clk,
	input logic rst,
	input logic [7:0] a,
	input logic [7:0] b,
	output logic [8:0] q
);

always_ff@( posedge clk or posedge rst )
begin: proc_sync_adder
	if ( rst ) 
		begin
			q <= '0;
		end
	else
		begin
			q <= a + b;
		end
end

initial
begin: proc_intro
	$display("Adder module says hello");
end

endmodule // adder
