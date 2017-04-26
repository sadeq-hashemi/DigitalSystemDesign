module UART_test(clk,RST_n,next_byte,LEDs);
//module UART_test();

input clk,RST_n;	// 50MHz clock & unsynched active low reset from push button
input next_byte;	// active low unsynched push button to send next byte over UART

output [7:0] LEDs;	// received byte of LEDs will be displayed over LEDs

wire [7:0] count;
//reg [7:0] tx_data;
//reg [7:0] rx_data;
wire send_next;

wire button_rise_edge, rst_n; 
wire TX, tx_done, trmt;
wire RX, rx_rdy, rx_rdy_clr; 

assign button_rise_edge = send_next;
assign trmt = button_rise_edge;
assign rx_rdy_clr = trmt; 
//assign tx_data = cnt; 
assign RX = TX;
//assign LEDs = rx_data;

//// Instantiate reset synchronizer ////
reset_synch iRST(.clk(clk), .RST_n(RST_n), .rst_n(rst_n));

//// Make or instantiate a push button release detector /////
Pushbutton_detect idetect(.clk(clk), .rst_n(rst_n), .next_byte(next_byte), .send_next(send_next));

//// Instantiate your UART_tx...data to transmit comes from 8-bit counter ////
uart_tx iTX(.clk(clk), .rst_n(rst_n), .tx(TX), .strt_tx(trmt), .tx_data(count), .tx_done(tx_done));
//// Instantiate your UART_rx...output byte should be connected to LEDs[7:0] ////
//UART_rcv iRCV(.RX(RX), .clk(clk), .rx_data(LEDs), .rst_n(rst_n), .rx_rdy(rx_rdy), .rx_rdy_clr(rx_rdy_clr));
uart_rcv_2 iRCV(.RX(RX), .clk(clk), .rx_data(LEDs), .rst_n(rst_n), .rx_rdy(rx_rdy), .rx_rdy_clr(rx_rdy_clr));

//// Make or instantiate an 8-bit counter to provide data to test with /////
counter_8 iCOUNTER(.button_rise_edge(button_rise_edge), .count(count), .clk(clk), .rst_n(rst_n));

/*
initial clk = 0; 
always #10 clk = ~clk; 

initial begin
RST_n = 0; 
next_byte = 1; 
#30
RST_n = 1; 
#12
#100
#1500000
next_byte = 0; 
#20
next_byte = 1; 
#1500000

next_byte = 0; 
#20
next_byte = 1; 
#1500000

next_byte = 0; 
#20
next_byte = 1; 
#1500000

next_byte = 0; 
#20
next_byte = 1; 
#1500000

next_byte = 0; 
#20
next_byte = 1; 
#1500000

next_byte = 0; 
#20
next_byte = 1; 
#1500000

next_byte = 0; 
#20
next_byte = 1; 
#1500000

next_byte = 0; 
#20
next_byte = 1; 
#1500000

next_byte = 0; 
#20
next_byte = 1; 
#1500000

next_byte = 0; 
#20
next_byte = 1; 
#1500000

$stop;

end
	*/
endmodule
