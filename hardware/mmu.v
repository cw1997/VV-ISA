module mmu(
	input clk, 
	input rst_n,
	
	output reg[15:0] S_DQ,
	output reg[11:0] S_A,
	output S_CLK,
	output reg[1:0] S_BA,
	output reg S_nCAS,
	output reg S_CKE,
	output reg S_nRAS,
	output reg S_nWE,
	output reg S_nCS,
	output reg[1:0] S_DQM
	
);

// clk = 50_000_000;
// 1 tick = 0.000_000_020s = 20ns
localparam TICK_INTERVAL = 20;
assign S_CLK = clk;
	
//#------------------SDRAM---------------------#
//set_location_assignment	PIN_56	-to	S_DQ[0]
//set_location_assignment	PIN_57	-to	S_DQ[1]
//set_location_assignment	PIN_58	-to	S_DQ[2]
//set_location_assignment	PIN_59	-to	S_DQ[3]
//set_location_assignment	PIN_60	-to	S_DQ[4]
//set_location_assignment	PIN_61	-to	S_DQ[5]
//set_location_assignment	PIN_63	-to	S_DQ[6]
//set_location_assignment	PIN_64	-to	S_DQ[7]
//set_location_assignment	PIN_80	-to	S_DQ[8]
//set_location_assignment	PIN_77	-to	S_DQ[9]
//set_location_assignment	PIN_76	-to	S_DQ[10]
//set_location_assignment	PIN_75	-to	S_DQ[11]
//set_location_assignment	PIN_74	-to	S_DQ[12]
//set_location_assignment	PIN_72	-to	S_DQ[13]
//set_location_assignment	PIN_70	-to	S_DQ[14]
//set_location_assignment	PIN_69	-to	S_DQ[15]
//
//set_location_assignment	PIN_103	-to	S_A[0]
//set_location_assignment	PIN_104	-to	S_A[1]
//set_location_assignment	PIN_106	-to	S_A[2]
//set_location_assignment	PIN_105	-to	S_A[3]
//set_location_assignment	PIN_94	-to	S_A[4]
//set_location_assignment	PIN_92	-to	S_A[5]
//set_location_assignment	PIN_90	-to	S_A[6]
//set_location_assignment	PIN_89	-to	S_A[7]
//set_location_assignment	PIN_88	-to	S_A[8]
//set_location_assignment	PIN_87	-to	S_A[9]
//set_location_assignment	PIN_102	-to	S_A[10]
//set_location_assignment	PIN_86	-to	S_A[11]
//
//set_location_assignment	PIN_82	-to	S_CLK
//set_location_assignment	PIN_99	-to	S_BA[0]
//set_location_assignment	PIN_101	-to	S_BA[1]
//set_location_assignment	PIN_95	-to	S_nCAS
//set_location_assignment	PIN_84	-to	S_CKE
//set_location_assignment	PIN_96	-to	S_nRAS
//set_location_assignment	PIN_68	-to	S_nWE
//set_location_assignment	PIN_97	-to	S_nCS
//set_location_assignment	PIN_67	-to	S_DQM[0]
//set_location_assignment	PIN_81	-to	S_DQM[1]



	localparam STATUS_DEFAULT = 0;
	localparam STATUS_POWER_UP = 1;
	localparam STATUS_PRE_CHARGE = 2;
	localparam STATUS_AUTO_REFRESH_1 = 3;
	localparam STATUS_AUTO_REFRESH_2 = 4;
	localparam STATUS_MODE_SET = 5;
	localparam STATUS_IDLE = 6;
	
	reg[3:0] status;
	
	reg[15:0] tick, last_tick;
	
	localparam POWER_UP_VCC_AND_CLK_STABLE = 200_000 / TICK_INTERVAL; // 10_000 tick 200us
	localparam RAS_PRECHARGE_TIME_tRP = 18 / TICK_INTERVAL + 1; // 1 tick
	localparam RAS_CYCLE_TIME_tRC = 60 / TICK_INTERVAL; // 3 tick
	localparam MRS_TO_NEW_COMMAND_tMRD = 2; // 2 tick
	
//	localparam NO_OPERATION = 

	always @(posedge clk or negedge rst_n) 
	begin
		if (!rst_n) begin
			tick <= 0;
			last_tick <= 0;
		end 
		else begin
			tick <= tick + 1;
		end	
		
		if (!rst_n) begin
