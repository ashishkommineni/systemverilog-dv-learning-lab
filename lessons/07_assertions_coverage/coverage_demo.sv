typedef enum bit [1:0] {
  READ_OP,
  WRITE_OP,
  ATOMIC_OP
} operation_e;

module coverage_demo;
  covergroup packet_cg with function sample(
    operation_e operation,
    int unsigned length,
    bit error
  );
    option.per_instance = 1;
    option.name = "packet_scenarios";

    operation_cp: coverpoint operation {
      bins read   = {READ_OP};
      bins write  = {WRITE_OP};
      bins atomic = {ATOMIC_OP};
      bins read_to_write = (READ_OP => WRITE_OP);
    }

    length_cp: coverpoint length {
      bins tiny   = {[1:2]};
      bins mid_len = {[3:7]};
      bins long_len = {[8:16]};
      illegal_bins zero = {0};
    }

    error_cp: coverpoint error {
      bins no  = {0};
      bins yes = {1};
    }

    operation_length_cross: cross operation_cp, length_cp;

    operation_error_cross: cross operation_cp, error_cp {
      ignore_bins atomic_error =
        binsof(operation_cp.atomic) && binsof(error_cp.yes);
    }
  endgroup

  packet_cg coverage;
  real achieved;

  initial begin
    coverage = new();

    coverage.sample(READ_OP,   1,  0);
    coverage.sample(WRITE_OP,  2,  0);
    coverage.sample(READ_OP,   4,  1);
    coverage.sample(WRITE_OP,  8,  1);
    coverage.sample(ATOMIC_OP, 16, 0);

    achieved = coverage.get_inst_coverage();
    assert (achieved > 0.0)
      else $fatal(1, "Covergroup did not record samples");

    $display("instance_coverage=%0.2f%%", achieved);
    $display("coverage_demo: PASS");
    $finish;
  end
endmodule
