#include <stdio.h>
#include "parser.tab.h"
#include "symbol_table.h"
#include "gen.h"

extern int lineNumber;

int main() {
	// If an error occurred
	if(yyparse()) {
		printf("Grammar not accepted...\n");
	}
	else {
		codeGen();
	}
}

int yyerror(char *status) {
	return 0;
}
