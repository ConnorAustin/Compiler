%{
	/*--------------------*/
	/*   Connor Austin    */
	/*  CS 4223, Compiler */
	/*--------------------*/
	#include <stdio.h>
	#include "symbol_table.h"

	int yylex();
	int yyerror(char *s);

	Type curTypeDeclaration;
%}

%union
{
    int intVal;
    float floatVal;
    char *strVal;
}

%token <strVal> VAR
%token <floatVal> REAL_CONSTANT
%token <intVal> INT_CONSTANT
%token MAIN
%token END
%token IF ELSE
%token WHILE
%token DATA ALGORITHM
%token EXIT
%token REAL INTEGER
%token COUNTING UPWARD DOWNWARD
%token TO
%token READ PRINT
%token BANG
%token SEMICOLON
%token COLON
%token COMMA
%token LBRACKET RBRACKET
%token PLUS MINUS MULTIPLY DIVIDE MODULO
%token LEQ GEQ GREATER LESS NEQ EQ
%token ASSIGN
%token AND OR NOT
%token LPAR RPAR
%token <strVal> STRING
%token NEWLINE
%token TRASH

%%

program: MAIN SEMICOLON datasection algorithmsection END MAIN SEMICOLON
;

datasection: DATA COLON vardeclarations
;

vardeclarations: /* empty */
|                declaration vardeclarations
;

declaration: INTEGER { curTypeDeclaration = INTEGER_TYPE; } COLON varlist SEMICOLON
|            REAL { curTypeDeclaration = REAL_TYPE; } COLON varlist SEMICOLON
;

varlist: var COMMA varlist
|        var
;

algorithmsection: ALGORITHM COLON statements
;

statements: /* empty */
|           statement statements
;

statement: assignment
|          conditional
|          while
|          read
|          print
|          exit
|          counting
;

assignment: var ASSIGN expression SEMICOLON
;

conditional: IF expression SEMICOLON statements END IF SEMICOLON
|            IF expression SEMICOLON statements ELSE SEMICOLON statements END IF SEMICOLON
;

while: WHILE expression SEMICOLON statements END WHILE SEMICOLON
;

read: READ var SEMICOLON
;

print: PRINT printlist SEMICOLON
;

printlist: printitem printlist
|          printitem
;

printitem: BANG
|          expression
|          STRING
;

exit: EXIT SEMICOLON
;

counting: COUNTING VAR UPWARD expression TO expression SEMICOLON statements END COUNTING SEMICOLON
|         COUNTING VAR DOWNWARD expression TO expression SEMICOLON statements END COUNTING SEMICOLON
;

expression: NOT expression
|           expression AND compareexpr
|           expression OR compareexpr
|           compareexpr
;

compareexpr: compareexpr LESS addexpr
|            compareexpr GREATER addexpr
|            compareexpr LEQ addexpr
|            compareexpr GEQ addexpr
|            compareexpr NEQ addexpr
|            compareexpr EQ addexpr
|            addexpr
;

addexpr: addexpr PLUS mulexpr
|        addexpr MINUS mulexpr
|        mulexpr
;

mulexpr: mulexpr MULTIPLY factor
|        mulexpr MODULO factor
|        mulexpr DIVIDE factor
|        factor
;

factor: LPAR expression RPAR
|       atom
|       MINUS factor
|       PLUS factor
;

atom: var
|     INT_CONSTANT
|     REAL_CONSTANT
;

var: VAR {
            Var var;
         	var.isArray = 0;
         	var.arrayLength = 1;
         	var.name = $VAR;
			var.type = curTypeDeclaration;
			symbolTableAddVar(var); }
|    VAR LBRACKET INT_CONSTANT[LENGTH] RBRACKET {
           Var var;
           var.isArray = 1;
           var.arrayLength = $LENGTH;
           var.name = $VAR;
		   var.type = curTypeDeclaration;
           symbolTableAddVar(var); }
;

%%
