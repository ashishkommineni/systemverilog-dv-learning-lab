# 04 — Randomization and constraints

## Learning objective

Generate legal, targeted, reproducible stimulus and recognize when the constraint model—not the simulator—is the bug.

## What

Constrained random verification separates two concerns:

- rand and randc identify variables the solver may choose;
- constraint blocks describe legal relationships between those variables.

randomize returns one on success and zero when no solution exists. Treat that return value as part of the test, never as optional decoration.

## Why

Directed tests prove known scenarios. Constrained random tests explore combinations a human may not list: length boundaries, command/address interactions, back-to-back channels, or error modes. Constraints keep that exploration meaningful and protocol-legal.

Randomization is not a substitute for a test plan. Coverage tells you whether the solver reached the intended scenarios.

## How

### rand and randc

- rand chooses a legal value on each successful solve.
- randc cycles through legal values before repeating, subject to constraints and implementation rules.

Use randc for a small domain such as a channel number. It is not a replacement for coverage and can become expensive for large domains.

### Common constraint forms

~~~systemverilog
constraint legal_c {
  length inside {[2:16]};
  opcode inside {READ, WRITE};
  write -> byte_enable != 0;
}
~~~

- inside expresses sets and ranges.
- dist adds relative weights.
- implication A -> B applies B only when A is true.
- if/else handles multi-branch relationships.
- foreach constrains collection elements.
- solve before influences solve order and distribution; it does not override legality.
- soft supplies a default that an inline hard constraint may replace.

### Inline constraints

Inline constraints target one scenario without permanently editing the class:

~~~systemverilog
assert(item.randomize() with { length == 8; });
~~~

Class constraints and inline constraints are combined. An inline constraint only overrides a class default when that class constraint is soft; two conflicting hard constraints make the solve fail.

### Constraint control

constraint_mode(0) disables a named block. rand_mode(0) freezes a variable at its current value. Use both carefully and restore them after a negative test, because state can leak into later stimulus.

### Hooks

pre_randomize runs before solving; post_randomize runs after a successful solve. Useful jobs include allocating dependent objects, calculating a checksum, or recording solve attempts. A post_randomize method must not silently change a value in a way that violates the constraints just solved.

### Reproducibility

Capture the test seed. During debug, rerun the same seed and transaction count. Do not print only “random failure”; print the seed and a transaction representation.

## Where

- legal packet lengths and payload bytes;
- weighted normal/error traffic;
- aligned addresses;
- burst-size/burst-length relationships;
- focused boundary tests through inline constraints.

## Code walkthrough

constraints_demo models a packet with:

- a small randc channel;
- weighted packet lengths;
- an opcode set;
- a payload whose size equals length;
- an error mode that requires opcode 4;
- solve-before ordering;
- a soft default length;
- pre/post hooks.

The test first overrides the soft length, then enables error injection, and finally asks for a value outside the hard legal range. The last randomize call must fail; that failure is expected and checked.

## Common mistakes

- Ignoring the boolean return of randomize.
- Writing an over-constrained model and repeatedly changing the seed.
- Assuming solve before makes an illegal combination legal.
- Using dist weights as exact percentages in a small sample.
- Depending on randomize call order without recording the seed.
- Editing randomized fields after post_randomize and invalidating the generated scenario.

## Quick interview answer

**What is the difference between soft and normal constraints?**  
A normal constraint is hard: it must hold together with every other enabled constraint. A soft constraint is a default preference that is dropped when a conflicting hard constraint—often an inline test constraint—requires another legal value.

## Follow-up questions

1. Why can randomize fail?  
   The enabled hard constraints have no common solution, an array size conflicts with element constraints, or a frozen variable already holds an illegal value.

2. Does dist guarantee exact percentages?  
   No. It defines relative selection weights; measured frequencies approach the relationship over a sufficiently large sample.

3. When is solve before useful?  
   When distribution depends on choice order, such as choosing an opcode first and then selecting a legal length for that opcode.
