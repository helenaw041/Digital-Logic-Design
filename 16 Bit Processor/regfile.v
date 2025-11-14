`timescale 1ns/1ns

module regfile (
		 input 	       clk_pi,
		 input 	       clk_en_pi,
		 input 	       reset_pi,
		 
		 // Source Register data for 1 and 2 register operations
		 input [2:0]   source_reg1_pi,
		 input [2:0]   source_reg2_pi,
		 
		 // Destination register and data to write when "wr_destination_reg_pi" is asserted
		 input [2:0]   destination_reg_pi,
		 input [15:0]  dest_result_data_pi,
		 input 	       wr_destination_reg_pi,
		
		 		 
		 // Move immediate commands and immediate data
		 input 	       movi_lower_pi,
		 input 	       movi_higher_pi,
		 input [7:0]   immediate_pi,

		// Values to update the CARRY and BORROW flags
		 input 	       new_carry_pi,
		 input 	       new_borrow_pi, 

		// Values of the the two specified source registers being read
		 output [15:0] reg1_data_po,
		 output [15:0] reg2_data_po,

		// Current value of the CARRY and BORROW flags
		 output        current_carry_po,
		 output        current_borrow_po,
		
		// Source register data for a STORE intruction. Indexed on "destination_reg_pi"  input
		 output [15:0] regD_data_po
	 );

	parameter NUM_REG = 8;

//  Define the register file "REG_FILE" of "NUM_REG" registers. Each register is 16-bits wide.
//  Define 1-bit registers  CARRY_FLAG and BORROW_FLAG.
//         Since these are variables that are internal to your module you could give them any names you like!!
	
	reg [15:0] REG_FILE [0:NUM_REG-1]; 
	reg CARRY_FLAG, BORROW_FLAG;
   
//   The REG_FILE will implement the 8 registers $0 through $7 of your processor.
//   The CARRY_FLAG and BORROW_FLAG are used to save the "carry_out" and "borrow_out" signals output from the ALU, and provide
//   the current "carry_in" and "borrow_in" values to the ALU.

	integer 		       i;  // Used in "for" loop (see below)
   // Suggestion: use "assign" statements to set the output port variables (suffix "_po") of the module.
	assign current_carry_po = CARRY_FLAG;
   	assign current_borrow_po = BORROW_FLAG;
	assign reg1_data_po = REG_FILE[source_reg1_pi];
	assign reg2_data_po = REG_FILE[source_reg2_pi];
	assign regD_data_po = REG_FILE[destination_reg_pi];
	
   /* Reset Code */
   // The "reset_pi" signal should act as a synchronous reset to initialize the CARRY and BORROW flags to 0, and to
   // initialize the registers of the register file as described below.

   // You must initialize register $i to the value "i". 
   // That is, register $0 is initialized to 0, register $1 to value 1, and so on.
   
   // NOTE: In the FPGA implementation, the  reset signal must  initialize all registers to 16'b0. 
   // Here we can run  shorter tests by avoiding additional program instructons to set the registers.
   
   // Since this module is parameterized use a "for" loop with the loop index variable "i". 
   // There is no need for any "generate" or "end generate" statements.
   
   /* Main Code */ 
   // At the positive edge of the clock, when "reset" is not asserted:
   
        // Update the CARRY and BORROW flags  when "clk_en_pi" input is asserted.
   
        // Update  the destination register  with the input data when "clk_en_pi" and "wr_destination_reg_pi" are  asserted.

	always @(posedge clk_pi) begin
		if (reset_pi) begin
			CARRY_FLAG <= 0;
			BORROW_FLAG <= 0;
			for (i=0; i<NUM_REG; i++) begin
				REG_FILE[i] <= i;
			end	
		end
		else if (clk_en_pi) begin
			CARRY_FLAG <= new_carry_pi;
			BORROW_FLAG <= new_borrow_pi;
			if (wr_destination_reg_pi) begin
				if (movi_lower_pi) begin
					REG_FILE[destination_reg_pi][7:0] <= immediate_pi;
				end
				else if (movi_higher_pi) begin
					REG_FILE[destination_reg_pi][15:8] <= immediate_pi;
				end
				else begin
					REG_FILE[destination_reg_pi] <= dest_result_data_pi;
				end
			end
		end
	end
	

endmodule


  
