module debounce_press #(
    parameter integer COUNT_MAX = 500000
)(
    input  logic clk,
    input  logic rst,
    input  logic btn_in,       
    output logic press_pulse
);

localparam integer W = (COUNT_MAX <= 1) ? 1 : $clog2(COUNT_MAX);

logic [W-1:0] count;
logic stable_pressed;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        count          <= '0;
        stable_pressed <= 1'b0;
        press_pulse    <= 1'b0;
    end else begin
        press_pulse <= 1'b0;

        if (btn_in) begin
            if (!stable_pressed) begin
                if (count == COUNT_MAX - 1) begin
                    stable_pressed <= 1'b1;
                    press_pulse    <= 1'b1;
                end else begin
                    count <= count + 1'b1;
                end
            end
        end else begin
            count          <= '0;
            stable_pressed <= 1'b0;
        end
    end
end

endmodule