HEAD
# axi_cdc_bridge
# Parameterized AXI4-Lite CDC Bridge with Power Intent


## Overview
This repository contains the RTL implementation and verification environment for a parameterized AXI4-Lite Clock Domain Crossing (CDC) bridge. Designed to facilitate reliable communication between asynchronous clock domains within System-on-Chip (SoC) interconnects, the bridge implements independent asynchronous FIFOs for all five AXI channels, gray-coded pointer synchronization, and an overarching Unified Power Format (UPF) methodology for multi-power-domain systems.

## Key Features
* **AXI4-Lite Compliance:** Manages independent channels for Write Address (AW), Write Data (W), Write Response (B), Read Address (AR), and Read Data (R).
* **CDC Synchronization:** Implements 2-stage flip-flop (2FF) synchronizers and Gray-coded read/write pointers to mitigate metastability and ensure transaction integrity across asynchronous boundaries.
* **Highly Parameterizable:** Configurable `DATA_WIDTH`, `ADDR_WIDTH`, `SYNC_STAGES`, and `FIFO_DEPTH` at the instantiation level.
* **Power Intent Annotation:** Includes IEEE 1801 UPF specifications defining `PD_MASTER` and `PD_SLAVE` domains, establishing isolation and level-shifter instantiation rules.
* **Automated Open-Source Flow:** Fully scripted verification and synthesis targets utilizing Yosys, Icarus Verilog, and Make.

## Directory Structure
```text
axi_cdc_bridge/
├── rtl/
│   ├── axi_cdc_bridge.sv       # Top-level bridge instantiation
│   ├── async_fifo.sv           # Parameterized asynchronous FIFO
│   ├── gray_encoder.sv         # Binary to Gray & Gray to Binary logic
│   ├── cdc_sync.sv             # Multi-stage synchronizer chain
│   └── axi_level_shifter.sv    # Behavioral stub for UPF domain crossing
├── tb/
│   ├── tb_axi_cdc_bridge.sv    # Directed and constrained-random testbench
│   └── axi_lite_bfm.sv         # Bus Functional Model for stimulus generation
├── upf/
│   └── power_intent.upf        # Power domain specification
├── synth/
│   └── synth.ys                # Yosys synthesis script targeting generic gates
├── Makefile                    # Automation for sim, synth, and clean targets
└── README.md

6048d97 (Initial commit: AXI CDC Bridge project and architecture documentation)
