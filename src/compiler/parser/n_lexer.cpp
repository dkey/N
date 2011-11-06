#include "n_lexer.hpp"
#include "location.hh"
#include "stype.hpp"

n_lexer::n_lexer(std::istream* input, std::ostream* output) :
    yyFlexLexer(input, output)
{
}

int n_lexer::yylex(compiler::parser::location* lloc, compiler::parser::stype* lval)
{
    yylval = lval;
    yylloc = lloc;
    return yylex();
}