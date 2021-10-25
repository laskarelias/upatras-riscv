%{
#define YYERROR_VERBOSE 1

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sym.h"

extern int yylex();
extern int yyparse();
extern int yylineno;

extern FILE* yyin;
extern FILE* yyout;

extern int symbols;
extern sym* table;

unsigned int ins = 0;
unsigned int mem = 0;

void yyerror(const char* s);

void writeins(unsigned int ins) {
    for (int i = 0; i < 4; i++) {
        fprintf(yyout, "%02x ", ins & 0xff);
        ins >>= 8;
    }
    mem += 4;
    fprintf(yyout, "\n");
}

unsigned int label_resolve(char* l) {
    for (int i = 0; i < symbols; i++) {
        if (!strcmp(table[i].name, l)) {
            return table[i].ad - mem;
        }
    }
    printf("[Assembler] [Line %d] Jump to Label %s - Label not declared\n", yylineno, l);
    exit(1);
    return 0;
}

%}
%union {
    unsigned int imm;
    unsigned int rs;
    char* sval;
}

%token       NL;
%token       LPAR;
%token       RPAR;
%token       COMMA;
%token       COLON;

%token <imm> NUM;
%token <rs>  REG;

%token LUI;
%token AUIPC;
%token JAL;
%token JALR;
%token BEQ;
%token BNE;
%token BLT;
%token BGE;
%token BLTU;
%token BGEU;
%token LB;
%token LH;
%token LW;
%token LD;
%token LBU;
%token LHU;
%token LWU;
%token SB;
%token SH;
%token SW;
%token ADDI;
%token SLTI;
%token SLTIU;
%token XORI;
%token ORI;
%token ANDI;
%token SLLI;
%token SRLI;
%token SRAI;
%token ADD;
%token SUB;
%token SLL;
%token SLT;
%token SLTU;
%token XOR;
%token SRL;
%token SRA;
%token OR;
%token AND;
%token FENCE;
%token ECALL;
%token EBREAK;

%token <sval> LABEL;

%%
file: instructions
;

instructions: instructions instruction NL
            | instruction NL
            | instruction
;

instruction: label
           | lui
           | auipc
           | jal
           | jalr
           | beq
           | bne 
           | blt
           | bge
           | bltu 
           | bgeu
           | lb 
           | lh 
           | lw 
           | ld
           | lbu
           | lhu
           | lwu
           | sb 
           | sh
           | sw 
           | addi 
           | slti 
           | sltiu 
           | xori
           | ori 
           | andi 
           | slli 
           | srli 
           | srai 
           | add
           | sub 
           | sll 
           | slt 
           | sltu 
           | xor 
           | srl 
           | sra 
           | or 
           | and 
           | fence 
           | ecall 
           | ebreak
;

label: LABEL COLON NL
;

lui: LUI REG COMMA NUM
   {
       ins =  0b0110111;
       ins += $2 << 7;
       ins += $4 << 12;
       writeins(ins);
   }
;

auipc: AUIPC REG COMMA NUM
     {
         ins =  0b0010111;
         ins += $2 << 7;
         ins += $4 << 12;
         writeins(ins);
     }
;

jal: JAL REG COMMA NUM
   {
       ins =  0b1101111;
       ins += $2     << 7;
       ins += (($4 >> 12) & 0xff) << 12;
       ins += (($4 >> 11) & 0x1)  << 20;
       ins += (($4 >> 1) & 0x3ff) << 21;
       ins += (($4 >> 20) & 0x1)  << 31;
       printf("[Assembler] [Line %d] [Warning] Jump with offset %x without using label\n", yylineno, (unsigned int)$4);
       writeins(ins);
   }
   | JAL REG COMMA LABEL
   {
       unsigned int lr = label_resolve($4);
       ins =  0b1101111;
       ins += $2     << 7;
       ins += ((lr >> 12) & 0xff) << 12;
       ins += ((lr >> 11) & 0x1)  << 20;
       ins += ((lr >> 1) & 0x3ff) << 21;
       ins += ((lr >> 20) & 0x1)  << 31;
       writeins(ins);
   }
