`timescale 1ns/1ns

/*
 * Module: segmentFormatter
 * Description: Combinational logic for the seven segment bits of a digit of the seven segment display
 *
 * 0 - LSB of disp_po
 * 6 - MSB of disp_po
 *      --(0)   
 * (5)|      |(1)
 *      --(6)
 * (4)|      |(2)
 *      --(3) 
 * 
 * disp_po is active low 
 */
module segmentFormatter(
    input [3:0] num_pi,      	// 4-bit binary number
    input p_en,
    input p_value,
    input [1:0] pos,
    output reg [6:0] disp_po 	// Hexadecimal digit {0, .., 9, A, b, C, d, E, F)
);

    always @(*) begin
        // based on p_en and p_value display the correct message according to the relative position
        if(p_en) begin
            case(pos)
                2'b11 : disp_po = (p_value ? ~7'b1111001 : {7{1'b1}});
                2'b10 : disp_po = (p_value ? ~7'b0111110 : ~{1'b0, {6{1'b1}}});
                2'b01 : disp_po = (p_value ? ~7'b1111001 : ~7'b1011110);
                2'b00 : disp_po = (p_value ? ~7'b0110111 : ~7'b1011110);
            endcase
        end
        else begin
            case(num_pi)
                4'h0: disp_po = ~{1'b0, {6{1'b1}}}; // 0111111
                4'h1: disp_po = ~{4'b0, {2{1'b1}}, 1'b0};
                4'h2: disp_po = ~7'b1011011;
                4'h3: disp_po = ~7'b1001111;
                4'h4: disp_po = ~7'b1100110;
                4'h5: disp_po = ~7'b1101101;
                4'h6: disp_po = ~7'b1111101;
                4'h7: disp_po = ~7'b0000111;
                4'h8: disp_po = ~{7{1'b1}};
                4'h9: disp_po = ~7'b1101111;
                4'hA: disp_po = ~7'b1110111;
                4'hB: disp_po = ~7'b1111100;
                4'hC: disp_po = ~7'b0111001;
                4'hD: disp_po = ~7'b1011110;
                4'hE: disp_po = ~7'b1111001;
                4'hF: disp_po = ~7'b1110001;
            endcase
        end
    end
endmodule // segmentFormatter



/* **************************************************************************************************** */


/*
 * Module: sevenSegDisplay
 * Description: Formats an input 16 bit number for the four digit seven-segment display
 */
module sevenSegDisplay(
    input clk_pi,
    input clk_en_pi,
    input[15:0] num_pi,
    input p_en, 
    input p_value,
    output reg [6:0] seg_po,
    output dp_po,
    output reg [3:0] an_po
);

    wire [6:0] disp0, disp1, disp2, disp3;
    wire [3:0] digit0, digit1, digit2, digit3;

    assign digit0 = num_pi[3:0];
    assign digit1 = num_pi[7:4];
    assign digit2 = num_pi[11:8];
    assign digit3 = num_pi[15:12];

    assign dp_po = 1'b1; // Decimal point is off

    // handoff p_en and p_value to the formatters and also give them position info
    segmentFormatter IsegmentFormat0 ( .num_pi(digit0), .disp_po(disp0), .p_en(p_en), .p_value(p_value), .pos(2'b00) );
    segmentFormatter IsegmentFormat1 ( .num_pi(digit1), .disp_po(disp1), .p_en(p_en), .p_value(p_value), .pos(2'b01) );
    segmentFormatter IsegmentFormat2 ( .num_pi(digit2), .disp_po(disp2), .p_en(p_en), .p_value(p_value), .pos(2'b10) );
    segmentFormatter IsegmentFormat3 ( .num_pi(digit3), .disp_po(disp3), .p_en(p_en), .p_value(p_value), .pos(2'b11) );

    initial begin
        seg_po <= 7'h7F;
        an_po <= 4'b1111;
    end

    always @(posedge clk_pi) begin
        if(clk_en_pi) begin
            case(an_po)
                4'b1110: begin
                    seg_po <= disp1;
                    an_po  <= 4'b1101;
                end
                4'b1101: begin
                    seg_po <= disp2;
                    an_po  <= 4'b1011;
                end
                4'b1011: begin
                    seg_po <= disp3;
                    an_po  <= 4'b0111;
                end
                default: begin
                    seg_po <= disp0;
                    an_po <= 4'b1110;
                end
            endcase
        end // clk_en
    end // always @(posedge clk_pi)
endmodule // sevenSegDisplay