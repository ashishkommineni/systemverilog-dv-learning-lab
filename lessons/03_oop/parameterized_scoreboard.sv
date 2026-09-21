class typed_scoreboard #(type T = int);
  T expected [$];
  int match_count;
  int mismatch_count;

  function void push_expected(T item);
    expected.push_back(item);
  endfunction

  function void observe(T actual);
    T wanted;
    if (expected.size() == 0) begin
      mismatch_count++;
      return;
    end

    wanted = expected.pop_front();
    if (actual == wanted)
      match_count++;
    else
      mismatch_count++;
  endfunction
endclass

module parameterized_scoreboard_demo;
  typed_scoreboard #(logic [7:0]) scoreboard;

  initial begin
    scoreboard = new();
    scoreboard.push_expected(8'hA5);
    scoreboard.push_expected(8'h3C);
    scoreboard.observe(8'hA5);
    scoreboard.observe(8'h3C);

    assert (scoreboard.match_count == 2);
    assert (scoreboard.mismatch_count == 0);
    $display("parameterized_scoreboard_demo: PASS");
    $finish;
  end
endmodule
