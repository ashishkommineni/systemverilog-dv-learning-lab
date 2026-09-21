# 07 — Assertions and functional coverage

## Learning objective

Turn specification sentences into executable checks, then measure whether stimulus reached the intended scenarios.

## What

Assertions answer: “Did the implementation obey this rule?”

Functional coverage answers: “Did the test exercise this planned behavior?”

They are complementary. An assertion can pass because its antecedent never occurred. A coverpoint can reach 100 percent while the observed behavior is wrong. Good verification needs both.

## Why

A scoreboard usually checks end-to-end data correctness. Assertions are better for local temporal rules such as:

- a request must receive a grant one cycle later;
- valid must remain asserted until ready;
- a FIFO may not read when empty;
- an address must be aligned when a transfer is accepted.

Coverage converts a written test plan into measurable bins: opcodes, boundaries, transitions, and combinations.

## How

### Immediate assertion

An immediate assertion evaluates now, inside procedural code:

~~~systemverilog
assert (count <= DEPTH) else $fatal(1, "overflow");
~~~

It is well suited to algorithm results and state invariants checked at a known point.

### Concurrent assertion

A concurrent assertion samples on a clock and evaluates a temporal property:

~~~systemverilog
property request_gets_grant;
  @(posedge clk) disable iff (!rst_n)
    request |=> grant;
endproperty
~~~

- |-> is overlapped implication: the consequent starts in the same sampled cycle.
- |=> is non-overlapped implication: the consequent starts one cycle later.
- disable iff cancels active attempts and disables new evaluation while reset is active.

### Sequences and repetition

Common operators include:

- ##N: delay N sampled clock ticks;
- [*N]: consecutive repetition;
- [=N]: nonconsecutive repetition;
- throughout: an expression holds for an entire sequence;
- until/ until_with: hold until termination.

Keep the property close to the English requirement. A clever one-line expression is not better if reviewers cannot confirm its timing.

### Sampled-value functions

- $past(expr): previously sampled value;
- $rose(expr), $fell(expr): sampled transitions;
- $stable(expr), $changed(expr): compare with the previous sample;
- $isunknown(expr): detect X/Z.

Guard $past when no valid previous sample exists, commonly with reset or a valid-history flag.

### Bind

bind attaches a checker without editing the DUT source. This is valuable for third-party RTL and reusable protocol checkers. The checker still needs correctly connected clocks, resets, and signals.

### Covergroups

A covergroup contains coverpoints and crosses.

- explicit bins map meaningful values or ranges;
- transition bins measure ordered behavior;
- ignore_bins removes combinations outside the plan;
- illegal_bins flags a forbidden sample, but an assertion is usually the stronger choice for protocol legality;
- crosses measure planned combinations.

Coverage closure is not “add broad auto bins until the number rises.” Every bin should trace to verification intent.

## Where

- interface protocol timing;
- FIFO safety and ordering conditions;
- reset convergence;
- opcode/length/error scenario coverage;
- state-transition coverage;
- end-to-end data checking alongside a scoreboard.

## Code walkthrough

assertions_demo creates a one-cycle request/grant exchange. Three properties check latency, causal history, and known control values. The stimulus creates two correct handshakes and an immediate final-state check.

coverage_demo uses a covergroup sample function so the sampling point is explicit. It includes value bins, length ranges, a transition bin, ignore/illegal bins, and a cross.

bind_demo attaches a request/acknowledge checker to a DUT instance without placing assertion source inside the DUT.

## Common mistakes

- Reversing |-> and |=> and checking the wrong cycle.
- Forgetting disable iff during reset.
- Reading unsampled procedural values while reasoning as if they were SVA sampled values.
- Calling $past on the first active clock without a history guard.
- Declaring bins but never calling sample or never enabling automatic sampling.
- Treating illegal_bins as the only checker for illegal behavior.
- Reporting aggregate coverage without reviewing holes and exclusions.

## Quick interview answer

**Assertion coverage versus functional coverage?**  
Assertion coverage reports activity and success/failure of properties: attempts, passes, vacuous behavior, and failures depending on the tool. Functional coverage measures user-defined data and scenario bins. Assertion coverage tells whether temporal checks were exercised; functional coverage tells whether planned stimulus space was sampled.

## Follow-up questions

1. What is vacuous success?  
   An implication can pass because its antecedent never became true. The consequent was never required.

2. Why use bind?  
   It attaches reusable checks to RTL without modifying the RTL source and can target a module type or specific instance.

3. Should illegal behavior be modeled only with illegal_bins?  
   Usually no. Use an assertion for a precise failure message and temporal context; use coverage only when it adds useful measurement.
