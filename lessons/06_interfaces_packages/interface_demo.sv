package counter_types_pkg;
  typedef enum logic {
    HOLD,
    COUNT
  } operation_e;

  function automatic logic [7:0] expected_next(
    input logic [7:0] current,
    input operation_e action
  );
    return (action == COUNT) ? current + 8'd1 : current;
  endfunction
endpackage

interface counter_if(input logic clk);
  logic       rst_n;
  logic       enable;
  logic [7:0] value;

  clocking driver_cb @(posedge clk);
    default input #1step output #0;
    output rst_n, enable;
    input  value;
  endclocking

  clocking monitor_cb @(posedge clk);
    default input #1step;
    input rst_n, enable, value;
  endclocking

  modport dut (
    input  clk, rst_n, enable,
    output value
  );

  modport driver (clocking driver_cb);
  modport monitor (clocking monitor_cb);
endinterface

module tiny_counter(counter_if.dut bus);
  always_ff @(posedge bus.clk or negedge bus.rst_n) begin
    if (!bus.rst_n)
      bus.value <= '0;
    else if (bus.enable)
      bus.value <= bus.value + 8'd1;
  end
endmodule

module interface_demo;
  import counter_types_pkg::*;

  logic clk = 1'b0;
  logic [7:0] expected;
  counter_if bus(clk);
  tiny_counter dut(bus);

  always #5 clk = ~clk;

  task automatic apply_and_check(input operation_e action);
    bus.enable = (action == COUNT);
    expected = expected_next(expected, action);
    @(negedge clk);
    assert (bus.value == expected)
      else $fatal(1, "Expected %0d, observed %0d", expected, bus.value);
  endtask

  initial begin
    bus.rst_n = 1'b0;
    bus.enable = 1'b0;
    expected = '0;

    repeat (2) @(negedge clk);
    bus.rst_n = 1'b1;

    apply_and_check(COUNT);
    apply_and_check(COUNT);
    apply_and_check(COUNT);
    apply_and_check(HOLD);

    assert (bus.value == 8'd3);
    $display("counter_value=%0d", bus.value);
    $display("interface_demo: PASS");
    $finish;
  end
endmodule
