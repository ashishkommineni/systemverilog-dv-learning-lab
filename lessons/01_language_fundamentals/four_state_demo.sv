module four_state_demo;
  logic four_state;
  bit   two_state;

  initial begin
    four_state = 1'bx;
    two_state  = four_state;

    assert (four_state === 1'bx)
      else $fatal(1, "logic did not preserve X");
    assert (two_state === 1'b0)
      else $fatal(1, "bit must convert X to 0");
    assert ((four_state == 1'b0) === 1'bx)
      else $fatal(1, "logical equality should return X");

    $display("logic=%b bit=%b", four_state, two_state);
    $display("four_state_demo: PASS");
    $finish;
  end
endmodule
