

module barcode_2(clk, rst_n, BC, clr_ID_vld, ID, ID_vld); 

input clk, rst_n;
input BC, clr_ID_vld; 
output reg [7:0] ID; 
output reg ID_vld; 

reg negative_edge, positive_edge;
reg FF1, BC_sync, clr_ID_vld_sync, FF2;

reg sCLK, sCLK_FF1, sCLK_FF2; 
wire sCLK_rise, sCLK_fall;

//reg start_timer;  
reg [21:0] timer, timer_count;
reg [3:0]bit_count;
reg set_ID_vld;

localparam byte_done = 4'b1000;

typedef enum reg[1:0] {IDLE, TIME, WAIT, SHIFT} state_t;
state_t state, nxt_state;

//////////////////////////////////////////////////
//synchronize BC with clock and sCLK.
////////////////////////////////////////////////// 
 
always @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		FF1 <= 1'b1; 
		BC_sync <= 1'b1; 


		end 
 
	else	begin
		FF1 <= BC;
		BC_sync <= FF1; 

  
		end
end

always @(posedge clk, negedge rst_n) begin
	if(!rst_n) 
		ID_vld <= 0; 
	else if(clr_ID_vld) ID_vld <= 0;
	else if(set_ID_vld) ID_vld <= 1; 
	 
end

//////////////////////////////////////////////////
//assign next states a every positive edge
//////////////////////////////////////////////////
always @(posedge clk, negedge rst_n) begin
	if(!rst_n) 
		state <= IDLE; 
	else
		state <= nxt_state; 
end

//////////////////////////////////////////////////
//COMBINATIONAL LOGIC FOR STATES
////////////////////////////////////////////////// 
always_comb begin
	
	case(state)
		//state where system waits for a start bit
		//start bits are started with a falling edge
		IDLE: begin
				if(clr_ID_vld) nxt_state = IDLE; 
 				else if(!BC_sync) nxt_state = TIME;

				else nxt_state = IDLE;
			end

		//On TIME, we move on to SHIFT, once the timing parameter is
		//recorded, in other words, when we see a positive edge, we 
		//start preparing for a negative edge
		TIME: begin
				if(clr_ID_vld) nxt_state = IDLE;
				else if(!BC_sync) nxt_state = TIME;

				else nxt_state = WAIT;
			end

		//On SHIFT, if we see that all bits have been added, we move to 
		//next state. 
		SHIFT: begin 
				if(clr_ID_vld) nxt_state = IDLE;

				else if(timer_count != timer) nxt_state = SHIFT;

				else nxt_state = WAIT;

			end

		WAIT: begin
				if(clr_ID_vld) nxt_state = IDLE;
				else if(timer_count == timer && bit_count != byte_done) nxt_state = SHIFT;

				else if(timer_count == timer && bit_count == byte_done) nxt_state = IDLE;

				else nxt_state = WAIT; 

		
			end
	
		default: nxt_state = IDLE; 

	endcase 
	end

//////////////////////////////////////////////////
//SEQUENTIAL LOGIC FOR FSM
//////////////////////////////////////////////////
always @(posedge clk, negedge rst_n) begin
	//rst_N and clr_ID_vld both set all values to 
	//their initial values
	if(!rst_n) begin
			bit_count <= 4'b0; 
			timer <= 8'b0; 
			timer_count <= 0; 
			ID_vld <= 0; 
			ID <= 0; 
		   end

	else begin
		set_ID_vld <= 0; 
	case(state)


		IDLE: begin
 				if(!BC_sync) timer <= 0;;

			end


		//recorded, in other words, when we see a positive edge, we 
		//start preparing for a negative edge
		TIME: begin
				if(!BC_sync) timer <= timer + 1;

				else begin
					 bit_count <=0; 
					 timer_count <= 0;
					 ID <= 0;
					end
			end


		SHIFT: begin 

				if(timer_count != timer) timer_count <= timer_count + 1;

				else	begin
						timer_count <= 0;
						bit_count <= bit_count + 1;
						ID <= {ID[6:0], BC_sync};  
					end

			end

		WAIT: begin
				if(timer_count == timer && bit_count != byte_done) timer_count <= 0;

				else if(timer_count == timer && bit_count == byte_done && (ID[7:6] == 2'b0)) set_ID_vld <= 1;

				else timer_count <= timer_count + 1; 

		
			end
	


	endcase 

	end 
end


endmodule 