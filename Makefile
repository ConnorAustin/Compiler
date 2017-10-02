compiler: lexer.l parser.y
	bison -d parser.y
	flex lexer.l
	gcc -o compiler parser.tab.c lex.yy.c -lfl
	./compiler < test.slic

clean:
	rm -f lex.yy.c
	rm -f compiler
	rm -f parser.tab.c
	rm -f parser.tab.h
