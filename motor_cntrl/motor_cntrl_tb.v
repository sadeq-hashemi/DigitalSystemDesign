module motor_cntrl_tb();

reg clk, rst_n;
reg [10:0] lft, rht;

wire fwd_lft, rev_lft, fwd_rht, rev_rht;

//instantiate
motor_cntrl iDUT(.clk(clk), .rst_n(rst_n), .lft(lft), .rht(rht), .fwd_lft(fwd_lft), 
		 .rev_lft(rev_lft), .fwd_rht(fwd_rht), .rev_rht(rev_rht));

// clock
always #5 clk = ~clk;

initial begin
clk = 0;
rst_n = 0;
lft = 11'b00000000000;
rht = 11'b00000000000;

#25000
rst_n = 1;

/*****************FORWARD LEFT*************/
// Forward Left, Reverse Right
lft = 11'b00000001111;
rht = 11'b11111111111;
#150000;

// Forward Left, 0 Right
lft = 11'b00000001111;
rht = 11'b00000000000;
#150000;

// Forward Left, Forward Right
lft = 11'b00100000000;
rht = 11'b00111111111;
#150000;

/*************** STATIONARY LEFT**********/
// 0 Left, Reverse Right
lft = 11'b00000000000;
rht = 11'b10000000000;
#150000;

// 0 Left, 0 Right
lft = 11'b00000000000;
rht = 11'b00000000000;
#150000;

// 0 Left, Forward Right
lft = 11'b00000000000;
rht = 11'b00000010000;
#150000;

/***************REVERSE LEFT*************/
// Reverse Left, Reverse Right
lft = 11'b11111110000;
rht = 11'b10000000000;
#150000;

// Reverse Left, 0 Right
lft = 11'b10101010101;
rht = 11'b00000000000;
#150000;

// Reverse Left, Forward Right
lft = 11'b11001100110;
rht = 11'b01110000111;
#150000;

$stop;

end
endmodule
