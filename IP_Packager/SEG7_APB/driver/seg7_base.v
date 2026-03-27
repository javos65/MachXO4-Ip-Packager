//
//
// Hex to 7Seg decoder
//
// Jay Vos - 2026
// Original : AI - Gemini Generated
//
//
//
//

module hex_to_7seg (
	input clk,
    input reset_n,       // _n suffix is standard notation for Active Low
    input [7:0] hex_val,
    output reg [7:0] seg // dp g f e d c b a
);

    // Trigger on the Falling Edge of the reset signal
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            seg[6:0] <= 7'b1111111; // All segments OFF (Active Low)
			seg[7] <= 1'b1;
        end else begin
            case (hex_val[6:0])
                // Patterns are bitwise inverted (~): 0 is ON, 1 is OFF
                7'h00: seg[6:0] <= 7'b1000000; // 0
                7'h01: seg[6:0] <= 7'b1111001; // 1
                7'h02: seg[6:0] <= 7'b0100100; // 2
                7'h03: seg[6:0] <= 7'b0110000; // 3
                7'h04: seg[6:0] <= 7'b0011001; // 4
                7'h05: seg[6:0] <= 7'b0010010; // 5
                7'h06: seg[6:0] <= 7'b0000010; // 6
                7'h07: seg[6:0] <= 7'b1111000; // 7
                7'h08: seg[6:0] <= 7'b0000000; // 8
                7'h09: seg[6:0] <= 7'b0010000; // 9
                7'h0A: seg[6:0] <= 7'b0001000; // A
                7'h0B: seg[6:0] <= 7'b0000011; // b
                7'h0C: seg[6:0] <= 7'b1000110; // C
                7'h0D: seg[6:0] <= 7'b0100001; // d
                7'h0E: seg[6:0] <= 7'b0000110; // E
                7'h0F: seg[6:0] <= 7'b0001110; // F
				
                7'h10: seg[6:0] <= 7'b0001001; // X
                7'h11: seg[6:0] <= 7'b1000000; // O
                7'h12: seg[6:0] <= 7'b0011001; // 4
                7'h13: seg[6:0] <= 7'b1111110; // round1 a
                7'h14: seg[6:0] <= 7'b1111101; // round1 b
                7'h15: seg[6:0] <= 7'b1111011; // round1 c
                7'h16: seg[6:0] <= 7'b1110111; // round1 d
                7'h17: seg[6:0] <= 7'b1101111; // round1 e
                7'h18: seg[6:0] <= 7'b1011111; // round1 f
                7'h19: seg[6:0] <= 7'b0111111; // round1 g				
				
                7'h20: seg[6:0] <= 7'b1001001; // special ||		
                7'h21: seg[6:0] <= 7'b1110110; // special =		
                7'h22: seg[6:0] <= 7'b1110110; // special #
                7'h23: seg[6:0] <= 7'b0011100; // special hig o
                7'h24: seg[6:0] <= 7'b0100011; // special low o
                default: seg[6:0] <= 7'b1111111;
            endcase
			case (hex_val[7])
                // Bit 8 is DP segment inverted output				
				1'b0: seg[7] <=1'b1;
				1'b1: seg[7] <=1'b0;			
			endcase	
        end
    end
endmodule