#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#define SYMBOL_TABLE_MAX_VARIABLES 300

typedef enum {
	INTEGER_TYPE = 0,
	REAL_TYPE = 1
} Type;

typedef struct {
	char* name;
	int arrayLength;
	int isArray;
	int address;
	Type type;
} Var;

typedef struct {
	Var table[SYMBOL_TABLE_MAX_VARIABLES];
	int length;
} SymbolTable;

void initSymbolTable();
Var* symbolTableGetVar(char* varName);
void symbolTableAddVar(Var var);
void symbolTablePrint();
int symbolTableTotalSize();

#endif
