module A2D_intf_tb();

// inputs to A2D_intf
reg clk, rst_n, strt_cnv, MISO;
reg[2:0] chnnl;
// outputs
wire cnv_cmplt, SCLK, MOSI, a2d_SS_n;
wire[11:0] res;

// instantiate the interface
A2D_intf iDUT1(.clk(clk),.rst_n(rst_n),.strt_cnv(strt_cnv),.cnv_cmplt(cnv_cmplt),
	      .chnnl(chnnl),.res(res),.a2d_SS_n(a2d_SS_n),.SCLK(SCLK),.MOSI(MOSI),.MISO(MISO));

// instantiate ADC128S
ADC128S iDUT2(.clk(clk),.rst_n(rst_n),.SS_n(a2d_SS_n),.SCLK(SCLK),.MISO(MISO),.MOSI(MOSI));

// clock
always #5 clk = ~clk;

initial begin
clk = 0;
rst_n = 0;
# 5;
rst_n = 1;

// CH0
chnnl = 0;
strt_cnv = 1;
#20; 
strt_cnv = 0;
#10000;

#10000; 

#10000; 
/*
// CH1
chnnl = 1;
strt_cnv = 1;
#20;
strt_cnv = 0;
#10000;

// CH2
chnnl = 2;
strt_cnv = 1;
#20;
strt_cnv = 0;
#10000;

// CH3
chnnl = 3;
strt_cnv = 1;
#20;
strt_cnv = 0;
#10000;

// CH4
chnnl = 4;
strt_cnv = 1;
#20;
strt_cnv = 0;
#10000;

// CH5
chnnl = 5;
strt_cnv = 1;
#20;
strt_cnv = 0;
#10000;

// CH6
chnnl = 6;
strt_cnv = 1;
#20;
strt_cnv = 0;
#10000;

// CH7
chnnl = 7;
strt_cnv = 1;
#20;
strt_cnv = 0;
#10000;
*/
$stop;
end

endmodule