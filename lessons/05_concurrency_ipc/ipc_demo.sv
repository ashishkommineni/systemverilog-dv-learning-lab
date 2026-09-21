module ipc_demo;
  mailbox #(int) messages;
  semaphore    sum_lock;
  event        stream_done;
  int          sum;
  bit          event_observed;

  task automatic producer();
    for (int value = 1; value <= 5; value++)
      messages.put(value);
    messages.put(-1);
  endtask

  task automatic consumer();
    int value;
    forever begin
      messages.get(value);
      if (value == -1)
        break;
      sum_lock.get(1);
      sum += value;
      sum_lock.put(1);
    end
    -> stream_done;
  endtask

  task automatic observer();
    @stream_done;
    event_observed = 1'b1;
  endtask

  initial begin
    messages = new(2);
    sum_lock = new(1);
    sum = 0;
    event_observed = 1'b0;

    fork
      producer();
      consumer();
      observer();
    join

    assert (sum == 15);
    assert (event_observed);
    assert (messages.num() == 0);

    $display("sum=%0d event_observed=%0b", sum, event_observed);
    $display("ipc_demo: PASS");
    $finish;
  end
endmodule
