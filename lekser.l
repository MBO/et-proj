%{
#include "parser.h"

%}

%option noyywrap

_DIGIT [0-9]
_ODIGIT [0-7]
_XDIGIT [0-9a-fA-F]

%x CLASS1ST
%x CLASS

%%

\| return OR;
\( return LPARENT;
\) return RPARENT;
"\[\^" BEGIN(CLASS); return LBRACKET_NEG;
"\["   BEGIN(CLASS); return LBRACKET;
<CLASS>"\]" BEGIN(INITIAL); return RBRACKET;
<CLASS>- return CLASS_RANGE;
<CLASS>. return CHAR;

\n return *yytext;

\\0([0-3]?{_ODIGIT}{2}|{_ODIGIT}{1,2}) return ONUMBER;
\\x{_XDIGIT}{4} return XNUMBER;

\\d|\\D|\\s|\\S|\\w|\\W return CHAR_CLASS_PRED;
\\a|\\f|\\n|\\r|\\t|\\v return SPECIAL_CHAR;

\\[1-9] return BACKREF;

\^ return BOL;
\$ return EOL;
\. return DOT;

\*|\+|\? return MULTI;
\{\s*{_DIGIT}+\s*\} return MULTI;
\{\s*{_DIGIT}+\s*,\s*{_DIGIT}+\s*\} return MULTI;
\{\s*{_DIGIT}+\s*,\s*\} return MULTI;
\{\s*,\s*{_DIGIT}+\s*\} return MULTI;

\\\. /* yytext[1]; */ return CHAR;
. /* yytext[0]; */ return CHAR;

%%
