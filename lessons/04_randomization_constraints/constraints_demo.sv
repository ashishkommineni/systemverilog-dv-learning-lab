typedef enum bit [2:0] {
  READ_OP  = 3'd1,
  WRITE_OP = 3'd2,
  ERROR_OP = 3'd4
} opcode_e;

class packet;
  randc bit [1:0] channel;
  rand  opcode_e  opcode;
  rand  int unsigned length;
  rand  byte unsigned payload[];

  bit inject_error;
  int solve_attempts;
  int unsigned checksum;

  constraint legal_length_c {
    length inside {[1:16]};
  }

  constraint preferred_length_c {
    soft length inside {[2:8]};
  }

  constraint length_weight_c {
    length dist {[1:4] := 4, [5:16] := 1};
  }

  constraint opcode_c {
    opcode inside {READ_OP, WRITE_OP, ERROR_OP};
  }

  constraint error_mode_c {
    inject_error -> opcode == ERROR_OP;
  }

  constraint opcode_length_c {
    opcode == ERROR_OP -> length inside {[2:4]};
    solve opcode before length;
  }

  constraint payload_c {
    payload.size() == length;
    foreach (payload[i])
      payload[i] inside {[0:15]};
  }

  function void pre_randomize();
    solve_attempts++;
  endfunction

  function void post_randomize();
    checksum = 0;
    foreach (payload[i])
      checksum += int'(payload[i]);
  endfunction
endclass

module constraints_demo;
  packet item;
  bit [3:0] channels_seen;
  bit failed_as_expected;

  initial begin
    item = new();
    item.srandom(32'h51A7_2026);
    channels_seen = '0;

    repeat (4) begin
      assert ((item.randomize() with { length == 8; }) == 1)
        else $fatal(1, "Inline length solve failed");
      assert (item.length == 8);
      assert (item.payload.size() == 8);
      channels_seen[item.channel] = 1'b1;
    end
    assert (&channels_seen)
      else $fatal(1, "randc channel repeated before completing its cycle");

    item.inject_error = 1'b1;
    assert (item.randomize() == 1)
      else $fatal(1, "Error-mode solve failed");
    assert (item.opcode == ERROR_OP);
    assert (item.length inside {[2:4]});

    failed_as_expected =
      ((item.randomize() with { length == 0; }) == 0);
    assert (failed_as_expected)
      else $fatal(1, "An illegal hard constraint unexpectedly solved");

    $display("error_packet channel=%0d opcode=%0d length=%0d checksum=%0d",
             item.channel, item.opcode, item.length, item.checksum);
    $display("conflicting_inline_constraint: expected failure");
    $display("constraints_demo: PASS");
    $finish;
  end
endmodule
