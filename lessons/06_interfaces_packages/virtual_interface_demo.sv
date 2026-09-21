interface pulse_if(input logic clk);
  logic rst_n;
  logic request;
  logic acknowledge;

  clocking driver_cb @(posedge clk);
    default input #1step output #0;
    output request;
    input  acknowledge;
  endclocking

  modport driver(clocking driver_cb, input rst_n);
endinterface

class pulse_driver;
  virtual pulse_if.driver vif;

  function new(virtual pulse_if.driver vif_value);
    if (vif_value == null)
      $fatal(1, "pulse_driver received a null virtual interface");
    vif = vif_value;
  endfunction

  task send();
    @(vif.driver_cb);
    vif.driver_cb.request <= 1'b1;
    @(vif.driver_cb);
    vif.driver_cb.request <= 1'b0;
  endtask
endclass

module virtual_interface_demo;
  logic clk = 1'b0;
  pulse_if bus(clk);
  pulse_driver driver;

  always #5 clk = ~clk;

  assign bus.acknowledge = bus.request;

  initial begin
    bus.rst_n = 1'b1;
    bus.request = 1'b0;
    driver = new(bus);
    driver.send();
    repeat (2) @(posedge clk);
    $display("virtual_interface_demo: PASS");
    $finish;
  end
endmodule
