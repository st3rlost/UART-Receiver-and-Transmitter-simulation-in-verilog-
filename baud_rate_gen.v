`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.08.2025 16:13:20
// Design Name: 
// Module Name: baud_rate_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// Module: baudrate
// Description: This module divides a 50 MHz input clock to generate enable signals
// for both transmitting (Tx) and receiving (Rx) that operate at a baud rate of 115200.
// The Rx clock is additionally oversampled by 16x to increase the reliability of data reception.

module baud_rate_gen(
    input wire clk_50m,       // Input clock at 50 MHz
    output wire Rxclk_en,     // Enable signal for the Rx clock, oversampled
    output wire Txclk_en      // Enable signal for the Tx clock
);

    // Parameters for calculating the number of clock cycles per baud bit , example 27 clock cycles we get one rx_enable bit 
    parameter RX_ACC_MAX = 50000000 / (115200 * 16); // Calculate max count for Rx oversampled by 16x
    parameter TX_ACC_MAX = 50000000 / 115200;        // Calculate max count for Tx
    parameter RX_ACC_WIDTH = $clog2(RX_ACC_MAX);     // Determine bit width needed for Rx accumulator
    parameter TX_ACC_WIDTH = $clog2(TX_ACC_MAX);     // $clog2(N) gives min no of bits needed to rep N, for example clog2(27) will be 5 for rx

    // Accumulators for baud rate generation
    reg [RX_ACC_WIDTH - 1:0] rx_acc = 0;  // Rx accumulator, initialized to 0
    reg [TX_ACC_WIDTH - 1:0] tx_acc = 0;  // Tx accumulator, initialized to 0

    // Generate Rx and Tx clock enable signals
    // Enable signals are active when accumulators reset
    assign Rxclk_en = (rx_acc == 0);
    assign Txclk_en = (tx_acc == 0);

    // Baud rate clock generation for Rx
    // each 50 mhz tick increases rx_acc, if it becomes max(27) then reset to 0
    // This clock is oversampled by 16x for better sampling of incoming data
    always @(posedge clk_50m) begin
        if (rx_acc == RX_ACC_MAX - 1)  // Check if the accumulator has reached its max value
            rx_acc <= 0;               // Reset the accumulator
        else
            rx_acc <= rx_acc + 1;      // Increment the accumulator
    end

    // Baud rate clock generation for Tx
    // This clock matches the baud rate of 115200 for data transmission
    always @(posedge clk_50m) begin
        if (tx_acc == TX_ACC_MAX - 1)  // Check if the accumulator has reached its max value
            tx_acc <= 0;               // Reset the accumulator
        else
            tx_acc <= tx_acc + 1;      // Increment the accumulator
    end

endmodule
