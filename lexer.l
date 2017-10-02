%{
    /*--------------------*/
    /*   Connor Austin    */
    /*  CS 4223, Compiler */
    /*--------------------*/
    #include <stdio.h>
    #include "parser.tab.h"
    #define DEBUG 1
%}

%%
#.*                                              { if (DEBUG) printf("COMMENT: %s\n", yytext);       return COMMENT; }
[0-9]+((\.[0-9]+(E[-+]?[0-9]+)?)|(E[-+]?[0-9]+)) { if (DEBUG) printf("REAL_CONSTANT: %s\n", yytext); return REAL_CONSTANT; }
[0-9]+                                           { if (DEBUG) printf("INT_CONSTANT: %s\n", yytext);  return INT_CONSTANT; }
[mM][aA][iI][nN]                                 { if (DEBUG) printf("MAIN: %s\n", yytext);          return MAIN; }
[eE][nN][dD]                                     { if (DEBUG) printf("END: %s\n", yytext);           return END; }
[iI][fF]                                         { if (DEBUG) printf("IF: %s\n", yytext);            return IF; }
[eE][lL][sS][eE]                                 { if (DEBUG) printf("ELSE: %s\n", yytext);          return ELSE; }
[wW][hH][iI][lL][eE]                             { if (DEBUG) printf("WHILE: %s\n", yytext);         return WHILE; }
[dD][aA][tT][aA]                                 { if (DEBUG) printf("DATA: %s\n", yytext);          return DATA; }
[aA][lL][gG][oO][rR][iI][tT][hH][mM]             { if (DEBUG) printf("ALGORITHM: %s\n", yytext);     return ALGORITHM; }
[eE][xX][iI][tT]                                 { if (DEBUG) printf("EXIT: %s\n", yytext);          return EXIT; }
[rR][eE][aA][lL]                                 { if (DEBUG) printf("REAL: %s\n", yytext);          return REAL; }
[iI][nN][tT][eE][gG][eE][rR]                     { if (DEBUG) printf("INTEGER: %s\n", yytext);       return INTEGER; }
[cC][oO][uU][nN][tT][iI][nN][gG]                 { if (DEBUG) printf("COUNTING: %s\n", yytext);      return COUNTING; }
[uU][pP][wW][aA][rR][dD]                         { if (DEBUG) printf("UPWARD: %s\n", yytext);        return UPWARD; }
[dD][oO][wW][nN][wW][aA][rR][dD]                 { if (DEBUG) printf("DOWNWARD: %s\n", yytext);      return DOWNWARD; }
[tT][oO]                                         { if (DEBUG) printf("TO: %s\n", yytext);            return TO; }
[rR][eE][aA][dD]                                 { if (DEBUG) printf("READ: %s\n", yytext);          return READ; }
[pP][rR][iI][nN][tT]                             { if (DEBUG) printf("PRINT: %s\n", yytext);         return PRINT; }
":="                                             { if (DEBUG) printf("ASSIGN: %s\n", yytext);        return ASSIGN; }
"!"                                              { if (DEBUG) printf("BANG: %s\n", yytext);          return BANG; }
";"                                              { if (DEBUG) printf("SEMICOLON: %s\n", yytext);     return SEMICOLON; }
":"                                              { if (DEBUG) printf("COLON: %s\n", yytext);         return COLON; }
","                                              { if (DEBUG) printf("COMMA: %s\n", yytext);         return COMMA; }
"["                                              { if (DEBUG) printf("LBRACKET: %s\n", yytext);      return LBRACKET; }
"]"                                              { if (DEBUG) printf("RBRACKET: %s\n", yytext);      return RBRACKET; }
"+"                                              { if (DEBUG) printf("PLUS: %s\n", yytext);          return PLUS; }
"-"                                              { if (DEBUG) printf("MINUS: %s\n", yytext);         return MINUS; }
"*"                                              { if (DEBUG) printf("MULTIPLY: %s\n", yytext);      return MULTIPLY; }
"/"                                              { if (DEBUG) printf("DIVIDE: %s\n", yytext);        return DIVIDE; }
"%"                                              { if (DEBUG) printf("MODULO: %s\n", yytext);        return MODULO; }
"<="                                             { if (DEBUG) printf("LEQ: %s\n", yytext);           return LEQ; }
">="                                             { if (DEBUG) printf("GEQ: %s\n", yytext);           return GEQ; }
">"                                              { if (DEBUG) printf("GREATER: %s\n", yytext);       return GREATER; }
"<"                                              { if (DEBUG) printf("LESS: %s\n", yytext);          return LESS; }
"<>"                                             { if (DEBUG) printf("NEQ: %s\n", yytext);           return NEQ; }
"="                                              { if (DEBUG) printf("EQ: %s\n", yytext);            return EQ; }
"&"                                              { if (DEBUG) printf("AND: %s\n", yytext);           return AND; }
"|"                                              { if (DEBUG) printf("OR: %s\n", yytext);            return OR; }
"~"                                              { if (DEBUG) printf("NOT: %s\n", yytext);           return NOT; }
"("                                              { if (DEBUG) printf("LPAR: %s\n", yytext);          return LPAR; }
")"                                              { if (DEBUG) printf("RPAR: %s\n", yytext);          return RPAR; }
\"([^"\n]|(\"\"))*\"                             { if (DEBUG) printf("STRING: %s\n", yytext);        return STRING; }
[a-zA-Z][a-zA-Z0-9]*                             { if (DEBUG) printf("VAR: %s\n", yytext);           return VAR; }
(\r)*\n                                          { /* if (DEBUG) printf("NEWLINE\n");                return NEWLINE; */ }
[ \t]                                            { /* Do nothing */ }
.                                                { if (DEBUG) printf("TRASH: %s\n", yytext);         return TRASH; }
%%
