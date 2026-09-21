# 06 — Interfaces and packages

## Learning objective

Separate connectivity, timing discipline, and reusable declarations so a testbench scales without long port lists or race-prone signal access.

## What

An interface bundles related signals and can also contain tasks, functions, assertions, and clocking blocks. A modport exposes a named view of that interface. A virtual interface lets a class hold a reference to a concrete interface instance.

A package is a namespace for shared declarations such as:

- typedefs and enums;
- parameters;
- functions;
- classes;
- covergroups.

## Why

A protocol agent may need twenty DUT signals. Repeating twenty ports across a driver, monitor, assertions, and DUT wrapper creates connection mistakes. One interface instance makes the protocol boundary explicit.

Even with correct wires, testbench and DUT code can race at the clock edge. A clocking block defines when the testbench samples inputs and drives outputs relative to its clock event.

Packages prevent type duplication. If a transaction kind is declared separately in a driver and scoreboard, those declarations may look identical but still be different types.

## How

### Interface instance

~~~systemverilog
counter_if bus_if(clk);
counter dut(.bus(bus_if));
~~~

The interface is static elaborated hardware-like connectivity.

### Modports

A DUT modport might declare request signals as inputs and response signals as outputs. A monitor modport can expose everything as input. Modports document and enforce access intent; they do not create new signals.

### Clocking blocks

~~~systemverilog
clocking driver_cb @(posedge clk);
  default input #1step output #0;
  output valid, data;
  input ready;
endclocking
~~~

The testbench samples ready just before the edge and drives valid/data in the declared output region. This avoids depending on arbitrary active-region process order.

### Virtual interface

A class does not have normal module ports. It stores a virtual handle:

~~~systemverilog
class driver;
  virtual counter_if.driver vif;
endclass
~~~

The environment assigns a real interface instance before the driver uses it. A null virtual interface is a configuration error and should fail early.

### Packages

Compile a package before files that import it. Prefer explicit imports in large projects:

~~~systemverilog
import counter_types_pkg::operation_e;
~~~

Wildcard import is concise for a small lesson but can make name collisions harder to locate in a large environment.

## Where

- protocol signal bundles;
- driver and monitor timing;
- reusable assertions attached to one interface;
- transaction/configuration type packages;
- class-based agents using virtual interfaces.

## Code walkthrough

interface_demo keeps its package, interface, RTL counter, and test in one source so the portable command is obvious.

1. counter_types_pkg defines the operation enum and reference function.
2. counter_if groups reset, enable, value, and two clocking blocks.
3. The dut modport constrains RTL directions.
4. tiny_counter updates value in always_ff.
5. The test drives three enabled cycles and one hold cycle.
6. The package function calculates the expected value for each check.

virtual_interface_demo shows the class hand-off separately. It is intended for a full event-driven simulator.

## Common mistakes

- Forgetting to assign a virtual interface before run-time use.
- Reversing modport direction from the component's point of view.
- Sampling raw interface signals at the same edge as the DUT instead of through a clocking block.
- Compiling an importing file before its package.
- Declaring the same enum in two packages and assuming assignment is type-compatible.
- Using a wildcard package import in every scope and creating ambiguous names.

## Quick interview answer

**Interface versus virtual interface?**  
An interface is a statically elaborated instance that contains signals and timing constructs. A virtual interface is a variable-sized handle used by class-based code to refer to that existing instance. The virtual interface does not create hardware or signals.

## Follow-up questions

1. Does a modport determine physical signal direction?  
   It restricts the view from the component using that modport; the underlying interface signals remain the same objects.

2. Why use input #1step in a monitor clocking block?  
   It samples immediately before the clock event, giving a stable pre-edge value and avoiding active-region races.

3. Can a package contain module instances?  
   No. Packages hold declarations, not elaborated design hierarchy.
