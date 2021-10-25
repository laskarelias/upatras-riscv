%option prefix="xx"
%option noyywrap
%option yylineno
%option nounput
%option noinput

%{
#include "preproc.tab.h"
// #define YY_DECL int yylex()
#define XX_DECL int xxlex()

%}

%option noyywrap
%option yylineno

empty    ^\s*[\n]+
linecom  ^[;][^\n]*\n
comment  [;][^\n]*
ws       [ \t]+
nl       [\n]+

reg      zero|ra|sp|gp|tp|t[0-6]|s[0-9]+|fp|a[0-7]|x[0-9]+
bin      0b[01]+
hex      0x[0-9a-fA-F]+
dec      [0-9]+

instr    lui|auipc|jal|jalr|beq|bne|blt|bge|bltu|bgeu|lb|lh|lw|lbu|lhu|sb|sh|sw|addi|slti|sltiu|xori|ori|andi|slli|srli|srai|add|sub|sll|slt|sltu|xor|srl|sra|or|and|fence|ecall|ebreak
pseudo   nop    

label    [_a-zA-Z][_a-zA-Z0-9]{1,31}

%%
{linecom} {};
{comment} {};
{empty}   {};
{ws}      {};
{nl}      return P_NL;
{bin}     { xxtext[xxleng] = '\0'; xxlval.sval = strdup(xxtext); return P_OP; }
{hex}     { xxtext[xxleng] = '\0'; xxlval.sval = strdup(xxtext); return P_OP; }
{dec}     { xxtext[xxleng] = '\0'; xxlval.sval = strdup(xxtext); return P_OP; }
{reg}     { xxtext[xxleng] = '\0'; xxlval.sval = strdup(xxtext); return P_REG; }

"("       return P_LPAR;
")"       return P_RPAR;
","       return P_COMMA;
":"       return P_COLON;

{instr}   { xxtext[xxleng] = '\0'; xxlval.sval = strdup(xxtext); return P_INSTR; }
{pseudo}  { xxtext[xxleng] = '\0'; xxlval.sval = strdup(xxtext); return P_PSEUDO; }
{label}   { xxtext[xxleng] = '\0'; xxlval.sval = strdup(xxtext); return P_LABEL; }
