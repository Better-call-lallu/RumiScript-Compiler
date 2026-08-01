#ifndef AST_H
#define AST_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

// Symbol Table Structure for Variables
typedef struct Symbol {
    char name[50];
    double value;
    struct Symbol* next;
} Symbol;

extern Symbol* symbolTable;

Symbol* getSymbol(const char* name);
void setSymbol(const char* name, double value);

// AST Node Types
typedef enum {
    NODE_NUM,
    NODE_STR,
    NODE_VAR,
    NODE_ASSIGN,
    NODE_BINOP,
    NODE_WHEN,
    NODE_WHILE,
    NODE_REPEAT,
    NODE_SAY,
    NODE_ASK,
    NODE_MATH_FUNC,
    NODE_STMT_LIST
} NodeType;

// AST Node Structure
typedef struct ASTNode {
    NodeType type;
    double numVal;
    char* strVal;
    char* varName;
    char op;
    struct ASTNode* left;
    struct ASTNode* right;
    struct ASTNode* third; // For when/otherwise or loop bodies
    struct ASTNode* next;  // For statement sequences / arg lists
} ASTNode;

ASTNode* createNumNode(double val);
ASTNode* createStrNode(const char* str);
ASTNode* createVarNode(const char* name);
ASTNode* createAssignNode(const char* name, ASTNode* expr);
ASTNode* createBinOpNode(char op, ASTNode* left, ASTNode* right);
ASTNode* createWhenNode(ASTNode* cond, ASTNode* thenBranch, ASTNode* elseBranch);
ASTNode* createWhileNode(ASTNode* cond, ASTNode* body);
ASTNode* createRepeatNode(ASTNode* count, ASTNode* body);
ASTNode* createSayNode(ASTNode* argList);
ASTNode* createAskNode(const char* name);
ASTNode* createMathFuncNode(const char* func, ASTNode* left, ASTNode* right);
ASTNode* appendStmt(ASTNode* list, ASTNode* stmt);

double evalAST(ASTNode* node);
void freeAST(ASTNode* node);

#endif