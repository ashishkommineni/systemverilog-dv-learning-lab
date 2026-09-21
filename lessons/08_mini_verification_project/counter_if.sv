interface counter_if #(
  parameter int unsigned WIDTH = 4
) (
  input logic clk
);
  logic             rst_n;
  logic             load;
  logic             enable;
  logic [WIDTH-1:0] load_value;
  logic [WIDTH-1:0] count;

  clocking drv_cb @(negedge clk);
    default input #1step output #0;
    output load, enable, load_value;
    input  count;
  endclocking

  clocking mon_cb @(posedge clk);
    default input #0;
    input load, enable, load_value, count;
  endclocking

  modport DUT (
    input  clk, rst_n, load, enable, load_value,
    output count
  );

  modport DRV (
    clocking drv_cb,
    input clk, rst_n
  );

  modport MON (
    clocking mon_cb,
    input clk, rst_n
  );

  property load_updates_count;
    @(posedge clk) disable iff (!rst_n)
      load |=> count == $past(load_value);
  endproperty

  property enable_increments_count;
    @(posedge clk) disable iff (!rst_n)
      (!load && enable) |=>
        count == ($past(count) + {{(WIDTH-1){1'b0}}, 1'b1});
  endproperty

  property idle_holds_count;
    @(posedge clk) disable iff (!rst_n)
      (!load && !enable) |=> count == $past(count);
  endproperty

  property controls_are_known;
    @(posedge clk) disable iff (!rst_n)
      !$isunknown({load, enable, load_value});
  endproperty

  assert property (load_updates_count)
    else $fatal(1, "LOAD rule failed");
  assert property (enable_increments_count)
    else $fatal(1, "COUNT rule failed");
  assert property (idle_holds_count)
    else $fatal(1, "HOLD rule failed");
  assert property (controls_are_known)
    else $fatal(1, "Unknown control observed");
endinterface
