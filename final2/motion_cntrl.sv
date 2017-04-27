module motion_cntrl(clk, rst_n, go, strt_cnv, chnnl, cnv_cmplt, A2D_res,
             IR_in_en, IR_mid_en, IR_out_en, LEDs, lft, rht);

// inputs
input clk, rst_n, go, cnv_cmplt;
input unsigned [11:0] A2D_res;

//outputs
output reg strt_cnv;
output IR_in_en, IR_mid_en, IR_out_en;
output [2:0] chnnl;
output [7:0] LEDs;
output [10:0] lft, rht;

// ALU inputs
logic [15:0] Accum, Pcomp;
logic [11:0] Fwd, A2D_res;
logic [11:0] Error, Intgrl, Icomp;
logic [2:0]  src1sel, src0sel;
logic multiply, sub, mult2, mult4, saturate;

// Easily Changeable Iterm and Pterm
localparam Pterm = 14'h3680;
localparam Iterm = 12'h500;
// right and left register signals
logic [11:0] rht_reg, lft_reg;

// ALU outputs
wire [15:0] dst;

// PWM Stuff
logic PWM_sig;


/******************Instantiations*********************/
// ALU Instantiation
alu iALU(.Accum(Accum), .Pcomp(Pcomp),.Icomp(Icomp), .Pterm(Pterm), .Iterm(Iterm), .Fwd(Fwd), .A2D_res(A2D_res), .Error(Error), .Intgrl(Intgrl),
       .src0sel(src0sel), .src1sel(src1sel), .multiply(multiply), .sub(sub), .mult2(mult2), .mult4(mult4), .saturate(saturate), .dst(dst));

// PWM Instantiation
pwm8 iPWM(.duty(8'h8C), .clk(clk), .rst_n(rst_n), .PWM_sig(PWM_sig));

// Timer Registers and signals
logic [11:0] timer;
logic en_timer, clr_timer;

// Channel signals
logic clr_chnnl, inc_chnnl;
logic [2:0] chnnl_no;

// Destination signals
logic clr_Accum, dst2Accum, dst2Err, dst2Int, dst2Icmp, dst2Pcmp, dst2lft, dst2rht;

// Intgrl signals
logic [1:0] int_dec;
logic en_int_dec;

assign lft = lft_reg[11:1];
assign rht = rht_reg[11:1];

assign LEDs = Error[11:4];

// Timer
always_ff @ (posedge clk, negedge rst_n)
begin
    if (!rst_n)
        timer <= 0;
    else if (clr_timer)
        timer <= 0;
    else
        timer <= timer + 1;
end

// Channel_no logic
always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    chnnl_no <= 0;
  else if (clr_chnnl)
    chnnl_no <= 0;
  else if (inc_chnnl)
    chnnl_no <= chnnl_no + 1;
  else
    chnnl_no <= chnnl_no;
end

// Channel Sequence Logic
assign chnnl = (chnnl_no == 0) ? 1 :
		(chnnl_no == 1) ? 0 :
		(chnnl_no == 2) ? 4 :
		(chnnl_no == 3) ? 2 :
		(chnnl_no == 4) ? 3 :	
		(chnnl_no == 5) ? 7 : 5;

/***********************MOTION CONTROLLER SIGNALS ******************/
// Accum logic
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n)
    		Accum <= 0;
 	else if (clr_Accum)
    		Accum <= 0;
  	else if (dst2Accum)
    		Accum <= dst[15:0];
  	else
   		Accum <= Accum;
end

// Fwd logic (from prof Kim)
always_ff @(posedge clk, negedge rst_n) begin
    	if (!rst_n)
        	Fwd <= 12'h000;
    	else if (~go)
        	Fwd <= 12'h000;
    	else if (dst2Int & ~(&Fwd[10:8]))
        	Fwd <= Fwd + 1'b1;
    	else
    		Fwd <= Fwd;
end

// Error Logic
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n)
    		Error <= 0;
  	else if (dst2Err)
   		Error <= dst[11:0];
  	else
  	 	Error <= Error;
end

