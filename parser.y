
%{
#include <stdio.h>
int yylex(void);
void yyerror(char const*);

%}

%debug
%verbose

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
    : follow_list
    | follow_list RANGE
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
    : end_range
    | character_class
    ;
range_expression
    : start_range end_range
    | start_range RANGE
    ;
start_range
    : end_range RANGE
    ;
end_range
    : range_char
    ;
range_char
    : CHAR
    ;

character_class
    : LBRACKET_COLLON CHAR_CLASS RBRACKET_COLLON
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

