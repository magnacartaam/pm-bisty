# Makefile for BIST Project

# Compiler
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

# Source files (BIST components)
SRC = src/ram_16x1.v \
      src/ri_unit.v \
      src/microcode_memory.v \
      src/fsm_controller.v \
      src/bist_top.v

# Testbenches (one per module + integration)
TB_RAM = tb/tb_ram.v
TB_RI = tb/tb_ri.v
TB_MM = tb/tb_mm.v
TB_FSM = tb/tb_fsm.v
TB_BIST = tb/tb_bist.v

# Default target
all: sim_ram

# Individual simulation targets
sim_ram: $(SRC) $(TB_RAM)
	@echo "Compiling RAM testbench..."
	$(IVERILOG) -o sim_ram $^
	@echo "Running simulation..."
	$(VVP) sim_ram
	@echo "Done. View waveforms with: make view_ram"

sim_ri: $(SRC) $(TB_RI)
	@echo "Compiling RI testbench..."
	$(IVERILOG) -o sim_ri $^
	@echo "Running simulation..."
	$(VVP) sim_ri
	@echo "Done. View waveforms with: make view_ri"

sim_mm: $(SRC) $(TB_MM)
	@echo "Compiling Microcode Memory testbench..."
	$(IVERILOG) -o sim_mm $^
	@echo "Running simulation..."
	$(VVP) sim_mm
	@echo "Done. View waveforms with: make view_mm"

sim_fsm: $(SRC) $(TB_FSM)
	@echo "Compiling FSM testbench..."
	$(IVERILOG) -o sim_fsm $^
	@echo "Running simulation..."
	$(VVP) sim_fsm
	@echo "Done. View waveforms with: make view_fsm"

sim_bist: $(SRC) $(TB_BIST)
	@echo "Compiling full BIST integration testbench..."
	$(IVERILOG) -o sim_bist $^
	@echo "Running simulation..."
	$(VVP) sim_bist
	@echo "Done. View waveforms with: make view_bist"

# Waveform viewing targets
view_ram:
	@$(GTKWAVE) tb_ram.vcd &

view_ri:
	@$(GTKWAVE) tb_ri.vcd &

view_mm:
	@$(GTKWAVE) tb_mm.vcd &

view_fsm:
	@$(GTKWAVE) tb_fsm.vcd &

view_bist:
	@$(GTKWAVE) tb_bist.vcd &

# Cleanup
clean:
	rm -f sim_* *.vcd

.PHONY: all sim_ram sim_ri sim_mm sim_fsm sim_bist view_ram view_ri view_mm view_fsm view_bist clean
