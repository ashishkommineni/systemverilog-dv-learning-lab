# SystemVerilog questions and answers

## 1. wire versus logic

**Answer:** wire is a net and represents connectivity; it is driven by continuous assignments, module outputs, or primitives. logic is a four-state variable data type and can be written procedurally. In modern SystemVerilog, logic replaces many old reg declarations, but it does not mean “always a register,” and it does not automatically make multiple drivers legal.

**Follow-up:** Can an output logic be driven by assign?  
Tool and declaration context matter, but the clean rule is to use a net for continuous multi-source connectivity and a variable for procedural ownership. Avoid mixing drivers.

## 2. Two-state versus four-state types

**Answer:** bit, byte, int, and related types have specific state rules; bit is two-state, while logic/reg are four-state. Four-state modeling preserves X and Z, which helps detect reset, contention, and initialization problems. Two-state types can be faster for abstract testbench data when unknowns have no meaning.

**Trap:** Assigning X to bit converts it, so the original uncertainty is lost.

## 3. Packed versus unpacked arrays

**Answer:** packed dimensions appear before the variable name and form one contiguous vector, so slicing, arithmetic, and bitwise operations work naturally. Unpacked dimensions appear after the name and create a collection of elements. A memory is commonly an unpacked array of packed words.

**Example:** logic [31:0] memory [1024] is 1024 unpacked elements, each a packed 32-bit word.

## 4. always_comb versus always @*

**Answer:** both infer sensitivity from referenced signals, but always_comb adds intent and semantic checks. It executes once at time zero, includes dependencies referenced inside called functions, and tools can flag illegal multiple procedural writers. It is the clearer combinational construct.

**Trap:** always_comb does not fix incomplete assignment; a missing path can still describe latch behavior and should be corrected.

## 5. Blocking versus nonblocking assignment

**Answer:** blocking assignment updates immediately in procedural order and is normally used for combinational calculation. Nonblocking assignment samples the right-hand side in the active region and updates the left-hand side in the NBA region, modeling simultaneous clocked state updates.

**Follow-up:** Can a clocked block use a temporary blocking variable?  
Yes, for a local calculation when the final state variables still use nonblocking assignment and the intent remains clear.

## 6. == versus ===

**Answer:** logical equality can return X when an operand contains X or Z. Case equality compares X and Z as literal symbols and always returns zero or one. A checker uses === when it intentionally cares about unknowns, but broad use can hide the fact that both expected and actual are X.

## 7. Task versus function

**Answer:** a function returns a value and may not consume simulation time. A task can have multiple output/ref arguments and may wait on time or events. I use functions for pure prediction and tasks for driving or timed protocol actions.

## 8. Automatic versus static lifetime

**Answer:** automatic locals are created independently for each call, so concurrent or recursive calls do not share them. Static locals retain one storage location across calls. Class methods are automatic by default; module tasks/functions are static unless declared automatic.

**Trap:** A static task called by two forked threads can corrupt shared local state.

## 9. Object versus handle

**Answer:** new creates the object; the class variable stores a handle to it. Handle assignment creates an alias, not a copy. Both handles then see the same fields.

**Follow-up:** How do you make an independent transaction?  
Construct a new object and implement copy semantics, recursively copying nested handles when independent ownership is required.

## 10. Shallow versus deep copy

**Answer:** a shallow copy duplicates top-level scalar values but keeps nested handles shared. A deep copy recursively constructs and copies nested objects or arrays. Scoreboards often need deep copies because a producer may reuse the original transaction.

## 11. Why virtual methods?

**Answer:** virtual enables runtime dispatch. When a base handle points to a derived object, calling a virtual method executes the derived override. Without virtual, the method is chosen from the handle's declared type.

## 12. rand versus randc

**Answer:** rand selects any legal value on each solve. randc cycles through its legal domain before repeating, subject to constraints. randc is useful for small domains, but coverage is still required and large cyclic spaces can be expensive.

## 13. What does soft do?

**Answer:** a soft constraint supplies a default that a conflicting hard constraint can override. It lets a reusable transaction express normal behavior while a test applies a targeted inline value. It cannot override another hard legality rule.

## 14. What does solve before do?

