`timescale 1ns/1ns

/*
 * Module: processor
 * Description: The top module of this lab 
 */
module processor (
	input CLK_pi,
	input CPU_RESET_pi
); 
 

	// ASSUMING IMMEDIATE BITS ARE THE LOWEST WILL HAVE TO CHECK LATER IF RUN INTO ISSUES

	// Declare wires to interconnect the ports of the modules to implement the processor


	wire       cpu_clk_en = 1'b1; // Used to slow down CLK in FPGA implementation
	wire       reset, clock_enable, rst_cmd, halt_cmd;
   	// Write an "assign" statement for the "reset" signal
	assign reset = CPU_RESET_pi | rst_cmd;
	// Write an "assign" statement for the  "clock_enable" signal
	assign clock_enable = cpu_clk_en & !halt_cmd;
   
   
	// Add the input-output ports of each module instantiated below
   
//    input  [15:0] instruction_pi, X

//     output reg [2:0] alu_func_po, X
//     output reg [2:0] destination_reg_po, X
//     output reg [2:0] source_reg1_po, X   
//     output reg [2:0] source_reg2_po, X
//     output reg [11:0] immediate_po, X

//     output reg arith_2op_po, X
//     output reg arith_1op_po, X

//     output reg movi_lower_po, X
//     output reg movi_higher_po, X

//     output reg addi_po, X
//     output reg subi_po, X

//     output reg load_po, X
//     output reg store_po, X

//     output reg branch_eq_po, X
//     output reg branch_ge_po, X
//     output reg branch_le_po, X
//     output reg branch_carry_po, X

//     output reg jump_po, X

//     output reg stc_cmd_po, X
//     output reg stb_cmd_po, X
//     output reg halt_cmd_po, X
//     output reg rst_cmd_po X

wire [15:0] instruction;
wire [15:0] reg1_data, reg2_data;
wire [11:0] immediate;
wire [2:0] alu_func, destination_reg;
wire [15:0] alu_result;
wire [2:0] source_reg1, source_reg2;

wire branch_eq, branch_ge, branch_le, branch_carry;
wire arith_2op, arith_1op;
wire load, store;
wire movi_higher, movi_lower;
wire addi, subi;
wire jump_taken, car;
wire stc_cmd, stb_cmd;
wire carry_in, borrow_in, carry_out, borrow_out;

	decoder myDecoder(
		.instruction_pi(instruction),
		
		.alu_func_po(alu_func),
		.destination_reg_po(destination_reg),
		.arith_2op_po(arith_2op),
		.arith_1op_po(arith_1op),
		.source_reg1_po(source_reg1),
		.source_reg2_po(source_reg2),
		.addi_po(addi),
		.subi_po(subi),
		.load_po(load),
		.store_po(store),
		.movi_higher_po(movi_higher),
		.movi_lower_po(movi_lower),

		.immediate_po(immediate),

		.branch_eq_po(branch_eq),
		.branch_ge_po(branch_ge),
		.branch_le_po(branch_le),
		.branch_carry_po(branch_carry),
		.jump_po(jump_taken),
		.stc_cmd_po(stc_cmd),
		.stb_cmd_po(stb_cmd),
		.rst_cmd_po(rst_cmd),
		.halt_cmd_po(halt_cmd)
	); 

	// input 	      arith_1op_pi, X
	// input 	      arith_2op_pi, X
	// input [2:0]   alu_func_pi, X
	// input 	      addi_pi, X
	// input 	      subi_pi, X
	// input 	      load_or_store_pi, X
	// input [15:0]  reg1_data_pi, X // Register operand 1
	// input [15:0]  reg2_data_pi, X // Register operand 2
	// input [5:0]   immediate_pi, X // Immediate operand
	// input 	      stc_cmd_pi, X // STC instruction must set carry_out
	// input 	      stb_cmd_pi, X // STB instruction must set borrow_out
	// input 	      carry_in_pi, X // Use for ADDC
	// input 	      borrow_in_pi, X // Use for SUBB
	
	// output reg [15:0] alu_result_po, X // The 16-bit result disregarding carry out or borrow
	// output reg	      carry_out_po, X // Propagate carry_in unless an arithmetic/STC instruction generates a new carry 
	// output reg	      borrow_out_po X // Propagate borrow_in unless an arithmetic/STB instruction generates a new borrow

	alu  myALU(
		.arith_1op_pi(arith_1op),
		.arith_2op_pi(arith_2op),
		.alu_func_pi(alu_func),
		.addi_pi(addi),
		.subi_pi(subi),
		.load_or_store_pi(load | store),
		.reg1_data_pi(reg1_data),
		.reg2_data_pi(reg2_data),
		.immediate_pi(immediate[5:0]), // assuming lowest bits
		.stc_cmd_pi(stc_cmd),
		.stb_cmd_pi(stb_cmd),
		.carry_in_pi(carry_in),
		.borrow_in_pi(borrow_in),
		
		.alu_result_po(alu_result),
		.carry_out_po(carry_out),
		.borrow_out_po(borrow_out)

	);

	// input        branch_eq_pi, X
	// input        branch_ge_pi, X
	// input        branch_le_pi, X
	// input        branch_carry_pi, X
	// input [15:0] reg1_data_pi, X
	// input [15:0] reg2_data_pi, X
	// input        alu_carry_bit_pi, X

	// output reg is_branch_taken_po X

	wire is_branch_taken;
	
	branch  myBranch( 
		.branch_eq_pi(branch_eq),
		.branch_ge_pi(branch_ge),
		.branch_le_pi(branch_le),
		.branch_carry_pi(branch_carry),
		.reg1_data_pi(reg1_data),
		.reg2_data_pi(reg2_data),
		.alu_carry_bit_pi(carry_out),

		.is_branch_taken_po(is_branch_taken)
	);
	
	// 		 input 	       clk_pi, X
	// 		 input 	       clk_en_pi, X
	// 		 input 	       reset_pi, X
			
	// 		 // Source Register data for 1 and 2 register operations
	// 		 input [2:0]   source_reg1_pi, X
	// 		 input [2:0]   source_reg2_pi, X
			
	// 		 // Destination register and data to write when "wr_destination_reg_pi" is asserted
	// 		 input [2:0]   destination_reg_pi, X
	// 		 input [15:0]  dest_result_data_pi, X
	// 		 input 	       wr_destination_reg_pi, X
			
					
	// 		 // Move immediate commands and immediate data
	// 		 input 	       movi_lower_pi, X
	// 		 input 	       movi_higher_pi, X
	// 		 input [7:0]   immediate_pi, X

	// 		// Values to update the CARRY and BORROW flags
	// 		 input 	       new_carry_pi, X
	// 		 input 	       new_borrow_pi, X

	// 		// Values of the the two specified source registers being read
	// 		 output [15:0] reg1_data_po, X
	// 		 output [15:0] reg2_data_po, X

	// 		// Current value of the CARRY and BORROW flags
	// 		 output        current_carry_po, X
	// 		 output        current_borrow_po, X
			
	// 		// Source register data for a STORE intruction. Indexed on "destination_reg_pi"  input
	// 		 output [15:0] regD_data_po X

	wire [15:0] regD_data;

	regfile   myRegfile(
		.clk_pi(CLK_pi),
		.clk_en_pi(clock_enable),
		.reset_pi(reset),
		.source_reg1_pi(source_reg1),
		.source_reg2_pi(source_reg2),
		.destination_reg_pi(destination_reg),
		.wr_destination_reg_pi(arith_2op | arith_1op | movi_lower | movi_higher | addi | subi | load),
		.dest_result_data_pi(load ? rdata : alu_result),
		.movi_lower_pi(movi_lower),
		.movi_higher_pi(movi_higher),	
		.immediate_pi(immediate[7:0]),
		.new_carry_pi(carry_out),
		.new_borrow_pi(borrow_out),

		.reg1_data_po(reg1_data),
		.reg2_data_po(reg2_data),
		.regD_data_po(regD_data),
		.current_carry_po(carry_in),
		.current_borrow_po(borrow_in)
	);

	// input 	      clk_pi, X
	// input 	      clk_en_pi, X
	// input 	      reset_pi, X

	// input 	      branch_taken_pi, X
	// input [5:0]   branch_immediate_pi, X// Needs to be sign extended		
	// input 	      jump_taken_pi, X
	// input [11:0]  jump_immediate_pi, X // Needs to be sign extended
		
	// output [15:0] pc_po X


wire [15:0] pc;

	program_counter myProgram_counter(
		.clk_pi(CLK_pi),
		.clk_en_pi(clock_enable),
		.reset_pi(reset),

		.branch_taken_pi(is_branch_taken),
		.branch_immediate_pi(immediate[5:0]),

		.jump_taken_pi(jump_taken),
		.jump_immediate_pi(immediate[11:0]),

		.pc_po(pc)
	);

	// input [15:0] pc_pi, X
	// output[15:0] instruction_po X

	// DONE
	instruction_mem myInstruction_mem(
		.pc_pi(pc),
		.instruction_po(instruction)
	);

	// input 		  clk_pi, X 		// 100 MHz clk 
	// 	input 		  clk_en_pi, X 	// Clock enable
	// 	input 		  reset_pi, X 	// synchronous reset
		
	// 	input 		  	  write_pi,	// write enable
	// 	input [15:0] 	  wdata_pi, // write data
	// 	input [15:0] 	  addr_pi, 	// address
		
	// 	output reg [15:0] rdata_po 	// read data

	wire [15:0] rdata;

	data_mem  myData_mem(
		.clk_pi(CLK_pi),
		.clk_en_pi(clock_enable),
		.reset_pi(reset),
		.write_pi(store),
		.wdata_pi(regD_data),
		.addr_pi(alu_result),

		.rdata_po(rdata)
	);
	  
endmodule 


