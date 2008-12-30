
%{
#include <stdio.h>
int yylex(void);
void yyerror(char const*);

%}

%debug
%verbose

%token OR LPARENT RPARENT LBRACKET LBRACKET_NEG RBRACKET

%token DIGIT
%token XNUMBER
%token ONUMBER
%token CHAR_CLASS_PRED
%token SPECIAL_CHAR
%token MULTI
%token CLASS_RANGE

%token BOL EOL
%token DOT
%token BACKREF

%token CHAR

%%

prog
    :
    | prog line
    ;

line
    : '\n'
    | pattern '\n'
    | error '\n'
    ;

/* definicja regexpa za dokumentacj¹ VIM (:he pattern.txt) */
pattern
    : branch
    | pattern OR branch
    ;

branch
    : piece
    | branch piece
    ;

piece
    : atom
    | atom MULTI
    ;

atom
    : ordinary_atom
    | LPARENT pattern RPARENT
    ;

ordinary_atom
    : metacharacter
    | XNUMBER
    | ONUMBER
    | CHAR
    | class
    ;

metacharacter
    : BOL
    | EOL
    | DOT
    | SPECIAL_CHAR
    | BACKREF
    ;

class
    : CHAR_CLASS_PRED
    | LBRACKET class_body RBRACKET
    | LBRACKET_NEG class_body RBRACKET
    ;

class_first_char
    :
//    | '-'
//    | RBRACKET
    ;
class_body
    : class_char
    | class_char CLASS_RANGE class_char
    ;

// TODO przerobiæ w *.l na oddzielny stan!!!
class_char
    : CHAR
    ;

%%

int main(int ac, char** av)
{
    if (ac > 1) {
        yydebug = 1;
    }
    return yyparse();
}

void yyerror(char const *s)
{
    fprintf(stderr, "%s\n", s);
}