;

jalr: JALR REG COMMA NUM LPAR REG RPAR
    {
        ins =  0b1100111;
        ins += $2    << 7;
        ins += 0b000 << 12;
        ins += $6    << 15;
        ins += $4    << 20;
        printf("[Assembler] [Line %d] [Warning] Jump with offset %x without using label\n", yylineno, (unsigned int)$4);
        writeins(ins);
    }
    | JALR REG COMMA LABEL LPAR REG RPAR
    {
        unsigned int lr = label_resolve($4);
        ins =  0b1100111;
        ins += $2    << 7;
        ins += 0b000 << 12;
        ins += $6    << 15;
        ins += lr    << 20;
        writeins(ins);
    }

;

beq: BEQ REG COMMA REG COMMA NUM
   {
       ins =  0b1100011;
       ins += (($6 >> 11) & 0x1) << 7;
       ins += (($6 >> 1)  & 0xf)  << 8;
       ins += 0b000 << 12;
       ins += $2    << 15;
       ins += $4    << 20;
       ins += (($6 >> 5)  & 0x3f) << 25;
       ins += (($6 >> 12) & 0x1)  << 31;
       printf("[Assembler] [Line %d] [Warning] Branch with offset %x without using label\n", yylineno, (unsigned int)$6);
       writeins(ins);
   }
   | BEQ REG COMMA REG COMMA LABEL
   {
       unsigned int lr = label_resolve($6); 
       ins =  0b1100011;
       ins += ((lr >> 11) & 0x1) << 7;
       ins += ((lr >> 1)  & 0xf)  << 8;
       ins += 0b000 << 12;
       ins += $2    << 15;
       ins += $4    << 20;
       ins += ((lr >> 5)  & 0x3f) << 25;
       ins += ((lr >> 12) & 0x1)  << 31;
       writeins(ins);
   }
;

bne: BNE REG COMMA REG COMMA NUM
   {
       ins =  0b1100011;
       ins += (($6 >> 11) & 0x1) << 7;
       ins += (($6 >> 1)  & 0xf) << 8;
       ins += 0b001 << 12;
       ins += $2    << 15;
       ins += $2    << 20;
       ins += (($6 >> 5)  & 0x3f) << 25;
       ins += (($6 >> 12) & 0x1)  << 31;
       writeins(ins);
   }
   | BNE REG COMMA REG COMMA LABEL
   {
       unsigned int lr = label_resolve($6); 
       ins =  0b1100011;
       ins += ((lr >> 11) & 0x1) << 7;
       ins += ((lr >> 1)  & 0xf) << 8;
       ins += 0b001 << 12;
       ins += $2    << 15;
       ins += $2    << 20;
       ins += ((lr >> 5)  & 0x3f) << 25;
       ins += ((lr >> 12) & 0x1)  << 31;
       writeins(ins);
   }
;

blt: BLT REG COMMA REG COMMA NUM
   {
       ins =  0b1100011;
       ins += (($6 >> 11) & 0x1) << 7;
       ins += (($6 >> 1)  & 0xf) << 8;
       ins += 0b100 << 12;
       ins += $2    << 15;
       ins += $2    << 20;
       ins += (($6 >> 5)  & 0x3f) << 25;
       ins += (($6 >> 12) & 0x1)  << 31;
       printf("[Assembler] [Line %d] [Warning] Branch with offset %x without using label\n", yylineno, (unsigned int)$6);
       writeins(ins);
   }
   | BLT REG COMMA REG COMMA LABEL
   {
       unsigned int lr = label_resolve($6);
       ins =  0b1100011;
       ins += ((lr >> 11) & 0x1) << 7;
       ins += ((lr >> 1)  & 0xf) << 8;
       ins += 0b100 << 12;
       ins += $2    << 15;
       ins += $2    << 20;
       ins += ((lr >> 5)  & 0x3f) << 25;
       ins += ((lr >> 12) & 0x1)  << 31;
       writeins(ins);
   }
