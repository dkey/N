#ifndef COMPILER_AST_EXPRESSIONS_HEADER
#define COMPILER_AST_EXPRESSIONS_HEADER

#include <memory>
#include <list>
#include "node.hpp"

namespace compiler { namespace ast {

class expression : public node
{
};

class identifier : public expression
{
public:
    std::string text;
    explicit identifier(const std::string& text) : text(text) {}
};

class integer_literal : public expression
{
public:
    std::string text;
    explicit integer_literal(const std::string& text) : text(text) {}
};

class double_literal : public expression
{
public:
    std::string text;
    explicit double_literal(const std::string& text) : text(text) {}
};

class boolean_literal : public expression
{
public:
    bool value;
    explicit boolean_literal(bool value) : value(value) {}
};

class argument_list : public node
{
public:
    std::list<expression*> args;
    virtual ~argument_list()
    {
        for(auto i = args.begin(), e = args.end(); i != e; ++i)
            delete *i;
    }
};

class call_expression : public expression
{
public:
    std::unique_ptr<expression> function;
    std::unique_ptr<argument_list> args;
    call_expression(expression* func, argument_list* args) : function(func), args(args) {}
};



class unary_expression : public expression
{
public:
    enum operator_type
    {
        logical_not_oper
       ,plus_oper
       ,minus_oper
    };
    std::unique_ptr<expression> operand;
    operator_type oper;
    unary_expression(expression* operand, operator_type oper) : operand(operand), oper(oper) {}
};

class binary_expression : public expression
{
public:
    enum operator_type
    {
        multiplication_oper
       ,division_oper
       ,mod_oper
       ,int_division_oper
       ,plus_oper
       ,minus_oper
       ,greater_oper
       ,less_oper
       ,greater_equal_oper
       ,less_equal_oper
       ,equal_oper
       ,not_equal_oper
       ,logical_and_oper
       ,logical_xor_oper
       ,logical_or_oper
       ,assignment_oper
    };
    std::unique_ptr<expression> left, right;
    operator_type oper;
    binary_expression(expression* left, expression* right, operator_type oper) :
        left(left), right(right), oper(oper)
    {}
};

class conditional_expression : public expression
{
public:
    std::unique_ptr<expression> condition, true_expression, false_expression;
    conditional_expression(expression* condition, expression* true_expr, expression* false_expr) :
        condition(condition), true_expression(true_expr), false_expression(false_expr)
    {}
};

}}

#endif