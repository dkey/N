#ifndef COMPILER_AST_EXPRESSIONS_HEADER
#define COMPILER_AST_EXPRESSIONS_HEADER

#include <memory>
#include <list>
#include "node.hpp"

namespace compiler { namespace ast {

class expression : public node
{
};

typedef std::shared_ptr<expression> expr_ptr;

class identifier : public expression
{
public:
    std::string text;
    explicit identifier(const std::string& text) :
        text(text)
    {}
};

class integer_literal : public expression
{
public:
    std::string text;
    explicit integer_literal(const std::string& text) :
       text(text)
    {}
};

class double_literal : public expression
{
public:
    std::string text;
    explicit double_literal(const std::string& text) :
        text(text)
    {}
};

class boolean_literal : public expression
{
public:
    bool value;
    explicit boolean_literal(bool value) :
        value(value)
    {}
};

class argument_list : public node
{
public:
    std::list<expr_ptr> args;
};

typedef std::shared_ptr<argument_list> arg_list_ptr;

class call_expression : public expression
{
public:
    expr_ptr function;
    arg_list_ptr args;
    call_expression(expr_ptr func, arg_list_ptr args) :
        function(std::move(func)), args(std::move(args))
    {}
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
    expr_ptr operand;
    operator_type oper;
    unary_expression(expr_ptr operand, operator_type oper) :
        operand(std::move(operand)), oper(oper)
    {}
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
    expr_ptr left, right;
    operator_type oper;
    binary_expression(expr_ptr left, expr_ptr right, operator_type oper) :
        left(std::move(left)), right(std::move(right)), oper(oper)
    {}
};

class conditional_expression : public expression
{
public:
    expr_ptr condition, true_expression, false_expression;
    conditional_expression(expr_ptr condition, expr_ptr true_expr, expr_ptr false_expr) :
        condition(std::move(condition)),
        true_expression(std::move(true_expr)),
        false_expression(std::move(false_expr))
    {}
};

}}

#endif