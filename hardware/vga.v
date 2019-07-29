module vga(
	input clk,
	input rst_n,
	output hsync,
	output vsync,
	output reg[2:0] vga_r,
	output reg[2:0] vga_g,
	output reg[1:0] vga_b,
	
	input[100-1:0] video_memory,
	
	output reg clk_25m
);

//#--------------------VGA----------------------#
//set_location_assignment	PIN_5	-to	hsync
//set_location_assignment	PIN_4	-to	vsync
//set_location_assignment	PIN_14	-to	vga_r[0]
//set_location_assignment	PIN_15	-to	vga_r[1]
//set_location_assignment	PIN_12	-to	vga_r[2]
//set_location_assignment	PIN_13	-to	vga_g[0]
//set_location_assignment	PIN_10	-to	vga_g[1]
//set_location_assignment	PIN_11	-to	vga_g[2]
//set_location_assignment	PIN_6	-to	vga_b[0]
//set_location_assignment	PIN_8	-to	vga_b[1]


//reg clk_25m;
reg div_cnt;

always @(posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		div_cnt <= 0;
		clk_25m <= 0;
	end 
	else if (div_cnt == 0) begin
		div_cnt <= 0;
		clk_25m <= ~clk_25m;
	end 
	else begin
		div_cnt <= div_cnt + 1;
	end
end

reg[18:0] cursor;
reg[11:0] row;
reg[11:0] col;
reg[11:0] x;
reg[11:0] y;

always @(posedge clk_25m or negedge rst_n)
begin
	if (!rst_n) begin
		row <= 0;
		col <= 0;
	end 
	else begin
		if (col == HORIZONTAL_WHOLE_LINE - 1) begin
			col <= 0;	
			row <= row + 1;	
		end 
		else begin
			col <= col + 1;
		end
		
		if (row == VERTICAL_WHOLE_FRAME - 1) begin
			row <= 0;		
		end
	end
end


localparam HORIZONTAL_FRONT_PROCH = 16;
localparam HORIZONTAL_SYNC_PLUSE = 96;
localparam HORIZONTAL_VISIBLE_AREA = 640;
localparam HORIZONTAL_BACK_PROCH = 48;
localparam HORIZONTAL_WHOLE_LINE = 800;

localparam VERTICAL_FRONT_PROCH = 10;
localparam VERTICAL_SYNC_PLUSE = 2;
localparam VERTICAL_VISIBLE_AREA = 480;
localparam VERTICAL_BACK_PROCH = 33;
localparam VERTICAL_WHOLE_FRAME = 525;

wire visible_area;

assign visible_area = col >= (HORIZONTAL_FRONT_PROCH + HORIZONTAL_SYNC_PLUSE) && col < (HORIZONTAL_FRONT_PROCH + HORIZONTAL_SYNC_PLUSE + HORIZONTAL_VISIBLE_AREA) && row >= (VERTICAL_FRONT_PROCH + VERTICAL_SYNC_PLUSE) && row < (VERTICAL_FRONT_PROCH + VERTICAL_SYNC_PLUSE + VERTICAL_VISIBLE_AREA);

//assign hsync = ~( col > HORIZONTAL_FRONT_PROCH && col <= HORIZONTAL_FRONT_PROCH + HORIZONTAL_SYNC_PLUSE );
//assign vsync = ~( row > VERTICAL_FRONT_PROCH && row <= VERTICAL_FRONT_PROCH + VERTICAL_SYNC_PLUSE );

// I dont know why should pulldown during FRONT_PROCH. by cw1997
assign hsync = col > (HORIZONTAL_FRONT_PROCH + HORIZONTAL_SYNC_PLUSE); // && (col < HORIZONTAL_FRONT_PROCH); 
assign vsync = row > (VERTICAL_FRONT_PROCH + VERTICAL_SYNC_PLUSE); // && (row < VERTICAL_FRONT_PROCH);

always @(posedge clk_25m or negedge rst_n)
begin
	if (!rst_n) begin
		vga_r <= 0;
		vga_g <= 0;
		vga_b <= 0;
		cursor <= 0;
	end 
	else if (visible_area) begin
		if (cursor == 640*480-1) begin
			cursor <= 0;
		end
		else begin
			cursor <= cursor + 1;
		end
		{vga_r, vga_g, vga_b} = {vga_r, vga_g, vga_b} + 1;
//		if (cursor < 100 && video_memory[cursor]) begin
//			vga_r <= 3'b111;
//			vga_g <= 3'b111;
//			vga_b <= 2'b11; 
//		end
//		else begin
//			vga_r <= 0;
//			vga_g <= 0;
//			vga_b <= 0;
//		end 
	end
	else begin
		vga_r <= 0;
		vga_g <= 0;
		vga_b <= 0;
	end 
//	if (!rst_n) begin
//	end 
//	else begin
//		if (col >= 0 && col < HORIZONTAL_FRONT_PROCH) begin
//			vsync <= 0;
//			hsync <= 0;
//			vga_r <= 0;
//			vga_g <= 0;
//			vga_b <= 0;
//			col <= col + 1;
//		end 
//		else if (col >= HORIZONTAL_FRONT_PROCH && col < HORIZONTAL_FRONT_PROCH + HORIZONTAL_SYNC_PLUSE) begin
//			vsync <= 0;
//			hsync <= 0;
//			vga_r <= 0;
//			vga_g <= 0;
//			vga_b <= 0;
//			col <= col + 1;
//		end 
//		else if (col >= HORIZONTAL_FRONT_PROCH + HORIZONTAL_SYNC_PLUSE && col < HORIZONTAL_FRONT_PROCH + HORIZONTAL_SYNC_PLUSE + HORIZONTAL_VISIBLE_AREA) begin
//			hsync <= 1;
//			row <= row + 1;
//			if (row >= 0 && row < VERTICAL_FRONT_PROCH) begin
//				vsync <= 1;
//				hsync <= 1;
//				vga_r <= 0;
//				vga_g <= 0;
//				vga_b <= 0;
//			end 
//			else 
//			if (row >= VERTICAL_FRONT_PROCH && row < VERTICAL_FRONT_PROCH + VERTICAL_SYNC_PLUSE) begin
//				vsync <= 1;
//				hsync <= 1;
//				vga_r <= 0;
//				vga_g <= 0;
//				vga_b <= 0;
//			end 
//			else if (row >= VERTICAL_FRONT_PROCH + VERTICAL_SYNC_PLUSE && row < VERTICAL_FRONT_PROCH + VERTICAL_SYNC_PLUSE + VERTICAL_VISIBLE_AREA) begin
//				vsync <= 1;
//				hsync <= 1;
//				vga_r <= 3'b111;
//				vga_g <= 3'b000;
//				vga_b <= 2'b00;
//			end
//			else if (row >= VERTICAL_FRONT_PROCH + VERTICAL_SYNC_PLUSE + VERTICAL_VISIBLE_AREA && row < VERTICAL_FRONT_PROCH + VERTICAL_SYNC_PLUSE + VERTICAL_VISIBLE_AREA + VERTICAL_BACK_PROCH) begin
//				vsync <= 1;
//				hsync <= 1;
//				vga_r <= 0;
//				vga_g <= 0;
//				vga_b <= 0;
//				col <= col + 1;
//			end 
//			else if (row >= VERTICAL_WHOLE_FRAME) begin
//				row <= 0;
//			end
//		end 
//		else if (col >= HORIZONTAL_WHOLE_LINE) begin
//			col <= 0;
//		end
//	end
end


endmodule