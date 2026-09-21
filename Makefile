SHELL := /usr/bin/env bash

.PHONY: help structure portable syntax xcelium check clean

help:
	@echo "make structure  - check the repository contract"
	@echo "make portable   - run the Verilator-supported examples"
	@echo "make syntax     - parse every SystemVerilog source with Verible"
	@echo "make xcelium    - run the complete suite with Cadence Xcelium"
	@echo "make check      - structure plus portable execution"
	@echo "make clean      - remove generated output"

structure:
	bash scripts/check_structure.sh

portable:
	bash scripts/run_verilator.sh

syntax:
	bash scripts/run_syntax.sh

xcelium:
	bash scripts/run_xcelium.sh

check: structure portable

clean:
	rm -rf build
