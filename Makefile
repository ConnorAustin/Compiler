compiler: lexer.l parser.y main.c
	bison -d parser.y
	flex lexer.l
	gcc -o compiler main.c parser.tab.c lex.yy.c -lfl

clean:
	rm -f lex.yy.c
	rm -f compiler
	rm -f parser.tab.c
	rm -f parser.tab.h
