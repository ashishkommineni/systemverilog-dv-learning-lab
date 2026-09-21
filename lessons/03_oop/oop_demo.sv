class transaction;
  static int created;

  protected int id;
  byte unsigned payload[];

  function new(int id_value, int payload_length);
    id = id_value;
    payload = new[payload_length];
    created++;
  endfunction

  function int get_id();
    return id;
  endfunction

  virtual function string describe();
    return $sformatf("transaction id=%0d", id);
  endfunction

  function transaction deep_copy();
    transaction copied;
    copied = new(id, payload.size());
    foreach (payload[i])
      copied.payload[i] = payload[i];
    return copied;
  endfunction
endclass

class write_transaction extends transaction;
  logic [31:0] address;

  function new(int id_value, logic [31:0] address_value);
    super.new(id_value, 2);
    address = address_value;
  endfunction

  virtual function string describe();
    return $sformatf("write id=%0d address=0x%0h", id, address);
  endfunction
endclass

module oop_demo;
  transaction       base_handle;
  transaction       alias_handle;
  transaction       copied_handle;
  write_transaction write_item;

  initial begin
    write_item = new(7, 32'h0000_1040);
    write_item.payload[0] = 8'hAA;
    write_item.payload[1] = 8'h55;

    base_handle = write_item;
    assert (base_handle.describe() == "write id=7 address=0x1040")
      else $fatal(1, "Virtual dispatch failed");

    alias_handle = base_handle;
    alias_handle.payload[0] = 8'h11;
    assert (base_handle.payload[0] == 8'h11)
      else $fatal(1, "Handle assignment did not alias");

    copied_handle = base_handle.deep_copy();
    copied_handle.payload[0] = 8'h22;
    assert (base_handle.payload[0] == 8'h11)
      else $fatal(1, "Deep copy still aliases payload");
    assert (copied_handle.get_id() == 7);
    assert (transaction::created == 2);

    $display("%s", base_handle.describe());
    $display("original=0x%0h copy=0x%0h objects=%0d",
             base_handle.payload[0], copied_handle.payload[0],
             transaction::created);
    $display("oop_demo: PASS");
    $finish;
  end
endmodule
