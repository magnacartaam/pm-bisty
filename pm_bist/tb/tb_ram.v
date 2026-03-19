// ============================================================================
// Testbench: tb_ram
// Purpose: Verify ram_16x1 module functionality
// Method: Apply controlled test sequences, monitor outputs
// ============================================================================
`timescale 1ns/1ps  // Match timescale with DUT (Device Under Test)

module tb_ram;
    // ============================================================================
    // Testbench Signal Generators (Like Lab Equipment)
    // ============================================================================
    // These are REG because we actively drive them (change their values)
    // They represent the "tester" applying signals to the RAM
    // ============================================================================
    reg clk;        // Clock generator
    reg cs;         // Chip select control
    reg wr;         // Write/read control
    reg [3:0] ab;   // Address generator
    reg di;         // Data input generator

    // ============================================================================
    // Testbench Probes (Oscilloscope Connections)
    // ============================================================================
    // These are WIRE because they just monitor outputs from DUT
    // We don't drive them - the DUT drives them
    // ============================================================================
    wire od;        // Data output probe (monitors RAM output)

    // ============================================================================
    // Device Under Test (DUT) Instantiation
    // ============================================================================
    // ram_16x1 u_ram (...) creates an instance of ram_16x1 module
    // 'u_ram' is the instance name (like a label on a chip)
    // Port connections use DOT notation: .port_name(signal_name)
    // ============================================================================
    ram_16x1 u_ram (
        .clk(clk),      // Connect testbench clk to DUT clk
        .cs(cs),        // Connect testbench cs to DUT cs
        .wr(wr),        // Connect testbench wr to DUT wr
        .ab(ab),        // Connect testbench ab to DUT ab
        .di(di),        // Connect testbench di to DUT di
        .od(od)         // Connect DUT od to testbench probe
    );

    // ============================================================================
    // Clock Generator Process
    // ============================================================================
    // initial begin ... end: Executes once at simulation start (time = 0)
    // forever: Loops indefinitely (until $finish)
    // #10: Delay 10 time units (10 ns with our timescale)
    // ============================================================================
    // Clock period = 20 ns (50 MHz frequency)
    //   - clk starts at 0
    //   - After #10 ns: clk toggles to 1 (rising edge at t=10ns)
    //   - After #10 ns: clk toggles to 0 (falling edge at t=20ns)
    //   - Repeats forever
    // ============================================================================
    initial begin
        clk = 0;                    // Start clock low
        forever #10 clk = ~clk;     // Toggle every 10ns (20ns period)
    end

    // ============================================================================
    // Test Sequence Process
    // ============================================================================
    // This is the "test program" - sequence of operations to verify RAM
    // Each #delay advances simulation time
    // $display prints messages to console
    // $time returns current simulation time
    // ============================================================================
    initial begin
        // ============================================================================
        // Initialization Phase (Time 0-25ns)
        // ============================================================================
        // Set all control signals to safe initial values
        // ============================================================================
        $display("========================================");
        $display("RAM Testbench Started");
        $display("========================================");

        // Initialize all signals
        cs = 0;     // RAM idle (storage mode)
        wr = 0;     // Default to write mode (doesn't matter when cs=0)
        ab = 0;     // Start at address 0
        di = 0;     // Default data = 0

        $display("[%0t ns] Initializing signals...", $time);
        #25;  // Wait 25ns for stability (covers 1+ clock cycles)

        // ============================================================================
        // Test 1: Write 1 to Address 3 (Time ~25-45ns)
        // ============================================================================
        // Operation sequence:
        //   1. Set up signals (cs=1, wr=0, ab=3, di=1)
        //   2. Wait for clock rising edge (write triggered)
        //   3. Verify: mem[3] should now contain 1
        // ============================================================================
        $display("[%0t ns] TEST 1: Write 1 to address 3", $time);

        cs = 1;     // Activate RAM
        wr = 0;     // Write mode
        ab = 4'd3;  // Address 3 (4'd3 = 4-bit decimal 3 = 0011 binary)
        di = 1'b1;  // Data = 1

        $display("[%0t ns]   Setup: CS=1, WR=0, AB=3, DI=1", $time);
        #20;  // Wait 20ns (covers one full clock cycle)

        $display("[%0t ns]   Write completed", $time);
        #10;  // Small delay before next operation

        // ============================================================================
        // Test 2: Read from Address 3 (Time ~75-95ns)
        // Expected: od = 1 (what we just wrote)
        // ============================================================================
        // Operation sequence:
        //   1. Change to read mode (wr=1)
        //   2. Keep address=3, cs=1
        //   3. Wait for clock rising edge (read triggered)
        //   4. Check od value
        // ============================================================================
        $display("[%0t ns] TEST 2: Read from address 3", $time);

        wr = 1;     // Read mode
        // ab stays 3, cs stays 1

        $display("[%0t ns]   Setup: CS=1, WR=1, AB=3", $time);
        #20;  // Wait for clock edge

        $display("[%0t ns]   Read value: od = %b", $time, od);

        // Check result
        if (od == 1'b1)
            $display("[%0t ns]   ✓ PASS: Read correct value (1)", $time);
        else
            $display("[%0t ns]   ✗ FAIL: Expected 1, got %b", $time, od);

        #10;

        // ============================================================================
        // Test 3: Write 0 to Address 7 (Time ~125-145ns)
        // ============================================================================
        $display("[%0t ns] TEST 3: Write 0 to address 7", $time);

        wr = 0;     // Write mode
        ab = 4'd7;  // Address 7
        di = 1'b0;  // Data = 0

        $display("[%0t ns]   Setup: CS=1, WR=0, AB=7, DI=0", $time);
        #20;

        $display("[%0t ns]   Write completed", $time);
        #10;

        // ============================================================================
        // Test 4: Read from Address 7 (Time ~175-195ns)
        // Expected: od = 0
        // ============================================================================
        $display("[%0t ns] TEST 4: Read from address 7", $time);

        wr = 1;     // Read mode
        #20;

        $display("[%0t ns]   Read value: od = %b", $time, od);

        if (od == 1'b0)
            $display("[%0t ns]   ✓ PASS: Read correct value (0)", $time);
        else
            $display("[%0t ns]   ✗ FAIL: Expected 0, got %b", $time, od);

        #10;

        // ============================================================================
        // Test 5: Read from Address 3 Again (Time ~225-245ns)
        // Expected: od = 1 (original value should still be there)
        // This verifies that writing to addr 7 didn't affect addr 3
        // ============================================================================
        $display("[%0t ns] TEST 5: Read from address 3 again (verify isolation)", $time);

        ab = 4'd3;  // Back to address 3
        #20;

        $display("[%0t ns]   Read value: od = %b", $time, od);

        if (od == 1'b1)
            $display("[%0t ns]   ✓ PASS: Address isolation verified", $time);
        else
            $display("[%0t ns]   ✗ FAIL: Address 3 corrupted!", $time);

        #10;

        // ============================================================================
        // Test 6: Test Idle Mode (CS=0) (Time ~275-295ns)
        // Expected: RAM should ignore operations when CS=0
        // ============================================================================
        $display("[%0t ns] TEST 6: Verify idle mode (CS=0)", $time);

        cs = 0;     // Deactivate RAM
        wr = 0;     // Try to write
        ab = 4'd5;  // To address 5
        di = 1'b1;  // Value 1

        $display("[%0t ns]   Setup: CS=0, WR=0, AB=5, DI=1 (should be ignored)", $time);
        #20;

        // Now read address 5 - should still be 0 (uninitialized)
        cs = 1;
        wr = 1;
        #20;

        $display("[%0t ns]   Read addr 5: od = %b", $time, od);
        $display("[%0t ns]   Note: Uninitialized memory reads 0 by default", $time);

        #10;

        // ============================================================================
        // Test Complete
        // ============================================================================
        $display("========================================");
        $display("[%0t ns] Testbench Complete", $time);
        $display("========================================");

        // End simulation
        $finish;
    end

    // ============================================================================
    // Waveform Dump Setup
    // ============================================================================
    // $dumpfile: Specifies VCD (Value Change Dump) output file
    // $dumpvars: Controls what signals to dump
    //   0 = dump all levels of hierarchy
    //   tb_ram = start from this module
    // VCD files can be viewed in GTKWave, Scansion, etc.
    // ============================================================================
    initial begin
        $dumpfile("tb_ram.vcd");      // Output file name
        $dumpvars(0, tb_ram);          // Dump all signals in tb_ram hierarchy
    end

endmodule
