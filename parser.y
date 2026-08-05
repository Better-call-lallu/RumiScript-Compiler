%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "ast.h"

int yylex();
void yyerror(const char *s);

struct Symbol* symTable = NULL;

void setSymbol(char* name, double val) {
    struct Symbol* curr = symTable;
    while(curr != NULL) {
        if(strcmp(curr->name, name) == 0) {
            curr->value = val;
            return;
        }
        curr = curr->next;
    }
    struct Symbol* newSym = (struct Symbol*)malloc(sizeof(struct Symbol));
    strcpy(newSym->name, name);
    newSym->value = val;
    newSym->next = symTable;
    symTable = newSym;
}

double getSymbol(char* name) {
    struct Symbol* curr = symTable;
    while(curr != NULL) {
        if(strcmp(curr->name, name) == 0) return curr->value;
        curr = curr->next;
    }
    return 0;
}

struct ASTNode* createNode(NodeType type) {
    struct ASTNode* node = (struct ASTNode*)malloc(sizeof(struct ASTNode));
    node->type = type;
    node->left = node->right = node->third = node->fourth = node->next = NULL;
    return node;
}

double eval(struct ASTNode* node) {
    if (!node) return 0;
    switch(node->type) {
        case NODE_NUM: return node->val;
        case NODE_IDENT: return getSymbol(node->varName);
        case NODE_ASSIGN: {
            double v = eval(node->left);
            setSymbol(node->varName, v);
            return v;
        }
        case NODE_BINOP: {
            double l = eval(node->left);
            double r = eval(node->right);
            if (node->op == '+') return l + r;
            if (node->op == '-') return l - r;
            if (node->op == '*') return l * r;
            if (node->op == '/') return (r != 0) ? l / r : 0;
            return 0;
        }
        case NODE_LOGIC: {
            double l = eval(node->left);
            double r = eval(node->right);
            if (node->op == 1) return l == r;
            if (node->op == 2) return l != r;
            if (node->op == 3) return l > r;
            if (node->op == 4) return l < r;
            if (node->op == 5) return l >= r;
            if (node->op == 6) return l <= r;
            return 0;
        }
        case NODE_PRINT: {
            struct ASTNode* curr = node->left;
            while(curr != NULL) {
                if (curr->type == NODE_IDENT) {
                    if (strlen(curr->strVal) > 0) printf("%s", curr->strVal);
                    else {
                        double val = getSymbol(curr->varName);
                        if (val == (long long)val) printf("%lld", (long long)val);
                        else printf("%g", val); // Fixed: Drops extra zeros
                    }
                } else if (curr->type == NODE_NUM) {
                    if (curr->val == (long long)curr->val) printf("%lld", (long long)curr->val);
                    else printf("%g", curr->val); // Fixed: Drops extra zeros
                }
                curr = curr->next;
            }
            printf("\n");
            return 0;
        }
        case NODE_SCAN: {
            double input;
            printf("Input for [%s]: ", node->varName);
            if(scanf("%lf", &input) == 1) {
                setSymbol(node->varName, input);
            }
            return 0;
        }
        case NODE_IF: {
            if (eval(node->left)) {
                eval(node->right);
            } else if (node->third) {
                eval(node->third);
            }
            return 0;
        }
        case NODE_FOR: {
            for(eval(node->left); eval(node->right); eval(node->third)) {
                eval(node->fourth);
            }
            return 0;
        }
        case NODE_REPEAT: {
            int count = (int)eval(node->left);
            for(int i=0; i<count; i++) {
                eval(node->right);
            }
            return 0;
        }
        case NODE_MATH_FUNC: {
            double a = eval(node->left);
            if (strcmp(node->varName, "abs") == 0) return fabs(a);
            double b = eval(node->right);
            if (strcmp(node->varName, "pow") == 0) return pow(a, b);
            if (strcmp(node->varName, "max") == 0) return (a > b) ? a : b;
            if (strcmp(node->varName, "min") == 0) return (a < b) ? a : b;
            return 0;
        }
        case NODE_BLOCK: {
            struct ASTNode* curr = node->left;
            while(curr != NULL) {
                eval(curr);
                curr = curr->next;
            }
            return 0;
        }
    }
    return 0;
}
%}

%union {
    double val;
    char str[256];
    struct ASTNode* node;
}

%token <val> NUMBER
%token <str> IDENTIFIER STRING
%token SET PRINT SCAN IF ELSE FOR REPEAT
%token MAX MIN POW ABS
%token EQ NEQ GTE LTE GT LT

%type <node> program stmt_list stmt assign_stmt expr print_args logic_expr

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%left '+' '-'
%left '*' '/'
%nonassoc UMINUS 

%%
program: stmt_list { eval($1); }
       ;

stmt_list: stmt { $$ = createNode(NODE_BLOCK); $$->left = $1; }
         | stmt_list stmt {
             struct ASTNode* curr = $1->left;
             while(curr->next != NULL) curr = curr->next;
             curr->next = $2;
             $$ = $1;
         }
         ;

assign_stmt: SET IDENTIFIER '=' expr {
             $$ = createNode(NODE_ASSIGN);
             strcpy($$->varName, $2);
             $$->left = $4;
         }
         ;

