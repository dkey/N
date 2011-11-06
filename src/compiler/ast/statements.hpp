#ifndef COMPILER_AST_STATEMENTS_HEADER
#define COMPILER_AST_STATEMENTS_HEADER

#include "expressions.hpp"

namespace compiler { namespace ast {

class statement : public node
{
};

typedef std::shared_ptr<statement> stmt_ptr;

class source_element : public statement
{
public:
    stmt_ptr element;
    explicit source_element(stmt_ptr element) :
        element(std::move(element))
    {}
};

typedef std::shared_ptr<source_element> src_elem_ptr;

class source_element_list : public node
{
public:
    std::list<src_elem_ptr> childs;
};

typedef std::shared_ptr<source_element_list> src_elem_list_ptr;

class statement_list : public node
{
public:
    std::list<stmt_ptr> statements;
};

typedef std::shared_ptr<statement_list> stmt_list_ptr;

class block : public statement
{
public:
    stmt_list_ptr childs;
    block() {}
    explicit block(stmt_list_ptr childs) :
        childs(std::move(childs))
    {}
};

class expression_statement : public statement
{
public:
    expr_ptr expr;
    explicit expression_statement(expr_ptr expr) :
        expr(std::move(expr))
    {}
};

class while_statement : public statement
{
public:
    expr_ptr condition;
    stmt_ptr body;
    while_statement(expr_ptr condition, stmt_ptr body) :
        condition(std::move(condition)), body(std::move(body))
    {}
};

class return_statement : public statement
{
public:
    expr_ptr expr;
    explicit return_statement(expr_ptr expr) :
        expr(std::move(expr))
    {}
};

class variable_declaration : public node
{
public:
    std::string name;
    expr_ptr initializer;
    explicit variable_declaration(const std::string& name, expr_ptr init = expr_ptr()) :
        name(name), initializer(std::move(init))
    {}
};

typedef std::shared_ptr<variable_declaration> var_decl_ptr;

class variable_declaration_list : public node
{
public:
    std::list<var_decl_ptr> vars;
};

typedef std::shared_ptr<variable_declaration_list> var_decl_list_ptr;

class variable_statement : public statement
{
public:
    std::string type;
    var_decl_list_ptr childs;
    variable_statement(const std::string& type, var_decl_list_ptr childs) :
        type(type), childs(std::move(childs))
    {}
};

class parameter : public node
{
public:
    std::string type, name;
    parameter(const std::string& type, const std::string& name) : type(type), name(name) {}
};

typedef std::shared_ptr<parameter> param_ptr;

class parameter_list : public node
{
public:
    std::list<param_ptr> params;
};

typedef std::shared_ptr<parameter_list> param_list_ptr;

class function_declaration : public statement
{
public:
    std::string name, type;
    param_list_ptr params;
    function_declaration(const std::string& name, const std::string& type, param_list_ptr params) :
        name(name), type(type), params(std::move(params))
    {}
};

typedef std::shared_ptr<function_declaration> func_decl_ptr;

class function_definition : public statement
{
public:
    func_decl_ptr declaration;
    stmt_ptr body;
    function_definition(func_decl_ptr declaration, stmt_ptr body) :
        declaration(std::move(declaration)), body(std::move(body))
    {}
};

class program : public node
{
public:
    src_elem_list_ptr elements;
    explicit program(src_elem_list_ptr elements) :
        elements(std::move(elements))
    {}
};

}}

#endif