// Intgrl Logic
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n)
    		Intgrl <= 0;
  	else if (dst2Int)
   		Intgrl <= dst[11:0];
  	else
  	 	Intgrl <= Intgrl;

end

// Pcomp Logic
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n)
    		Pcomp <= 0;
  	else if (dst2Pcmp)
   		Pcomp <= dst[15:0];
  	else
  	 	Pcomp <= Pcomp;
end

// Icomp Logic
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n)
    		Icomp <= 0;
  	else if (dst2Icmp)
   		Icomp <= dst[11:0];
  	else
  	 	Icomp <= Icomp;
end

// Left Register Logic
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n)
		lft_reg <= 12'h000;
	else if (!go)
		lft_reg <= 12'h000;
	else if (dst2lft)
		lft_reg <= dst[11:0];
end

// Right Register Logic
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n)
		rht_reg <= 12'h000;
	else if (!go)
		rht_reg <= 12'h000;
	else if (dst2rht)
		rht_reg <= dst[11:0];
end

// It takes 4 cycles to integrate properly
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n)
    		int_dec <= 0;
  	else if (en_int_dec)
   		int_dec <= int_dec + 1;

end


// States
typedef enum reg [3:0] {IDLE, WAIT_4096, WAIT_CNV_1, CALC_RHT, WAIT_32, WAIT_CNV_2, CALC_LFT, INTGRL,
			ICOMP, PCOMP, ACCUM1, RHT_REG, ACCUM2, LFT_REG, WAIT_ICOMP, WAIT_PCOMP} state_t;

state_t state, next_state;

// Select IR Sensor Pair
assign IR_in_en = (chnnl_no == 0 || chnnl_no == 1) ? PWM_sig : 0;
assign IR_mid_en = (chnnl_no == 2 || chnnl_no == 3) ? PWM_sig : 0;
assign IR_out_en = (chnnl_no == 4 || chnnl_no == 5) ? PWM_sig : 0;

// Update state
always_ff @(posedge clk, negedge rst_n)
begin
    if(!rst_n)
        state <= IDLE;
    else
        state <= next_state;
end

