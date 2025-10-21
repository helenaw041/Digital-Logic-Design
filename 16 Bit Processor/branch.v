`timescale 1ns/1ns

`define EQ 4'b1000
`define GE 4'b0100
`define LE 4'b0010
`define CARRY 4'b0001

module branch (
input        branch_eq_pi,
input        branch_ge_pi,
input        branch_le_pi,
input        branch_carry_pi,
input [15:0] reg1_data_pi,
input [15:0] reg2_data_pi,
input        alu_carry_bit_pi,

output reg is_branch_taken_po)
;
    always@(*) begin
        case({branch_eq_pi, branch_ge_pi, branch_le_pi, branch_carry_pi})
            `EQ: is_branch_taken_po = reg1_data_pi == reg2_data_pi;
            `GE: is_branch_taken_po = reg1_data_pi >= reg2_data_pi;
            `LE: is_branch_taken_po = reg1_data_pi <= reg2_data_pi;
            `CARRY: is_branch_taken_po = alu_carry_bit_pi;
            default: is_branch_taken_po = 1'b0;
        endcase
    end


endmodule // branch_comparator
