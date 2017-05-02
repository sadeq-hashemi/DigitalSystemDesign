module counter_8(button_rise_edge, count, clk, rst_n);

input button_rise_edge, clk, rst_n; 
output reg [7:0] count; 

always @(posedge clk, negedge rst_n)begin

	if(!rst_n) count <= 8'b0; 
	else if(button_rise_edge) count <= count + 1; //make sure it is active low

end
endmodule