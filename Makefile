all:
	bison -d parser.y
	flex lexer.l
	gcc lex.yy.c parser.tab.c -lm -o rumiscript

clean:
	rm -f lex.yy.c parser.tab.c parser.tab.h rumiscript