# SystemVerilog DV Learning Lab

A practical, example-first notebook for learning SystemVerilog as a design-verification engineer.

I built this repository around one rule: every concept should answer five questions before it becomes “notes”:

1. What problem does it solve?
2. Why does a verification engineer care?
3. How does the language feature behave?
4. Where would I use it in a real testbench?
5. What mistake is most likely to appear in an interview or simulation?

The examples are intentionally small enough to read in one sitting, but they are not disconnected syntax snippets. The final chapter combines transactions, a generator, driver, monitor, scoreboard, interface, clocking blocks, constraints, assertions, and functional coverage into one verification environment.

> Scope: this is a broad practical curriculum for SystemVerilog design verification. It is not a replacement for the IEEE 1800 Language Reference Manual.

Looking for one construct quickly? Use the [topic index](docs/topic_index.md).

## Learning path

| Chapter | Topics | Main result |
|---|---|---|
| 01 — Language fundamentals | 2-state/4-state types, packed/unpacked data, enum, struct, union, operators, casting, procedural blocks, blocking/nonblocking assignments, tasks and functions | A reliable mental model for RTL and testbench code |
| 02 — Arrays and collections | Fixed, dynamic, associative arrays, queues, array methods, foreach | Choosing the correct data structure for a scoreboard or stimulus model |
| 03 — Object-oriented programming | Handles, objects, constructors, inheritance, virtual methods, polymorphism, encapsulation, static members, shallow/deep copy | Transaction modeling without handle-alias bugs |
| 04 — Randomization and constraints | rand/randc, inside, dist, implication, if/else, foreach, solve before, soft, pre/post_randomize, inline constraints | Legal, reproducible stimulus with negative-test control |
| 05 — Concurrency and IPC | fork/join variants, process lifetime, events, mailboxes, semaphores | Coordinating independent testbench components without races |
| 06 — Interfaces and packages | Interfaces, modports, clocking blocks, virtual interfaces, packages, parameterized classes | Clean DUT connectivity and reusable types |
| 07 — Assertions and coverage | Immediate/concurrent SVA, implication, repetition, disable iff, sampled-value functions, covergroups, bins, transitions, crosses, ignore/illegal bins, bind | Checking behavior and measuring intent |
| 08 — Mini verification project | Transaction, generator, driver, monitor, scoreboard, environment, constrained stimulus, SVA, functional coverage | A complete non-UVM counter verification environment |
| 09 — Interview practice | Spoken answers, traps, follow-ups, debugging questions | Revision material that explains reasoning, not memorized lines |

## Repository map

~~~text
systemverilog-dv-learning-lab/
├── lessons/
│   ├── 01_language_fundamentals/
│   ├── 02_arrays_collections/
│   ├── 03_oop/
│   ├── 04_randomization_constraints/
│   ├── 05_concurrency_ipc/
│   ├── 06_interfaces_packages/
│   ├── 07_assertions_coverage/
│   ├── 08_mini_verification_project/
│   └── 09_interview_practice/
├── docs/
├── scripts/
├── Makefile
└── README.md
~~~

Each technical chapter contains:

- a concept guide written as WHAT → WHY → HOW → WHERE → EXAMPLE;
- runnable SystemVerilog source;
- the expected console output;
- common mistakes and short interview questions;
- a clear simulator-support label.

## Run the verified portable examples

Requirements:

- GNU Make
- Verilator 5.x
- a C++ compiler

~~~sh
make check
~~~

This performs the repository structure checks and runs the portable examples. A successful run ends with:

~~~text
Portable suite: 9/9 PASS
Repository checks: PASS
~~~

To run only the examples:

~~~sh
make portable
~~~

## Run the complete language examples with Xcelium

Cadence Xcelium supports the constraint and covergroup examples that an open-source smoke simulator may not fully support.

~~~sh
make xcelium
~~~

The script uses a fresh output directory and runs each example independently. See [Simulator notes](docs/simulator_notes.md) for the exact support boundary.

## What was checked

The checked-in source was reviewed in three layers:

1. **Structure:** every lesson has a guide, source, and expected output.
2. **Syntax:** every SystemVerilog file passes a SystemVerilog parser.
3. **Execution:** the portable suite compiles and runs with assertions enabled.

The exact commands and results are recorded in [Verification report](docs/verification_report.md). Xcelium-specific examples are supplied with commands and expected results, but this repository never labels them “executed” unless an Xcelium transcript exists.

## A note on style

These notes and examples were written specifically for this learning path. The code uses meaningful names, short checks, and comments that explain decisions. Generated simulator databases, waveforms, backup files, and tool logs are deliberately excluded from version control.

## License

MIT License. See [LICENSE](LICENSE).
