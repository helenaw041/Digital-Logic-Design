`timescale 1ns/1ns

/*
 * Module: clock_fsm 
 * 
 * Description: State machine for a basic 12-hour clock. Initially blinks, 
 * until the time is changed by the user.
 * 
 * Outputs current second, minute, and hour values of the clock.
 *
 * Signal "clk_en_pi" will be asserted for 1 cycle of "clk_pi" every second.
 */

module clock_fsm(
	input clk_pi,
	input clk_en_pi,
	
	input increment_minute_pi,
	input increment_hour_pi,
	
	output  [5:0] seconds_po,
	output  [5:0] minutes_po,
	output  [3:0] hours_po,	
	output blink_en_po);
	
   // State variables of clock module
   reg [5:0] seconds;
   reg [5:0] minutes;
   reg [3:0] hours;
   reg  blink_en;

   
   assign seconds_po = seconds;
   assign minutes_po = minutes;
   assign hours_po = hours;
   assign blink_en_po = blink_en;

     
   initial begin
      seconds <= 0;
      minutes <= 0;
      hours <= 4'd12;
      blink_en <= 1'b1;
   end
   
   always @(posedge clk_pi) begin
      
       if(increment_minute_pi || increment_hour_pi) // Disable blinking
	        blink_en <= 0;
	
	   if(increment_minute_pi)
            if(minutes == 6'd59)
                minutes <= 6'd0;
            else
                minutes <= minutes+1;
        if(increment_hour_pi)
            if(hours == 4'd12)
                hours <=4'd1;
            else
                hours <= hours+1;
                
        if(clk_en_pi)
            if (seconds == 6'd59)begin
                seconds <= 6'd0;
                if(minutes == 6'd59)begin
                    minutes <= 6'd0;
                    if(hours == 4'd12)
                        hours <= 4'd1;
                    else
                        hours <= hours + 1;
                end
                else
                    minutes <= minutes + 1;
            end
            else 
                seconds = seconds + 1;
   end
endmodule // clock_fsm



