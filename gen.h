#ifndef GEN_H
#define GEN_H

#include "ast.h"

void codegen(AstNode *root);

void exprgen(AstNode *root);

void addressgen();

#endif
