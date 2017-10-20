#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "symbol_table.h"

SymbolTable table;
int address = 0;

void initSymbolTable() {
	table.length = 0;
}

Var* symbolTableGetVar(char* varName) {
	for(int i = 0; i < table.length; i++) {
		if(strcmp(table.table[i].name, varName) == 0) {
			return &table.table[i];
		}
	}
	return NULL;
}

void symbolTableAddVar(Var var) {
	if(table.length > SYMBOL_TABLE_MAX_VARIABLES) {
		printf("Error: Too many variables");
		exit(-1);
	}
	if(symbolTableGetVar(var.name)) {
		printf("Error: Duplicate variable name \"%s\"\n", var.name);
		exit(-1);
	}
	var.address = address;
	address += var.arrayLength;
	table.table[table.length] = var;
	table.length++;
}

void symbolTablePrint() {
	printf("Symbol Table:\n");
	for(int i = 0; i < table.length; i++) {
		Var var = table.table[i];
		char* type = "Integer";
		if(var.type == REAL_TYPE) {
			type = "Real";
		}

		if(var.isArray) {
			printf("\t%s\t%s[%d]\t@address %d\n", type, var.name, var.arrayLength, var.address);
		} else {
			printf("\t%s\t%s\t@address %d\n", type, var.name, var.address);
		}
	}
}
