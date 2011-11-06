#ifndef COMPILER_PARSER_STYPE_HEADER
#define COMPILER_PARSER_STYPE_HEADER

#include <string>
#include <memory>
#include "boost/variant.hpp"
#include "ast/statements.hpp"

namespace compiler { namespace parser {

typedef ast::expr_ptr expr_ptr;
typedef ast::arg_list_ptr arg_list_ptr;
typedef ast::stmt_ptr stmt_ptr;
typedef ast::stmt_list_ptr stmt_list_ptr;
typedef ast::var_decl_list_ptr var_decl_list_ptr;
typedef ast::var_decl_ptr var_decl_ptr;
typedef ast::param_list_ptr param_list_ptr;
typedef ast::param_ptr param_ptr;
typedef ast::src_elem_list_ptr src_elem_list_ptr;
typedef ast::src_elem_ptr src_elem_ptr;

struct stype
{
    boost::variant<
        std::string,
        expr_ptr,
        arg_list_ptr,
        stmt_ptr,
        stmt_list_ptr,
        var_decl_list_ptr,
        var_decl_ptr,
        param_list_ptr,
        param_ptr,
        src_elem_list_ptr,
        src_elem_ptr> var;
};

}}

#endif