;

bge: BGE REG COMMA REG COMMA NUM
   {
       ins =  0b1100011;
       ins += (($6 >> 11) & 0x1) << 7;
       ins += (($6 >> 1)  & 0xf)  << 8;
       ins += 0b101 << 12;
       ins += $2    << 15;
       ins += $4    << 20;
       ins += (($6 >> 5)  & 0x3f) << 25;
       ins += (($6 >> 12) & 0x1)  << 31;
       printf("[Assembler] [Line %d] [Warning] Branch with offset %x without using label\n", yylineno, (unsigned int)$6);
       writeins(ins);
   }
   | BGE REG COMMA REG COMMA LABEL
   {
       unsigned int lr = label_resolve($6);
       ins =  0b1100011;
       ins += ((lr >> 11) & 0x1) << 7;
       ins += ((lr >> 1)  & 0xf) << 8;
       ins += 0b101 << 12;
       ins += $2    << 15;
       ins += $2    << 20;
       ins += ((lr >> 5)  & 0x3f) << 25;
       ins += ((lr >> 12) & 0x1)  << 31;
       writeins(ins);
   }
;

bltu: BLTU REG COMMA REG COMMA NUM
   {
       ins =  0b1100011;
       ins += (($6 >> 11) & 0x1) << 7;
       ins += (($6 >> 1)  & 0xf)  << 8;
       ins += 0b110 << 12;
       ins += $2    << 15;
       ins += $4    << 20;
       ins += (($6 >> 5)  & 0x3f) << 25;
       ins += (($6 >> 12) & 0x1)  << 31;
       printf("[Assembler] [Line %d] [Warning] Branch with offset %x without using label\n", yylineno, (unsigned int)$6);
       writeins(ins);
   }
   | BLTU REG COMMA REG COMMA LABEL
   {
       unsigned int lr = label_resolve($6);
       ins =  0b1100011;
       ins += ((lr >> 11) & 0x1) << 7;
       ins += ((lr >> 1)  & 0xf) << 8;
       ins += 0b110 << 12;
       ins += $2    << 15;
       ins += $2    << 20;
       ins += ((lr >> 5)  & 0x3f) << 25;
       ins += ((lr >> 12) & 0x1)  << 31;
       writeins(ins);
   }
;

bgeu: BGEU REG COMMA REG COMMA NUM
   {
       ins =  0b1100011;
       ins += (($6 >> 11) & 0x1) << 7;
       ins += (($6 >> 1)  & 0xf)  << 8;
       ins += 0b111 << 12;
       ins += $2    << 15;
       ins += $4    << 20;
       ins += (($6 >> 5)  & 0x3f) << 25;
       ins += (($6 >> 12) & 0x1)  << 31;
       printf("[Assembler] [Line %d] [Warning] Branch with offset %x without using label\n", yylineno, (unsigned int)$6);
       writeins(ins);
   }
   | BGEU REG COMMA REG COMMA LABEL
   {
       unsigned int lr = label_resolve($6);
       ins =  0b1100011;
       ins += ((lr >> 11) & 0x1) << 7;
       ins += ((lr >> 1)  & 0xf) << 8;
       ins += 0b111 << 12;
       ins += $2    << 15;
       ins += $2    << 20;
       ins += ((lr >> 5)  & 0x3f) << 25;
       ins += ((lr >> 12) & 0x1)  << 31;
       writeins(ins);
   }
;

lb: LB REG COMMA NUM LPAR REG RPAR
  {
      ins =  0b0000011;
      ins += $2    << 7;
      ins += 0b000 << 12;
      ins += $6    << 15;
      ins += $4    << 20;
      writeins(ins);
  }
;

