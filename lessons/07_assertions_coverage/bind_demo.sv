module handshake_dut (
  input  logic clk,
  input  logic rst_n,
  input  logic request,
  output logic acknowledge
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      acknowledge <= 1'b0;
    else
      acknowledge <= request;
  end
endmodule

module handshake_checker (
  input logic clk,
  input logic rst_n,
  input logic request,
  input logic acknowledge
);
  property request_is_acknowledged;
    @(posedge clk) disable iff (!rst_n)
      request |=> acknowledge;
  endproperty

  assert property (request_is_acknowledged)
    else $fatal(1, "Bound checker observed a missing acknowledge");
endmodule

bind handshake_dut handshake_checker bound_checker (
  .clk(clk),
  .rst_n(rst_n),
  .request(request),
  .acknowledge(acknowledge)
);

module bind_demo;
  logic clk = 1'b0;
  logic rst_n = 1'b0;
  logic request = 1'b0;
  logic acknowledge;

  handshake_dut dut (
    .clk,
    .rst_n,
    .request,
    .acknowledge
  );

  always #5 clk = ~clk;

  initial begin
    repeat (2) @(negedge clk);
    rst_n = 1'b1;
    @(negedge clk);
    request = 1'b1;
    @(negedge clk);
    request = 1'b0;
    repeat (2) @(negedge clk);
    $display("bind_demo: PASS");
    $finish;
  end
endmodule
