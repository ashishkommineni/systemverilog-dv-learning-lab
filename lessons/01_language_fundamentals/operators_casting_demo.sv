module operators_casting_demo;
  logic [3:0] value;
  logic [3:0] masked;
  int signed  signed_value;
  int         population;

  initial begin
    value        = 4'b1101;
    masked       = value & 4'b0111;
    signed_value = $signed(value);
    population   = $countones(value);

    assert (masked == 4'b0101);
    assert (signed_value == -3);
    assert (population == 3);
    assert (&value == 1'b0);
    assert (|value == 1'b1);
    assert (value inside {[4'hC:4'hF]});
    assert ((value << 1) == 4'b1010);

    $display("value=0x%0h signed=%0d ones=%0d", value, signed_value,
             population);
    $display("operators_casting_demo: PASS");
    $finish;
  end
endmodule