lh: LH REG COMMA NUM LPAR REG RPAR
  {
      ins =  0b0000011;
      ins += $2    << 7;
      ins += 0b001 << 12;
      ins += $6    << 15;
      ins += $4    << 20;
      writeins(ins);
  }
;

lw: LW REG COMMA NUM LPAR REG RPAR
  {
      ins =  0b0000011;
      ins += $2    << 7;
      ins += 0b010 << 12;
      ins += $6    << 15;
      ins += $4    << 20;
      writeins(ins);
  }
;

ld: LD REG COMMA NUM LPAR REG RPAR
  {
      ins =  0b0000011;
      ins += $2    << 7;
      ins += 0b011 << 12;
      ins += $6    << 15;
      ins += $4    << 20;
      writeins(ins);
  }
;

lbu: LBU REG COMMA NUM LPAR REG RPAR
  {
      ins =  0b0000011;
      ins += $2    << 7;
      ins += 0b100 << 12;
      ins += $6    << 15;
      ins += $4    << 20;
      writeins(ins);
  }
;

lhu: LHU REG COMMA NUM LPAR REG RPAR
  {
      ins =  0b0000011;
      ins += $2    << 7;
      ins += 0b101 << 12;
      ins += $6    << 15;
      ins += $4    << 20;
      writeins(ins);
  }
;

lwu: LWU REG COMMA NUM LPAR REG RPAR
  {
      ins =  0b0000011;
      ins += $2    << 7;
      ins += 0b110 << 12;
      ins += $6    << 15;
      ins += $4    << 20;
      writeins(ins);
  }
;

sb: SB REG COMMA NUM LPAR REG RPAR
  {
      ins =  0b0100011;
      ins += ($4 & 0x1f)  << 7;
      ins += 0b000 << 12;
      ins += $6    << 15;
      ins += $2    << 20;
      ins += ($4 >> 5) << 25;
      writeins(ins);
  }
;

sh: SH REG COMMA NUM LPAR REG RPAR
  {
      ins =  0b0100011;
      ins += ($4 & 0x1f)  << 7;
      ins += 0b001 << 12;
      ins += $6    << 15;
      ins += $2    << 20;
      ins += ($4 >> 5) << 25;
      writeins(ins);
  }
;

sw: SW REG COMMA NUM LPAR REG RPAR
  {
      ins =  0b0100011;
      ins += ($4 & 0x1f)  << 7;
      ins += 0b010 << 12;
      ins += $6    << 15;
      ins += $2    << 20;
      ins += ($4 >> 5) << 25;
      writeins(ins);
  }
;

addi: ADDI REG COMMA REG COMMA NUM
    {
        ins =  0b0010011;
        ins += $2    << 7;
        ins += 0b000 << 12;
        ins += $4    << 15;
        ins += $6    << 20;
        writeins(ins);
    }
;

slti: SLTI REG COMMA REG COMMA NUM
    {
        ins =  0b0010011;
        ins += $2    << 7;
        ins += 0b010 << 12;
        ins += $4    << 15;
        ins += $6    << 20;
        writeins(ins);
    }
;

sltiu: SLTIU REG COMMA REG COMMA NUM
     {
         ins =  0b0010011;
         ins += $2    << 7;
         ins += 0b011 << 12;
         ins += $4    << 15;
         ins += $6    << 20;
         writeins(ins);
     }
;

xori: XORI REG COMMA REG COMMA NUM
    {
        ins =  0b0010011;
        ins += $2    << 7;
        ins += 0b100 << 12;
        ins += $4    << 15;
        ins += $6    << 20;
        writeins(ins);
    }
;

ori: ORI REG COMMA REG COMMA NUM
   {
       ins =  0b0010011;
       ins += $2    << 7;
       ins += 0b110 << 12;
       ins += $4    << 15;
       ins += $6    << 20;
       writeins(ins);
   }
;

andi: ANDI REG COMMA REG COMMA NUM
    {
        ins =  0b0010011;
        ins += $2    << 7;
        ins += 0b111 << 12;
        ins += $4    << 15;
        ins += $6    << 20;
        writeins(ins);
    }
