
module TX_RX_tb(); 

reg clk, rst_n, trmt;
reg [7:0] value;
wire [7:0] out;
wire TX_out, rx_rdy, rx_rdy_clr, tx_done; 



//// Instantiate your UART_tx...data to transmit comes from 8-bit counter ////
UART_tx iTX(.clk(clk), .rst_n(rst_n), .TX(TX_out), .trmt(trmt), .tx_data(value), .tx_done(tx_done));
//// Instantiate your UART_rx...output byte should be connected to LEDs[7:0] ////
UART_rcv iRCV(.RX(TX_out), .clk(clk), .rx_data(out), .rst_n(rst_n), .rx_rdy(rx_rdy), .rx_rdy_clr(rx_rdy_clr));
initial clk = 0;
always #10 clk = ~clk; 
initial begin

rst_n = 1'b0;
	trmt = 0;
	//tx_data = 8'h0;  
	#70
	rst_n = 1'b1; 
	value =  8'b0001_1101; 
	trmt = 1'b1; 
	#50
	trmt = 1'b0;
	#1000000

	rst_n = 1'b1; 
	value =  8'b0111_1101; 
	trmt = 1'b1; 
	#50
	trmt = 1'b0;
	#1000000

	$stop;

end

endmodule