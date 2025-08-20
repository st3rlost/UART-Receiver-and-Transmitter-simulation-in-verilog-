`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.08.2025 00:00:29
// Design Name: 
// Module Name: transmitter
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



module transmitter(
    input wire [7:0] data_in,        // 8-bit input data to transmit
    input wire txen,            // transmit enable signal
    input wire clk_50m,          // 50 MHz system clock
    input wire clken,            // Clock enable (baud rate generator output)
    output reg tx,               // Serial output line
    output wire tx_busy          // Indicates transmission is in progress
);
    initial begin
        tx = 1'b1;                   // Default UART line is idle high
    end
    // Define UART transmission states
    parameter STATE_IDLE = 2'b00;
    parameter STATE_START = 2'b01;
    parameter STATE_DATA = 2'b10;
    parameter STATE_STOP = 2'b11;
    
    //internal registers
    reg [7:0] data = 8'h00;         // Register to hold data to be transmitted
    reg [2:0] bitpos = 3'h0;        // Bit position counter (0 to 7)
    reg [1:0] state = STATE_IDLE;   // Current state of the transmitter FSM
    
    always @(posedge clk_50m) begin
        case (state)
            STATE_IDLE: begin
                if (~txen) begin
                    state <= STATE_START;   // Go to start bit state
                    data <= data_in;            // Load data to transmit
                    bitpos <= 3'h0;         // Reset bit position
                end
            end
            STATE_START: begin              //transmission starts of start bit 
                if (clken) begin
                    tx <= 1'b0;             // Send start bit (low)
                    state <= STATE_DATA;    // Go to data transmission state
                end
            end
            STATE_DATA: begin
                if (clken) begin
                    tx <= data[bitpos];     // Send data bit at current bitpos
                    if (bitpos == 3'h7)
                        state <= STATE_STOP; // After last bit, go to stop bit
                    else
                        bitpos <= bitpos + 3'h1; // Move to next bit
                end
            end
            STATE_STOP: begin
                if (clken) begin
                    tx <= 1'b1;             // Send stop bit (high)
                    state <= STATE_IDLE;    // Return to idle state
                end
            end
            default: begin
                tx <= 1'b1;                 // Default to idle line high
                state <= STATE_IDLE;
            end
        endcase
    end
    
    // output busy signal if the tx is not IDLE 
    assign tx_busy = (state != STATE_IDLE); // High when transmitting
endmodule