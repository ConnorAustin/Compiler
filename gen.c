#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "gen.h"
#include "symbol_table.h"

char** codeStmts = NULL;
int size = 1000; // TODO: Make bigger!
int codeEnd = -1;

void nodeGen(AstNode *node);
void exprGen(AstNode *node);

AstNode *root;

Type getVarType(AstNode *node) {
	Var *var = symbolTableGetVar(node->strVal);
	if(!var) {
		printf("Error: unknown variable: %s\n", node->strVal);
	}

	return var->type;
}

void newCodeStatement() {
	codeEnd += 1;
	if(codeEnd == size) {
		size *= 2;
		codeStmts = (char **)realloc(codeStmts, size * sizeof(char *));
	}
}

int addCode(char *str) {
	newCodeStatement();
	codeStmts[codeEnd] = strdup(str);
	return codeEnd;
}

int addCodeInt(char *str, int x) {
	static char codebuffer[100];
	sprintf(codebuffer, "%s %d", str, x);
	return addCode(codebuffer);
}

int addCodeFloat(char *str, float x) {
	static char codebuffer[100];
	sprintf(codebuffer, "%s %f", str, x);
	return addCode(codebuffer);
}

void insertCode(int index, char *str) {
	newCodeStatement();
	for(int i = codeEnd; i >= index; i--) {
		codeStmts[i + 1] = codeStmts[i];
	}
	codeStmts[index] = str;
}

void replaceCode(int index, char *str) {
	free(codeStmts[index]);
	codeStmts[index] = strdup(str);
}

void replaceCodeInt(int index, char *str, int num) {
	static char codebuffer[100];
	sprintf(codebuffer, "%s %d", str, num);
	return replaceCode(index, codebuffer);
}

void replaceCodeFloat(int index, char *str, float num) {
	static char codebuffer[100];
	sprintf(codebuffer, "%s %f", str, num);
	return replaceCode(index, codebuffer);
}

void addressGen(AstNode *node) {
	Var* var = symbolTableGetVar(node->strVal);
	if(var == NULL) {
		printf("Error: unknown variable: %s\n", node->strVal);
		exit(-1);
	}
	if(var->isArray) {
		exprGen(node->right);
		if(node->right->type == REAL_TYPE) {
			addCode("FTI");
		}
		addCodeInt("LRA", var->address);
		addCode("ADI");
	} else {
		addCodeInt("LRA", var->address);
	}
}

Type resolveTypes(AstNode *node, int leftIndex) {
	Type type = node->left->type;
	if(node->left->type == INTEGER_TYPE && node->right->type == REAL_TYPE) {
		insertCode(leftIndex + 1, "ITF");
		type = REAL_TYPE;
	}
	else if(node->left->type == REAL_TYPE && node->right->type == INTEGER_TYPE) {
		addCode("ITF");
		type = REAL_TYPE;
	}
	return type;
}

void modGen(AstNode *node) {
	// Steps for the mod go as follows:
	/*
	   _a = evaluated left side
	   _b = evaluated right side
	   perform casting if needed on _a and _b
	   return _a - _b * (int)(_a / _b)
	*/

	// Grab our compiler reserved variables
	Var *_a = symbolTableGetVar("_a");
	Var *_b = symbolTableGetVar("_b");

	// _a = evaluated left side
	addCodeInt("LRA", _a->address);
	exprGen(node->left);
	addCode("STO");

	// _b = evaluated right side
	addCodeInt("LRA", _b->address);
	exprGen(node->right);
	addCode("STO");

	// perform casting if needed on _a and _b
	if(node->left->type == INTEGER_TYPE && node->right->type == REAL_TYPE) {
		addCodeInt("LRA", _a->address);
		addCode("LOD");
		addCode("ITF");
		addCodeInt("LRA", _a->address);
		addCode("STO");
	}
	if(node->left->type == REAL_TYPE && node->right->type == INTEGER_TYPE) {
		addCodeInt("LRA", _b->address);
		addCode("LOD");
		addCode("ITF");
		addCodeInt("LRA", _b->address);
		addCode("STO");
	}

	// return _a - _b * (int)(_a / _b)
	addCodeInt("LRA", _a->address);
	addCode("LOD");

	addCodeInt("LRA", _b->address);
	addCode("LOD");

	addCodeInt("LRA", _a->address);
	addCode("LOD");

	addCodeInt("LRA", _b->address);
	addCode("LOD");

	if(node->left->type == REAL_TYPE || node->right->type == REAL_TYPE) {
		node->type = REAL_TYPE;
		addCode("DVF");
		addCode("FTI");
		addCode("ITF");
		addCode("MLF");
		addCode("SBF");
	} else {
		node->type = INTEGER_TYPE;
		addCode("DVI");
		addCode("MLI");
		addCode("SBI");
	}
}

void binaryOP(AstNode *node, char *intOp, char *floatOp) {
	exprGen(node->left);
	int leftIndex = codeEnd;

	exprGen(node->right);

	Type type = resolveTypes(node, leftIndex);
	node->type = type;

	if(type == INTEGER_TYPE) {
		addCode(intOp);
	}
	else {
		addCode(floatOp);
	}
}

