#ifndef COMPILER_PARSER_LEXER_HEADER
#define COMPILER_PARSER_LEXER_HEADER

#undef yyFlexLexer
#include "FlexLexer.h"

namespace compiler
{
    namespace parser
    {
        class stype;
        class location;
    }
}

//namespace compiler { namespace parser {

class n_lexer : public yyFlexLexer
{
public:
    n_lexer(std::istream* input = 0, std::ostream* output = 0);
    virtual int yylex();
    int yylex(compiler::parser::location* lloc, compiler::parser::stype* lval);

private:
    compiler::parser::stype* yylval;
    compiler::parser::location* yylloc;
};

//}}

#endif