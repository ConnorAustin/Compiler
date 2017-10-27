compiler: lexer.l parser.y gen.c symbol_table.c main.c
	bison -d parser.y
	flex lexer.l
	gcc -o compiler gen.c symbol_table.c main.c parser.tab.c lex.yy.c -lfl

clean:
	rm -f lex.yy.c
	rm -f compiler
	rm -f parser.tab.c
	rm -f parser.tab.h