stmt: assign_stmt ';' { $$ = $1; }
    | PRINT '(' print_args ')' ';' {
        $$ = createNode(NODE_PRINT);
        $$->left = $3;
    }
    | SCAN '(' IDENTIFIER ')' ';' {
        $$ = createNode(NODE_SCAN);
        strcpy($$->varName, $3);
    }
    | IF '(' logic_expr ')' '{' stmt_list '}' %prec LOWER_THAN_ELSE {
        $$ = createNode(NODE_IF);
        $$->left = $3;
        $$->right = $6;
    }
    | IF '(' logic_expr ')' '{' stmt_list '}' ELSE '{' stmt_list '}' {
        $$ = createNode(NODE_IF);
        $$->left = $3;
        $$->right = $6;
        $$->third = $10;
    }
    | FOR '(' assign_stmt ';' logic_expr ';' assign_stmt ')' '{' stmt_list '}' {
        $$ = createNode(NODE_FOR);
        $$->left = $3;   
        $$->right = $5;  
        $$->third = $7;  
        $$->fourth = $10; 
    }
    | REPEAT '(' expr ')' '{' stmt_list '}' {
        $$ = createNode(NODE_REPEAT);
        $$->left = $3;
        $$->right = $6;
    }
    ;

print_args: STRING {
             $$ = createNode(NODE_IDENT);
             strcpy($$->strVal, $1);
         }
         | IDENTIFIER {
             $$ = createNode(NODE_IDENT);
             strcpy($$->varName, $1);
         }
         | NUMBER {
             $$ = createNode(NODE_NUM);
             $$->val = $1;
         }
         | print_args ',' STRING {
             struct ASTNode* n = createNode(NODE_IDENT);
             strcpy(n->strVal, $3);
             struct ASTNode* curr = $1;
             while(curr->next != NULL) curr = curr->next;
             curr->next = n;
             $$ = $1;
         }
         | print_args ',' IDENTIFIER {
             struct ASTNode* n = createNode(NODE_IDENT);
             strcpy(n->varName, $3);
             struct ASTNode* curr = $1;
             while(curr->next != NULL) curr = curr->next;
             curr->next = n;
             $$ = $1;
         }
         | print_args ',' NUMBER {
             struct ASTNode* n = createNode(NODE_NUM);
             n->val = $3;
             struct ASTNode* curr = $1;
             while(curr->next != NULL) curr = curr->next;
             curr->next = n;
             $$ = $1;
         }
         ;

logic_expr: expr EQ expr { $$ = createNode(NODE_LOGIC); $$->left = $1; $$->right = $3; $$->op = 1; }
          | expr NEQ expr { $$ = createNode(NODE_LOGIC); $$->left = $1; $$->right = $3; $$->op = 2; }
          | expr GT expr { $$ = createNode(NODE_LOGIC); $$->left = $1; $$->right = $3; $$->op = 3; }
          | expr LT expr { $$ = createNode(NODE_LOGIC); $$->left = $1; $$->right = $3; $$->op = 4; }
          | expr GTE expr { $$ = createNode(NODE_LOGIC); $$->left = $1; $$->right = $3; $$->op = 5; }
          | expr LTE expr { $$ = createNode(NODE_LOGIC); $$->left = $1; $$->right = $3; $$->op = 6; }
          | expr { $$ = $1; } 
          ;

expr: NUMBER { $$ = createNode(NODE_NUM); $$->val = $1; }
    | IDENTIFIER { $$ = createNode(NODE_IDENT); strcpy($$->varName, $1); }
    | expr '+' expr { $$ = createNode(NODE_BINOP); $$->left = $1; $$->right = $3; $$->op = '+'; }
    | expr '-' expr { $$ = createNode(NODE_BINOP); $$->left = $1; $$->right = $3; $$->op = '-'; }
    | expr '*' expr { $$ = createNode(NODE_BINOP); $$->left = $1; $$->right = $3; $$->op = '*'; }
    | expr '/' expr { $$ = createNode(NODE_BINOP); $$->left = $1; $$->right = $3; $$->op = '/'; }
    | '-' expr %prec UMINUS { $$ = createNode(NODE_BINOP); $$->left = createNode(NODE_NUM); $$->left->val = 0; $$->right = $2; $$->op = '-'; } // Fixed: Unary Minus Support
    | ABS '(' expr ')' { $$ = createNode(NODE_MATH_FUNC); strcpy($$->varName, "abs"); $$->left = $3; }
    | POW '(' expr ',' expr ')' { $$ = createNode(NODE_MATH_FUNC); strcpy($$->varName, "pow"); $$->left = $3; $$->right = $5; }
    | MAX '(' expr ',' expr ')' { $$ = createNode(NODE_MATH_FUNC); strcpy($$->varName, "max"); $$->left = $3; $$->right = $5; }
    | MIN '(' expr ',' expr ')' { $$ = createNode(NODE_MATH_FUNC); strcpy($$->varName, "min"); $$->left = $3; $$->right = $5; }
    | '(' expr ')' { $$ = $2; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *f = fopen(argv[1], "r");
        if (!f) { perror(argv[1]); return 1; }
        extern FILE *yyin;
        yyin = f;
    }
    yyparse();
    return 0;
}