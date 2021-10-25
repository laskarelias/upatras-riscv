%option noyywrap
%option yylineno
%option nounput
%option noinput


%{
#include "asm.tab.h"
#define YY_DECL int yylex()

static char* tmp;

// register to integer
int rtoi(char *yy){
    if (!strcmp(yy, "zero")) { return 0; } 
    if (!strcmp(yy, "ra"))   { return 1; }
    if (!strcmp(yy, "sp"))   { return 2; }
    if (!strcmp(yy, "gp"))   { return 3; }
    if (!strcmp(yy, "tp"))   { return 4; }
    if (!strcmp(yy, "fp"))   { return 8; }
    if (yy[0] == 't') {
        if (atoi(yy+1) < 3) { return atoi(yy+1) + 5; }
        if (atoi(yy+1) < 7) { return atoi(yy+1) + 25; }
        return -1;
    }
    if (yy[0] == 's') {
        if (atoi(yy+1) < 2)  { return atoi(yy+1) + 8; }
        if (atoi(yy+1) < 12) { return atoi(yy+1) + 16; }
        return -1;
    }
    if (yy[0] == 'a') {
        if (atoi(yy+1) < 8)  { return atoi(yy+1) + 10; }
        return -1;
    }
    if (yy[0] == 'x') {
        if (atoi(yy+1) < 32) { return atoi(yy+1); }
        return -1;
    }
    return -1;
}

%}

%option noyywrap
%option yylineno

empty    ^\s*[\n]+
linecom  ^[;][^\n]*\n
comment  [;][^\n]*
ws       [ \t]+
nl       [\n]+
reg      (zero|ra|sp|gp|tp|t[0-6]|s[0-9]+|fp|a[0-7]|x[0-9]+)
bin      0b[01]+
hex      0x[0-9a-fA-F]+
dec      [0-9]+
num      {bin}{dec}{hex}  
label    [_a-zA-Z][_a-zA-Z0-9]{1,31}

%%
{linecom} {};
{comment} {};
{empty}   {};
{ws}      {};
{nl}      return NL;
{bin}     { yylval.imm = strtoul(yytext+2, &tmp, 2);  return NUM; }
{dec}     { yylval.imm = strtoul(yytext,   &tmp, 10); return NUM; }
{hex}     { yylval.imm = strtoul(yytext+2, &tmp, 16); return NUM; }
{reg}     { yylval.rs  = rtoi(yytext);                return REG; }


"("       return LPAR;
")"       return RPAR;
","       return COMMA;
":"       return COLON;

"lui"     return LUI;
"auipc"   return AUIPC;

"jal"     return JAL;
"jalr"    return JALR;
"beq"     return BEQ;
"bne"     return BNE;
"blt"     return BLT;
"bge"     return BGE;
"bltu"    return BLTU;
"bgeu"    return BGEU;

"lb"      return LB;
"lh"      return LH;
"lw"      return LW;
"ld"      return LD;
"lbu"     return LBU;
"lhu"     return LHU;
"lwu"     return LWU;

"sb"      return SB;
"sh"      return SH;
"sw"      return SW;

"addi"    return ADDI;
"slti"    return SLTI;
"sltiu"   return SLTIU;
"xori"    return XORI;
"ori"     return ORI;
"andi"    return ANDI;
"slli"    return SLLI;
"srli"    return SRLI;
"srai"    return SRAI;

"add"    return ADD;
"sub"    return SUB;
"sll"    return SLL;
"slt"    return SLT;
"sltu"   return SLTU;
"xor"    return XOR;
"srl"    return SRL;
"sra"    return SRA;
"or"     return OR;
"and"    return AND;

"fence"  return FENCE;
"ecall"  return ECALL;
"ebreak" return EBREAK;

{label}  { yytext[yyleng] = '\0'; yylval.sval = strdup(yytext); return LABEL; }
