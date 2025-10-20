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

/*
 * Module: instruction_decode
 * Description: Decodes the instruction.
 *              All outputs must be driven based upon instruction opcode and function.
 *              All logic should be combinational.
 */

module decoder(
    input  [15:0] instruction_pi,

    output reg [2:0] alu_func_po, 
    output reg [2:0] destination_reg_po, 
    output reg [2:0] source_reg1_po,     
    output reg [2:0] source_reg2_po, 
    output reg [11:0] immediate_po,

    output reg arith_2op_po,
    output reg arith_1op_po,

    output reg movi_lower_po,
    output reg movi_higher_po,

    output reg addi_po,
    output reg subi_po,

    output reg load_po,
    output reg store_po,

    output reg branch_eq_po,
    output reg branch_ge_po,
    output reg branch_le_po,
    output reg branch_carry_po,

    output reg jump_po,

    output reg stc_cmd_po,
    output reg stb_cmd_po,
    output reg halt_cmd_po,
    output reg rst_cmd_po
);

    wire [3:0] opcode = instruction_pi[15:12];

    always @(*) begin
        // update immediate
        immediate_po = instruction_pi[11:0];

        // default all po
        arith_2op_po = 0;
        arith_1op_po = 0;
        movi_lower_po = 0;
        movi_higher_po = 0;
        addi_po = 0;
        subi_po = 0;
        load_po = 0;
        store_po = 0;
        branch_eq_po = 0;
        branch_ge_po = 0;
        branch_le_po = 0;
        branch_carry_po = 0;
        jump_po = 0;
        stc_cmd_po = 0;
        stb_cmd_po = 0;
        halt_cmd_po = 0;
        rst_cmd_po = 0;

        // default case
        destination_reg_po = instruction_pi[11:9];
        source_reg1_po = instruction_pi[8:6];
        source_reg2_po = instruction_pi[5:3];
        alu_func_po = instruction_pi[2:0];

        case (opcode)
			// `NOP is not needed by the default case
            `ARITH_2OP: arith_2op_po = 1;

            `ARITH_1OP: arith_1op_po = 1;

            `MOVI: begin
                movi_higher_po = instruction_pi[8];
                movi_lower_po = !instruction_pi[8];
            end

            `ADDI: addi_po = 1;
            `SUBI: subi_po = 1;

            `LOAD: load_po = 1;
            `STOR: store_po = 1;

            `BEQ: begin
                branch_eq_po = 1;
                source_reg1_po = instruction_pi[11:9];
                source_reg2_po = instruction_pi[8:6];
            end
            `BGE: begin
                branch_ge_po = 1;
                source_reg1_po = instruction_pi[11:9];
                source_reg2_po = instruction_pi[8:6];
            end
            `BLE: begin
                branch_le_po = 1;
                source_reg1_po = instruction_pi[11:9];
                source_reg2_po = instruction_pi[8:6];
            end
            `BC: begin
                branch_carry_po = 1;
                source_reg1_po = instruction_pi[11:9];
                source_reg2_po = instruction_pi[8:6];
            end

            `J: jump_po = 1;

            `CONTROL: begin
                case (instruction_pi[11:0])
                    `STC:   stc_cmd_po = 1;
                    `STB:   stb_cmd_po = 1;
                    `RESET: rst_cmd_po = 1;
                    `HALT:  halt_cmd_po = 1;
                endcase
            end
        endcase
    end
endmodule 