**Answer:** it influences variable solve order and therefore distribution when legal choices depend on earlier choices. It does not make an inconsistent constraint set solvable and does not impose procedural execution inside the constraint block.

## 15. Why can randomize return zero?

**Answer:** enabled hard constraints have no common solution, a frozen variable violates a constraint, or array-size and element rules conflict. I always assert or check the return and reduce the constraint set to find the unsatisfiable core.

## 16. Queue versus mailbox

**Answer:** a queue is a data structure manipulated directly by the current process. A mailbox is an inter-process communication primitive whose put/get operations can block and synchronize producers and consumers. A bounded mailbox also models backpressure.

## 17. Can an event be missed?

**Answer:** yes. A plain event trigger is not stored. If ->done occurs before a process reaches @done, that process waits for the next trigger. For persistent notification, use a mailbox, state flag with wait, or another handshake.

## 18. join, join_any, and join_none

**Answer:** join waits for all children, join_any waits for one, and join_none lets the parent continue immediately. After join_any, remaining children still run until they finish or are stopped. A scoped disable fork is a common timeout pattern.

## 19. What does a semaphore protect?

**Answer:** it controls a limited number of access keys. A one-key semaphore acts like a mutex; multiple keys model multiple identical resources. Every get must have a matching put on all paths to avoid deadlock.

## 20. Interface versus virtual interface

**Answer:** an interface is an elaborated signal/timing container. A virtual interface is a class handle to that existing instance. Drivers and monitors use it because classes do not have static module ports.

## 21. What does a modport do?

**Answer:** a modport defines a named access view—directions, clocking blocks, and imported tasks/functions—for a component. It documents and restricts interaction; it does not duplicate the interface signals.

## 22. Why use a clocking block?

**Answer:** it defines a clock event and input/output skews, separating testbench sampling/driving from DUT scheduling. This removes dependence on active-region execution order and gives a consistent cycle-level view.

## 23. |-> versus |=>

**Answer:** |-> is overlapped implication, so the consequent starts in the same sampled cycle in which the antecedent completes. |=> is non-overlapped, so it starts on the next sampled clock. I draw a two- or three-cycle timing table before choosing.

## 24. What does disable iff do?

**Answer:** it asynchronously disables property evaluation and cancels active attempts while its expression is true. It is commonly used for reset. This differs from adding reset only as a normal sampled antecedent.

## 25. What is risky about $past?

**Answer:** at the first eligible sample there may be no meaningful prior value. Gate the property with reset/history validity or structure the antecedent so a valid previous sample is guaranteed.

## 26. Assertion versus scoreboard

**Answer:** an assertion is strongest for local temporal protocol rules and invariants. A scoreboard is strongest for end-to-end data prediction and reordering. They overlap, but neither fully replaces the other.

## 27. Functional coverage versus code coverage

**Answer:** functional coverage is user-defined verification intent: commands, boundaries, transitions, and crosses. Code coverage measures implementation activity such as statement, branch, toggle, FSM, or expression coverage. High code coverage does not prove the required scenarios occurred.

## 28. What causes cross-coverage explosion?

**Answer:** every bin combination in the crossed coverpoints can become a cross bin. Reduce bins to test-plan categories, ignore impossible combinations, and cross only relationships that answer a useful question.

## 29. illegal_bins versus assertion

**Answer:** illegal_bins reports a forbidden sampled value through the coverage mechanism. An assertion usually gives clearer protocol timing and failure context. I use an assertion for correctness and an illegal bin only when the coverage model also benefits.

## 30. Why should the scoreboard consume monitor data?

**Answer:** pin-level monitored data is what the DUT actually accepted. If the scoreboard consumes the generator object directly, a driver encoding or timing defect can affect the DUT while the scoreboard still predicts from the intended command and misses the integration bug.

## 31. Why wait after the last stimulus item?

**Answer:** pipelines, nonblocking updates, monitors, and temporal assertion consequents may still be active. End-of-test should use explicit drain or objection logic and allow every launched check to resolve before $finish.

## 32. What makes a verification example credible?

**Answer:** a written requirement, a self-checking test, failure criteria, reproducible command, expected stable output, and an honest simulator boundary. A waveform screenshot alone proves activity, not correctness.
