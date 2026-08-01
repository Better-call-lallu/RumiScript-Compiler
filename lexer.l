%{
#include "ast.h"
#include "parser.tab.h"
#include <string.h>
%}

%option noyywrap

%%

[ \t\r\n]+              ; // Skip whitespace
"//".*                  ; // Single-line comments

"set"                   { return SET; }
"say"                   { return SAY; }
"ask"                   { return ASK; }
"when"                  { return WHEN; }
"otherwise"             { return OTHERWISE; }
"while"                 { return WHILE; }
"repeat"                { return REPEAT; }

"max"                   { return MAX_KW; }
"min"                   { return MIN_KW; }
"pow"                   { return POW_KW; }
"abs"                   { return ABS_KW; }

[0-9]+(\.[0-9]+)?       { yylval.numVal = atof(yytext); return NUMBER; }
\"([^\"\\]|\\.)*\"      { 
                            yytext[strlen(yytext)-1] = '\0'; 
                            yylval.strVal = strdup(yytext + 1); 
                            return STRING; 
                        }
[a-zA-Z_][a-zA-Z0-9_]*  { yylval.strVal = strdup(yytext); return IDENTIFIER; }

"=="                    { yylval.op = 'E'; return EQ; }
"!="                    { yylval.op = 'N'; return NEQ; }
">="                    { yylval.op = 'G'; return GE; }
"<="                    { yylval.op = 'L'; return LE; }
">"                     { yylval.op = '>'; return '>'; }
"<"                     { yylval.op = '<'; return '<'; }

"+"                     { return '+'; }
"-"                     { return '-'; }
"*"                     { return '*'; }
"/"                     { return '/'; }
"="                     { return '='; }
";"                     { return ';'; }
","                     { return ','; }
"("                     { return '('; }
")"                     { return ')'; }
"{"                     { return '{'; }
"}"                     { return '}'; }

.                       { printf("Lexical Error: Unknown character %s\n", yytext); }

%%