;

slli: SLLI REG COMMA REG COMMA NUM
    {
        ins =  0b0010011;
        ins += $2    << 7;
        ins += 0b001 << 12;
        ins += $4    << 15;
        ins += ($6 & 0x1f) << 20;
        writeins(ins);
    }
;

srli: SRLI REG COMMA REG COMMA NUM
    {
        ins =  0b0010011;
        ins += $2    << 7;
        ins += 0b101 << 12;
        ins += $4    << 15;
        ins += ($6 & 0x1f) << 20;
        writeins(ins);
    }
;

srai: SRAI REG COMMA REG COMMA NUM
    {
        ins =  0b0010011;
        ins += $2    << 7;
        ins += 0b101 << 12;
        ins += $4    << 15;
        ins += ($6 & 0x1f) << 20;
        ins += 0b0100000 << 25;
        writeins(ins);
    }
;

add: ADD REG COMMA REG COMMA REG
   {
       ins =  0b0110011;
       ins += $2    << 7;
       ins += 0b000 << 12;
       ins += $4    << 15;
       ins += $6    << 20;
       writeins(ins);
   }
;

sub: SUB REG COMMA REG COMMA REG
   {
       ins =  0b0110011;
       ins += $2    << 7;
       ins += 0b000 << 12;
       ins += $4    << 15;
       ins += $6    << 20;
       ins += 0b0100000 << 25;
       writeins(ins);
   }
;

sll: SLL REG COMMA REG COMMA REG
   {
       ins =  0b0110011;
       ins += $2    << 7;
       ins += 0b001 << 12;
       ins += $4    << 15;
       ins += $6    << 20;
       writeins(ins);
   }
;

slt: SLT REG COMMA REG COMMA REG
   {
       ins =  0b0110011;
       ins += $2    << 7;
       ins += 0b010 << 12;
       ins += $4    << 15;
       ins += $6    << 20;
       writeins(ins);
   }
;

sltu: SLTU REG COMMA REG COMMA REG
    {
        ins =  0b0110011;
        ins += $2    << 7;
        ins += 0b011 << 12;
        ins += $4    << 15;
        ins += $6    << 20;
        writeins(ins);
    }
;

xor: XOR REG COMMA REG COMMA REG
   {
       ins =  0b0110011;
       ins += $2    << 7;
       ins += 0b100 << 12;
       ins += $4    << 15;
       ins += $6    << 20;
       writeins(ins);
   }
;

srl: SRL REG COMMA REG COMMA REG
   {
       ins =  0b0110011;
       ins += $2    << 7;
       ins += 0b101 << 12;
       ins += $4    << 15;
       ins += $6    << 20;
       writeins(ins);
   }
;

sra: SRA REG COMMA REG COMMA REG
   {
       ins =  0b0110011;
       ins += $2    << 7;
       ins += 0b101 << 12;
       ins += $4    << 15;
       ins += $6    << 20;
       ins += 0b0100000 << 25;
       writeins(ins);
   }
;

or: OR REG COMMA REG COMMA REG
  {
      ins =  0b0110011;
      ins += $2    << 7;
      ins += 0b110 << 12;
      ins += $4    << 15;
      ins += $6    << 20;
      writeins(ins);
  }
;

and: AND REG COMMA REG COMMA REG
   {
       ins =  0b0110011;
       ins += $2    << 7;
       ins += 0b111 << 12;
       ins += $4    << 15;
       ins += $6    << 20;
       writeins(ins);
   }
;

fence: FENCE
;

ecall: ECALL 
     {   
         ins  = 0b1110011;
         writeins(ins);
     }
;

ebreak: EBREAK
      {   
          ins  = 0b1110011;
          ins += 1 << 20;
          writeins(ins);
      }
;

%%

void yyerror(const char *s) {
  printf("[Assembler] [Line %d] %s\n", yylineno, s);
  exit(1);
}

