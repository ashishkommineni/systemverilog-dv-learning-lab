module processes_demo;
  int completed;
  int winner;
  bit background_done;

  task automatic worker(input int id, input time delay_value);
    #delay_value;
    completed++;
    $display("worker_%0d complete", id);
  endtask

  initial begin
    completed = 0;
    winner = 0;
    background_done = 0;

    fork
      worker(0, 3ns);
      worker(1, 5ns);
    join
    assert (completed == 2);

    fork
      begin
        #2ns;
        winner = 1;
      end
      begin
        #10ns;
        winner = 2;
      end
    join_any
    disable fork;
    assert (winner == 1)
      else $fatal(1, "Slow timeout branch was not cancelled");

    fork
      begin
        #1ns;
        background_done = 1;
      end
    join_none

    assert (!background_done);
    wait fork;
    assert (background_done);

    $display("completed=%0d winner=%0d background=%0b",
             completed, winner, background_done);
    $display("processes_demo: PASS");
    $finish;
  end
endmodule
