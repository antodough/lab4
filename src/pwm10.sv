module pwm10 (
    input  logic clk,
    input  logic rst,
    input  logic [3:0] duty_cycle,   // 0-10 then off
    output logic pwm_out
);

logic [3:0] pwm_count;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        pwm_count <= 4'd0;
    end else begin
        if (pwm_count == 4'd9)
            pwm_count <= 4'd0;
        else
            pwm_count <= pwm_count + 1'b1;
    end
end

always_comb begin
    if (duty_cycle >= 4'd10)
        pwm_out = 1'b1;
    else
        pwm_out = (pwm_count < duty_cycle);
end

endmodule