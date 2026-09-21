# Debugging exercises

Try to identify the root cause before reading the diagnosis.

## 1. Register pipeline collapses

~~~systemverilog
always_ff @(posedge clk) begin
  stage1 = input_data;
  stage2 = stage1;
end
~~~

**Symptom:** stage2 receives the current input instead of the previous stage1 value.

**Diagnosis:** blocking assignment updates stage1 before stage2 reads it. Use nonblocking assignments for both state elements.

## 2. Randomize silently reuses old values

~~~systemverilog
item.randomize() with { length == 0; };
driver.send(item);
~~~

**Symptom:** length is not zero, but the transaction is still sent.

**Diagnosis:** a hard class constraint may reject zero. randomize returned zero and left old field values. Check the return and never send a failed object.

## 3. Scoreboard expected item changes later

~~~systemverilog
expected_q.push_back(item);
item.randomize();
~~~

**Symptom:** queued expected transactions appear to change.

**Diagnosis:** the queue stores the same class handle. Push a deep copy or transfer ownership and construct a new item.

## 4. Timeout fires during the next transfer

~~~systemverilog
fork
  wait_for_done();
  #100ns timed_out = 1;
join_any
~~~

**Symptom:** the timeout thread survives after done and changes state later.

**Diagnosis:** join_any leaves the losing child alive. Use a safely scoped disable fork or explicit process control.

## 5. Event wait hangs

~~~systemverilog
-> ready;
@ready;
~~~

**Symptom:** the receiver waits forever.

**Diagnosis:** the trigger occurred before the wait began and events do not queue notifications. Use a persistent handshake or start the waiter first.

## 6. Assertion checks the wrong cycle

~~~systemverilog
request |-> grant;
~~~

**Requirement:** grant must arrive one cycle after request.

**Diagnosis:** overlapped implication checks the same starting cycle. Use |=> for the next-cycle requirement.

## 7. Monitor sometimes sees old data

Both DUT and monitor execute @(posedge clk), and the monitor reads raw DUT outputs.

**Symptom:** results depend on simulator scheduling or appear one cycle late.

**Diagnosis:** the monitor samples before the DUT NBA update. Define a clocking-block sampling scheme or deliberately sample after the update region.

## 8. Coverage stays at zero

The covergroup is constructed but no clock event or explicit sample call is defined.

**Diagnosis:** a covergroup does not sample merely because it exists. Add an event to the covergroup declaration or call sample at the accepted-transaction point.

## 9. Associative scoreboard reports false matches

The code reads expected[address] without checking exists(address).

**Diagnosis:** a missing key returns the element type's default, which may equal the actual data. Check exists first and report an unexpected response.

## 10. Last SVA never fails

The test drives the final request and calls $finish immediately after the same cycle.

**Diagnosis:** the property's delayed consequent never receives a sampling edge. Drain the protocol and allow outstanding properties to complete before ending simulation.
