module hex2physical(
    input logic [4:0] hex,
    output logic [7:0] cathodes
);

always_comb begin: hex_to_cathodes
    case (hex)           //DP A B C D E F G
        5'h00: cathodes = 8'b10000001; // 0 C0
        5'h01: cathodes = 8'b11001111; // 1 F9
        5'h02: cathodes = 8'b10010010; // 2 A4
        5'h03: cathodes = 8'b10000110; // 3 B0
        5'h04: cathodes = 8'b11001100; // 4 99
        5'h05: cathodes = 8'b10100100; // 5 92
        5'h06: cathodes = 8'b10100000; // 6 82
        5'h07: cathodes = 8'b10001111; // 7 F8
        5'h08: cathodes = 8'b10000000; // 8 80
        5'h09: cathodes = 8'b10000100; // 9 90
        5'h0A: cathodes = 8'b10001000; // A 88
        5'h0B: cathodes = 8'b11100000; // B 83
        5'h0C: cathodes = 8'b10110001; // C C6
        5'h0D: cathodes = 8'b11000010; // D A1
        5'h0E: cathodes = 8'b10110000; // E 86
        5'h0F: cathodes = 8'b10111000; // F 8E
        default: cathodes = 8'b11111111; // blank FF
    endcase
end
endmodule