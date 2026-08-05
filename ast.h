#ifndef AST_H
#define AST_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

// Define all instruction types
typedef enum {
    NODE_NUM, NODE_IDENT, NODE_ASSIGN, NODE_BINOP, NODE_LOGIC,
    NODE_PRINT, NODE_SCAN, NODE_IF, NODE_FOR, NODE_REPEAT,
    NODE_MATH_FUNC, NODE_BLOCK
} NodeType;

// The Abstract Syntax Tree Node
struct ASTNode {
    NodeType type;
    double val;
    char varName[50];
    char strVal[256];
    int op; 
    struct ASTNode *left, *right, *third, *fourth, *next;
};

// The Symbol Table (Stores Variables)
struct Symbol {
    char name[50];
    double value;
    struct Symbol* next;
};

#endif