#ifndef AST_H
#define AST_H
#include "symbol_table.h"

typedef enum {
	ADD_OP,
	SUB_OP,
	MUL_OP,
	DIV_OP,
	MOD_OP,
	NEGATE_OP,
	AND_OP,
	NOT_OP,
	OR_OP,
	LESS_OP,
	GREATER_OP,
	LEQ_OP,
	GEG_OP,
	NEQ_OP,
	EQ_OP,
	ASSIGNMENT_OP,
	CONDITIONAL_OP,
	IFELSE_OP,
	PRINT_OP,
	WHILE_OP,
	COUNTING_DOWNWARD_OP,
	COUNTING_UPWARD_OP,
	VARIABLE,
	LITERAL_INT,
	LITERAL_REAL,
	LITERAL_STRING,
	LITERAL_NEWLINE
} Kind;

typedef struct AstNode {
	struct AstNode *next;

	struct AstNode *left;
	struct AstNode *right;
	struct AstNode *misc;
	struct AstNode *misc2;

	Kind kind;
	Type type;

	float floatVal;
	int intVal;
	char* strVal;
} AstNode;

#endif
