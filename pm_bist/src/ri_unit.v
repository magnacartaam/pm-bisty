// ============================================================================
// Module: ri_unit
// Description: RAM Interface Unit
//              - Generates address sequences (up/down counting)
//              - Produces RAM control signals
//              - Detects address boundaries
//              - Interfaces between BIST controller and RAM under test
// ============================================================================
`timescale 1ns/1ps

module ri_unit (
    input  wire        clk,
    input  wire        reset,
    input  wire        up_down,
    input  wire        next_addr,
    input  wire        ram_wr_in,
    input  wire        ram_di_in,

    output reg [3:0]   addr,

    output wire        at_max,
    output wire        at_min,

    output reg         ram_cs,
    output reg         ram_wr,
    output reg         ram_di,

    input  wire        ram_do_in,
    output wire        ram_do_out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            addr <= 4'd0;
        end
        else if (next_addr) begin
            if (up_down == 1'b0) begin
                addr <= addr + 1;
            end
            else begin
                addr <= addr - 1;
            end
        end
    end

    assign at_max = (addr == 4'b1111);

    assign at_min = (addr == 4'b0000);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ram_cs <= 1'b0;
            ram_wr <= 1'b0;
            ram_di <= 1'b0;
        end else begin
            ram_cs <= 1'b1;

            ram_wr <= ram_wr_in;
            ram_di <= ram_di_in;
        end
    end

    assign ram_do_out = ram_do_in;

endmodule
