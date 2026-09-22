# Verification report

Last checked: 2026-09-22

## Review contract

This repository separates three different claims:

- **parsed:** a language-aware parser accepted the source;
- **executed:** a simulator compiled and ran the example;
- **expected:** the result is documented but requires a simulator unavailable in the authoring environment.

That distinction prevents a common portfolio problem: presenting a hand-written expected log as proof of execution.

## Checks performed

| Check | Scope | Result |
|---|---|---|
| Repository contract | Required lesson guides, examples, and outputs | PASS |
| SystemVerilog parse | 21 of 21 source files with Verible syntax parser | PASS |
| Portable compile | 9 of 9 selected examples with Verilator 5.49 | PASS |
| Portable runtime self-checks | 9 of 9 selected examples | PASS |
| GitHub Actions portable CI | Ubuntu 24.04, Verilator 5.020, 9 of 9 examples | PASS |
| Extended elaboration | 8 additional feature examples plus the complete mini environment | PASS; unsupported cover bins explicitly reported by Verilator |
| Documentation links and Xcelium file list | Every local target resolved | PASS |
| Generated-artifact scan | Logs, waves, databases, backups | PASS |
| Cadence Xcelium runtime | Xcelium-only constraints, coverage, IPC paths | Not run locally; command supplied |

## Portable pass criteria

An example passes only when:

1. compilation exits successfully;
2. runtime exits successfully;
3. its exact PASS marker appears in the transcript;
4. an assertion or explicit comparison would terminate the run on an incorrect value.

## Reproduce

~~~sh
make clean
make syntax
make check
~~~

The console summary should end with:

~~~text
Portable suite: 9/9 PASS
Repository checks: PASS
~~~

The chapter expected_output files are learning aids. They show the stable lines that matter and omit simulator banners, license messages, compile paths, and timestamps.
