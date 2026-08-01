%{
#include "ast.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

void yyerror(const char* s);
int yylex(void);

Symbol* symbolTable = NULL;

Symbol* getSymbol(const char* name) {
    Symbol* s = symbolTable;
    while (s) {
        if (strcmp(s->name, name) == 0) return s;
        s = s->next;
    }
    return NULL;
}

void setSymbol(const char* name, double value) {
    Symbol* s = getSymbol(name);
    if (!s) {
        s = (Symbol*)malloc(sizeof(Symbol));
        strcpy(s->name, name);
        s->next = symbolTable;
        symbolTable = s;
    }
    s->value = value;
}

ASTNode* createNumNode(double val) {
    ASTNode* n = (ASTNode*)calloc(1, sizeof(ASTNode));
    n->type = NODE_NUM; n->numVal = val; return n;
}

ASTNode* createStrNode(const char* str) {
    ASTNode* n = (ASTNode*)calloc(1, sizeof(ASTNode));
    n->type = NODE_STR; n->strVal = strdup(str); return n;
}

ASTNode* createVarNode(const char* name) {
    ASTNode* n = (ASTNode*)calloc(1, sizeof(ASTNode));
    n->type = NODE_VAR; n->varName = strdup(name); return n;
}

ASTNode* createAssignNode(const char* name, ASTNode* expr) {
    ASTNode* n = (ASTNode*)calloc(1, sizeof(ASTNode));
    n->type = NODE_ASSIGN; n->varName = strdup(name); n->left = expr; return n;
}

ASTNode* createBinOpNode(char op, ASTNode* left, ASTNode* right) {
    ASTNode* n = (ASTNode*)calloc(1, sizeof(ASTNode));
    n->type = NODE_BINOP; n->op = op; n->left = left; n->right = right; return n;
}

ASTNode* createWhenNode(ASTNode* cond, ASTNode* thenBranch, ASTNode* elseBranch) {
    ASTNode* n = (ASTNode*)calloc(1, sizeof(ASTNode));
    n->type = NODE_WHEN; n->left = cond; n->right = thenBranch; n->third = elseBranch; return n;
}

ASTNode* createWhileNode(ASTNode* cond, ASTNode* body) {
    ASTNode* n = (ASTNode*)calloc(1, sizeof(ASTNode));
    n->type = NODE_WHILE; n->left = cond; n->right = body; return n;
}

ASTNode* createRepeatNode(ASTNode* count, ASTNode* body) {
    ASTNode* n = (ASTNode*)calloc(1, sizeof(ASTNode));
    n->type = NODE_REPEAT; n->left = count; n->right = body; return n;
}

ASTNode* createSayNode(ASTNode* argList) {
    ASTNode* n = (ASTNode*)calloc(1, sizeof(ASTNode));
    n->type = NODE_SAY; n->left = argList; return n;
}

ASTNode* createAskNode(const char* name) {
    ASTNode* n = (ASTNode*)calloc(1, sizeof(ASTNode));
    n->type = NODE_ASK; n->varName = strdup(name); return n;
}

ASTNode* createMathFuncNode(const char* func, ASTNode* left, ASTNode* right) {
    ASTNode* n = (ASTNode*)calloc(1, sizeof(ASTNode));
    n->type = NODE_MATH_FUNC; n->varName = strdup(func); n->left = left; n->right = right; return n;
}

ASTNode* appendStmt(ASTNode* list, ASTNode* stmt) {
    if (!stmt) return list;
    if (!list) return stmt;
    ASTNode* cur = list;
    while (cur->next) cur = cur->next;
    cur->next = stmt;
    return list;
}

double evalAST(ASTNode* node) {
    if (!node) return 0;
    switch (node->type) {
        case NODE_NUM: return node->numVal;
        case NODE_VAR: {
            Symbol* s = getSymbol(node->varName);
            if (!s) { printf("Runtime Error: Undefined variable '%s'\n", node->varName); return 0; }
            return s->value;
        }
        case NODE_ASSIGN: {
            double val = evalAST(node->left);
            setSymbol(node->varName, val);
            return val;
        }
        case NODE_BINOP: {
            double l = evalAST(node->left);
            double r = evalAST(node->right);
            switch (node->op) {
                case '+': return l + r;
                case '-': return l - r;
                case '*': return l * r;
                case '/': return r != 0 ? l / r : 0;
                case '>': return l > r;
                case '<': return l < r;
                case 'E': return l == r;
                case 'N': return l != r;
                case 'G': return l >= r;
                case 'L': return l <= r;
            }
            return 0;
        }
        case NODE_WHEN: {
            if (evalAST(node->left)) evalAST(node->right);
            else if (node->third) evalAST(node->third);
            return 0;
        }
        case NODE_WHILE: {
            while (evalAST(node->left)) evalAST(node->right);
            return 0;
        }
        case NODE_REPEAT: {
            int count = (int)evalAST(node->left);
            for (int i = 0; i < count; i++) evalAST(node->right);
            return 0;
        }
        case NODE_SAY: {
            ASTNode* arg = node->left;
            while (arg) {
                if (arg->type == NODE_STR) printf("%s", arg->strVal);
                else printf("%g", evalAST(arg));
                arg = arg->next;
            }
            printf("\n");
            return 0;
        }
        case NODE_ASK: {
            double val;
            printf("Input for [%s]: ", node->varName);
            if (scanf("%lf", &val) == 1) setSymbol(node->varName, val);
            return 0;
        }
        case NODE_MATH_FUNC: {
            double l = evalAST(node->left);
            double r = node->right ? evalAST(node->right) : 0;
            if (strcmp(node->varName, "max") == 0) return l > r ? l : r;
            if (strcmp(node->varName, "min") == 0) return l < r ? l : r;
            if (strcmp(node->varName, "pow") == 0) return pow(l, r);
            if (strcmp(node->varName, "abs") == 0) return fabs(l);
            return 0;
        }
        case NODE_STMT_LIST: {
            ASTNode* cur = node->left;
            while (cur) { evalAST(cur); cur = cur->next; }
            return 0;
        }
    }
    return 0;
}
%}

