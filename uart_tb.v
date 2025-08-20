`timescale 1ns/1ps

module uart_tb;

    // Testbench signals
    reg [7:0] data = 0;
    reg clk = 0;
    reg enable = 0;
    reg Rx_en = 0;
    reg ready_clr = 0;

    // UART outputs
    wire Tx_busy;
    wire ready;
    wire [7:0] Rx_data;

    // Loopback
    wire loopback;

    // Instantiate UART
    uart uut (
        .data_in(data),
        .Tx_en(enable),
        .clk_50m(clk),
        .Tx(loopback),
        .Tx_busy(Tx_busy),
        .Rx(loopback),
        .ready(ready),
        .ready_clr(ready_clr),
        .Rx_en(Rx_en),
        .data_out(Rx_data)
    );

    // Clock generation: 50 MHz
    always #10 clk = ~clk;

    // Test sequence
    initial begin
        enable    = 0;
        Rx_en     = 0;
        ready_clr = 0;

        // reset delay
        #100;

        // Start from ASCII 0x00
        data = 8'h00;
        send_byte(data);

        // Run long enough for all tests
        #1000000;
        $display("Simulation timeout reached");
        $finish;
    end

    // Task: Send a byte
    task send_byte(input [7:0] byte);
    begin
        @(posedge clk);
        data   <= byte;
        enable <= 1;
        Rx_en  <= 1;
        #20;
        enable <= 0;
        Rx_en  <= 0;
    end
    endtask

    // On reception
    always @(posedge ready) begin
        #5 ready_clr <= 1;
        #5 ready_clr <= 0;

        if (Rx_data !== data) begin
            $display("[%0t ns] ❌ FAIL: Sent %h, Received %h", $time, data, Rx_data);
        end else begin
            $display("[%0t ns] ✅ PASS: %h (ASCII: %s)", $time, Rx_data,
                     (Rx_data >= 8'h20 && Rx_data <= 8'h7E) ? Rx_data : " ");
        end

        // Next test
        if (data == 8'h7F) begin
            $display("✅✅ All ASCII characters tested including edge cases.");
            #50 $finish;
        end else begin
            send_byte(data + 1);
        end
    end

endmodule
