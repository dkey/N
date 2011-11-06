#ifndef COMPILER_AST_STATEMENTS_HEADER
#define COMPILER_AST_STATEMENTS_HEADER

#include "expressions.hpp"

namespace compiler { namespace ast {

class statement : public node
{
};

class source_element : public statement
{
public:
    std::unique_ptr<statement> element;
    explicit source_element(statement* element) : element(element) {}
};

class source_element_list : public node
{
public:
    std::list<source_element*> childs;
    virtual ~source_element_list()
    {
        for(auto i = childs.begin(), e = childs.end(); i != e; ++i)
            delete *i;
    }
};

class statement_list : public node
{
public:
    std::list<statement*> statements;
    virtual ~statement_list()
    {
        for(auto i = statements.begin(), e = statements.begin(); i != e; ++i)
            delete *i;
    }
};

class block : public statement
{
public:
    std::unique_ptr<statement_list> childs;
    block() {}
    explicit block(statement_list* childs) : childs(childs) {}
};

class expression_statement : public statement
{
public:
    std::unique_ptr<expression> expr;
    explicit expression_statement(expression* expr) : expr(expr) {}
};

class while_statement : public statement
{
public:
    std::unique_ptr<expression> condition;
    std::unique_ptr<statement> body;
    while_statement(expression* condition, statement* body) :
        condition(condition), body(body)
    {}
};

class return_statement : public statement
{
public:
    std::unique_ptr<expression> expr;
    explicit return_statement(expression* expr) : expr(expr) {}
};

class variable_declaration : public node
{
public:
    std::string name;
    std::unique_ptr<expression> initializer;
    explicit variable_declaration(const std::string& name, expression* init = 0) :
        name(name), initializer(init)
    {}
};

class variable_declaration_list : public node
{
public:
    std::list<variable_declaration*> vars;
    virtual ~variable_declaration_list()
    {
        for(auto i = vars.begin(), e = vars.end(); i != e; ++i)
            delete *i;
    }
};

class variable_statement : public statement
{
public:
    std::string type;
    std::unique_ptr<variable_declaration_list> childs;
    variable_statement(const std::string& type, variable_declaration_list* childs) :
        type(type), childs(childs)
    {}
};

class parameter : public node
{
public:
    std::string type, name;
    parameter(const std::string& type, const std::string& name) : type(type), name(name) {}
};

class parameter_list : public node
{
public:
    std::list<parameter*> params;
    ~parameter_list()
    {
        for(auto i = params.begin(), e = params.end(); i != e; ++i)
            delete *i;
    }
};

class function_declaration : public statement
{
public:
    std::string name, type;
    std::unique_ptr<parameter_list> params;
    function_declaration(const std::string& name, const std::string& type, parameter_list* params) :
        name(name), type(type), params(params)
    {}
};

class function_definition : public statement
{
public:
    std::unique_ptr<function_declaration> declaration;
    std::unique_ptr<statement> body;
    function_definition(function_declaration* declaration, statement* body) :
        declaration(declaration), body(body)
    {}
};

class program : public node
{
public:
    std::unique_ptr<source_element_list> elements;
    explicit program(source_element_list* elements) : elements(elements) {}
};

}}

#endif