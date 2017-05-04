module pwm(duty,clk,rst_n,PWM_sig);

// inputs
input [9:0] duty;
input clk, rst_n;

// outputs
output reg PWM_sig;

// count variable
reg [9:0] cnt;

// signals
wire set, reset;

// logic for set and reset
always @ (posedge clk, negedge rst_n) begin
	if (rst_n) begin	
		// signal is high if set is high
		if (set) begin
			PWM_sig <= 1;
		end
		// signal is low if reset is high
		else if (reset) begin
			PWM_sig <= 0;
		end	
		//signal gets previous value	
		else begin
			PWM_sig <= PWM_sig;
		end	
	end
	else begin
		// reset is asserted, set signal to zero
		PWM_sig <= 1'b0;
	end
end

always @ (posedge clk, negedge rst_n) begin
	// count is zero if reset	
	if (!rst_n)
		cnt <= 0;
	// increment count if not	
	else 
		cnt <= cnt + 1;
end

// set is asserted if count is max
assign set = (cnt == 10'h3FF)? 1: 0;
// reset is asserted if count = duty
assign reset = (cnt == duty) ? 1: 0;

endmodule	












