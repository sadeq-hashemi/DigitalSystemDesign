module motor_cntrl(clk, rst_n, lft, rht, fwd_lft, rev_lft, fwd_rht, rev_rht);

// inputs
input [10:0] lft, rht;
input clk, rst_n;

// outputs
output fwd_lft, rev_lft, fwd_rht, rev_rht;

// use to calculate magnitudes of left and right signals
wire [10:0] mag_lft, mag_rht;

// use for setting the break signal
wire brake_lft, brake_rht;

// use for specifying duty cycle
wire PWM_lft, PWM_rht;

// take the magnitudes of left and right singals
assign mag_lft = (lft[10]) ? -lft : lft;
assign mag_rht = (rht[10]) ? -rht : rht;

wire [9:0] abbr_mag_lft, abbr_mag_rht;
assign abbr_mag_lft = mag_lft[9:0];
assign abbr_mag_rht = mag_rht[9:0];

// set brake 
assign brake_lft = (!(|lft)) ? 1 : 0;
assign brake_rht = (!(|rht)) ? 1 : 0;

// send to pwm for a specified duty cycle
pwm ileft (.duty(abbr_mag_lft),.clk(clk),.rst_n(rst_n),.PWM_sig(PWM_lft));
pwm iright (.duty(abbr_mag_rht),.clk(clk),.rst_n(rst_n),.PWM_sig(PWM_rht));


// if MSB of lft/rht is 0 (postive number), set duty cycle
// if not, check assertion of brake signal
assign fwd_lft = (brake_lft) ? 1 : ((!lft[10]) ?  PWM_lft : 0);
assign fwd_rht = (brake_rht) ? 1 : ((!rht[10]) ?  PWM_rht : 0);

// if MSB of lft/rht is 1 (negative number), set duty cycle
// if not, check assertion of brake signal
assign rev_lft = (brake_lft) ? 1 : ((lft[10]) ?  PWM_lft : 0);
assign rev_rht = (brake_rht) ? 1 : ((rht[10]) ?  PWM_rht : 0);

endmodule