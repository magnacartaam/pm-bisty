`timescale 1ns/1ps

module ram_16x1(
    input wire clk,
    input wire cs,
    input wire[3:0] ab,
    input wire di,
    input wire wr,
    output reg od
);
    reg[15:0] mem;

    always @(posedge clk) begin
        if (cs) begin
            if (wr == 0)
                mem[ab] <= di;
            else
                od <= mem[ab];
        end
    end
endmodule
