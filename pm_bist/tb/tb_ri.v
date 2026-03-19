// ============================================================================
// Testbench: tb_ri (PROPERLY SYNCHRONIZED VERSION)
// ============================================================================
`timescale 1ns/1ps

module tb_ri;
    reg clk, reset, up_down, next_addr, ram_wr_in, ram_di_in;
    wire [3:0] addr;
    wire at_max, at_min, ram_cs, ram_wr, ram_di, ram_do_out;

    // Test RAM for loopback
    reg [15:0] test_ram;
    reg ram_do_out_tb;

    // RAM read logic (synchronous)
    always @(posedge clk) begin
        if (ram_cs && ram_wr)  // Read operation
            ram_do_out_tb <= test_ram[addr];
    end

    // DUT Instantiation
    ri_unit u_ri (
        .clk(clk), .reset(reset), .up_down(up_down), .next_addr(next_addr),
        .ram_wr_in(ram_wr_in), .ram_di_in(ram_di_in), .addr(addr),
        .at_max(at_max), .at_min(at_min), .ram_cs(ram_cs), .ram_wr(ram_wr),
        .ram_di(ram_di), .ram_do_in(ram_do_out_tb), .ram_do_out(ram_do_out)
    );

    // Clock generator (20ns period = 50 MHz)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // Toggle every 10ns
    end

    // Helper task: Wait for next clock rising edge
    task wait_clk;
        begin
            @(posedge clk);
        end
    endtask

    // Helper task: Pulse next_addr for ONE clock cycle
    task pulse_next_addr;
        begin
            next_addr = 1'b1;
            wait_clk;  // Keep high for one full clock cycle
            next_addr = 1'b0;
        end
    endtask

    // Test sequence
    initial begin
        $display("========================================");
        $display("RI Unit Testbench Started");
        $display("========================================");

        // Initialize
        reset = 1'b1;
        up_down = 1'b0;
        next_addr = 1'b0;
        ram_wr_in = 1'b0;
        ram_di_in = 1'b0;
        test_ram = 16'h0000;

        $display("[%0t ns] Initializing...", $time);
        wait_clk; wait_clk;  // Wait 2 clock cycles

        // Release reset
        reset = 1'b0;
        wait_clk;
        $display("[%0t ns] Reset released, addr = %d", $time, addr);

        // ============================================================================
        // TEST 1: Count UP from 0 to 5
        // ============================================================================
        $display("========================================");
        $display("[%0t ns] TEST 1: Count UP (0 → 5)", $time);
        $display("========================================");

        up_down = 1'b0;  // Count up

        for (integer i = 0; i < 5; i = i + 1) begin
            pulse_next_addr;
            $display("[%0t ns] addr = %2d, at_max=%b, at_min=%b",
                $time, addr, at_max, at_min);
        end

        // ============================================================================
        // TEST 2: Count DOWN from 5 to 2
        // ============================================================================
        $display("========================================");
        $display("[%0t ns] TEST 2: Count DOWN (5 → 2)", $time);
        $display("========================================");

        up_down = 1'b1;  // Count down

        for (integer i = 0; i < 3; i = i + 1) begin
            pulse_next_addr;
            $display("[%0t ns] addr = %2d, at_max=%b, at_min=%b",
                $time, addr, at_max, at_min);
        end

        // ============================================================================
        // TEST 3: Count UP to MAX and detect boundary
        // ============================================================================
        $display("========================================");
        $display("[%0t ns] TEST 3: Count to MAX (detect at_max)", $time);
        $display("========================================");

        up_down = 1'b0;

        while (!at_max) begin
            pulse_next_addr;
            $display("[%0t ns] addr = %2d, at_max=%b", $time, addr, at_max);
        end

        $display("[%0t ns] ✓ at_max detected at addr = %d!", $time, addr);

        // ============================================================================
        // TEST 4: Count DOWN to MIN and detect boundary
        // ============================================================================
        $display("========================================");
        $display("[%0t ns] TEST 4: Count to MIN (detect at_min)", $time);
        $display("========================================");

        up_down = 1'b1;

        while (!at_min) begin
            pulse_next_addr;
            $display("[%0t ns] addr = %2d, at_min=%b", $time, addr, at_min);
        end

        $display("[%0t ns] ✓ at_min detected at addr = %d!", $time, addr);

        // ============================================================================
        // TEST 5: Verify RAM Control Signal Pass-through
        // ============================================================================
        $display("========================================");
        $display("[%0t ns] TEST 5: Verify signal pass-through", $time);
        $display("========================================");

        ram_wr_in = 1'b0;
        ram_di_in = 1'b1;
        wait_clk;
        $display("[%0t ns] Write: ram_wr_in=%b, ram_di_in=%b → ram_wr=%b, ram_di=%b",
            $time, ram_wr_in, ram_di_in, ram_wr, ram_di);

        ram_wr_in = 1'b1;
        wait_clk;
        $display("[%0t ns] Read:  ram_wr_in=%b → ram_wr=%b", $time, ram_wr_in, ram_wr);

        // ============================================================================
        // TEST 6: Simulate Complete March Element
        // ============================================================================
        $display("========================================");
        $display("[%0t ns] TEST 6: Simulate upward march element", $time);
        $display("========================================");

        // Initialize
        test_ram = 16'h0000;
        up_down = 1'b0;

        // Reset address counter
        reset = 1'b1;
        wait_clk;
        reset = 1'b0;
        wait_clk;

        $display("[%0t ns] Starting upward march from addr 0", $time);

        // Write phase: write 1 to addresses 0-7
        ram_wr_in = 1'b0;  // Write mode

        for (integer i = 0; i < 8; i = i + 1) begin
            ram_di_in = 1'b1;

            // Update test RAM BEFORE incrementing (write to current address)
            test_ram[addr] = ram_di_in;

            $display("[%0t ns] Write 1 to addr %2d (test_ram[%2d]=%b)",
                $time, addr, addr, test_ram[addr]);

            pulse_next_addr;
        end

        // Read phase: read back from addresses 0-7
        ram_wr_in = 1'b1;  // Read mode

        // Reset address counter
        reset = 1'b1;
        wait_clk;
        reset = 1'b0;
        wait_clk;

        $display("[%0t ns] Reading back from addr 0", $time);

        for (integer i = 0; i < 8; i = i + 1) begin
            wait_clk;  // Wait for read to complete
            $display("[%0t ns] Read addr %2d: expected=1, got=%b (test_ram[%2d]=%b)",
                $time, addr, ram_do_out, addr, test_ram[addr]);

            pulse_next_addr;
        end

        $display("========================================");
        $display("[%0t ns] RI Unit Testbench Complete", $time);
        $display("========================================");

        $finish;
    end

    // Waveform dump
    initial begin
        $dumpfile("tb_ri.vcd");
        $dumpvars(0, tb_ri);
    end

endmodule
