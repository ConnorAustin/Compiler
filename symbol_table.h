#define SYMBOL_TABLE_MAX_VARIABLES 300

typedef enum {
	INTEGER_TYPE,
	REAL_TYPE
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
