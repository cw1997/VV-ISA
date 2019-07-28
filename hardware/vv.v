module vv(
	input clk,
	input rst_n,
	
	output hsync,
	output vsync,
	output[2:0] vga_r,
	output[2:0] vga_g,
	output[1:0] vga_b,
	
	output[3:0] gpio
);

vga vga(
	.clk(clk),
	.rst_n(rst_n),
	.hsync(hsync),
	.vsync(vsync),
	.vga_r(vga_r),
	.vga_g(vga_g),
	.vga_b(vga_b),
	.clk_25m(clk_25m),
);

assign gpio[0] = hsync;
assign gpio[1] = 0;
assign gpio[2] = vsync;
assign gpio[3] = 0;

endmodule