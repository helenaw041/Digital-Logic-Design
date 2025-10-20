`timescale 1ns/1ns

/*
 * Module: clkdiv
 * Description: Generates a clk_en signal that can be used to effectively divide the clock used elsewhere
 *              The seven segment display is not particularly visible with the full 50Mhz clock
 *
 * Parameterized to experiment with different clock frequencies for the display
 */
module clkdiv (
	input clk_pi,
	output clk_en_po
);
	
	parameter SIZE = 8;
	
	reg [SIZE-1:0] counter;
		
	initial begin
		counter <= 0;
	end
	
	always @(posedge clk_pi) begin
		counter = counter + 1;
	end
	
	assign clk_en_po = (counter == {SIZE{1'b0}}); 
	
endmodule // clkdiv


/*
 * Module: increment
 * Description: Constantly increments a sixteen bit number 
 */
module increment (
	input clk_pi,
	output [15:0] counter_po
);
	localparam SIZE = 40;

	reg [SIZE:0] count;
	
	always @(posedge clk_pi) begin
		count = count+1;
	end
	
	assign counter_po = count[SIZE:SIZE-15];

endmodule // increment