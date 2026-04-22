`include "src/debounce_press.sv"
`include "src/decoder.sv"
`include "src/pwm10.sv"

module top #(
    parameter integer DEBOUNCE_MAX = 500000 //high just in case
)(
    input  logic clk,
    input  logic btn_red_n,
    input  logic btn_blue_n,
    input  logic sel_sw_n,
    output logic [7:0] seg7,
    output logic led_r,
    output logic led_b
);

logic rst;

logic red_pressed, blue_pressed;
logic red_pulse, blue_pulse;

logic [3:0] duty_red;
logic [3:0] duty_blue;
logic [3:0] display_value;

logic [6:0] seg_core;
logic pwm_red, pwm_blue;

assign rst = 1'b0;
assign red_pressed  = ~btn_red_n;
assign blue_pressed = ~btn_blue_n; //opposites

debounce_press #(
    .COUNT_MAX(DEBOUNCE_MAX)
) db_red (
    .clk(clk),
    .rst(rst),
    .btn_in(red_pressed),
    .press_pulse(red_pulse)
);

debounce_press #(
    .COUNT_MAX(DEBOUNCE_MAX)
) db_blue (
    .clk(clk),
    .rst(rst),
    .btn_in(blue_pressed),
    .press_pulse(blue_pulse)
);

always_ff @(posedge clk) begin
    if (red_pulse) begin
        if (duty_red == 4'd10)
            duty_red <= 4'd0;
        else
            duty_red <= duty_red + 1'b1;
    end

    if (blue_pulse) begin
        if (duty_blue == 4'd10)
            duty_blue <= 4'd0;
        else
            duty_blue <= duty_blue + 1'b1;
    end
end

always_comb begin
    if (sel_sw_n)
        display_value = duty_red;
    else
        display_value = duty_blue;
end

decoder dec_inst (
    .bcd(display_value),
    .seg7(seg_core)
);

pwm10 pwm_red_inst (
    .clk(clk),
    .rst(rst),
    .duty_cycle(duty_red),
    .pwm_out(pwm_red)
);
//using red for left and blue for right
pwm10 pwm_blue_inst (
    .clk(clk),
    .rst(rst),
    .duty_cycle(duty_blue),
    .pwm_out(pwm_blue)
);

assign seg7[6:0] = seg_core;
assign seg7[7]   = sel_sw_n; // keep normal active low so that 7seg works

// active low so have to add ~
assign led_r = ~pwm_red;
assign led_b = ~pwm_blue;

endmodule