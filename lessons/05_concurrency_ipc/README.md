# 05 — Concurrency and inter-process communication

## Learning objective

Start, stop, and coordinate parallel testbench activity without leaving orphaned processes or introducing ordering races.

## What

SystemVerilog testbenches are naturally concurrent. Drivers, monitors, clocks, timeouts, and scoreboards all progress independently.

Fork variants control when the parent continues:

| Construct | Parent continues when |
|---|---|
| fork...join | Every child finishes |
| fork...join_any | Any one child finishes |
| fork...join_none | Immediately after children are spawned |

wait fork blocks until the current process's outstanding children finish. disable fork terminates its active child processes.

IPC primitives solve different coordination problems:

- event: notification without data;
- mailbox: ordered message transport, optionally typed and bounded;
- semaphore: a pool of keys controlling access to a shared resource;
- process handle: status and explicit control of a spawned process.

## Why

Timing bugs are often testbench bugs. A timeout thread may survive into the next transaction. An event can trigger before the receiver begins waiting. Two components may update the same reference model concurrently. Correct concurrency makes the checker deterministic.

## How

### fork/join_any timeout pattern

~~~systemverilog
fork
  begin
    wait_for_response();
  end
  begin
    #100ns;
    timed_out = 1;
  end
join_any
disable fork;
~~~

The disable is important: it removes the losing thread. Put this pattern inside a dedicated task or block so disable fork cannot terminate unrelated descendants owned by an outer process.

### Events

Trigger with -> done and wait with @done. A plain event trigger is not stored. If the trigger occurs before @done begins waiting, it is missed. The triggered property can help in the current time slot, or a mailbox can be used when the notification must persist.

### Mailboxes

put blocks when a bounded mailbox is full. get blocks when it is empty. try_put and try_get are nonblocking alternatives. Typed mailboxes catch payload-type mistakes at compile time.

### Semaphores

new(N) creates N keys. get(K) waits for K keys and put(K) returns them. Always return every key on every control path; otherwise the testbench can deadlock.

### Process handles

process::self returns the current process handle. status reports RUNNING, WAITING, SUSPENDED, KILLED, or FINISHED. suspend, resume, kill, and await give explicit control, but structured fork scopes are usually easier to reason about.

## Where

- generator-to-driver transaction transport;
- watchdog and timeout logic;
- arbitration around a shared bus model;
- end-of-test notification;
- parallel reset, traffic, and error-injection threads.

## Code walkthrough

processes_demo covers:

1. join waits for two workers;
2. join_any selects a fast branch;
3. disable fork removes the slow branch;
4. join_none lets the parent continue;
5. wait fork proves the background task completed.

ipc_demo sends integers through a bounded typed mailbox. The consumer guards the shared sum with a semaphore and triggers an event at end of stream.

## Common mistakes

- Using join_any without terminating or tracking the remaining children.
- Calling disable fork from a scope that owns unrelated background work.
- Triggering an event before the receiver starts waiting.
- Forgetting semaphore.put on an error or early-return path.
- Using a zero-capacity assumption for mailbox; new() without a bound creates an unbounded mailbox.
- Starting a forever loop without a shutdown mechanism.

## Quick interview answer

**Mailbox versus semaphore?**  
A mailbox transports ordered data between processes. A semaphore transports access rights: a process takes keys before entering a limited resource and returns them afterward. A mailbox can synchronize because get may block, but it should not be used as a disguised lock when a semaphore expresses the intent.

## Follow-up questions

1. What does join_none do with child lifetime?  
   The parent continues immediately; children remain active until they finish or are explicitly controlled.

2. Can an event carry a transaction?  
   No. Use a mailbox, queue plus synchronization, or another data channel.

3. Why prefer a typed mailbox?  
   It makes the message contract explicit and catches accidental payload types earlier.
