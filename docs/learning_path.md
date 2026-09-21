# Learning path

The order matters. SystemVerilog becomes easier when each layer solves a problem created by the previous layer.

## Stage 1 — Read and predict

Complete chapters 01 and 02. Before running an example, write down the value and type you expect for each printed expression. This catches the two mistakes that cause many early bugs: confusing packed bits with collections, and forgetting that X/Z exist in four-state types.

## Stage 2 — Model information

Complete chapters 03 and 04. Build a transaction object, copy it, mutate the copy, and prove that the original did or did not change. Then add constraints gradually. If randomization fails, inspect the constraint set before blaming the simulator.

## Stage 3 — Coordinate time

Complete chapters 05 and 06. A verification environment is a group of concurrent components sharing time and data. Learn which construct owns each job:

- event: a notification without payload;
- mailbox: ordered message transport;
- semaphore: access to a limited resource;
- clocking block: a disciplined sampling/driving boundary;
- modport: an interface access contract.

## Stage 4 — Check and measure

Complete chapter 07. Assertions answer “did the required behavior happen?” Coverage answers “did the intended scenario occur?” A passing assertion suite with weak coverage can still mean the test never reached important states.

## Stage 5 — Integrate

Complete chapter 08. Trace one transaction from generation to scoreboard comparison. Then break one DUT behavior deliberately and confirm that the correct checker fails. Verification confidence comes from proving the checker can detect a real defect.

## Stage 6 — Explain

Use chapter 09 without looking at the answers first. A strong spoken answer has this order:

1. definition;
2. practical reason;
3. internal behavior;
4. small example;
5. edge case or common trap.

If you can explain a feature in that order, you usually understand it well enough to debug it.
