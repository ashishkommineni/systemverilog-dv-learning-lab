module counter_portable_smoke;
  logic clk = 1'b0;
  logic rst_n = 1'b0;
  logic load = 1'b0;
  logic enable = 1'b0;
  logic [3:0] load_value = '0;
  logic [3:0] count;

  counter_dut #(.WIDTH(4)) dut (
    .clk,
    .rst_n,
    .load,
    .enable,
    .load_value,
    .count
  );

  always #5 clk = ~clk;

  property load_rule;
    @(posedge clk) disable iff (!rst_n)
      load |=> count == $past(load_value);
  endproperty

  assert property (load_rule)
    else $fatal(1, "Portable load assertion failed");

  task automatic apply(
    input logic do_load,
    input logic do_count,
    input logic [3:0] value,
    input logic [3:0] expected
  );
    @(negedge clk);
    load = do_load;
    enable = do_count;
    load_value = value;
    @(negedge clk);
    assert (count == expected)
      else $fatal(1, "Expected %0h, got %0h", expected, count);
    load = 1'b0;
    enable = 1'b0;
    load_value = '0;
  endtask

  initial begin
    repeat (2) @(negedge clk);
    assert (count == 4'h0);
    rst_n = 1'b1;

    apply(1'b1, 1'b0, 4'hE, 4'hE);
    apply(1'b0, 1'b1, 4'h0, 4'hF);
    apply(1'b0, 1'b1, 4'h0, 4'h0);
    apply(1'b0, 1'b0, 4'h0, 4'h0);

    @(negedge clk);
    $display("load, increment, wrap, hold: checked");
    $display("counter_portable_smoke: PASS");
    $finish;
  end
endmodule
