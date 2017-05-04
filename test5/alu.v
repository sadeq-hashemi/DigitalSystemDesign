module alu(Accum, Pcomp,Icomp, Pterm, Iterm, Fwd, A2D_res, Error, Intgrl,
	   src0sel, src1sel, multiply, sub, mult2, mult4, saturate, dst);
	
   // inputs
   input [15:0] Accum, Pcomp;
   input unsigned [13:0] Pterm;
   input unsigned [11:0] Fwd, A2D_res;
   input signed [11:0] Error, Intgrl, Icomp, Iterm;
   input [2:0] 	       src1sel, src0sel;
   input 	       multiply, sub, mult2, mult4, saturate;
   
   // outputs
   output [15:0]       dst;  
   wire signed [29:0]  product;
   wire [15:0] 	       src1, int_src0, mult_src0, src0, final_result, saturated_ALU, sat_mult_ALU;
   wire signed [14:0]  op1, op0;
   
   // the mux select for src1 -extends all inputs to required # of bits
   assign src1 = ((src1sel == 3'b000) ? Accum :
		  (src1sel == 3'b001) ? {4'b0000,Iterm} :
		  (src1sel == 3'b010) ? {{4{Error[11]}},Error} :
		  (src1sel == 3'b011) ? {{8{Error[11]}},Error[11:4]} :
		  (src1sel == 3'b100) ? {4'b0000,Fwd} : 16'b0);
   
 
   // the mux select for src0 -extends all inputs to required # of bits  
   assign int_src0 = ((src0sel == 3'b000) ? {4'b0000, A2D_res} :
			  (src0sel == 3'b001) ? {{4{Intgrl[11]}},Intgrl} :
			  (src0sel == 3'b010) ? {{4{Icomp[11]}},Icomp} :
			  (src0sel == 3'b011) ? Pcomp :
			  (src0sel == 3'b100) ? {2'b00, Pterm} : 16'b0);
     
    // multiplier for src0
   assign mult_src0 = ((mult2) ? (int_src0 << 1) :
		      (mult4) ? (int_src0 << 2) : int_src0);
   
  // subtraction for src0
   assign src0 = ((sub) ? (~mult_src0) : mult_src0);
   
   // the sum of all data (sub included for the + 1 in flipping bits in final_src0)
   assign final_result = src1 + src0 + sub;
   
   // check correct parameters for saturation		  
    assign saturated_ALU = (saturate) ? (((final_result[15]) ? ((&final_result[14:11]) ?  16'hF800: final_result) : ((|final_result[14:11]) ? 16'h07FF : final_result))) : final_result; 



   // multiply output
   assign op1 = src1[14:0];
   assign op0 = src0[14:0];
   
   // unshifted ALU to check for saturation
   assign product = op1 * op0;
  
   // checks correct parameters for multiplication saturation
   assign sat_mult_ALU = ((product[29]) ? ((&product[28:26]) ?  product[27:12] : 16'hC000) : ((|product[28:26]) ? 16'h3FFF :  product[27:12])); 
   
   // final ALU Output
   assign dst = (multiply) ? sat_mult_ALU : saturated_ALU;
   
   
endmodule
