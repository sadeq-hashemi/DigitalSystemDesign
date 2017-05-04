module pwm8(duty,clk,rst_n,PWM_sig);

input [7:0] duty;
input clk, rst_n;
output reg PWM_sig;
reg [7:0] cnt;
wire set, reset;

always @ (posedge clk, negedge rst_n) begin
	if (!rst_n) begin	
	// reset is asserted, set  signal to zero
		PWM_sig <= 1'b0;
	end
	else begin
		if (set) begin
			PWM_sig <= 1;
		end
		else if (reset) begin
			PWM_sig <= 0;
		end		
		else begin
			PWM_sig <= PWM_sig;
		end	
	end
end

always @ (posedge clk, negedge rst_n) begin
	if (!rst_n)
		cnt <= 0;
	else 
		cnt <= cnt + 1;
end

assign set = (cnt == 8'hFF)? 1: 0;
assign reset = (cnt == duty) ? 1: 0;

endmodule	

