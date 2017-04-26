
module pushbutton_detect(clk,rst_n, next_byte, send_next);

input clk;			// 50MHz clock
input rst_n;		// non synched reset from push button
input next_byte;
reg FF1, FF2, FF3;
output send_next;	// synched on deassert to negedge of clock


assign send_next = (FF2) & (~FF3); 

always @(negedge clk, negedge rst_n)
  if (!rst_n)
    begin
	  FF1    <= 1'b1;
	  FF2 <= 1'b1;
	  FF3 <= 1'b1;
	  
	end
  else
    begin
	  FF1 <= next_byte;
	  FF2 <= FF1;
	  FF3 <= FF2;
	end

endmodule