`timescale 1ns/1ns

/*
 * Module: alarm_fsm
 *
 * Description: State machine for an alarm for a 12-hour clock. 
 * Outputs the minute and hour values the alarm is currently set for. Defaults to 11:59
 * 
 * With the inputs clock_minutes_pi and clock_hours_pi, it checks to see if the alarm has been triggered
 * If alarm_en_pi is true and the alarm triggers, drives alarm_triggered_po to 1 (driven back to 0 if alarm_en_pi goes to 0).
 */

 module alarm_fsm(
	input 		  clk_pi,
	input 		  alarm_en_pi,
	
	// Current time
	input [5:0] 	  clock_minutes_pi,
	input [3:0] 	  clock_hours_pi,

       // Current alarm settings
	output wire [5:0] minutes_po,
	output wire [3:0] hours_po,

       // Increment inputs	
	input 		  increment_minute_pi,
	input 		  increment_hour_pi,


    input wire snooze_en,
       // Alarm indicator
	output wire 	  alarm_triggered_po);

	initial begin
	   alarm_min <= 6'd59;
	   alarm_hour <= 4'd11;
	   alarm_state <= 1'b0;
	end
 

   // State variables of the alarm
   reg 			  alarm_state;
   reg [3:0] 		  alarm_hour;
   reg [5:0] 		  alarm_min;
   
   reg [3:0] snooze_hour;
   reg [5:0] snooze_min;
   
   reg is_snoozed = 1'b0;

   assign minutes_po = alarm_min;
   assign hours_po = alarm_hour;
   assign alarm_triggered_po = alarm_state;
 		  
   // Implement the alarm state machine
   always @(posedge clk_pi) begin
        if(is_snoozed == 1'b0)begin
            snooze_min = clock_minutes_pi;
            snooze_hour = clock_hours_pi;
        end
        if(increment_minute_pi)
            if(alarm_min == 6'd59)
                alarm_min <= 6'd0;
            else
                alarm_min <= alarm_min+1;
        if(increment_hour_pi)
            if(alarm_hour == 4'd12)
                alarm_hour <= 4'd1;
            else
                alarm_hour <= alarm_hour+1;
        if(alarm_en_pi && alarm_min == clock_minutes_pi && alarm_hour == clock_hours_pi && is_snoozed == 1'b0)
            alarm_state <= 1'b1;
        if(alarm_en_pi == 1'b0)
            alarm_state <= 1'b0;
        if(snooze_en == 1'b1 && alarm_state == 1'b1) begin
            alarm_state <= 1'b0;
            is_snoozed <= 1'b1;
            if (snooze_min == 6'd59)begin
                if (snooze_hour == 4'd12)begin
                    snooze_hour = 4'd1;
                end
                else
                    snooze_hour = snooze_hour + 1;
            end
            else
                snooze_min <= snooze_min + 1;
        end
        if(alarm_en_pi && is_snoozed == 1'b1 && snooze_min == clock_minutes_pi && snooze_hour == clock_hours_pi) begin
            // check if the alarm should be going off
            // if it is then set off the alarm and set is snoozed to off
            alarm_state <= 1'b1;
            is_snoozed <= 1'b0;
        end
   end

   
endmodule // alarm_fsm