void compOP(AstNode *node, char *intOp, char *floatOp) {
	exprGen(node->left);
	int leftIndex = codeEnd;

	exprGen(node->right);

	Type type = resolveTypes(node, leftIndex);

	// Always use integer type
	node->type = INTEGER_TYPE;

	if(type == INTEGER_TYPE) {
		addCode(intOp);
	}
	else {
		addCode(floatOp);
	}
}

void nonZeroGen(Type type) {
	if(type == INTEGER_TYPE) {
		addCodeInt("LLI", 0);
		addCode("NEI");
	} else {
		addCodeFloat("LLF", 0.0f);
		addCode("NEF");
	}
}

void negateGen(AstNode *node) {
	addCode("NOP"); // Reserve space for LLI or LLF
	int loadIndex = codeEnd;

	exprGen(node->right);
	if(node->right->type == INTEGER_TYPE) {
		replaceCodeInt(loadIndex, "LLI", 0);
		addCode("SBI");
	} else {
		replaceCodeFloat(loadIndex, "LLF", 0.0f);
		addCode("SBF");
	}
}

void exprGen(AstNode *node) {
	switch(node->kind) {
		case MOD_OP:
			modGen(node);
			break;

		case AND_OP:
			node->type = INTEGER_TYPE;
			exprGen(node->left);
			nonZeroGen(node->left->type);

			exprGen(node->right);
			nonZeroGen(node->right->type);

			addCode("MLI");
			break;

		case NOT_OP:
			node->type = INTEGER_TYPE;
			exprGen(node->right);
			nonZeroGen(node->right->type);
			addCode("LLI 0");
			addCode("EQI");
			break;

		case OR_OP:
			node->type = INTEGER_TYPE;
			// Check if the left side is non-zero
			exprGen(node->left);
			nonZeroGen(node->left->type);

			// Check if the right side is non-zero
			exprGen(node->right);
			nonZeroGen(node->right->type);

			// Add results
			addCode("ADI");

			// See if result is non-zero
			nonZeroGen(INTEGER_TYPE);

			break;

		case ADD_OP:
			binaryOP(node, "ADI", "ADF");
			break;

		case SUB_OP:
			binaryOP(node, "SBI", "SBF");
			break;

		case MUL_OP:
			binaryOP(node, "MLI", "MLF");
			break;

		case DIV_OP:
			binaryOP(node, "DVI", "DVF");
			break;

		case NEGATE_OP:
			negateGen(node);
			break;

		case LESS_OP:
			compOP(node, "LTI", "LTF");
			break;

		case GREATER_OP:
			compOP(node, "GTI", "GTF");
			break;

		case LEQ_OP:
			compOP(node, "LEI", "LEF");
			break;

		case GEG_OP:
			compOP(node, "GEI", "GEF");
			break;

		case NEQ_OP:
			compOP(node, "NEI", "NEF");
			break;

		case EQ_OP:
			compOP(node, "EQI", "EQF");
			break;

		case VARIABLE: {
			addressGen(node);
			addCode("LOD");

			// Get type of variable
			Var *var = symbolTableGetVar(node->strVal);
			node->type = var->type;
			break;
		}

		case LITERAL_INT:
			addCodeInt("LLI", node->intVal);
			node->type = INTEGER_TYPE;
			break;

		case LITERAL_REAL:
			addCodeFloat("LLF", node->floatVal);
			node->type = REAL_TYPE;
			break;
	}
}

void assignGen(AstNode *node) {
	addressGen(node->left);
	exprGen(node->right);

	Var *var = symbolTableGetVar(node->left->strVal);
	if(var->type == INTEGER_TYPE && node->right->type == REAL_TYPE) {
		addCode("FTI");
	}
	if(var->type == REAL_TYPE && node->right->type == INTEGER_TYPE) {
		addCode("ITF");
	}

	addCode("STO");
}

void printGen(AstNode *node) {
	AstNode *list = node->right;
	while(list != NULL) {
		if(list->kind == LITERAL_NEWLINE) {
			addCode("PTL");
		} else if(list->kind == LITERAL_STRING) {
			for(int i = 1; i < strlen(list->strVal) - 1; i++) {
				int c = (int)list->strVal[i];

				// Skip the paired quotation mark
				if(c == (int)'"') {
					i++;
				}

				addCodeInt("LLI", c);
				addCode("PTC");
			}
		} else {
			// Expression
			exprGen(list);

			if(list->type == INTEGER_TYPE) {
				addCode("PTI");
			} else {
				addCode("PTF");
			}
		}
		list = list->next;
	}
}

void conditionalGen(AstNode *node) {
	exprGen(node->left);
	nonZeroGen(node->left->type);

	addCode("NOP"); // Reserve space for JPF instruction
	int jumpIndex = codeEnd;

	nodeGen(node->right);
	replaceCodeInt(jumpIndex, "JPF", codeEnd + 1); // Fill in the JPF instruction
}

