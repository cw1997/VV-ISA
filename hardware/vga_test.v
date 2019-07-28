`timescale 1ns/1ns

module vga_test(
);

reg clk;
reg rst_n;
wire hsync;
wire vsync;
wire[2:0] vga_r;
wire[2:0] vga_g;
wire[1:0] vga_b;
wire clk_25m;

vga vga(
	.clk(clk),
	.rst_n(rst_n),
	.hsync(hsync),
	.vsync(vsync),
	.vga_r(vga_r),
	.vga_g(vga_g),
	.vga_b(vga_b),
	.clk_25m(clk_25m)
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
