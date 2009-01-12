
%{
#include <stdio.h>
#include "ast.h"

int yylex(void);
void yyerror(char const*);

typedef struct {
    int min;
    int max;
} range;

%}

%union {
    range r;
    int num;
    Node* N;
    CharacterNode* ChN;
}

%locations
%debug
%verbose
// wykorzystanie parsera GLR, ze wzlędu na problemy z parsowanie '[a-]'
// w tym miejscu występuje konflikt s/r, ale poprawne rozwiązanie jest
// widoczne dopiero po 2 znakach od 'a', a LALR(1) tak daleko nie zagląda
%glr-parser

%token OR LPAREN RPAREN LBRACKET LBRACKET_NEG RBRACKET LBRACKET_COLLON RBRACKET_COLLON
%token XNUMBER ONUMBER
%token CHAR CHAR_CLASS_PRED CHAR_CLASS SPECIAL_CHAR RANGE BACKREF
%token MULTI DOT ANCHOR

%type <N> pattern branch piece atom ordinary_atom metacharacter
%type <N> bracket_expr bracket_list follow_list
%type <N> opt_follow_list1 opt_follow_list2 range_expression1 range_expression2
%type <N> range_expression single_expression expression_term
%type <N> character_class
%type <ChN> range_char

%%

prog
    :
    | prog line
    ;

line
    : '\n'
    | pattern '\n' { std::cout << "Wyrazenie\n"; $1->print(1); delete $1; std::cout << "\n"; }
    | error '\n'   { yyerrok; }
    ;

/* definicja regexpa za dokumentacj? VIM (:he pattern.txt) */
pattern
    : branch { $$ = new PatternNode($1); }
    | pattern OR branch { $$ = $1->add($3); }
    ;

branch
    : piece { $$ = new BranchNode($1); }
    | branch piece { $$ = $1->add($2); }
    ;

piece
    : atom { $$ = $1; }
    | atom MULTI { $$ = new PieceNode($1, $<r>2.min, $<r>2.max); }
    ;

atom
    : ordinary_atom { $$ = $1; }
    | LPAREN pattern RPAREN { $$ = new SubpatternNode($2); }
    ;

ordinary_atom
    : metacharacter { $$ = $$; }
    | XNUMBER { $$ = new HexCharNode($<num>1); }
    | ONUMBER { $$ = new OctCharNode($<num>1); }
    | CHAR { $$ = new CharacterNode($<num>1); }
    | CHAR_CLASS_PRED { $$ = new PredClassNode($<num>1); }
    | bracket_expr { $$ = $1; }
    ;

metacharacter
    : ANCHOR { $$ = new AnchorNode($<num>1); }
    | DOT { $$ = new Node("dowolny znak"); }
    | SPECIAL_CHAR { $$ = new SpecialCharNode($<num>1); }
    | BACKREF { $$ = new BackrefNode($<num>1); }
    ;

bracket_expr
    : LBRACKET bracket_list RBRACKET { $$ = new BracketNode(0, $2); }
    | LBRACKET_NEG bracket_list RBRACKET { $$ = new BracketNode(1, $2); }
    ;
bracket_list
    : opt_follow_list1 follow_list opt_follow_list2 { $$ = new BracketListNode($1, $2, $3); }
    ;
opt_follow_list1
    : { $$ = new EmptyNode(); }
    | RANGE { $$ = new CharacterNode('-'); }
    | range_expression1 { $$ = $1; }
    ;
opt_follow_list2
    : { $$ = new EmptyNode(); }
    | RANGE { $$ = new CharacterNode('-'); }
    | range_expression2 { $$ = $1; }
    ;
range_expression1
    : RANGE RANGE range_char { $$ = new RangeNode(new CharacterNode('-'), $3); }
    ;
range_expression2
    : range_char RANGE RANGE { $$ = new RangeNode($1, new CharacterNode('-')); }
    ;
follow_list
    : expression_term { $$ = new FollowListNode($1); }
    | follow_list expression_term { $$ = $1->add($2); }
    ;
expression_term
    : single_expression { $$ = $1; }
    | range_expression { $$ = $1; }
    ;
single_expression
    : range_char { $$ = $1; }
    | character_class { $$ = $1; }
    ;
range_expression
    : range_char RANGE range_char { $$ = new RangeNode($1, $3); }
    ;
range_char
    : CHAR { $$ = new CharacterNode($<num>1); }
    | XNUMBER { $$ = new HexCharNode($<num>1); }
    | ONUMBER { $$ = new OctCharNode($<num>1); }
    | SPECIAL_CHAR { $$ = new SpecialCharNode($<num>1); }
    ;
character_class
    : LBRACKET_COLLON CHAR_CLASS RBRACKET_COLLON { $$ = new Node("Character Class"); }
    | CHAR_CLASS_PRED { $$ = new Node("Character Class"); }
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
    if (yylloc.first_line != yylloc.last_line) {
        fprintf(stderr, "[%d.%d-%d.%d]: %s\n",
            yylloc.first_line, yylloc.first_column,
            yylloc.last_line, yylloc.last_column,
            s);
    }
    else {
        fprintf(stderr, "[%d.%d-%d]: %s\n",
            yylloc.first_line, yylloc.first_column,
            yylloc.last_column,
            s);
    }
}

