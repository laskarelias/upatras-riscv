.PHONY: error memory alu registerfile immediate branch

error:
	@echo "Usage: make [ memory | alu | registerfile | immediate | branch ]"
	@exit 0

memory:
	iverilog -o mem ../mem.v memtest.v
	vvp mem

alu:
	iverilog -o alu ../alu.v alutest.v
	vvp alu

registerfile:
	iverilog -o regfile ../regfile.v regtest.v
	vvp regfile

immediate:
	iverilog -o immgen ../immgen.v immtest.v
	vvp immgen

branch:
	iverilog -o branch ../branch.v branchtest.v
	vvp branch
