module hcsr04_device_tb #(
    parameter real TIME_UNIT = 1,
    parameter integer LIMIT = 10
) (
    // Inputs and output ports
    input trigger,
    output reg echo
);

  // Declaración de señales [reg, wire]
  reg [31:0] cnt;
  reg state;
  initial begin
    echo  = 0;
    cnt   = 0;
    state = 0;
  end

  reg clk = 0;
  always #(TIME_UNIT) clk = !clk;

  // Descripción del comportamiento
  always @(posedge clk) begin
    if (state && ~trigger) begin  // past state = 1 and trigger 0 -> negedge
      echo <= 1;
    end
    if (echo) begin
      cnt <= cnt + 1;
    end
    if (cnt == LIMIT) begin
      echo = 0;
      cnt <= 0;
    end
    state <= trigger;  // Next state
  end

endmodule
