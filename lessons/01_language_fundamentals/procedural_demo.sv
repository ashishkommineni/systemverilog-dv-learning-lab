module procedural_demo;
  logic clk   = 1'b0;
  logic rst_n = 1'b1;
  logic enable;
  logic data_in;
  logic next_q;
  logic q;

  always #5 clk = ~clk;

  always_comb begin
    next_q = enable ? data_in : q;
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      q <= 1'b0;
    else
      q <= next_q;
  end

  initial begin
    enable  = 1'b0;
    data_in = 1'b0;

    #1 rst_n = 1'b0;
    #2 rst_n = 1'b1;

    enable  = 1'b1;
    data_in = 1'b1;
    @(negedge clk);
    assert (q == 1'b1) else $fatal(1, "Enabled update failed");

    enable  = 1'b0;
    data_in = 1'b0;
    @(negedge clk);
    assert (q == 1'b1) else $fatal(1, "Hold behavior failed");

    $display("q=%0b after update and hold", q);
    $display("procedural_demo: PASS");
    $finish;
  end
endmodule
