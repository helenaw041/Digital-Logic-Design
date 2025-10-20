`timescale 1ns/1ns

/*
 * Module: logic_unit
 * Description: Performs logical operations based on the op_pi input.
 */
module logic_unit(
    input [3:0]  dataA_pi,   // operand A
    input [3:0]  dataB_pi,   // operand B
    input [3:0]  op_pi,      // operation select
    input [1:0]  shamt,      // shift amount
    input [15:0] counter_pi, // counter value for default case
    input sw,
    output reg [7:0] result_po,   // 8-bit result
    output reg p_en,
    output reg p_value
);
    
    always @(*) begin 
        result_po = counter_pi[7:0];
        // p_en default value
        p_en = 1'b0;
        
        case(op_pi)
            4'b0000: result_po = dataA_pi & dataB_pi;
            4'b0001: result_po = dataA_pi ^ dataB_pi;
            4'b0010: result_po = {4'b0000, dataB_pi} << shamt;
            4'b0100: result_po = {4'b0000, dataB_pi} >>> shamt;
            4'b1000: begin
                // implement p_en logic
                p_en = sw;
                result_po = dataA_pi > dataB_pi ? {8{1'b1}} : {8{1'b0}};
            end
        endcase
        
        // implement parity checking logic for p_value
        p_value = ~(^{dataA_pi, dataB_pi});
    end

endmodule // logic_unit