void ifelseGen(AstNode *node) {
	exprGen(node->left);
	nonZeroGen(node->left->type);

	addCode("NOP"); // Reserve space for JPF instruction
	int jumpIndex = codeEnd;

	nodeGen(node->right);

	addCode("NOP"); // Reserve space for JMP instruction to skip over else
	int skipIndex = codeEnd;

	nodeGen(node->misc);

	replaceCodeInt(jumpIndex, "JPF", skipIndex + 1);
	replaceCodeInt(skipIndex, "JMP", codeEnd + 1);
}

void allocateVarsGen() {
	int size = symbolTableTotalSize();
	replaceCodeInt(0, "ISP", size);
}

void reserveVars() {
	Var reservedVar;
	reservedVar.isArray = 0;
	reservedVar.arrayLength = 1;
	reservedVar.type = INTEGER_TYPE;

	reservedVar.name = "_a";
	symbolTableAddVar(reservedVar);

	reservedVar.name = "_b";
	symbolTableAddVar(reservedVar);
}

void whileGen(AstNode *node) {
	int jumpToTopIndex = codeEnd + 1;

	exprGen(node->left);
	nonZeroGen(node->left->type);

	addCode("NOP"); // Reserve space for JPF to bottom
	int jumpToEndIndex = codeEnd;

	nodeGen(node->right);

	addCodeInt("JMP", jumpToTopIndex);

	replaceCodeInt(jumpToEndIndex, "JPF", codeEnd + 1);
}

void countingGen(AstNode *node) {
	static int countingID = 0;

	// Check that the loop control variable is an integer
	if(getVarType(node->misc) != INTEGER_TYPE) {
		printf("Error: The loop control variable '%s' is not an integer.\n", node->misc->strVal);
		exit(-1);
	}

	// Initial value
	addressGen(node->misc);
	exprGen(node->left);
	if(node->left->type == REAL_TYPE) {
		addCode("FTI");
	}
	addCode("STO");

	// Create compiler variable to store the end expression
	char varName[100];
	countingID++;
	Var endVar;
	endVar.isArray = 0;
	endVar.arrayLength = 1;
	endVar.type = INTEGER_TYPE;
	sprintf(varName, "_%d", countingID);
	endVar.name = strdup(varName);
	symbolTableAddVar(endVar);

	// End value
	int endAddress = symbolTableGetVar(varName)->address;
	addCodeInt("LRA", endAddress);
	exprGen(node->right);
	if(node->right->type == REAL_TYPE) {
		addCode("FTI");
	}
	addCode("STO");

	// Conditional
	int countingStartIndex = codeEnd + 1;
	addressGen(node->misc);
	addCode("LOD");
	addCodeInt("LRA", endAddress);
	addCode("LOD");

	if(node->kind == COUNTING_UPWARD_OP) {
		addCode("LEI");
	}
	else {
		addCode("GEI");
	}
	// Reserve spot for JPF to end
	addCode("NOP");
	int jumpToEndIndex = codeEnd;

	// Body
	nodeGen(node->misc2);

	// Increment / Decrement
	addressGen(node->misc);
	addressGen(node->misc);
	addCode("LOD");
	if(node->kind == COUNTING_UPWARD_OP) {
		addCodeInt("LLI", 1);
		addCode("ADI");
	} else {
		addCodeInt("LLI", 1);
		addCode("SBI");
	}
	addCode("STO");

	// Jump back to conditional
	addCodeInt("JMP", countingStartIndex);

	// Fill in jump to bottom
	replaceCodeInt(jumpToEndIndex, "JPF", codeEnd + 1);
}

void exitGen(AstNode *node) {
	addCode("HLT");
}

void readGen(AstNode *node) {
	addressGen(node->right);

	Type type = getVarType(node->right);
	if(type == INTEGER_TYPE) {
		addCode("INI");
	} else {
		addCode("INF");
	}

	addCode("STO");
}

void nodeGen(AstNode *node) {
	while(node != NULL) {
		switch(node->kind) {
			case ASSIGNMENT_OP:
				assignGen(node);
				break;
			case PRINT_OP:
				printGen(node);
				break;
			case CONDITIONAL_OP:
				conditionalGen(node);
				break;
			case IFELSE_OP:
				ifelseGen(node);
				break;
			case WHILE_OP:
				whileGen(node);
				break;
			case COUNTING_UPWARD_OP:
			case COUNTING_DOWNWARD_OP:
				countingGen(node);
				break;
			case EXIT_OP:
				exitGen(node);
				break;
			case READ_OP:
				readGen(node);
				break;
		}
		node = node->next;
	}
}

void codeGen() {
	codeStmts = (char **)malloc(size * sizeof(char *));

	addCode("NOP"); // Reserve spot for allocateVarsGen
	reserveVars();
	nodeGen(root);
	addCode("HLT");
	allocateVarsGen();

	// Print out code
	for(int i = 0; i <= codeEnd; i++) {
		printf("%s\n", codeStmts[i]);
	}
}
