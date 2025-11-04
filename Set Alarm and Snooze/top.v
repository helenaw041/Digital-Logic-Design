`timescale 1ns/1ns

/*
 * Module: alarm_clock
 * Description: The top module of this lab 
 */
module alarm_clock (
	input CLK,
	input [7:0] SW,
	input [3:0] BTN,
	output [7:0] LED,
	output [6:0] SEG,
	output DP,
	output [3:0] AN
); 
	
	wire [15:0] display_num;
	wire [6:0] display_seg;
	
	wire [5:0] clock_seconds;
	wire [5:0] clock_minutes;
	wire [3:0] clock_hours;
	
	wire [3:0] clock_minutes_ones_digit;
	wire [3:0] clock_minutes_tens_digit;
	
	wire [3:0] clock_hours_ones_digit;
	wire [3:0] clock_hours_tens_digit;
	
	
	wire display_clk_en;
	wire seconds_clk_en;
	
	wire blink_clk_en;
	wire blink_en;
	reg blink;
	
	// alarms
	wire alarm0_triggered, alarm1_triggered;
	wire [5:0] alarm0_minutes;
	wire [3:0] alarm0_hours;
	wire [5:0] alarm1_minutes;
	wire [3:0] alarm1_hours;
	
	// Debounce
	wire [1:0] BTN_down;
	
	reg snooze_en;
		
	// base 10 formatting
	assign display_num[15:12] = clock_hours_tens_digit;
	assign display_num[11:8]  = clock_hours_ones_digit;
	assign display_num[7:4]   = clock_minutes_tens_digit;
	assign display_num[3:0]   = clock_minutes_ones_digit;
	
	assign LED = {alarm1_triggered & blink, alarm0_triggered & blink, clock_seconds};
	assign DP = (~blink_en | blink) ? AN[2] : 1'b1;
   assign SEG = (~blink_en | blink) ? display_seg : 7'b1111111;

   
	clkdiv Idisplay_clkdiv (
		.clk_pi(CLK),
		.clk_en_po(display_clk_en));
	
	seconds_clkdiv Iseconds_clkdiv (
		.clk_pi(CLK),
		.clk_en_po(seconds_clk_en));
		
	clkdiv #(.SIZE(26)) Iblink_clkdiv (
		.clk_pi(CLK),
		.clk_en_po(blink_clk_en));
		

		
	clock_fsm Iclock_fsm (
		.clk_pi(CLK),
		.clk_en_pi(seconds_clk_en),
		.seconds_po(clock_seconds),
		.minutes_po(clock_minutes),
		.hours_po(clock_hours),
		.increment_minute_pi(BTN_down[0] & ~BTN[2] && ~BTN[3]),
		.increment_hour_pi(BTN_down[1] & ~BTN[2] && ~BTN[3]),
		.blink_en_po(blink_en));
		
	alarm_fsm Ialarm0_fsm (
		.clk_pi(CLK),
		.alarm_en_pi(SW[0]),
		.clock_minutes_pi(clock_minutes),
		.clock_hours_pi(clock_hours),
		
		.minutes_po(alarm0_minutes),
		.hours_po(alarm0_hours),
		
		.increment_minute_pi(BTN_down[0] & BTN[2]),
		.increment_hour_pi(BTN_down[1] & BTN[2]),
		
		.snooze_en(snooze_en),

		.alarm_triggered_po(alarm0_triggered)); 
		
	alarm_fsm Ialarm1_fsm (
		.clk_pi(CLK),
		.alarm_en_pi(SW[1]),
		.clock_minutes_pi(clock_minutes),
		.clock_hours_pi(clock_hours),
		
		.minutes_po(alarm1_minutes),
		.hours_po(alarm1_hours),
		
		.increment_minute_pi(BTN_down[0] & BTN[3]),
		.increment_hour_pi(BTN_down[1] & BTN[3]),
		
		.snooze_en(snooze_en),
		
		.alarm_triggered_po(alarm1_triggered)); 



		
	sevenSegDisplay IsevenSegDisplay (
		.clk_pi(CLK),
		.clk_en_pi(display_clk_en),
		.num_pi(display_num),
		.seg_po(display_seg),
		.an_po(AN));

	binary_to_BCD Iminutes_BCD (
		.num_pi(BTN[3] ? alarm1_minutes : (BTN[2] ? alarm0_minutes : clock_minutes)),
		.ones_digit_po(clock_minutes_ones_digit),
		.tens_digit_po(clock_minutes_tens_digit));
		
	binary_to_BCD Ihours_BCD (
		.num_pi(BTN[3] ? alarm1_hours : (BTN[2] ? alarm0_hours : clock_hours)),
		.ones_digit_po(clock_hours_ones_digit),
		.tens_digit_po(clock_hours_tens_digit));

	button_debouncer Ibtn0_debouncer (
		.clk(CLK),
		.pushbutton(BTN[0]),
		.pushbutton_down(BTN_down[0]));
		
	button_debouncer Ibtn1_debouncer (
		.clk(CLK),
		.pushbutton(BTN[1]),
		.pushbutton_down(BTN_down[1]));

	initial begin
		blink <= 0;
	end
	
   always @(posedge CLK) begin
	   if(blink_clk_en)
		  blink <= ~blink;
		  
	   if((alarm1_triggered || alarm0_triggered) && BTN[3] == 1'b1) begin
	       snooze_en <= 1'b1;
	   end
	   else
	       snooze_en <= 1'b0;
	end

endmodule // alarm_clock


