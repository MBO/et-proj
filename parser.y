
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
    | character_class
    ;

metacharacter
    : BOL
    | EOL
    | DOT
    | SPECIAL_CHAR
    | BACKREF
    ;

character_class
    : CHAR_CLASS_PRED
    | LBRACKET character_class_first_char sth RBRACKET
    | LBRACKET_NEG character_class_first_char sth RBRACKET
    ;

character_class_first_char
    :
    | '-'
    | RBRACKET
    ;
sth
    : sth character_class_char
    | sth character_class_char '-' character_class_char
    | character_class_char
    | character_class_char '-' character_class_char
    ;

// TODO przerobiæ w *.l na oddzielny stan!!!
character_class_char
    : CHAR
    ;

%%

int main(int ac, char** av)
{
    return yyparse();
}

void yyerror(char const *s)
{
    yydebug = 1;
    fprintf(stderr, "%s\n", s);
}

