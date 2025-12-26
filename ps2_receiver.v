
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Armanda Byberi 
// 
// Create Date: 12/24/2025 06:32:07 PM
// Design Name:
// Module Name: ps2_module
// Project Name: PS/2 packer parser with a datapath for received packets 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision: 1.2
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ps2_module(
    input wire       clk,
    input wire       reset,
    input wire [7:0] in,
    output reg [23:0] out_bytes,
    output reg       done
);

    // State encoding 
    localparam BYTE1 = 2'b00,
               BYTE2 = 2'b01,
               BYTE3 = 2'b10,
               DONE  = 2'b11;

    reg [1:0] state, next_state;

    // Registers to store the three bytes of the current packet
    reg [7:0] byte1;
    reg [7:0] byte2;
    reg [7:0] byte3;

    // ============================
    // State register (synchronous reset)
    // ============================
    always @(posedge clk) begin
        if (reset)
            state <= BYTE1;
        else
            state <= next_state;
    end

    // ============================
    // Next-state logic
    // ============================
    always @(*) begin
        next_state = state;

        case (state)
            BYTE1: begin
                if (in[3])
                    next_state = BYTE2;
                else
                    next_state = BYTE1;
            end
            BYTE2: next_state = BYTE3;
            BYTE3: next_state = DONE;
            DONE: begin
                if (in[3])
                    next_state = BYTE2;
                else
                    next_state = BYTE1;
            end
            default: next_state = BYTE1;
        endcase
    end

    // ============================
    // Output logic: done is registered (as in your port declaration)
    // ============================
    always @(posedge clk) begin
        if (reset)
            done <= 1'b0;
        else
            done <= (next_state == DONE);  // done high in the cycle AFTER the third byte arrives
    end

    // ============================
    // Datapath: capture the three bytes and assemble out_bytes
    // ============================
    always @(posedge clk) begin
        if (reset) begin
            byte1 <= 8'd0;
            byte2 <= 8'd0;
            byte3 <= 8'd0;
            out_bytes <= 24'd0;
        end
        else begin
            case (state)
                BYTE1: begin
                    if (in[3]) begin
                        byte1 <= in;               // valid start byte -> capture as first byte
                    end
                    // else discard byte, registers unchanged
                end

                BYTE2: begin
                    byte2 <= in;                   // capture second byte
                end

                BYTE3: begin
                    byte3 <= in;                   // capture third byte
                    out_bytes <= {byte1, byte2, in}; // assemble full packet now
                end

                DONE: begin
                    if (in[3]) begin
                        byte1 <= in;               // new start byte arrives immediately -> capture for next packet
                    end
                    // out_bytes holds previous packet value (valid while done==1)
                end

                default: begin
                    byte1 <= 8'd0;
                    byte2 <= 8'd0;
                    byte3 <= 8'd0;
                    out_bytes <= 24'd0;
                end
            endcase
        end
    end

endmodule
