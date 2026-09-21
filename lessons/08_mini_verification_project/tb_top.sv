module tb_top;
  import counter_tb_pkg::*;

  localparam int unsigned ITEM_COUNT = 24;

  logic clk = 1'b0;
  counter_if #(.WIDTH(4)) bus(clk);
  counter_environment environment;

  counter_dut #(.WIDTH(4)) dut (
    .clk        (clk),
    .rst_n      (bus.rst_n),
    .load       (bus.load),
    .enable     (bus.enable),
    .load_value (bus.load_value),
    .count      (bus.count)
  );

  always #5 clk = ~clk;

  initial begin
    bus.rst_n     = 1'b0;
    bus.load      = 1'b0;
    bus.enable    = 1'b0;
    bus.load_value = '0;

    repeat (2) @(negedge clk);
    assert (bus.count == '0)
      else $fatal(1, "Counter did not reset");
    bus.rst_n = 1'b1;
    #1;

    environment = new(bus);
    environment.run(ITEM_COUNT);

    // Resolve consequents launched by the final accepted transaction.
    repeat (2) @(posedge clk);

    assert (environment.scoreboard.mismatch_count == 0)
      else $fatal(1, "Scoreboard found %0d mismatches",
                  environment.scoreboard.mismatch_count);
    assert (environment.scoreboard.match_count == ITEM_COUNT)
      else $fatal(1, "Expected %0d matches, got %0d",
                  ITEM_COUNT, environment.scoreboard.match_count);

    $display("matches=%0d mismatches=%0d coverage=%0.2f%%",
             environment.scoreboard.match_count,
             environment.scoreboard.mismatch_count,
             environment.coverage.get_coverage());
    $display("tb_top: PASS");
    $finish;
  end
endmodule
