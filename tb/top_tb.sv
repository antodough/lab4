`include "src/top.sv"
`timescale 1ns/1ps

module top_tb;

/** declare tb signals below */
logic clk_tb;
logic btn_red_n_tb;
logic btn_blue_n_tb;
logic sel_sw_n_tb;
logic [7:0] seg7_tb;
logic led_r_tb;
logic led_b_tb;

/** declare module(s) below */
top #(
    .DEBOUNCE_MAX(4)
) dut (
    .clk(clk_tb),
    .btn_red_n(btn_red_n_tb),
    .btn_blue_n(btn_blue_n_tb),
    .sel_sw_n(sel_sw_n_tb),
    .seg7(seg7_tb),
    .led_r(led_r_tb),
    .led_b(led_b_tb)
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk_tb = ~clk_tb;

initial begin
    $dumpfile("build/top.vcd");
    $dumpvars(0, top_tb);
end

task press_red;
begin
    btn_red_n_tb = 1'b0;
    repeat (6) @(posedge clk_tb);
    btn_red_n_tb = 1'b1;
    repeat (8) @(posedge clk_tb);
end
endtask

task press_blue;
begin
    btn_blue_n_tb = 1'b0;
    repeat (6) @(posedge clk_tb);
    btn_blue_n_tb = 1'b1;
    repeat (8) @(posedge clk_tb);
end
endtask

initial begin
    clk_tb        = 1'b0;
    btn_red_n_tb  = 1'b1;
    btn_blue_n_tb = 1'b1;
    sel_sw_n_tb   = 1'b1;   // OFF -> show red

    repeat (5) @(posedge clk_tb);

    // red: 0 -> 1 -> 2
    press_red();
    press_red();

    // switch to blue display
    sel_sw_n_tb = 1'b0;
    repeat (10) @(posedge clk_tb);

    // blue: 0 to 1
    press_blue();

    // blue: 1 to 2
    press_blue();

    // blue: 2 to 3
    press_blue();

    // switch back to red display
    sel_sw_n_tb = 1'b1;
    repeat (10) @(posedge clk_tb);

    $finish;
end

endmodule