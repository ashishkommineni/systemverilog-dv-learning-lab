module counter_dut #(
  parameter int unsigned WIDTH = 4
) (
  input  logic                 clk,
  input  logic                 rst_n,
  input  logic                 load,
  input  logic                 enable,
  input  logic [WIDTH-1:0]     load_value,
  output logic [WIDTH-1:0]     count
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      count <= '0;
    else if (load)
      count <= load_value;
    else if (enable)
      count <= count + {{(WIDTH-1){1'b0}}, 1'b1};
  end
endmodule
