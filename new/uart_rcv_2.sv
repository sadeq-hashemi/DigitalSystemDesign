module uart_rcv(RX, clk, rx_data, rst_n, rx_rdy, clr_rx_rdy);

input clk, rst_n; 
input RX, clr_rx_rdy; 

output wire [7:0] rx_data;
output reg rx_rdy; 

reg [9:0] rx_data_10; 
reg [12:0]counter_12;		//12 bit counter variable
reg [3:0] counter_4; 

reg shift, rx_rdy_set;

reg FF1, RX_sync;

//wait 1300 clock cycles 
localparam baud_end = 12'hA2B;//12 bit counter's endtime
localparam baud_mid = 12'h514; //12-bit counter's mid point

//numbers of needed shifts: 10 bits
localparam byte_complete = 4'b1010; 

//shift signal to indicate and shift right starting from MSB
//assign shift = ((counter_12 == baud_mid) && (!rx_rdy)) ? 1'b1: 1'b0;
//done signal that indicates that 9 bits have been shifted in (we have lost start bit)
//assign rx_rdy = (counter_4 == byte_complete) ? 1'b1: 1'b0; 

assign rx_data = rx_data_10[8:1]; 

typedef enum reg [1:0]{IDLE, RECEIVE} state_t; 
state_t state, nxt_state; 


always @(posedge clk, negedge rst_n)
begin
	if(!rst_n) rx_rdy <= 0;  
 
	else if (clr_rx_rdy) rx_rdy <= 0;
	else if(rx_rdy_set) rx_rdy <= 1;
	//else if (clr_rx_rdy) rx_rdy <= 0; 
end

//*************************FSM DESGIN***************************************************************************
//synchronize RX
always @(negedge clk, negedge rst_n) begin

  if (!rst_n)
    begin
	  FF1    <= 1'b1;
	  RX_sync <= 1'b1;
	  
	end
  else
    begin
	  FF1 <= RX;
	  RX_sync <= FF1;
	end

end


//Assigns next state at every positive edge
always @(posedge clk, negedge rst_n) 
begin
		if(!rst_n) state <= IDLE; 
		else	   state <= nxt_state; 
end

//Assigns next state at every positive edge
always_comb 
begin
		if(!rst_n) nxt_state <= IDLE; 
		else	
 
		 case(state)

			IDLE: 	begin
					if(!RX_sync)
							nxt_state = RECEIVE;

					else		nxt_state = IDLE; 

				end
			RECEIVE:begin
					if(counter_4 == byte_complete)
							nxt_state <= IDLE;

					else nxt_state <= RECEIVE;
				end 
		endcase
end

//NXT_STATE logic: In IDLE, next state is RECEIVE if RX is low
//		   In RECEIVE, next state is IDLE if rx_rdy is high 
always @(posedge clk, negedge rst_n) 
begin
	if(!rst_n) begin
			rx_rdy_set <= 0;
			shift <= 0;
			counter_12<= 12'b0; 
			counter_4<= 4'b0; 
			rx_data_10 <= 10'b0;
		end
	else begin
			rx_rdy_set <=0;
			shift <= 0;
		case(state)
			
			default: begin
				 	rx_rdy_set <= 0;
					shift <= 0;
				end 

			IDLE: 	begin
					if(!RX_sync)	begin
								counter_12<= 12'b0; 
								counter_4<= 4'b0; 
							end


				end
			RECEIVE:begin
					if(counter_4 == byte_complete)begin
							rx_rdy_set <= 1;
							
							end

					else if(counter_12 == baud_mid)	begin
							counter_12 <= counter_12 + 1; 
							rx_data_10 <= {RX_sync, rx_data_10[9:1]};
							//shift <= 1; 
						end
					else if(counter_12 == baud_end) begin
							counter_12 <= 12'b0; 
							counter_4 <= counter_4 + 1; 
						end
					else counter_12 <= counter_12 + 1; 
				end 
		endcase
	end
end


endmodule
