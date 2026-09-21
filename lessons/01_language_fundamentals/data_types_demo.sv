module data_types_demo;
  typedef enum logic [1:0] {
    IDLE,
    ACTIVE,
    ERROR
  } state_e;

  typedef struct packed {
    logic [3:0] tag;
    logic [7:0] payload;
    logic       valid;
  } packet_header_t;

  typedef union packed {
    logic [15:0] word;
    logic [1:0][7:0] bytes;
  } word_view_t;

  bit [3:0]       packed_nibble;
  int             samples [3];
  state_e         state;
  packet_header_t header;
  word_view_t     view;
  string          label;

  initial begin
    packed_nibble = 4'b1010;
    samples       = '{11, 22, 33};
    state         = ACTIVE;
    header.tag     = 4'hA;
    header.payload = 8'h5C;
    header.valid   = 1'b1;
    view.word      = 16'hCAFE;
    label          = "typed transaction";

    assert ($bits(header) == 13)
      else $fatal(1, "Packed header width changed");
    assert (packed_nibble[3:0] == 4'hA);
    assert (samples[2] == 33);
    assert (state == ACTIVE);
    assert (header == 13'h14B9);
    assert (view.bytes[1] == 8'hCA);
    assert (view.bytes[0] == 8'hFE);
    assert (label.len() == 17);

    $display("header=0x%0h word=0x%0h samples=%0d", header, view.word,
             $size(samples));
    $display("data_types_demo: PASS");
    $finish;
  end
endmodule
