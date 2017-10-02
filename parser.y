%{
	#include <stdio.h>
	int yylex();
	int yyerror(char *s);
%}

%token COMMENT
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
|                vardeclarations declaration
;

declaration: INTEGER COLON varlist SEMICOLON
|            REAL COLON varlist SEMICOLON
;

varlist: varlist COMMA VAR
|        varlist COMMA VAR LBRACKET INT_CONSTANT RBRACKET
|        VAR
|        VAR LBRACKET INT_CONSTANT RBRACKET
;

algorithmsection: ALGORITHM COLON statements
;

statements: /* empty */
|           statements statement
;

statement: assignment
|          conditional
|          while
|          read
|          print
|          exit
|          counting
;

assignment: VAR ASSIGN expression SEMICOLON
;

conditional: IF expression SEMICOLON statements END IF SEMICOLON
|            IF expression SEMICOLON statements ELSE SEMICOLON statements END IF SEMICOLON
;

while: WHILE expression SEMICOLON statements END WHILE SEMICOLON
;

read: READ VAR SEMICOLON
;

print: PRINT printlist SEMICOLON
;

printlist: printlist COMMA BANG
|          printlist COMMA STRING
|          printlist expression
|          BANG
|          STRING
|          expression
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

atom: VAR
|     VAR LBRACKET expression RBRACKET
|     INT_CONSTANT
|     REAL_CONSTANT
;

%%

int main() {
	yyparse();
}

int yyerror(char *status) {
	printf("%s", status);
	return 0;
}
