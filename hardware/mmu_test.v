`timescale 1ns/1ns

module mmu_test(
);

reg clk;
reg rst_n;
	
wire[15:0] S_DQ;
wire[11:0] S_A;
wire S_CLK;
wire[1:0] S_BA;
wire S_nCAS;
wire S_CKE;
wire S_nRAS;
wire S_nWE;
wire S_nCS;
wire[1:0] S_DQM;

mmu mmu(
	.clk(clk),
	.rst_n(rst_n),
	
	.S_DQ(S_DQ),
	.S_A(S_A),
	.S_CLK(S_CLK),
	.S_BA(S_BA),
	.S_nCAS(S_nCAS),
	.S_CKE(S_CKE),
	.S_nRAS(S_nRAS),
	.S_nWE(S_nWE),
	.S_nCS(S_nCS),
	.S_DQM(S_DQM)
);

always 
begin 
	#1 clk = ~clk;
end

initial
begin
	clk = 0;
	rst_n = 0;
	#10
	rst_n = 1;
	
end

endmodule