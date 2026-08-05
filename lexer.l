%{
#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>
%}

%option noyywrap

%%

[ \t\r\n]+          ; // Ignore whitespace
"//".*              ; // Ignore comments

"set"               { return SET; }
"print"             { return PRINT; }
"scan"              { return SCAN; }
"if"                { return IF; }
"else"              { return ELSE; }
"for"               { return FOR; }
"repeat"            { return REPEAT; }

"max"               { return MAX; }
"min"               { return MIN; }
"pow"               { return POW; }
"abs"               { return ABS; }

[a-zA-Z_][a-zA-Z0-9_]* { strcpy(yylval.str, yytext); return IDENTIFIER; }
[0-9]+(\.[0-9]+)?      { yylval.val = atof(yytext); return NUMBER; }
\"([^\"\\]|\\.)*\"     { yytext[strlen(yytext)-1] = '\0'; strcpy(yylval.str, yytext+1); return STRING; }

"=="                { return EQ; }
"!="                { return NEQ; }
">="                { return GTE; }
"<="                { return LTE; }
">"                 { return GT; }
"<"                 { return LT; }

[-+*/=(){};,]       { return yytext[0]; }

.                   { /* Ignore unknown characters */ }

%%