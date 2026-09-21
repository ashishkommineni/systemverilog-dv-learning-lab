# Topic index

This index is a fast map from a SystemVerilog question to the lesson that explains and demonstrates it.

## Language and RTL semantics

| Topic | Location |
|---|---|
| Two-state and four-state values | 01 language fundamentals |
| logic, bit, int, string | 01 language fundamentals |
| Packed and unpacked dimensions | 01 language fundamentals |
| enum, typedef, packed struct, packed union | data_types_demo.sv |
| Sizing, signedness, reductions, shifts | operators_casting_demo.sv |
| Static cast and system cast | operators_casting_demo.sv |
| inside operator | operators_casting_demo.sv |
| == versus === | 01 language fundamentals |
| always_comb and always_ff | procedural_demo.sv |
| Blocking and nonblocking scheduling | 01 language fundamentals |
| Asynchronous reset | procedural_demo.sv and counter_dut.sv |
| Tasks and functions | tasks_functions_demo.sv |
| input, output, ref arguments | tasks_functions_demo.sv |
| Automatic lifetime | tasks_functions_demo.sv |
| Parameters and width reuse | counter_dut.sv |

## Collections

| Topic | Location |
|---|---|
| Fixed arrays | arrays_demo.sv |
| Dynamic arrays and new[N] | arrays_demo.sv |
| Queues and push/pop | arrays_demo.sv |
| Associative arrays, exists, num | arrays_demo.sv |
| foreach | arrays_demo.sv and constraint examples |
| Reduction, locator, and ordering methods | 02 arrays and collections guide |
| In-order and out-of-order scoreboard choices | 02 guide and interview Q&A |

## Object-oriented programming

| Topic | Location |
|---|---|
| Class handles, null, new | oop_demo.sv |
| Constructor and super.new | oop_demo.sv |
| Inheritance | oop_demo.sv |
| Virtual methods and polymorphism | oop_demo.sv |
| public, protected, local | 03 OOP guide |
| Static properties and class scope | oop_demo.sv |
| Handle aliasing | oop_demo.sv |
| Shallow versus deep copy | oop_demo.sv |
| Parameterized classes and type parameters | parameterized_scoreboard.sv |
| Checked down-cast with $cast | 03 OOP guide |

## Randomization

| Topic | Location |
|---|---|
| rand and randc | constraints_demo.sv |
| inside and range lists | constraints_demo.sv |
| dist weighting | constraints_demo.sv |
| Implication and conditional constraints | constraints_demo.sv |
| Dynamic-array size and foreach constraints | constraints_demo.sv |
| solve before | constraints_demo.sv |
| soft defaults and inline overrides | constraints_demo.sv |
| pre_randomize and post_randomize | constraints_demo.sv |
| srandom and repeatability | constraints_demo.sv |
| Expected randomize failure | constraints_demo.sv |
| Constraint/rand mode control | 04 randomization guide |

## Processes and communication

| Topic | Location |
|---|---|
| fork/join | processes_demo.sv |
| join_any and timeout cleanup | processes_demo.sv |
| join_none and wait fork | processes_demo.sv |
| disable fork scope | 05 concurrency guide |
| Events and missed-trigger behavior | ipc_demo.sv and 05 guide |
| Typed bounded mailbox | ipc_demo.sv |
| Blocking put/get | ipc_demo.sv |
| Semaphore key ownership | ipc_demo.sv |
| Process handles and states | 05 concurrency guide |

## Connectivity and race avoidance

| Topic | Location |
|---|---|
| Interface | interface_demo.sv |
| Modport | interface_demo.sv |
| Clocking block | interface_demo.sv |
| Input/output skew | 06 interfaces guide |
| Virtual interface | virtual_interface_demo.sv |
| Package, import, and scope | interface_demo.sv |
| Driver/monitor clocking separation | counter_if.sv |

## Assertions

| Topic | Location |
|---|---|
| Immediate assertion | assertions_demo.sv |
| Concurrent property | assertions_demo.sv |
| Overlapped and non-overlapped implication | 07 assertions guide |
| disable iff | assertions_demo.sv |
| Delay and repetition operators | 07 assertions guide |
| $past and $isunknown | assertions_demo.sv |
| $rose, $fell, $stable, $changed | 07 assertions guide |
| Cover property and vacuity | assertions_demo.sv and 07 guide |
| bind | bind_demo.sv |
| Interface-local SVA | counter_if.sv |

## Functional coverage

| Topic | Location |
|---|---|
| Covergroup construction and sample | coverage_demo.sv |
| Coverpoint and explicit bins | coverage_demo.sv |
| Range and transition bins | coverage_demo.sv |
| ignore_bins and illegal_bins | coverage_demo.sv |
| Cross coverage | coverage_demo.sv |
| Per-instance coverage | coverage_demo.sv |
| Coverage-driven plan for a project | 08 mini verification project |

## Verification architecture

| Topic | Location |
|---|---|
| Transaction | counter_tb_pkg.sv |
| Generator | counter_tb_pkg.sv |
| Driver | counter_tb_pkg.sv |
| Pin-level monitor | counter_tb_pkg.sv |
| Independent reference model | counter_tb_pkg.sv |
| Scoreboard | counter_tb_pkg.sv |
| Coverage collector | counter_tb_pkg.sv |
| Environment and end-of-test | counter_tb_pkg.sv and tb_top.sv |
| Directed boundary plus random traffic | counter_generator |
| Requirement-to-check-to-coverage trace | 08 README |

## Practice and debugging

The interview chapter includes 32 spoken answers and 10 debugging exercises covering types, scheduling, classes, constraints, concurrency, interfaces, SVA, coverage, and architecture.

## Deliberate boundary

This repository focuses on SystemVerilog used directly in RTL and class-based verification. UVM is kept in a separate learning repository so phase, factory, sequence, and TLM concepts do not hide the language fundamentals. DPI-C, PLI/VPI, mixed-language integration, and tool-specific coverage APIs are also outside this practical core and are not falsely labeled as covered.
