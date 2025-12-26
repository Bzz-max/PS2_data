
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Armanda Byberi 
// Create Date: 12/24/2025 07:04:02 PM
// Design Name: FSM PS/2 datapath test bench 
// Module Name: tb_fsm_ps2data
// Revision 1.11
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module ps2_module_tb;

    reg         clk;
    reg         reset;
    reg  [7:0]  in;
    wire [23:0] out_bytes;
    wire        done;

    // Instantiate DUT
    ps2_module dut (
        .clk(clk),
        .reset(reset),
        .in(in),
        .out_bytes(out_bytes),
        .done(done)
    );

    // Clock generation (10 ns)

    initial clk = 0;
    always #5 clk = ~clk;
    
    // Stimulus

    initial begin
        // Defaults
        reset = 1;
        in    = 8'h00;

        // Hold reset for a few cycles
        #20;
        reset = 0;

        // ---- First packet ----
        // byte1 = 08 (in[3]=1)
        @(posedge clk);
        in = 8'h08;

        // byte2 = 01
        @(posedge clk);
        in = 8'h01;

        // byte3 = 02  --> done, out_bytes = 080102
        @(posedge clk);
        in = 8'h02;

        // idle
        @(posedge clk);
        in = 8'h38; // noise, in[3]=0

        // ---- Second packet ----
        // byte1 = 38 (in[3]=1)
        @(posedge clk);
        in = 8'h38;

        // byte2 = ff
        @(posedge clk);
        in = 8'hff;

        // byte3 = fe  --> done, out_bytes = 38fffe
        @(posedge clk);
        in = 8'hfe;

        // idle
        @(posedge clk);
        in = 8'h08; // start of next packet

        @(posedge clk);
        in = 8'h03;

        @(posedge clk);
        in = 8'h04;

        // finish
        #20;
        $stop;
    end

endmodule