// Next State Logic
always_comb 
begin
	// Default
	inc_chnnl = 0; // gives closer to correct IR_en values

  	clr_timer = 1;

	strt_cnv = 0;

	// ALU Input Controls
	src0sel = 3'b000;
	src1sel = 3'b000;

	// ALU Operation Controls
	sub = 0;
	multiply = 0;
	mult2 = 0;
	mult4 = 0;
	saturate = 0;

	// Destination Controls
	clr_Accum = 1;
	dst2Accum = 0;
	dst2Err = 0;
	dst2Int = 0;
	dst2Icmp = 0;
	dst2Pcmp = 0;
	dst2lft = 0;
	dst2rht = 0;

	en_int_dec = 0;
	
    	next_state = IDLE;
	
    	case(state)
        // Enabling timer and clearing all signals specified
        IDLE: begin
            if(go) begin 
                clr_timer = 0;
                clr_chnnl = 1;
                clr_Accum = 1;
                next_state = WAIT_4096;
            end
            else
                next_state = IDLE;
        end

       WAIT_4096: begin
		clr_timer = 0;
		if(&timer) begin
			strt_cnv = 1;
			next_state = WAIT_CNV_1;
		end
		else
			next_state = WAIT_4096;
		
        end
        WAIT_CNV_1: begin
		if(cnv_cmplt) begin
			next_state = CALC_RHT;
		end
		else begin
			next_state = WAIT_CNV_1;
		end
        end
        CALC_RHT: begin
		clr_timer = 1;
		clr_chnnl = 0;
		inc_chnnl = 1;
		case(chnnl_no) 
			// Accum = IR_in_rht
			0: begin
				src0sel = 3'b000; // Accum2Src1
				src1sel = 3'b000; // A2DSrc0
				dst2Accum = 1;				
				next_state = WAIT_32;
			end
			// Accum = Accum + IR_in_mid_rht*2
			2: begin
				src0sel = 3'b000; // Accum2Src1
				src1sel = 3'b000; // A2DSrc0
				mult2 = 1;
				dst2Accum = 1;
				next_state = WAIT_32;
			end
			// Accum = Accum + IR_out_rht*4
			4: begin 
				src0sel = 3'b000; // Accum2Src1
				src1sel = 3'b000; // A2DSrc0
				mult2 = 0;
				mult4 = 1;
				dst2Accum = 1;
				next_state = WAIT_32;
			end
			default:
				next_state = CALC_RHT;
		endcase
		
        end
        WAIT_32: begin
		clr_timer = 0;
		if(&timer[3:0]) begin
			strt_cnv = 1;
			next_state = WAIT_CNV_2;
		end
		else
			next_state = WAIT_32;
        end
        WAIT_CNV_2: begin
		if(cnv_cmplt) begin
			next_state = CALC_LFT;
		end
		else begin
			next_state = WAIT_CNV_2;
		end
        end
        CALC_LFT: begin
		clr_timer = 1;
		clr_chnnl = 0;
		inc_chnnl = 1;
		case(chnnl_no) 
			// Accum = Accum - IR_in_lft
			1: begin
				src0sel = 3'b000; // Accum2Src1
				src1sel = 3'b000; // A2DSrc0
				sub = 1;
				dst2Accum = 1;				
				next_state = INTGRL;
			end
			// Accum = Accum - IR_in_mid_lft*2
			3: begin
				src0sel = 3'b000; // Accum2Src1
				src1sel = 3'b000; // A2DSrc0
				sub = 1;
				mult2 = 1;
				dst2Accum = 1;
				next_state = INTGRL;
			end
			// Error = Accum - IR_out_lft*4
			5: begin 
				src0sel = 3'b000; // Accum2Src1
				src1sel = 3'b000; // A2DSrc0
				mult4 = 1;
				sub = 1;
				saturate = 1;
				dst2Err = 1;
				next_state = INTGRL;
			end
			default:
				next_state = CALC_LFT;
		endcase
        end
       	INTGRL: begin
		if (chnnl_no == 6) begin
			// Intgrl = Error>>4 + Intgrl
			src0sel = 3'b001; // Intgrl
			src1sel = 3'b011; // ErrDiv22Src1
			saturate = 1;
			en_int_dec = 1;
			dst2Int = &int_dec;
			next_state = ICOMP;
		end
		else
			next_state = WAIT_4096;

        end
	ICOMP: begin
			// Icomp = Iterm*Intgrl
			src0sel = 3'b001; //Intgrl
			src1sel = 3'b001; //Iterm
			multiply = 1;
			dst2Icmp = 1;
			next_state = WAIT_ICOMP;
	end
	PCOMP: begin
			// Pcomp =Error*Pterm
			src0sel = 3'b100; // Pterm
			src1sel = 3'b010; // Err2Src1
			multiply = 1;
			dst2Pcmp = 1;			
			next_state = WAIT_PCOMP;
	end
	ACCUM1: begin
			// Accum = Fwd - Pcomp
			src0sel = 3'b011; // Pcomp
			src1sel = 3'b100; // Fwd
			sub = 1;
			dst2Accum = 1;	
			next_state = RHT_REG;
	end
	RHT_REG: begin
			// rht_reg = Accum ? Icomp
			src0sel = 3'b010; // Icomp
			src1sel = 3'b000; // Accum
			sub = 1;	
			saturate = 1;	
			dst2rht = 1;
			next_state = ACCUM2;
	end
	ACCUM2: begin
			// Accum = Fwd + Pcomp	
			src0sel = 3'b011; // Pcomp
			src1sel = 3'b100; // Fwd
			dst2Accum = 1;
			next_state = LFT_REG;
	end
	LFT_REG: begin
			// lft_reg = Accum + Icomp
			src0sel = 3'b010; // Icomp
			src1sel = 3'b000; // Accum
			saturate = 1;
			dst2lft = 1;
			next_state = IDLE;
	end
	WAIT_ICOMP: begin	
			next_state = PCOMP;
	end
	WAIT_PCOMP: begin
			next_state = ACCUM1;
	end
		
	endcase
end
endmodule
