%{
#include "parser.h"

%}

%option noyywrap

_DIGIT [0-9]
_ODIGIT [0-7]
_XDIGIT [0-9a-fA-F]
_WORD [a-zA-Z]

%x BE1ST
%x BE
%x CLASS

%%

\|                                     return OR;
\(                                     return LPARENT;
\)                                     return RPARENT;
"\[^"/"\]"                             BEGIN(BE1ST); return LBRACKET_NEG;
"\[\^"                                 BEGIN(BE);    return LBRACKET_NEG;
"\["/"\]"                              BEGIN(BE1ST); return LBRACKET;
"\["                                   BEGIN(BE);    return LBRACKET;
<BE1ST>"\]"                            BEGIN(BE);    return CHAR;
<BE>"\]"                               BEGIN(INITIAL); return RBRACKET;
<BE>-                                  return RANGE;

<BE>"\[:"                              BEGIN(CLASS); return LBRACKET_COLLON;
<CLASS>":\]"                           BEGIN(BE); return RBRACKET_COLLON;
<CLASS>{_WORD}+                        return CHAR_CLASS;

<INITIAL,BE>\n                         return *yytext;

\\0([0-3]?{_ODIGIT}{2}|{_ODIGIT}{1,2}) return ONUMBER;
\\x{_XDIGIT}{4}                        return XNUMBER;

<INITIAL,BE>\\d|\\D|\\s|\\S|\\w|\\W    return CHAR_CLASS_PRED;
<INITIAL,BE>\\a|\\f|\\n|\\r|\\t|\\v    return SPECIAL_CHAR;

\\[1-9]                                return BACKREF;

\^                                     return BOL;
\$                                     return EOL;
\.                                     return DOT;

\*|\+|\?                               return MULTI;
\{\s*{_DIGIT}+\s*\}                    return MULTI;
\{\s*{_DIGIT}+\s*,\s*{_DIGIT}+\s*\}    return MULTI;
\{\s*{_DIGIT}+\s*,\s*\}                return MULTI;
\{\s*,\s*{_DIGIT}+\s*\}                return MULTI;

<INITIAL,BE>\\\.                       return CHAR;
<INITIAL,BE>.                          return CHAR;

%%
