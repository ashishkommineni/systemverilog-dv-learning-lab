# 08 — Mini verification project

## Goal

Verify a parameterized up-counter with a small class-based SystemVerilog environment. This chapter connects the language features from earlier chapters without hiding the data flow behind a framework.

## DUT specification

The counter is WIDTH bits wide and updates on the rising clock edge.

| Priority | Condition | Required result |
|---:|---|---|
| 1 | rst_n is low | count becomes zero |
| 2 | load is high | count becomes load_value |
| 3 | enable is high | count increments with natural WIDTH-bit wrap |
| 4 | otherwise | count holds |

If load and enable are both high, load wins.

## Verification plan

| Feature | Stimulus | Checker | Coverage |
|---|---|---|---|
| Reset | Two reset cycles before traffic | Immediate zero check | Reset is deterministic setup |
| Load | Random loads plus forced zero and maximum | Reference-model compare; load SVA | Command and load-value bins |
| Increment | Weighted count commands | Reference-model compare; count SVA | Command × observed boundary cross |
| Hold | Weighted hold commands | Reference-model compare; hold SVA | Command bin |
| Wrap | Load maximum, then count | Reference model and count SVA | Zero/maximum observed bins |
| Priority | Command encoding drives mutually exclusive load/enable | Model plus local assertion opportunity | Load command samples |

## Architecture

The transaction path is:

1. **Generator** randomizes a counter_transaction and puts it in a typed mailbox.
2. **Driver** receives the transaction and drives the interface on the falling edge.
3. **DUT** accepts the command on the next rising edge.
4. **Monitor** samples the command and updated result through a clocking block.
5. **Scoreboard** updates an independent reference count and compares it with the observed count.
6. **Coverage collector** samples the same monitored transaction.
7. **Interface assertions** independently check temporal update rules.

This separation matters. The scoreboard does not read generator predictions, so a driver mapping error can still be detected from monitored pins.

## File map

| File | Responsibility |
|---|---|
| counter_dut.sv | Synthesizable parameterized DUT |
| counter_if.sv | Signals, clocking blocks, modports, SVA |
| counter_tb_pkg.sv | Transaction, generator, driver, monitor, scoreboard, coverage, environment |
| tb_top.sv | Clock/reset, construction, run control, final checks |
| counter_portable_smoke.sv | Small open-source executable smoke test |
| filelist.f | Xcelium compile order |
| expected_output.txt | Stable result lines |

## Constraints

The generator uses a weighted command distribution: count is common, while load and hold still occur. The first three transactions are deliberately focused:

1. load zero;
2. load maximum;
3. count once, forcing wrap to zero.

The remaining transactions are constrained random. This combines guaranteed boundary intent with broader exploration.

## Assertions

The interface checks:

- load causes the previous load_value to appear;
- enabled count increments by one with WIDTH-bit wrap;
- hold preserves the previous count;
- control signals are never X/Z after reset.

Assertions are written against pins, not transaction objects. They remain useful even if the class environment is replaced.

## Coverage

The covergroup measures:

- hold, count, and load commands;
- zero, middle, and maximum load values;
- zero, middle, and maximum observed counts;
- command × observed-count cross.

The reported percentage is a diagnostic, not the pass condition. A short random run is not expected to close every cross bin.

## End-of-test rules

The test passes only when:

- the monitor observed the requested transaction count;
- the scoreboard has zero mismatches;
- its match count equals the requested count;
- no assertion terminated simulation.

## Run

Portable DUT/SVA smoke:

~~~sh
make portable
~~~

Full class, constraints, assertions, and covergroup environment:

~~~sh
xrun -64bit -sv -access +rwc -coverage all -covoverwrite -f lessons/08_mini_verification_project/filelist.f
~~~

## Common mistakes this project avoids

- Sending the original randomized object and then re-randomizing it before the consumer is done.
- Letting the scoreboard use generator data instead of monitored interface data.
- Sampling count before the DUT's nonblocking update.
- Ending simulation before the last temporal assertion resolves.
- Making random boundary coverage probable instead of guaranteed.
- Treating a nonzero coverage percentage as proof of correctness.

## Interview explanation

“I used a pin-level monitor as the source of truth. It reconstructs the accepted command and sends it to an independent reference model. The scoreboard checks data behavior, SVA checks cycle relationships, and the covergroup measures whether command and boundary scenarios were exercised. I also forced zero, maximum, and wrap cases before random traffic, so important boundaries do not depend on the seed.”
