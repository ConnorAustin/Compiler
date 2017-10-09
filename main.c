#include "parser.tab.h"
#include <stdio.h>

int main() {
	// If an error occurred
	if(yyparse()) {
		printf("Grammar not accepted...\n");
	}
	else {
		printf("Grammar accepted!\n");
	}
}

int yyerror(char *status) {
	return 0;
}
