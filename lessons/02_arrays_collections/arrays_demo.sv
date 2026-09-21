module arrays_demo;
  int fixed_values [4];
  int dynamic_values [];
  int pending [$];
  int by_name [string];
  int fixed_sum;
  int front_value;

  initial begin
    fixed_values = '{2, 4, 6, 8};
    fixed_sum = 0;
    foreach (fixed_values[i])
      fixed_sum += fixed_values[i];

    dynamic_values = new[3];
    foreach (dynamic_values[i])
      dynamic_values[i] = (i + 1) * 10;

    pending = '{3, 5};
    pending.push_front(1);
    pending.push_back(7);
    front_value = pending.pop_front();

    by_name["control"] = 32'h0000_0001;
    by_name["status"]  = 32'h0000_00A5;

    assert (fixed_sum == 20);
    assert (dynamic_values.size() == 3);
    assert (dynamic_values[2] == 30);
    assert (front_value == 1);
    assert (pending.size() == 3);
    assert (pending[0] == 3 && pending[$] == 7);
    assert (by_name.exists("status"));
    assert (by_name["status"] == 32'hA5);
    assert (!by_name.exists("missing"));

    $display("fixed_sum=%0d dynamic_size=%0d queue=%p",
             fixed_sum, dynamic_values.size(), pending);
    $display("associative_entries=%0d status=0x%0h",
             by_name.num(), by_name["status"]);
    $display("arrays_demo: PASS");
    $finish;
  end
endmodule
