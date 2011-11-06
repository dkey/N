#ifndef COMPILER_PARSER_STYPE_HEADER
#define COMPILER_PARSER_STYPE_HEADER

#include <string>
#include "boost/variant.hpp"
#include "ast/statements.hpp"

namespace compiler { namespace parser {

struct stype
{
    boost::variant<
        std::string,
        ast::expression*,
        ast::argument_list*,
        ast::statement*,
        ast::statement_list*,
        ast::variable_declaration_list*,
        ast::variable_declaration*,
        ast::parameter_list*,
        ast::parameter*,
        ast::source_element_list*,
        ast::source_element*> var;
};

}}

#endif