%union {
    double numVal;
    char* strVal;
    char op;
    struct ASTNode* nodeVal;
}

%token <numVal> NUMBER
%token <strVal> STRING IDENTIFIER
%token SET SAY ASK WHEN OTHERWISE WHILE REPEAT
%token MAX_KW MIN_KW POW_KW ABS_KW
%token EQ NEQ GE LE

%type <nodeVal> program stmt_list stmt expr arg_list block

%right '='
%left EQ NEQ '>' '<' GE LE
%left '+' '-'
%left '*' '/'

%%

program:
    stmt_list { 
        ASTNode* root = (ASTNode*)calloc(1, sizeof(ASTNode));
        root->type = NODE_STMT_LIST;
        root->left = $1;
        evalAST(root); 
    }
;

stmt_list:
    stmt_list stmt { $$ = appendStmt($1, $2); }
  | stmt           { $$ = $1; }
;

stmt:
    SET IDENTIFIER '=' expr opt_semi                           { $$ = createAssignNode($2, $4); }
  | SAY '(' arg_list ')' opt_semi                              { $$ = createSayNode($3); }
  | ASK '(' IDENTIFIER ')' opt_semi                            { $$ = createAskNode($3); }
  | WHEN '(' expr ')' block OTHERWISE block                    { $$ = createWhenNode($3, $5, $7); }
  | WHEN '(' expr ')' block                                    { $$ = createWhenNode($3, $5, NULL); }
  | WHILE '(' expr ')' block                                   { $$ = createWhileNode($3, $5); }
  | REPEAT '(' expr ')' block                                  { $$ = createRepeatNode($3, $5); }
  | ';'                                                        { $$ = NULL; }
;

opt_semi:
    ';'
  | /* empty */
;

block:
    '{' stmt_list '}' { 
        ASTNode* listNode = (ASTNode*)calloc(1, sizeof(ASTNode));
        listNode->type = NODE_STMT_LIST;
        listNode->left = $2;
        $$ = listNode;
    }
  | '{' '}' { $$ = NULL; }
;

arg_list:
    arg_list ',' expr { $$ = appendStmt($1, $3); }
  | expr              { $$ = $1; }
;

expr:
    NUMBER                                 { $$ = createNumNode($1); }
  | STRING                                 { $$ = createStrNode($1); }
  | IDENTIFIER                             { $$ = createVarNode($1); }
  | expr '+' expr                          { $$ = createBinOpNode('+', $1, $3); }
  | expr '-' expr                          { $$ = createBinOpNode('-', $1, $3); }
  | expr '*' expr                          { $$ = createBinOpNode('*', $1, $3); }
  | expr '/' expr                          { $$ = createBinOpNode('/', $1, $3); }
  | expr '>' expr                          { $$ = createBinOpNode('>', $1, $3); }
  | expr '<' expr                          { $$ = createBinOpNode('<', $1, $3); }
  | expr EQ expr                           { $$ = createBinOpNode('E', $1, $3); }
  | expr NEQ expr                          { $$ = createBinOpNode('N', $1, $3); }
  | MAX_KW '(' expr ',' expr ')'           { $$ = createMathFuncNode("max", $3, $5); }
  | MIN_KW '(' expr ',' expr ')'           { $$ = createMathFuncNode("min", $3, $5); }
  | POW_KW '(' expr ',' expr ')'           { $$ = createMathFuncNode("pow", $3, $5); }
  | ABS_KW '(' expr ')'                    { $$ = createMathFuncNode("abs", $3, NULL); }
  | '(' expr ')'                           { $$ = $2; }
;

%%

void yyerror(const char* s) {
    fprintf(stderr, "Syntax Error: %s\n", s);
}

extern FILE* yyin;

int main(int argc, char** argv) {
    if (argc > 1) {
        FILE* file = fopen(argv[1], "r");
        if (!file) {
            perror("Error opening file");
            return 1;
        }
        yyin = file;
    }
    if (yyparse() != 0) {
        fprintf(stderr, "Parsing failed.\n");
    }
    return 0;
}