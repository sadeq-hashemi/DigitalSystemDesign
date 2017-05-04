// Testbench for our motion controller module
module motion_cntrl_tb();

reg go,cnv_cmplt,clk,rst_n;
reg [11:0] A2D_res;

wire start_conv,IR_in_en,IR_mid_en,IR_out_en;
wire [2:0] chnnl;
wire[7:0] LEDs;
wire[10:0] lft,rht;

// DUT
motion_cntrl iBUTT(	.go(go),
					.strt_cnv(start_conv),
					.cnv_cmplt(cnv_cmplt),
					.chnnl(chnnl),
					.A2D_res(A2D_res),
					.IR_in_en(IR_in_en),
					.IR_mid_en(IR_mid_en),
					.IR_out_en(IR_out_en),
					.LEDs(LEDs),
					.lft(lft),
					.rht(rht),
					.clk(clk),
					.rst_n(rst_n));

// clock instantiation					
always #2 clk = ~clk;

initial begin
	// begin with reset asserted and all inputs 0 
	clk = 1'b0;
	rst_n = 1'b0;
	cnv_cmplt = 1'b0;
	go = 1'b0;
	A2D_res = 12'h00;
	#20;
	// cnv_cmplt = 1'b1; // assert converstion complete throughout whole test because data will always be ready as this is a testbench
	// deassert reset, GO not asserted so should stay in IDLE state 
	rst_n = 1'b1;
	
	// FIRST TEST, A2D_res = 12'h222 throughout whole process
	#20;
	// assert GO to proceed to EN state, give A2D_res nonzero value
	go = 1'b1;
	A2D_res = 12'h222;
	#4; // transition to EN 
	//go = 1'b0;
	#16384; // 4 * 4096, wait 4096 in EN state
	#4; // transition to CONVERTR
	#2500; // wait until conversion is complete
	cnv_cmplt = 1'b1;
	#4; // transtition to INC_CHANNEL state 
	cnv_cmplt = 1'b0;
	#128; // 4 * 32, wait 32 in INC_CHANNEL state 
	#4; // transition to CONVERTL state
	#2500; // wait until conversion is complete
	cnv_cmplt = 1'b1;
	#4; // transition to EN 
	cnv_cmplt = 1'b0;
	#16384; // 4 * 4096, wait 4096 in EN state
	#4; // transition to CONVERTR
	#2500; // wait until conversion is complete
	cnv_cmplt = 1'b1;
	#4; // transtition to INC_CHANNEL state 
	cnv_cmplt = 1'b0;
	#128; // 4 * 32, wait 32 in INC_CHANNEL state 
	#4; // transition to CONVERTL state
	#2500; // wait until conversion is complete
	cnv_cmplt = 1'b1;
	#4; // transition to EN 
	cnv_cmplt = 1'b0;
	#16384; // 4 * 4096, wait 4096 in EN state
	#4; // transition to CONVERTR
	#2500; // wait until conversion is complete
	cnv_cmplt = 1'b1;
	#4; // transtition to INC_CHANNEL state 
	cnv_cmplt = 1'b0;
	#128; // 4 * 32, wait 32 in INC_CHANNEL state 
	#4; // transition to CONVERTL state
	#2500; // wait until conversion is complete
	cnv_cmplt = 1'b1;
	#4; // transition to EN 
	cnv_cmplt = 1'b0;
	#4; // transition to INTG
	#8; // transition to ITERM (extra cycle due to muliplication)
	#8; // transition to PTERM (extra cycle due to muliplication)
	#4; // transition to MRT_R1
	#4; // transition to MRT_R2
	#4; // transition to MRT_L1
	#4; // transition to MRT_L2
	#4; // transition to IDLE
	
	// SECOND TEST, A2D_res changes throughout to test timing 
	#20;
	// assert GO to proceed to EN state, give A2D_res nonzero value
	//go = 1'b1;
	A2D_res = 12'h111;
	#4; // transition to EN 
	//go = 1'b0;
	#16384; // 4 * 4096, wait 4096 in EN state
	#4; // transition to CONVERTR
	A2D_res = 12'h222;
	#2500; // wait until conversion is complete
	cnv_cmplt = 1'b1;
	#4; // transtition to INC_CHANNEL state 
	cnv_cmplt = 1'b0;
	#128; // 4 * 32, wait 32 in INC_CHANNEL state 
	#4; // transition to CONVERTL state
	A2D_res = 12'h004;
	#2500; // wait until conversion is complete
	cnv_cmplt = 1'b1;
	#4; // transition to EN 
	cnv_cmplt = 1'b0;
	#16384; // 4 * 4096, wait 4096 in EN state
	#4; // transition to CONVERTR
	A2D_res = 12'h005;
	#2500; // wait until conversion is complete
	cnv_cmplt = 1'b1;
	#4; // transtition to INC_CHANNEL state 
	cnv_cmplt = 1'b0;
	#128; // 4 * 32, wait 32 in INC_CHANNEL state 
	#4; // transition to CONVERTL state
	#2500; // wait until conversion is complete
	A2D_res = 12'h006;
	cnv_cmplt = 1'b1;
	#4; // transition to EN 
	cnv_cmplt = 1'b0;
	#16384; // 4 * 4096, wait 4096 in EN state
	#4; // transition to CONVERTR
	A2D_res = 12'h009;
	#2500; // wait until conversion is complete
	cnv_cmplt = 1'b1;
	#4; // transtition to INC_CHANNEL state 
	cnv_cmplt = 1'b0;
	#128; // 4 * 32, wait 32 in INC_CHANNEL state 
	#4; // transition to CONVERTL state
	A2D_res = 12'h008;
	#2500; // wait until conversion is complete
	cnv_cmplt = 1'b1;
	#4; // transition to EN 
	cnv_cmplt = 1'b0;
	#4; // transition to INTG
	#8; // transition to ITERM (extra cycle due to muliplication)
	#8; // transition to PTERM (extra cycle due to muliplication)
	#4; // transition to MRT_R1
	#4; // transition to MRT_R2
	#4; // transition to MRT_L1
	#4; // transition to MRT_L2
	#4; // transition to IDLE
	
	// THIRD TEST, A2D_res changes throughout to test timing 
	#20;
	// assert GO to proceed to EN state, give A2D_res nonzero value
	//go = 1'b1;
	A2D_res = 12'h110;
	#4; // transition to EN 
	//go = 1'b0;
	#16384; // 4 * 4096, wait 4096 in EN state
	#4; // transition to CONVERTR
	A2D_res = 12'h420;
	#2500; // wait until conversion is complete
	cnv_cmplt = 1'b1;
	#4; // transtition to INC_CHANNEL state 
	cnv_cmplt = 1'b0;
	#128; // 4 * 32, wait 32 in INC_CHANNEL state 
	#4; // transition to CONVERTL state
	A2D_res = 12'h360;
	#2500; // wait until conversion is complete
	cnv_cmplt = 1'b1;
	#4; // transition to EN 
	cnv_cmplt = 1'b0;
	#16384; // 4 * 4096, wait 4096 in EN state
	#4; // transition to CONVERTR
	A2D_res = 12'h069;
	#2500; // wait until conversion is complete
	cnv_cmplt = 1'b1;
	#4; // transtition to INC_CHANNEL state 
	cnv_cmplt = 1'b0;
	#128; // 4 * 32, wait 32 in INC_CHANNEL state 
	#4; // transition to CONVERTL state
	#2500; // wait until conversion is complete
	A2D_res = 12'h666;
	cnv_cmplt = 1'b1;
	#4; // transition to EN 
	cnv_cmplt = 1'b0;
	#16384; // 4 * 4096, wait 4096 in EN state
	#4; // transition to CONVERTR
	A2D_res = 12'h123;
	#2500; // wait until conversion is complete
	cnv_cmplt = 1'b1;
	#4; // transtition to INC_CHANNEL state 
	cnv_cmplt = 1'b0;
	#128; // 4 * 32, wait 32 in INC_CHANNEL state 
	#4; // transition to CONVERTL state
	A2D_res = 12'h999;
	#2500; // wait until conversion is complete
	cnv_cmplt = 1'b1;
	#4; // transition to EN 
	cnv_cmplt = 1'b0;
	#4; // transition to INTG
	#8; // transition to ITERM (extra cycle due to muliplication)
	#8; // transition to PTERM (extra cycle due to muliplication)
	#4; // transition to MRT_R1
	#4; // transition to MRT_R2
	#4; // transition to MRT_L1
	#4; // transition to MRT_L2
	#4; // transition to IDLE
	
	// FOURTH TEST, A2D_res changes throughout to test timin, INTEGRAL TERM WILL BE IMPLEMENTED 
	#20;
	// assert GO to proceed to EN state, give A2D_res nonzero value
	//go = 1'b1;
	A2D_res = 12'h555;
	#4; // transition to EN 
	//go = 1'b0;
	#16384; // 4 * 4096, wait 4096 in EN state
	#4; // transition to CONVERTR
	A2D_res = 12'h010;
	#2500; // wait until conversion is complete
	cnv_cmplt = 1'b1;
	#4; // transtition to INC_CHANNEL state 
	cnv_cmplt = 1'b0;
	#128; // 4 * 32, wait 32 in INC_CHANNEL state 
	#4; // transition to CONVERTL state
	A2D_res = 12'h100;
	#2500; // wait until conversion is complete
	cnv_cmplt = 1'b1;
	#4; // transition to EN 
	cnv_cmplt = 1'b0;
	#16384; // 4 * 4096, wait 4096 in EN state
	#4; // transition to CONVERTR
	A2D_res = 12'h526;
	#2500; // wait until conversion is complete
	cnv_cmplt = 1'b1;
	#4; // transtition to INC_CHANNEL state 
	cnv_cmplt = 1'b0;
	#128; // 4 * 32, wait 32 in INC_CHANNEL state 
	#4; // transition to CONVERTL state
	#2500; // wait until conversion is complete
	A2D_res = 12'h188;
	cnv_cmplt = 1'b1;
	#4; // transition to EN 
	cnv_cmplt = 1'b0;
	#16384; // 4 * 4096, wait 4096 in EN state
	#4; // transition to CONVERTR
	A2D_res = 12'h363;
	#2500; // wait until conversion is complete
	cnv_cmplt = 1'b1;
	#4; // transtition to INC_CHANNEL state 
	cnv_cmplt = 1'b0;
	#128; // 4 * 32, wait 32 in INC_CHANNEL state 
	#4; // transition to CONVERTL state
	A2D_res = 12'h222;
	#2500; // wait until conversion is complete
	cnv_cmplt = 1'b1;
	#4; // transition to EN 
	cnv_cmplt = 1'b0;
	#4; // transition to INTG
	#8; // transition to ITERM (extra cycle due to muliplication)
	#8; // transition to PTERM (extra cycle due to muliplication)
	#4; // transition to MRT_R1
	#4; // transition to MRT_R2
	#4; // transition to MRT_L1
	#4; // transition to MRT_L2
	#4; // transition to IDLE
	$stop;
end

endmodule
