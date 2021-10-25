%define api.prefix {xx}

%{
#define XXERROR_VERBOSE 1
//#define YYERROR_VERBOSE 1

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sym.h"

extern int xxlex();
extern int xxparse();
extern int xxlineno;

//extern int yylex();
//extern int yyparse();
//extern int yylineno;

extern FILE* xxin;
extern FILE* xxout;

// extern FILE* yyin;
// extern FILE* yyout;

extern void xxerror(const char* s);
//extern void yyerror(const char* s);

extern sym* table;
extern int symbols;

unsigned int mem_ad = 0;

void label_handler(char* l) {
    table = (sym *)realloc(table, ++symbols * sizeof(sym));
    table[symbols-1].ad = mem_ad;
    strcpy(table[symbols-1].name, l);
}

void ptoi(char* p) {
    if (!strcmp(p, "nop")){
        fprintf(xxout, "addi x0, x0, 0\n");
    }
}

%}
%union {
	char* sval;
}

%token       P_NL;
%token       P_LPAR;
%token       P_RPAR;
%token       P_COMMA;
%token       P_COLON;

%token <sval> P_OP;
%token <sval> P_REG;
%token <sval> P_INSTR;
%token <sval> P_PSEUDO;
%token <sval> P_LABEL;


%%
file: instructions
;

instructions: instruction P_NL instructions
            | instruction P_NL
            | instruction
;

instruction: instr 
           { 
               mem_ad += 4; 
           }
;

instr: P_INSTR P_REG P_COMMA P_OP P_LPAR P_REG P_RPAR // ok
     {   
         fprintf(xxout, "%s %s, %s(%s)\n", $1, $2, $4, $6);
     }
     | P_INSTR P_REG P_COMMA P_REG P_COMMA P_REG // ok
     {   
         fprintf(xxout, "%s %s, %s, %s\n", $1, $2, $4, $6);
     }
     | P_INSTR P_REG P_COMMA P_REG P_COMMA P_OP // ok
     {   
         fprintf(xxout, "%s %s, %s, %s\n", $1, $2, $4, $6);
     }
     | P_INSTR P_REG P_COMMA P_REG P_COMMA P_LABEL // ok
     {   
         fprintf(xxout, "%s %s, %s, %s\n", $1, $2, $4, $6);
     }
     | P_INSTR P_REG P_COMMA P_OP // ok
     {   
         fprintf(xxout, "%s %s, %s\n", $1, $2, $4);
     }
     | P_INSTR P_REG P_COMMA P_LABEL // ok
     {   
         fprintf(xxout, "%s %s, %s\n", $1, $2, $4);
     }
     | P_LABEL P_COLON // ok
     {  
         fprintf(xxout, "; %s:\n", $1);
         label_handler($1);
         mem_ad -= 4;
     }
     | P_PSEUDO
     {
         ptoi($1);
     }
;

%%

void xxerror(const char *s) {
  printf("[Preprocessor] [Line %d] %s\n", xxlineno, s);
  exit(1);
}

