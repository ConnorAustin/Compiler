%{
	/*--------------------*/
	/*   Connor Austin    */
	/*  CS 4223, Compiler */
	/*--------------------*/
	#include <stdio.h>

	int yylex();
	int yyerror(char *s);

%}

%code requires {
	#include <stdlib.h>

	#include "ast.h"
	#include "symbol_table.h"

	extern AstNode* root;

	Type curTypeDeclaration;

	// Helper function to create an expression node in the AST
	AstNode* newExpression(Kind kind, AstNode *left, AstNode *right);
}

%union
{
    int intVal;
    float floatVal;
    char *strVal;
	AstNode *node;
	Var var;
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

%type <var> vardecl
%type <node> algorithmsection
%type <node> statements
%type <node> statement
%type <node> var
%type <node> expression
%type <node> compareexpr
%type <node> addexpr
%type <node> mulexpr
%type <node> factor
%type <node> atom
%type <node> print
%type <node> printlist
%type <node> printitem
%type <node> assignment
%type <node> conditional
%type <node> ifelse
%type <node> while
%type <node> counting
%type <node> exit

%%

program: MAIN SEMICOLON datasection algorithmsection END MAIN SEMICOLON {
    root = $4;
}
;

datasection: DATA COLON vardeclarations
;

vardeclarations: /* empty */
|                declaration vardeclarations
;

declaration: INTEGER { curTypeDeclaration = INTEGER_TYPE; } COLON varlist SEMICOLON
|            REAL { curTypeDeclaration = REAL_TYPE; } COLON varlist SEMICOLON
;

varlist: vardecl COMMA varlist  {
	         symbolTableAddVar($1);
         }
|        vardecl {
	         symbolTableAddVar($1);
         }
;

algorithmsection: ALGORITHM COLON statements {
    $$ = $3;
}
;

statements: /* empty */ {
	            $$ = NULL;
            }
|           statement statements {
                $$ = $1;
				$$->next = $2;
            }
;

statement: assignment {
               $$ = $1;
           }
|          conditional {
               $$ = $1;
           }
|          ifelse {
               $$ = $1;
           }
|          while {
               $$ = $1;
           }
|          read {
               $$ = NULL;
			   perror("Unimplemented code");
           }
|          print {
               $$ = $1;
           }
|          exit {
               $$ = $1;
           }
|          counting {
               $$ = $1;
           }
;

assignment: var ASSIGN expression SEMICOLON {
    $$ = newExpression(ASSIGNMENT_OP, $1, $3);
}
;

conditional: IF expression SEMICOLON statements END IF SEMICOLON {
    $$ = newExpression(CONDITIONAL_OP, $2, $4);
}
;

ifelse: IF expression SEMICOLON statements ELSE SEMICOLON statements END IF SEMICOLON {
	$$ = newExpression(IFELSE_OP, $2, $4);
	$$->misc = $7;
}
;

while: WHILE expression SEMICOLON statements END WHILE SEMICOLON {
    $$ = newExpression(WHILE_OP, $2, $4);
}
;

read: READ var SEMICOLON
;

print: PRINT printlist SEMICOLON {
    $$ = newExpression(PRINT_OP, NULL, $2);
}
;

printlist: printitem COMMA printlist {
               $$ = $1;
			   $$->next = $3;
           }
|          printitem {
               $$ = $1;
           }
;

printitem: BANG {
               $$ = newExpression(LITERAL_NEWLINE, NULL, NULL);
           }
|          expression {
               $$ = $1;
           }
|          STRING {
               $$ = newExpression(LITERAL_STRING, NULL, NULL);
			   $$->strVal = $1;
           }
;

exit: EXIT SEMICOLON {
	      $$ = newExpression(EXIT_OP, NULL, NULL);
      }
;

counting: COUNTING var UPWARD expression TO expression SEMICOLON statements END COUNTING SEMICOLON {
	          $$ = newExpression(COUNTING_UPWARD_OP, $4, $6);
			  $$->misc = $2;
			  $$->misc2 = $8;
          }
|         COUNTING var DOWNWARD expression TO expression SEMICOLON statements END COUNTING SEMICOLON {
             $$ = newExpression(COUNTING_DOWNWARD_OP, $4, $6);
			 $$->misc = $2;
			 $$->misc2 = $8;
          }
;

expression: NOT expression {
                $$ = newExpression(NOT_OP, NULL, $2);
            }
|           expression AND compareexpr {
                $$ = newExpression(AND_OP, $1, $3);
            }
|           expression OR compareexpr  {
                $$ = newExpression(OR_OP, $1, $3);
            }
|           compareexpr  {
                $$ = $1;
            }
;

compareexpr: compareexpr LESS addexpr {
	             $$ = newExpression(LESS_OP, $1, $3);
             }
|            compareexpr GREATER addexpr {
	             $$ = newExpression(GREATER_OP, $1, $3);
             }
|            compareexpr LEQ addexpr {
	             $$ = newExpression(LEQ_OP, $1, $3);
             }
|            compareexpr GEQ addexpr {
	            $$ = newExpression(GEG_OP, $1, $3);
             }
|            compareexpr NEQ addexpr {
	            $$ = newExpression(NEQ_OP, $1, $3);
             }
|            compareexpr EQ addexpr {
	            $$ = newExpression(EQ_OP, $1, $3);
             }
|            addexpr {
	            $$ = $1;
             }
;

addexpr: addexpr PLUS mulexpr {
	         $$ = newExpression(ADD_OP, $1, $3);
         }
|        addexpr MINUS mulexpr {
	         $$ = newExpression(SUB_OP, $1, $3);
         }
|        mulexpr {
	         $$ = $1;
         }
;

mulexpr: mulexpr MULTIPLY factor {
	         $$ = newExpression(MUL_OP, $1, $3);
         }
|        mulexpr MODULO factor {
	         $$ = newExpression(MOD_OP, $1, $3);
         }
|        mulexpr DIVIDE factor {
	         $$ = newExpression(DIV_OP, $1, $3);
         }
|        factor {
	         $$ = $1;
         }
;

factor: LPAR expression RPAR {
	        $$ = $2;
        }
|       atom {
	        $$ = $1;
        }
|       MINUS factor  {
	        $$ = newExpression(NEGATE_OP, NULL, $2);
        }
|       PLUS factor  {
	        $$ = $2;
        }
;

atom: var {
	      $$ = $1;
      }
|     INT_CONSTANT {
	      $$ = (AstNode *)malloc(sizeof(AstNode));
		  $$->kind = LITERAL_INT;
		  $$->intVal = $1;
      }
|     REAL_CONSTANT {
	      $$ = (AstNode *)malloc(sizeof(AstNode));
	      $$->kind = LITERAL_REAL;
	      $$->floatVal = $1;
      }
;

vardecl: VAR {
         $$.isArray = 0;
         $$.arrayLength = 1;
         $$.name = $1;
	     $$.type = curTypeDeclaration;
     }
|    VAR LBRACKET INT_CONSTANT RBRACKET {
         $$.isArray = 1;
         $$.arrayLength = $3;
         $$.name = $1;
		 $$.type = curTypeDeclaration;
     }
;

var: VAR {
         $$ = newExpression(VARIABLE, NULL, NULL);
         $$->strVal = $1;
     }
|    VAR LBRACKET expression RBRACKET {
         $$ = newExpression(VARIABLE, NULL, NULL);
         $$->strVal = $1;
		 $$->right = $3;
     }
;

%%

AstNode* newExpression(Kind kind, AstNode *left, AstNode *right) {
	AstNode *result = (AstNode *)malloc(sizeof(AstNode));
	result->kind = kind;
	result->left = left;
	result->right = right;
	return result;
}