//			pre charge  exec nop for 200us
			status <= STATUS_DEFAULT;
		end 
		else if (tick > 0 && tick <= POWER_UP_VCC_AND_CLK_STABLE) begin
			status <= STATUS_POWER_UP;
		end
		else if (tick > POWER_UP_VCC_AND_CLK_STABLE && tick <= POWER_UP_VCC_AND_CLK_STABLE + RAS_PRECHARGE_TIME_tRP) begin
			status <= STATUS_PRE_CHARGE;
		end
		else if (tick > POWER_UP_VCC_AND_CLK_STABLE + RAS_PRECHARGE_TIME_tRP && tick <= POWER_UP_VCC_AND_CLK_STABLE + RAS_PRECHARGE_TIME_tRP + RAS_CYCLE_TIME_tRC) begin
			status <= STATUS_AUTO_REFRESH_1;
		end
		else if (tick > POWER_UP_VCC_AND_CLK_STABLE + RAS_PRECHARGE_TIME_tRP + RAS_CYCLE_TIME_tRC && tick <= POWER_UP_VCC_AND_CLK_STABLE + RAS_PRECHARGE_TIME_tRP + RAS_CYCLE_TIME_tRC + RAS_CYCLE_TIME_tRC) begin
			status <= STATUS_AUTO_REFRESH_2;
		end
		else if (tick > POWER_UP_VCC_AND_CLK_STABLE + RAS_PRECHARGE_TIME_tRP + RAS_CYCLE_TIME_tRC + RAS_CYCLE_TIME_tRC && tick <= POWER_UP_VCC_AND_CLK_STABLE + RAS_PRECHARGE_TIME_tRP + RAS_CYCLE_TIME_tRC + RAS_CYCLE_TIME_tRC + MRS_TO_NEW_COMMAND_tMRD) begin
			status <= STATUS_MODE_SET;
		end
		else if (tick > POWER_UP_VCC_AND_CLK_STABLE + RAS_PRECHARGE_TIME_tRP + RAS_CYCLE_TIME_tRC + RAS_CYCLE_TIME_tRC + MRS_TO_NEW_COMMAND_tMRD) begin
			status <= STATUS_IDLE;
		end
		else begin
		
		end
	end

	always @(posedge clk or negedge rst_n) 
	begin
		case(status)
			STATUS_DEFAULT : begin
				S_CKE <= 0;
				S_nCS <= 1;
				S_nRAS <= 1;
				S_nCAS <= 1;
				S_nWE <= 1;
				S_DQM <= 0;
				S_A <= 0;
				S_A[10] <= 0;
				S_BA <= 0;
			end
			STATUS_POWER_UP : begin
//				S_CKE <= 1;
				S_nCS <= 0;
				S_nRAS <= 1;
				S_nCAS <= 1;
				S_nWE <= 1;
//				S_DQM <= 0;
//				S_A <= 0;
//				S_A[10] <= 0;
//				S_BA <= 0;
			end
			STATUS_PRE_CHARGE : begin
//				S_CKE <= 1;
				S_nCS <= 0;
				S_nRAS <= 0;
				S_nCAS <= 1;
				S_nWE <= 0;
//				S_DQM <= 0;
//				S_A <= 0;
				S_A[10] <= 1;
//				S_BA <= 0;
			end
			STATUS_AUTO_REFRESH_1 : begin
				S_CKE <= 1;
				S_nCS <= 0;
				S_nRAS <= 0;
				S_nCAS <= 0;
				S_nWE <= 1;
//				S_DQM <= 0;
//				S_A <= 0;
//				S_A[10] <= 1;
//				S_BA <= 0;
			end
			STATUS_AUTO_REFRESH_2 : begin
				S_CKE <= 1;
				S_nCS <= 0;
				S_nRAS <= 0;
				S_nCAS <= 0;
				S_nWE <= 1;
//				S_DQM <= 0;
//				S_A <= 0;
//				S_A[10] <= 1;
//				S_BA <= 0;
			end
			STATUS_MODE_SET : begin
				S_CKE <= 1;
				S_nCS <= 0;
				S_nRAS <= 0;
				S_nCAS <= 0;
				S_nWE <= 1;
//				S_DQM <= 0;
//				S_A <= 0;
//				S_A[10] <= 1;
//				S_BA <= 0;
				S_A <= 12'b00_0_00_010_0_011;
				S_BA <= 0;
			end
			STATUS_IDLE : begin
//				S_CKE <= 1;
//				S_nCS <= 0;
//				S_nRAS <= 0;
//				S_nCAS <= 0;
//				S_nWE <= 1;
//				S_DQM <= 0;
//				S_A <= 0;
//				S_A[10] <= 1;
//				S_BA <= 0;
//				S_A <= 12'b00_0_00_010_0_011;
//				S_BA <= 0;
			end
		endcase
	end

	reg[15:0] refresh_tick;
	
	always @(posedge clk or negedge rst_n) 
	begin
//		if (tick == POWER_UP_VCC_AND_CLK_STABLE + RAS_PRECHARGE_TIME_tRP + RAS_CYCLE_TIME_tRC + RAS_CYCLE_TIME_tRC + MRS_TO_NEW_COMMAND_tMRD) begin
//			
//		end
		if (!rst_n) begin
			refresh_tick <= 0;
		end
		else begin
			if (refresh_tick == 15_000 / TICK_INTERVAL) begin
				refresh_tick <= 0;
			end
			else begin
				refresh_tick <= refresh_tick + 1;
			end
		end
//		if (status == STATUS_IDLE) begin
//			
//		end
	end

endmodule