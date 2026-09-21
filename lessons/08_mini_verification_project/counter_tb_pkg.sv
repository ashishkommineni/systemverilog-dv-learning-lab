package counter_tb_pkg;
  typedef enum bit [1:0] {
    CMD_HOLD,
    CMD_COUNT,
    CMD_LOAD
  } counter_command_e;

  class counter_transaction;
    rand counter_command_e command;
    rand logic [3:0]       load_value;

    bit         stop;
    logic [3:0] observed_count;

    constraint command_weight_c {
      command dist {
        CMD_HOLD  := 2,
        CMD_COUNT := 6,
        CMD_LOAD  := 2
      };
    }

    constraint value_c {
      if (command == CMD_LOAD)
        load_value dist {
          4'h0     := 3,
          4'hF     := 3,
          [4'h1:4'hE] := 1
        };
      else
        load_value == 4'h0;
    }

    function string convert2string();
      return $sformatf("command=%s load=0x%0h observed=0x%0h",
                       command.name(), load_value, observed_count);
    endfunction
  endclass

  class counter_generator;
    mailbox #(counter_transaction) output_mb;
    int unsigned seed;

    function new(
      mailbox #(counter_transaction) output_mb,
      int unsigned seed = 32'hC017_2026
    );
      this.output_mb = output_mb;
      this.seed = seed;
    endfunction

    task run(input int unsigned item_count);
      counter_transaction item;

      for (int unsigned index = 0; index < item_count; index++) begin
        item = new();
        item.srandom(seed + index);

        if (index == 0) begin
          assert ((item.randomize() with {
            command == CMD_LOAD;
            load_value == 4'h0;
          }) == 1) else $fatal(1, "Could not generate load-zero item");
        end
        else if (index == 1) begin
          assert ((item.randomize() with {
            command == CMD_LOAD;
            load_value == 4'hF;
          }) == 1) else $fatal(1, "Could not generate load-maximum item");
        end
        else if (index == 2) begin
          assert ((item.randomize() with {
            command == CMD_COUNT;
          }) == 1) else $fatal(1, "Could not generate wrap item");
        end
        else begin
          assert (item.randomize() == 1)
            else $fatal(1, "Randomization failed at item %0d", index);
        end

        output_mb.put(item);
      end

      item = new();
      item.stop = 1'b1;
      output_mb.put(item);
    endtask
  endclass

  class counter_driver;
    virtual counter_if.DRV vif;
    mailbox #(counter_transaction) input_mb;

    function new(
      virtual counter_if.DRV vif,
      mailbox #(counter_transaction) input_mb
    );
      this.vif = vif;
      this.input_mb = input_mb;
    endfunction

    task drive_idle();
      vif.drv_cb.load       <= 1'b0;
      vif.drv_cb.enable     <= 1'b0;
      vif.drv_cb.load_value <= '0;
    endtask

    task drive_item(counter_transaction item);
      @(vif.drv_cb);
      case (item.command)
        CMD_LOAD: begin
          vif.drv_cb.load       <= 1'b1;
          vif.drv_cb.enable     <= 1'b0;
          vif.drv_cb.load_value <= item.load_value;
        end
        CMD_COUNT: begin
          vif.drv_cb.load       <= 1'b0;
          vif.drv_cb.enable     <= 1'b1;
          vif.drv_cb.load_value <= '0;
        end
        default: begin
          drive_idle();
        end
      endcase
    endtask

    task run();
      counter_transaction item;
      forever begin
        input_mb.get(item);
        if (item.stop) begin
          @(vif.drv_cb);
          drive_idle();
          break;
        end
        drive_item(item);
      end
    endtask
  endclass

  class counter_scoreboard;
    logic [3:0] model;
    int unsigned match_count;
    int unsigned mismatch_count;

    function new();
      model = '0;
    endfunction

    function void check(counter_transaction observed);
      case (observed.command)
        CMD_LOAD:  model = observed.load_value;
        CMD_COUNT: model = model + 4'd1;
        default:   model = model;
      endcase

      if (observed.observed_count !== model) begin
        mismatch_count++;
        $error("Scoreboard mismatch: %s expected=0x%0h",
               observed.convert2string(), model);
      end
      else begin
        match_count++;
      end
    endfunction
  endclass

  class counter_coverage;
    covergroup behavior_cg with function sample(
      counter_command_e command,
      logic [3:0] load_value,
      logic [3:0] observed_count
    );
      option.per_instance = 1;

      command_cp: coverpoint command {
        bins hold  = {CMD_HOLD};
        bins count = {CMD_COUNT};
        bins load  = {CMD_LOAD};
      }

      load_value_cp: coverpoint load_value iff (command == CMD_LOAD) {
        bins zero    = {4'h0};
        bins middle  = {[4'h1:4'hE]};
        bins maximum = {4'hF};
      }

      observed_cp: coverpoint observed_count {
        bins zero    = {4'h0};
        bins middle  = {[4'h1:4'hE]};
        bins maximum = {4'hF};
      }

      command_observed_cross: cross command_cp, observed_cp;
    endgroup

    function new();
      behavior_cg = new();
    endfunction

    function void sample(counter_transaction observed);
      behavior_cg.sample(observed.command, observed.load_value,
                         observed.observed_count);
    endfunction

    function real get_coverage();
      return behavior_cg.get_inst_coverage();
    endfunction
  endclass

  class counter_monitor;
    virtual counter_if.MON vif;
    counter_scoreboard scoreboard;
    counter_coverage coverage;

    function new(
      virtual counter_if.MON vif,
      counter_scoreboard scoreboard,
      counter_coverage coverage
    );
      this.vif = vif;
      this.scoreboard = scoreboard;
      this.coverage = coverage;
    endfunction

    task run(input int unsigned item_count);
      counter_transaction observed;

      @(negedge vif.clk);
      repeat (item_count) begin
        @(vif.mon_cb);
        observed = new();
        if (vif.mon_cb.load)
          observed.command = CMD_LOAD;
        else if (vif.mon_cb.enable)
          observed.command = CMD_COUNT;
        else
          observed.command = CMD_HOLD;

        observed.load_value    = vif.mon_cb.load_value;
        observed.observed_count = vif.mon_cb.count;
        scoreboard.check(observed);
        coverage.sample(observed);
      end
    endtask
  endclass

  class counter_environment;
    mailbox #(counter_transaction) channel;
    counter_generator  generator;
    counter_driver     driver;
    counter_monitor    monitor;
    counter_scoreboard scoreboard;
    counter_coverage   coverage;

    function new(virtual counter_if vif);
      channel    = new(4);
      scoreboard = new();
      coverage   = new();
      generator  = new(channel);
      driver     = new(vif, channel);
      monitor    = new(vif, scoreboard, coverage);
    endfunction

    task run(input int unsigned item_count);
      fork
        generator.run(item_count);
        driver.run();
        monitor.run(item_count);
      join
    endtask
  endclass
endpackage
