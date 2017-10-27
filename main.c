#include <stdio.h>
#include "parser.tab.h"
#include "symbol_table.h"

extern int lineNumber;

int main() {
	// If an error occurred
	if(yyparse()) {
		printf("Grammar not accepted...\n");
	}
	else {
		symbolTablePrint();
		printf("Grammar accepted\n");
	}
}

int yyerror(char *status) {
	return 0;
}
