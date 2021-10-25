.PHONY: asm install clean

all: clean asm install run

asm: 
	@bison -d -t -v asm.y
	@flex  -o asm.lex.c asm.l
	@bison -d -t -v preproc.y
	@flex  -o preproc.lex.c preproc.l
	@gcc -Wall -o asm main2.c asm.lex.c preproc.lex.c asm.tab.c preproc.tab.c -lfl -lm 
install: asm
	@cp asm ~/.local/bin/rvasm

clean:
	@rm -rf asm *.lex.c *.tab.c *.tab.h

run:
	@rvasm ../prog.rva ../instr.mem
