`timescale 1ns/1ns

`define NOP 4'b0000
`define ARITH_2OP 4'b0001
`define ARITH_1OP 4'b0010
`define MOVI 4'b0011
`define ADDI 4'b0100
`define SUBI 4'b0101
`define LOAD 4'b0110
`define STOR 4'b0111
`define BEQ 4'b1000
`define BGE 4'b1001
`define BLE 4'b1010
`define BC 4'b1011
`define J 4'b1100
`define CONTROL 4'b1111

`define ADD 3'b000
`define ADDC 3'b001
`define SUB 3'b010
`define SUBB 3'b011
`define AND 3'b100
`define OR 3'b101
`define XOR 3'b110
`define XNOR 3'b111

`define NOT 3'b000
`define SHIFTL 3'b001
`define SHIFTR 3'b010
`define CP 3'b011

`define STC    12'b000000000001
`define STB    12'b000000000010
`define RESET  12'b101010101010
`define HALT   12'b111111111111

`define VONEOP 5'b10000
`define VTWOOP 5'b01000
`define VADDI 5'b00100
`define VSUBI 5'b00010
`define VLORS 5'b00001




/*
 * Module: alu
 * Description: Arithmetic Logic Unit
 *              This unit contains the math/logical units for the processor, and is used for the following functions:
 *              - 2 Operand Arithmetic
 *                  Add, Add with Carry, Subtract, Subtract with Borrow, bitwise AND/OR/XOR/XNOR
 *              - 1 Operand Arithmetic
 *                  Bitwise NOT, Shift Left, Shift Right, Register Copy
 *              - Add immediate (no carry bit)
 *              - Subtract immediate (no borrow bit)
 *              - Load and Store (Address addition - effectively the same to the ALU as Add immediate)
 *              This module does not contain the adder for the Program Counter, nor does it have the comparator logic for branches
 */
module alu (
	input 	      arith_1op_pi,
	input 	      arith_2op_pi,
	input [2:0]   alu_func_pi,
	input 	      addi_pi,
	input 	      subi_pi,
	input 	      load_or_store_pi,
	input [15:0]  reg1_data_pi, // Register operand 1
	input [15:0]  reg2_data_pi, // Register operand 2
	input [5:0]   immediate_pi, // Immediate operand
	input 	      stc_cmd_pi, // STC instruction must set carry_out
	input 	      stb_cmd_pi, // STB instruction must set borrow_out
	input 	      carry_in_pi, // Use for ADDC
	input 	      borrow_in_pi, // Use for SUBB
	
	output reg [15:0] alu_result_po,// The 16-bit result disregarding carry out or borrow
	output reg	      carry_out_po, // Propagate carry_in unless an arithmetic/STC instruction generates a new carry 
	output reg	      borrow_out_po // Propagate borrow_in unless an arithmetic/STB instruction generates a new borrow
);

	always @(*) begin
		carry_out_po = stc_cmd_pi ? 1'b1 : carry_in_pi;
		borrow_out_po = stb_cmd_pi ? 1'b1 : borrow_in_pi;
		case ({arith_1op_pi, arith_2op_pi, addi_pi, subi_pi, load_or_store_pi})
			`VONEOP: begin
				case(alu_func_pi)
					`NOT: alu_result_po = ~reg1_data_pi;
					`SHIFTL: alu_result_po = reg1_data_pi << 1;
					`SHIFTR: alu_result_po = reg1_data_pi >> 1;
					`CP: alu_result_po = reg1_data_pi;
				endcase
			end
			`VTWOOP: begin
				case(alu_func_pi)
					`ADD: {carry_out_po, alu_result_po} = reg1_data_pi + reg2_data_pi;
					`ADDC: {carry_out_po, alu_result_po} = reg1_data_pi + reg2_data_pi + carry_in_pi;
					`SUB: {borrow_out_po, alu_result_po} = reg1_data_pi - reg2_data_pi;
					`SUBB: {borrow_out_po, alu_result_po} = reg1_data_pi - reg2_data_pi - borrow_in_pi;
					`AND: alu_result_po = reg1_data_pi & reg2_data_pi;
					`OR: alu_result_po = reg1_data_pi | reg2_data_pi;
					`XOR: alu_result_po = reg1_data_pi ^ reg2_data_pi;
					`XNOR: alu_result_po = ~(reg1_data_pi ^ reg2_data_pi);
				endcase
			end
			`VADDI: {carry_out_po, alu_result_po} = reg1_data_pi + immediate_pi;
			`VSUBI: {borrow_out_po, alu_result_po} = reg1_data_pi - immediate_pi;
			`VLORS: alu_result_po = reg1_data_pi + immediate_pi;
			default: alu_result_po = 0;
		endcase
	end


endmodule // alu