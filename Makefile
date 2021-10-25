compile:
	rvasm prog.rva instr.mem
	iverilog -o dsn *.v
	vvp dsn

clean:
	rm dsn
