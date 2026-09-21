# 01 — Language fundamentals

## Learning objective

Build a precise mental model for values, shapes, time, and subroutines before using classes or UVM.

## What

SystemVerilog extends Verilog with richer types and clearer procedural intent.

- **bit** is a two-state variable: 0 or 1.
- **logic** is a four-state variable: 0, 1, X, or Z.
- A **packed** declaration is one contiguous vector of bits and supports slicing and arithmetic.
- An **unpacked** declaration is a collection of separate elements.
- **enum** gives state encodings readable names.
- **struct** groups fields; a packed struct can travel as one vector.
- **union** lets several views share the same storage.
- **always_comb**, **always_ff**, and **always_latch** communicate the intended hardware model.
- A **function** returns without consuming simulation time. A **task** may have multiple outputs and may consume time.

## Why

Most “mysterious” SystemVerilog bugs are type or scheduling bugs. A value can have the correct visible bits but the wrong signedness. A signal can be sampled one scheduler region too early. An unpacked array cannot always be assigned like a packed vector. Clear types and intent-specific procedural blocks move those failures closer to the line that caused them.

## How

### Two-state versus four-state

Use four-state logic at RTL boundaries and wherever X/Z carries debugging meaning. Two-state bit is useful in abstract data models when unknowns are not meaningful. Assigning X or Z to a two-state variable loses that information.

The four_state_demo example is deliberately kept out of the portable two-state run. On a four-state simulator it proves the conversion:

~~~systemverilog
logic four_state = 1'bx;
bit   two_state  = four_state; // converts X to 0
~~~

### Packed versus unpacked

Read dimensions from the identifier outward:

~~~systemverilog
logic [7:0] lane [4];
~~~

lane is an unpacked array of four elements; every element is an eight-bit packed vector.

### Equality operators

- == and != are logical equality. An X/Z in either operand may make the result unknown.
- === and !== are case equality. X and Z are compared as literal values, so the result is always 0 or 1.

Use case equality when a checker intentionally needs to detect unknowns. Do not hide accidental X propagation by using it everywhere.

### Blocking versus nonblocking assignment

- Use blocking assignment for local procedural calculation and combinational logic.
- Use nonblocking assignment for state updated on a clock.

At a clock edge, a nonblocking assignment evaluates its right-hand side now and schedules the left-hand-side update for the NBA region. That is why multiple flops observe the old state consistently.

### Function versus task

A function is ideal for a pure calculation used by a constraint, assertion, or scoreboard. A task is better for an action such as driving a bus item, waiting for an edge, or returning several results.

Argument directions matter:

- input copies a value into the subroutine;
- output copies a final value out;
- inout copies in and then out;
- ref aliases the caller's variable immediately.

## Where

- Packed structs make readable bus transactions.
- Enums describe FSM states and transaction kinds.
- Automatic functions implement reference-model calculations.
- always_ff makes accidental multi-driver state updates easier for tools to flag.
- Case equality is useful in reset/X checks.

## Examples

| File | Focus | Support |
|---|---|---|
| data_types_demo.sv | enum, packed struct/union, packed and unpacked data | Portable run |
| four_state_demo.sv | X preservation and two-state conversion | Four-state simulator |
| operators_casting_demo.sv | sizing, signed cast, reductions, inside | Portable run |
| procedural_demo.sv | always_comb, always_ff, blocking/NBA behavior | Portable run |
| tasks_functions_demo.sv | automatic function, task, output and ref arguments | Portable run |

## Code walkthrough: procedural_demo

1. next_q is computed in always_comb with a blocking assignment.
2. q changes only in always_ff.
3. The asynchronous reset provides a known starting state.
4. The test enables an update and checks q after the NBA update has completed.
5. The test disables updates, changes the input, and proves q holds.

## Common mistakes

- Writing logic [3:0] a [7:0] and assuming it is a 32-bit packed number.
- Comparing a possibly unknown signal with == and treating an X result as false evidence.
- Using a nonblocking assignment in a combinational block and creating delta-cycle surprises.
- Forgetting signed casts when combining signed and unsigned operands.
- Declaring a task static when two concurrent callers need independent local storage.

## Quick interview answer

**Why is nonblocking assignment used in sequential logic?**  
It models simultaneous register updates. Every right-hand side is sampled in the active region, and the left-hand sides update later in the NBA region. That prevents one clocked block from seeing another register's new value simply because the simulator executed that block first.

## Follow-up questions

1. Can logic have multiple drivers?  
   The logic type itself does not guarantee a single driver. Procedural and net driving rules still apply; intent-specific blocks and lint help enforce discipline.

2. Is int always synthesizable?  
   It can be, but it is a 32-bit signed type and may infer more hardware than intended. Explicit packed widths are clearer in RTL.

3. Why can === be dangerous in normal functional checking?  
   It can make two matching X values look “equal,” masking the fact that both sides are unknown.
