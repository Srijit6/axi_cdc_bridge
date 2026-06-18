IVERILOG = iverilog
VVP      = vvp
GTKWAVE  = gtkwave
YOSYS    = yosys

# Directory management
RTL_DIR   = rtl
TB_DIR    = tb
SYNTH_DIR = synth

# Source files
RTL_SRCS = $(wildcard $(RTL_DIR)/*.sv)
TB_SRCS  = $(wildcard $(TB_DIR)/*.sv)

# Build artifacts
SIM_BIN   = sim.out
WAVE_FILE = dump.vcd
NETLIST   = $(SYNTH_DIR)/netlist.json
SCHEMATIC = $(SYNTH_DIR)/axi_cdc_bridge_schematic.svg

# -----------------------------------------------------------------------------
# Default Target: Help Menu
# -----------------------------------------------------------------------------
.PHONY: help
help:
	@echo "====================================================================="
	@echo " AXI4-Lite CDC Bridge Build System"
	@echo "====================================================================="
	@echo " Available targets:"
	@echo "   make sim    - Compile RTL and run simulation using Icarus Verilog"
	@echo "   make wave   - Run simulation and open waveform in GTKWave"
	@echo "   make synth  - Run logic synthesis and generate netlist using Yosys"
	@echo "   make clean  - Remove all generated build artifacts"
	@echo "====================================================================="

# -----------------------------------------------------------------------------
# Simulation Targets
# -----------------------------------------------------------------------------
.PHONY: sim
sim: $(SIM_BIN)
	@echo "--- Running Simulation ---"
	$(VVP) $(SIM_BIN)

$(SIM_BIN): $(RTL_SRCS) $(TB_SRCS)
	@echo "--- Compiling RTL & Testbench ---"
	$(IVERILOG) -g2012 -o $(SIM_BIN) $(RTL_SRCS) $(TB_SRCS)

.PHONY: wave
wave: sim
	@echo "--- Launching GTKWave ---"
	$(GTKWAVE) $(WAVE_FILE) &

# -----------------------------------------------------------------------------
# Synthesis Targets
# -----------------------------------------------------------------------------
.PHONY: synth
synth: $(RTL_SRCS)
	@echo "--- Running Yosys Synthesis ---"
	$(YOSYS) -c $(SYNTH_DIR)/synth.ys

# -----------------------------------------------------------------------------
# Cleanup
# -----------------------------------------------------------------------------
.PHONY: clean
clean:
	@echo "--- Cleaning Build Artifacts ---"
	rm -f $(SIM_BIN) $(WAVE_FILE)
	rm -f $(NETLIST)
	rm -f $(SCHEMATIC) $(SYNTH_DIR)/*.dot