module vv(
	input clk,
	input rst_n,
	
	output hsync,
	output vsync,
	output[2:0] vga_r,
	output[2:0] vga_g,
	output[1:0] vga_b,
	
	output[15:0] S_DQ,
	output[11:0] S_A,
	output S_CLK,
	output[1:0] S_BA,
	output S_nCAS,
	output S_CKE,
	output S_nRAS,
	output S_nWE,
	output S_nCS,
	output[1:0] S_DQM,
	
	output[3:0] gpio
);

wire clk_25m;
//wire clk_25m_by_pll;

assign gpio[0] = clk;
assign gpio[1] = 0;
assign gpio[2] = clk_25m;
assign gpio[3] = 0;

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


wire[100-1:0] video_memory;
assign video_memory[50] = 1;

vga vga(
	.clk(clk),
	.rst_n(rst_n),
	.hsync(hsync),
	.vsync(vsync),
	.vga_r(vga_r),
	.vga_g(vga_g),
	.vga_b(vga_b),
	
	.video_memory(video_memory),
	
	//.clk_25m_by_pll(clk_25m_by_pll),
	.clk_25m(clk_25m)
);

endmodule