%{
	/*--------------------*/
	/*   Connor Austin    */
	/*  CS 4223, Compiler */
	/*--------------------*/
	#include <stdio.h>
	int yylex();
	int yyerror(char *s);
%}

%token VAR
%token REAL_CONSTANT
%token INT_CONSTANT
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
%token STRING
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

declaration: INTEGER COLON varlist SEMICOLON
|            REAL COLON varlist SEMICOLON
;

varlist: varlistitem COMMA varlist
|        varlistitem
;

varlistitem: VAR
|            VAR LBRACKET INT_CONSTANT RBRACKET
;

algorithmsection: ALGORITHM COLON
;

%%
