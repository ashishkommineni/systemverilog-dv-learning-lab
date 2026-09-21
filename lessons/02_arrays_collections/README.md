# 02 — Arrays and collections

## Learning objective

Choose a data structure from its access pattern, not from habit.

## What

SystemVerilog has several collection types because verification code needs several kinds of storage.

| Type | Size | Index | Best fit |
|---|---|---|---|
| Fixed unpacked array | Compile-time | Integral | Small tables with a known shape |
| Dynamic array | Runtime, explicitly resized | Integral | A block whose final size is known after configuration |
| Queue | Runtime, grows and shrinks | Ordered integral positions | Expected-data streams and pending transactions |
| Associative array | Sparse, grows on assignment | Integral, enum, string, or other legal key | Address-indexed scoreboards and sparse memories |

## Why

A scoreboard may receive addresses 0x10 and 0xFFFF_F000. Allocating a giant dense array wastes memory; an associative array stores only visited locations. A driver may need strict arrival order; a queue expresses that directly. Choosing the correct collection makes the algorithm visible and removes manual book-keeping.

## How

### Fixed array

Its bounds are part of the declaration and storage exists immediately.

~~~systemverilog
int samples [4];
~~~

### Dynamic array

The variable starts empty. new[N] allocates N elements. Reallocating can optionally copy existing elements:

~~~systemverilog
samples = new[8](samples);
~~~

### Queue

A queue supports efficient insertion and removal at either end:

~~~systemverilog
pending.push_back(item);
item = pending.pop_front();
~~~

That pair naturally models FIFO order.

### Associative array

Writing a new key creates that entry. exists, delete, first, next, last, and prev help with sparse traversal.

~~~systemverilog
expected_by_addr[32'h1000] = 8'hA5;
if (expected_by_addr.exists(address)) begin
  // compare response
end
~~~

### foreach and array methods

foreach follows declared indices and works with every collection category. Array methods add intent:

- reduction: sum, product, and, or, xor;
- locator: find, find_index, min, max, unique;
- ordering: sort, rsort, reverse, shuffle.

The with clause names each candidate as item:

~~~systemverilog
large = values.find with (item > 100);
~~~

## Where

- Use a queue for an in-order reference stream.
- Use an associative array for out-of-order responses indexed by transaction ID.
- Use a dynamic array when a packet payload length is randomized first.
- Use a fixed packed array for arithmetic, masks, and protocol fields.

## Code walkthrough

The example builds all four collection types. It computes a fixed-array sum, allocates and fills a dynamic array, mutates both ends of a queue, and records sparse register values by name. Every operation is followed by a check.

## Common mistakes

- Calling delete(index) on a queue and assuming later indices stay unchanged.
- Using queue index [$] when the queue is empty.
- Forgetting that new[N] without a copy argument discards a dynamic array's old contents.
- Using an associative array read before checking exists; the default value can look like valid expected data.
- Confusing packed bit dimensions with unpacked element dimensions.

## Quick interview answer

**Queue versus dynamic array?**  
A dynamic array is resized as an allocation operation and is good when the required size is known for a phase of work. A queue is designed to change size continuously and offers push/pop operations, so it is a better fit for ordered transaction flow.

## Follow-up questions

1. What collection models an out-of-order bus scoreboard?  
   Usually an associative array indexed by transaction ID, often with a queue per ID when multiple outstanding items can share that ID.

2. Is a queue synthesizable?  
   It is primarily a testbench construct. Synthesis support should never be assumed.

3. What does foreach visit in an associative array?  
   Only keys that currently exist.
