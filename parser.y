
%{
#include <stdio.h>
int yylex(void);
void yyerror(char const*);

%}

%debug
%verbose
// wykorzystanie parsera GLR, ze wzlêdu na problemy z parsowanie '[a-]'
// w tym miejscu wystêpuje konflikt s/r, ale poprawne rozwi¹zanie jest
// widoczne dopiero po 2 znakach od 'a', a LALR(1) tak daleko nie zagl¹da
%glr-parser

%token OR LPARENT RPARENT LBRACKET LBRACKET_NEG RBRACKET LBRACKET_COLLON RBRACKET_COLLON

%token XNUMBER
%token ONUMBER
%token CHAR_CLASS_PRED CHAR_CLASS
%token SPECIAL_CHAR
%token MULTI
%token RANGE

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
    | CHAR_CLASS_PRED
    | bracket_expr
    ;

metacharacter
    : BOL
    | EOL
    | DOT
    | SPECIAL_CHAR
    | BACKREF
    ;

bracket_expr
    : LBRACKET bracket_list RBRACKET
    | LBRACKET_NEG bracket_list RBRACKET
    ;
bracket_list
    : opt_follow_list1 follow_list opt_follow_list2
    ;
opt_follow_list1
    :
    | RANGE
    | range_expression1
    ;
opt_follow_list2
    :
    | RANGE
    | range_expression2
    ;
range_expression1
    : RANGE RANGE range_char
    ;
range_expression2
    : range_char RANGE RANGE
    ;
follow_list
    : expression_term
    | follow_list expression_term
    ;
expression_term
    : single_expression
    | range_expression
    ;
single_expression
    : range_char
    | character_class
    ;
range_expression
    : range_char RANGE range_char
    ;
range_char
    : CHAR
    | SPECIAL_CHAR
    ;
character_class
    : LBRACKET_COLLON CHAR_CLASS RBRACKET_COLLON
    | CHAR_CLASS_PRED
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

