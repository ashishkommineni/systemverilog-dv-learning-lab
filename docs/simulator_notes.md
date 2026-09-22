# Simulator notes

SystemVerilog is one language, but simulators implement different portions of the verification feature set.

| Feature group | Verilator portable suite | Cadence Xcelium suite |
|---|---:|---:|
| Data types, functions, arrays | Run | Run |
| Classes and polymorphism | Run | Run |
| Interfaces and clocked RTL | Run | Run |
| Basic concurrent assertions | Run with assertion support; explicit `##` cover sequence excluded on Verilator 5.020 | Run |
| Constrained randomization | Source-only in portable suite | Run |
| Mailbox, semaphore, process control | Source-only in portable suite | Run |
| Covergroups and coverage crosses | Source-only in portable suite | Run with coverage |
| Complete class-based mini environment | DUT/SVA smoke run; class/covergroup path excluded | Run with coverage |

## Verilator

The portable script invokes:

~~~sh
verilator --binary --timing --assert -Wall -Wno-fatal
~~~

Each example uses a separate build directory, so top-module names and generated files cannot collide.
The assertion lesson keeps its `request ##1 grant` cover sequence in the source
for Xcelium and other full-featured simulators. The `VERILATOR` path omits that
single cover statement because the stable Ubuntu package (5.020) does not
implement sequence delays inside `cover property`; the executable assertions
and the two-handshake end check still run.

## Cadence Xcelium

The complete script invokes:

~~~sh
xrun -64bit -sv -access +rwc -clean source.sv
~~~

Coverage-oriented examples add:

~~~sh
-coverage all -covoverwrite
~~~

The local authoring environment used for the checked-in report did not contain Xcelium. Therefore, Xcelium commands and expected results are documented, while only the portable runs are marked as executed. Run make xcelium on a licensed machine to create your own transcript and coverage database.

## Version-independent habits

- Compile each lesson separately.
- Treat warnings as review items.
- Use a fixed seed while debugging and record it with a failing test.
- Keep build products outside the source tree.
- Never commit tool databases merely to make a repository look “complete.”
