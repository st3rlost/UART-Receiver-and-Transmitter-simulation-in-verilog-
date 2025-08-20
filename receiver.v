`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.08.2025 00:04:32
// Design Name: 
// Module Name: receiver
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


// UART Receiver
// ==========================

module receiver(
    input wire rx,               // Serial input line
    input wire rx_en,             // receiver enable 
    input wire rdy_clr,          // Ready clear signal (acknowledge read)
    input wire clk_50m,          // 50 MHz clock
    input wire clken,            // Baud rate sample enable
    output reg rdy,              // High when data byte is received
    output reg [7:0] data        // Received data output
);

    initial begin
        rdy = 0; // set to 0 initally, data cant be read 
        data = 8'b0; // data cleared frst 
    end
    // FSM states for receiver
    parameter RX_STATE_START = 2'b00;
    parameter RX_STATE_DATA  = 2'b01;
    parameter RX_STATE_STOP  = 2'b10;
    
    reg [1:0] state = RX_STATE_START; // Current state
    reg [3:0] sample = 0;             // Sample counter
    reg [3:0] bitpos = 0;             // Bit position counter
    reg [7:0] scratch = 8'b0;         // Temporary storage for incoming bits
    always @(posedge clk_50m) begin
        if (rdy_clr)
            rdy <= 0;                 // Clear ready flag
    
        if (clken && ~rx_en) begin
            case (state)
            RX_STATE_START: begin
                // Wait for falling edge (start bit)
                if (!rx || sample != 0)
                    sample <= sample + 4'b1;
    
                // If low is stable for a full bit time, start receiving
                if (sample == 15) begin //full bit has been sampled at sampling (over sampling) rate of 16
                    state <= RX_STATE_DATA;
                    bitpos <= 0;
                    sample <= 0;
                    scratch <= 0;
                end
            end
            RX_STATE_DATA: begin
                sample <= sample + 4'b1;
    
                // Sample in the middle of bit time
                if (sample == 4'h8) begin
                    scratch[bitpos[2:0]] <= rx; // Store sampled bit
                    bitpos <= bitpos + 4'b1;
                end
    
                // After receiving all 8 bits
                if (bitpos == 8 && sample == 15) 
                    state <= RX_STATE_STOP;
            end
            RX_STATE_STOP: begin
                // Wait for stop bit (line high) or allow transition
                if (sample == 15 || (sample >= 8 && !rx)) begin
                    state <= RX_STATE_START;
                    data <= scratch;      // Transfer scratch to output
                    rdy <= 1'b1;          // Set ready flag means data is ready 
                    sample <= 0;
                end else begin
                    sample <= sample + 4'b1;
                end
            end
            default: begin
                state <= RX_STATE_START;
            end
            endcase
        end
    end
    
    endmodule
