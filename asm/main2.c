#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sym.h"
#include "asm.tab.h"
#include "preproc.tab.h"
#define YY_DECL int yylex()
#define XX_DECL int xxlex()
#define DEBUG 0

extern int xxlex();
extern int xxparse();
extern int xxlineno;

extern int yylex();
extern int yyparse();
extern int yylineno;

extern FILE* yyin;
extern FILE* xxin;
extern FILE* xxout;
extern FILE* yyout;

sym* table;
int symbols;

int main(int argc, char** argv) {
    #ifdef YYDEBUG
        yydebug = DEBUG;
    #endif
    #ifdef XXDEBUG
        xxdebug = DEBUG;
    #endif

    char fout[32];
    strcpy(fout, argv[2]);
    symbols = 0;
    table = (sym *)malloc(1 * sizeof(sym));
    xxin = fopen(argv[1], "r");
    char* fname = strcat(argv[1], ".out");
    //printf("fname is : %s\n", fname);
    xxout = fopen(fname, "w");
    //printf("Preproc...\n");
    xxparse();
    //for (int i = 0; i < symbols; i++) {
        //printf("; [0x%08x] %s\n", table[i].ad, table[i].name);
    //}
    fclose(xxout);
    //printf("Preproc Done\n");
    //printf("Asm...\n");
    yyin = fopen(fname, "r");
    yyout = fopen(fout, "w");
    fprintf(yyout, "@0\n");
    yyparse();
    fprintf(yyout, "// SYMBOL TABLE\n");
    for (int i = 0; i < symbols; i++) {
        fprintf(yyout, "// [0x%08x] %s\n", table[i].ad, table[i].name);
    }
    fclose(yyout);
    //printf("Asm Done\n");

    return 0;
}
