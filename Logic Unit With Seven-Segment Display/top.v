/*
 * Module: top
 * Description: The top module of Lab 1 assignment
 */
module top(
    input CLK,
    input [15:0] SW,
    input [3:0] BTN,
    output [15:0] LED,
    output [6:0] SEG,
    output DP,
    output [3:0] AN
);

    wire [7:0]  result_binary;
    wire [15:0] display_value;
    wire [15:0] counter;
    wire        clk_en;
    wire p_en, p_value;
    
    // update LED[15] based on parity
    assign LED[15] = p_en & p_value;
    assign LED[14:8] = 7'b0;    
	assign LED[7:0] = result_binary;
    assign display_value = {8'b0, result_binary};


    logic_unit Ilogic_unit(
        .dataA_pi(SW[7:4]),
        .dataB_pi(SW[3:0]),
        .op_pi(BTN[3:0]),
        .shamt(SW[15:14]), 
        .counter_pi(counter),
        .result_po(result_binary),
        .sw(SW[13]),
        .p_en(p_en),
        .p_value(p_value)
    );
    
    // handoff p_en and p_value to display
    sevenSegDisplay IsevenSegDisplay (
        .clk_pi(CLK),
        .clk_en_pi(clk_en),
        .num_pi(display_value),
        .seg_po(SEG),
        .dp_po(DP),
        .an_po(AN),
        .p_en(p_en),
        .p_value(p_value)
    );


    clkdiv #(.SIZE(10)) Iclkdiv (
        .clk_pi(CLK),
        .clk_en_po(clk_en)
    );

    increment Iincrement (
        .clk_pi(CLK),
        .counter_po(counter)
    );

endmodule // top