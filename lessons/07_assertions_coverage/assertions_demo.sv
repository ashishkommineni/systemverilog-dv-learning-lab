module assertions_demo;
  logic clk     = 1'b0;
  logic rst_n   = 1'b0;
  logic request = 1'b0;
  logic grant   = 1'b0;
  int handshakes;

  always #5 clk = ~clk;

  property request_gets_grant;
    @(posedge clk) disable iff (!rst_n)
      request |=> grant;
  endproperty

  property grant_has_history;
    @(posedge clk) disable iff (!rst_n)
      grant |-> $past(request);
  endproperty

  property controls_are_known;
    @(posedge clk) disable iff (!rst_n)
      !$isunknown({request, grant});
  endproperty

  assert property (request_gets_grant)
    else $fatal(1, "Grant was not asserted one cycle after request");

  assert property (grant_has_history)
    else $fatal(1, "Grant had no request in the previous cycle");

  assert property (controls_are_known)
    else $fatal(1, "Handshake control contains X or Z");

  // Keep the explicit sequence-delay cover point for full-featured simulators.
  // Verilator 5.020 executes the three assertions above but does not implement
  // ## delays inside a cover property, so the portable smoke run skips only
  // this coverage statement. The handshake count below still proves that the
  // antecedent and consequent occur twice during the test.
`ifndef VERILATOR
  cover property (@(posedge clk) disable iff (!rst_n)
                  request ##1 grant);
`endif

  always @(posedge clk) begin
    if (rst_n && grant)
      handshakes++;
  end

  task automatic send_request();
    @(negedge clk);
    request = 1'b1;
    grant   = 1'b0;
    @(negedge clk);
    request = 1'b0;
    grant   = 1'b1;
    @(negedge clk);
    grant   = 1'b0;
  endtask

  initial begin
    handshakes = 0;
    repeat (2) @(negedge clk);
    rst_n = 1'b1;

    send_request();
    send_request();
    @(negedge clk);

    assert (handshakes == 2)
      else $fatal(1, "Expected two handshakes, got %0d", handshakes);
    $display("handshakes=%0d", handshakes);
    $display("assertions_demo: PASS");
    $finish;
  end
endmodule
