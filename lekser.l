%{
#include "parser.h"

void step()
{
    yylloc.first_column = yylloc.last_column;
    yylloc.first_line   = yylloc.last_line;
    yylloc.last_column += strlen(yytext);
}
%}

%option noyywrap noyymore nounput

_DIGIT [0-9]
_ODIGIT [0-7]
_XDIGIT [0-9a-fA-F]
_WORD [a-zA-Z]

%x BE1ST
%x BE
%x CLASS

%%

\| {
    step();
    return OR;
    }
\( {
    step();
    return LPAREN;
    }
\) {
    step();
    return RPAREN;
    }
"\[^"/"\]" {
    step();
    BEGIN(BE1ST);
    return LBRACKET_NEG;
    }
"\[\^" {
    step();
    BEGIN(BE);
    return LBRACKET_NEG;
    }
"\["/"\]" {
    step();
    BEGIN(BE1ST);
    return LBRACKET;
    }
"\[" {
    step();
    BEGIN(BE);
    return LBRACKET;
    }
<BE1ST>"\]" {
    step();
    BEGIN(BE);
    yylval.num = yytext[0];
    return CHAR;
    }
<BE>"\]" {
    step();
    BEGIN(INITIAL);
    return RBRACKET;
    }
<BE>- {
    step();
    return RANGE;
    }

<BE>"\[:" {
    step();
    BEGIN(CLASS);
    return LBRACKET_COLLON;
    }
<CLASS>":\]" {
    step();
    BEGIN(BE);
    return RBRACKET_COLLON;
    }
<CLASS>{
{_WORD}+ {
    step();
    // ???
    return CHAR_CLASS;
    }
}

\\0([0-3]?{_ODIGIT}{2}|{_ODIGIT}{1,2}) {
    step();
    int num = 0;
    for (int i = 2; yytext[i]; i++) {
        num <<= 3;
        num += yytext[i]-'0';
    }
    yylval.num = num;
    return ONUMBER;
    }
\\x{_XDIGIT}{4} {
    step();
    int num = 0;
    for (int i = 2; i < 6; i++) {
        num <<= 4;
        num += (yytext[i] <= '9')
             ? yytext[i]-'0'
             : (yytext[i] <= 'f')
                ? yytext[i]-'a'
                : yytext[i]-'A';
    }
    yylval.num = num;
    return XNUMBER;
    }

\\[1-9] {
    step();
    yylval.num = yytext[1] - '0';
    return BACKREF;
    }

\^|\$ {
    step();
    yylval.num = yytext[0];
    return ANCHOR;
    }
\\b|\\B {
    step();
    yylval.num = yytext[1];
    return ANCHOR;
    }
\. {
    step();
    return DOT;
    }

\*|\+|\? {
    step();
    switch (yytext[0]) {
        case '*': yylval.r.min = 0; yylval.r.max = -1; break;
        case '+': yylval.r.min = 1; yylval.r.max = -1; break;
        case '?': yylval.r.min = 0; yylval.r.max =  1; break;
    };
    return MULTI;
    }
\{\s*{_DIGIT}+\s*\} {
    step();
    yylval.r.min = yylval.r.max = atoi(&yytext[1]);
    return MULTI;
    }
\{\s*{_DIGIT}+\s*,\s*{_DIGIT}+\s*\} {
    step();
    yylval.r.min = atoi(&yytext[1]);
    yylval.r.max = atoi(strchr(yytext, ',') + 1);
    return MULTI;
    }
\{\s*{_DIGIT}+\s*,\s*\} {
    step();
    yylval.r.min = atoi(&yytext[1]);
    yylval.r.max = -1;
    return MULTI;
    }
\{\s*,\s*{_DIGIT}+\s*\} {
    step();
    yylval.r.min = 0;
    yylval.r.max = atoi(strchr(yytext, ',') + 1);
    return MULTI;
    }

<INITIAL,BE>{
\n {
    yylloc.first_column = yylloc.last_column;
    yylloc.last_column = 0;
    yylloc.last_line++;
    return *yytext;
    }
\\d|\\D|\\s|\\S|\\w|\\W {
    step();
    yylval.num = yytext[1];
    return CHAR_CLASS_PRED;
    }
\\a|\\f|\\n|\\r|\\t|\\v {
    step();
    yylval.num = yytext[1];
    return SPECIAL_CHAR;
    }

\\\. {
    step();
    yylval.num = yytext[1];
    return CHAR;
    }
. {
    step();
    yylval.num = yytext[0];
    return CHAR;
    }
}

%%
