# Contributing

Small, verifiable improvements are welcome.

## A useful lesson contribution

A lesson should contain:

- one clearly stated learning objective;
- a minimal example that checks itself;
- expected output;
- simulator requirements;
- one common mistake and one interview follow-up.

Please keep generated logs, waveforms, coverage databases, editor files, and backup files out of the commit.

## Before opening a pull request

Run:

~~~sh
make structure
make syntax
make portable
~~~

If a feature requires Xcelium, say so in the lesson and include the exact command. Do not present an expected transcript as an executed result.
