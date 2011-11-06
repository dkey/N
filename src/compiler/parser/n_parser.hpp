#ifndef COMPILER_PARSER_N_PARSER_HEADER
#define COMPILER_PARSER_N_PARSER_HEADER

#include <memory>
#include <iosfwd>

#include "ast/statements.hpp"

namespace compiler {

namespace parser {

class n_parser
{
public:
    n_parser(std::istream& input);
    ast::program* tree() const;

private:
    std::unique_ptr<ast::program> program_;

    n_parser(const n_parser&);
    n_parser& operator= (const n_parser&);    
};

}}

#endif