module tasks_functions_demo;
  function automatic logic [7:0] saturating_add(
    input logic [7:0] lhs,
    input logic [7:0] rhs
  );
    logic [8:0] wide_sum;
    wide_sum = {1'b0, lhs} + {1'b0, rhs};
    return wide_sum[8] ? 8'hFF : wide_sum[7:0];
  endfunction

  task automatic check_add(
    input  logic [7:0] lhs,
    input  logic [7:0] rhs,
    input  logic [7:0] expected,
    output bit         passed
  );
    logic [7:0] actual;
    actual = saturating_add(lhs, rhs);
    passed = (actual == expected);
    if (!passed)
      $error("%0d + %0d: expected %0d, got %0d",
             lhs, rhs, expected, actual);
  endtask

  task automatic increment(ref int value);
    value++;
  endtask

  bit ok;
  int counter;

  initial begin
    check_add(8'd10, 8'd20, 8'd30, ok);
    assert (ok);
    check_add(8'd250, 8'd20, 8'd255, ok);
    assert (ok);

    counter = 41;
    increment(counter);
    assert (counter == 42);

    $display("saturating_add(250,20)=%0d counter=%0d",
             saturating_add(8'd250, 8'd20), counter);
    $display("tasks_functions_demo: PASS");
    $finish;
  end
endmodule
